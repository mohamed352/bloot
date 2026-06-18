import { onDocumentUpdated } from 'firebase-functions/v2/firestore';
import * as admin from 'firebase-admin';
import { db } from '../config/admin';
import { declareChampion } from '../engine/declareChampion';
import { createTournamentMatchRoom } from '../engine/createTournamentMatchRoom';

interface Match {
  matchId: string;
  playerAUid?: string | null;
  playerAName?: string;
  playerBUid?: string | null;
  playerBName?: string;
  winnerUid?: string | null;
  winnerTeamPlayerIds?: string[];
  playerAScore?: number;
  playerBScore?: number;
  status?: string;
  nextMatchId?: string | null;
  roundIndex?: number;
  roomId?: string | null;
  gameId?: string | null;
  teamAPlayerIds?: string[];
  teamBPlayerIds?: string[];
}

type TournamentTransactionResult =
  | null
  | { type: 'final'; tournamentId: string; championUid: string; championName: string }
  | {
      type: 'advance';
      tournamentId: string;
      matchId: string;
      teamAPlayerIds: string[];
      teamBPlayerIds: string[];
    }
  | { type: 'waiting' };

export const processGameEnd = onDocumentUpdated('games/{gameId}', async (event) => {
  const before = event.data?.before?.data();
  const after = event.data?.after?.data();

  if (!before || !after) return;

  if (before.status !== 'gameEnd' && after.status === 'gameEnd') {
    const game = after;
    const batch = db.batch();
    const now = new Date();

    const winner = game.teamAScore >= game.teamBScore ? 'A' : 'B';
    const gameType = game.gameType || 'sun';
    const duration = now.getTime() - (game.createdAt?.toMillis?.() || Date.now());

    for (const [, player] of Object.entries(game.players) as [string, Record<string, unknown>][]) {
      const userRef = db.collection('users').doc(player.uid as string);
      const isWin = player.team === winner;

      // Update user stats using atomic increments based on the user's current doc,
      // not the in-game snapshot.
      batch.update(userRef, {
        gamesPlayed: admin.firestore.FieldValue.increment(1),
        gamesWon: admin.firestore.FieldValue.increment(isWin ? 1 : 0),
        [`${gameType}GamesPlayed`]: admin.firestore.FieldValue.increment(1),
        [`${gameType}GamesWon`]: admin.firestore.FieldValue.increment(isWin ? 1 : 0),
        xp: admin.firestore.FieldValue.increment(isWin ? 50 : 20),
        updatedAt: now,
      });

      // Add game history entry
      const historyRef = db.collection('users').doc(player.uid as string).collection('gameHistory').doc();
      batch.set(historyRef, {
        gameId: event.params.gameId,
        result: isWin ? 'won' : 'lost',
        scoreTeamA: game.teamAScore,
        scoreTeamB: game.teamBScore,
        gameType,
        duration: Math.floor(duration / 1000),
        playedAt: now,
      });
    }

    // Update room status
    const roomRef = db.collection('rooms').doc(game.roomId);
    batch.update(roomRef, {
      status: 'finished',
      updatedAt: now,
    });

    await batch.commit();

    // ─── Tournament handling ───
    await handleTournamentGameEnd(game.roomId, winner, game.teamAScore, game.teamBScore);
  }
});

async function handleTournamentGameEnd(
  roomId: string,
  winningTeam: string,
  teamAScore: number,
  teamBScore: number,
): Promise<void> {
  if (!roomId) return;

  const roomDoc = await db.collection('rooms').doc(roomId).get();
  if (!roomDoc.exists) return;

  const roomData = roomDoc.data()!;
  const tournamentId = roomData.tournamentId as string | undefined;
  const matchId = roomData.matchId as string | undefined;

  if (!tournamentId || !matchId) return;

  const tournamentRef = db.collection('tournaments').doc(tournamentId);

  // Atomically update the tournament bracket to avoid lost updates when multiple
  // matches finish concurrently.
  const transactionResult = await db.runTransaction<TournamentTransactionResult>(async (transaction) => {
    const tournamentDoc = await transaction.get(tournamentRef);
    if (!tournamentDoc.exists) return null;

    const tournamentData = tournamentDoc.data()!;
    const matches: Match[] = (tournamentData.matches as Match[]) ?? [];

    const matchIndex = matches.findIndex((m) => m.matchId === matchId);
    if (matchIndex === -1) return null;

    const match = matches[matchIndex];
    const teamA = match.teamAPlayerIds ?? [];
    const teamB = match.teamBPlayerIds ?? [];

    // Determine winning team (full player ids).
    const winningTeamIds = winningTeam === 'A' ? teamA : teamB;
    const winnerUid = winningTeamIds[0] || null;
    const winnerName = winningTeam === 'A' ? match.playerAName : match.playerBName;

    if (!winnerUid || winningTeamIds.length !== 2) {
      console.error(`Tournament match ${matchId} has no valid winning team`);
      return null;
    }
    const finalWinnerName = winnerName || 'Winner';
    const safeWinnerUid = winnerUid;

    // Update match with result
    match.winnerUid = winnerUid;
    match.winnerTeamPlayerIds = winningTeamIds;
    match.playerAScore = teamAScore;
    match.playerBScore = teamBScore;
    match.status = 'finished';
    match.gameId = roomData.gameId ?? null;

    // Check if final
    if (!match.nextMatchId) {
      transaction.update(tournamentRef, { matches, updatedAt: new Date() });
      return { type: 'final' as const, tournamentId, championUid: safeWinnerUid, championName: finalWinnerName };
    }

    // Advance winning team to next match
    const nextMatchIndex = matches.findIndex((m) => m.matchId === match.nextMatchId);
    if (nextMatchIndex === -1) {
      console.error(`Next match ${match.nextMatchId} not found`);
      transaction.update(tournamentRef, { matches, updatedAt: new Date() });
      return null;
    }

    const nextMatch = matches[nextMatchIndex];

    // Slot winner into next match
    if (!nextMatch.teamAPlayerIds || nextMatch.teamAPlayerIds.length === 0) {
      nextMatch.teamAPlayerIds = winningTeamIds;
      nextMatch.playerAUid = winnerUid;
      nextMatch.playerAName = winnerName;
    } else if (!nextMatch.teamBPlayerIds || nextMatch.teamBPlayerIds.length === 0) {
      nextMatch.teamBPlayerIds = winningTeamIds;
      nextMatch.playerBUid = winnerUid;
      nextMatch.playerBName = winnerName;
    } else {
      console.error(`Next match ${nextMatch.matchId} already has both teams`);
      transaction.update(tournamentRef, { matches, updatedAt: new Date() });
      return null;
    }

    // Update current round if we just completed the last match of a round
    let currentRound = (tournamentData.currentRound as number) ?? 0;
    const roundMatches = matches.filter((m) => m.roundIndex === currentRound);
    const roundFinished = roundMatches.every((m) => m.status === 'finished');
    const nextMatchFull =
      (nextMatch.teamAPlayerIds?.length ?? 0) > 0 &&
      (nextMatch.teamBPlayerIds?.length ?? 0) > 0;
    if (roundFinished && nextMatchFull) {
      currentRound++;
    }

    transaction.update(tournamentRef, {
      matches,
      currentRound,
      updatedAt: new Date(),
    });

    if (nextMatchFull) {
      return {
        type: 'advance' as const,
        tournamentId,
        matchId: nextMatch.matchId,
        teamAPlayerIds: nextMatch.teamAPlayerIds!,
        teamBPlayerIds: nextMatch.teamBPlayerIds!,
      };
    }

    return { type: 'waiting' as const };
  });

  if (!transactionResult) return;

  if (transactionResult.type === 'final') {
    await declareChampion({
      tournamentId: transactionResult.tournamentId,
      championUid: transactionResult.championUid,
      championName: transactionResult.championName,
    });
    return;
  }

  if (transactionResult.type === 'advance') {
    // Create the room outside the transaction. If a concurrent process already
    // created the room, the idempotent check below will skip the write.
    await db.runTransaction(async (transaction) => {
      const tournamentDoc = await transaction.get(tournamentRef);
      if (!tournamentDoc.exists) return;

      const matches: Match[] = (tournamentDoc.data()!.matches as Match[]) ?? [];
      const nextMatch = matches.find((m) => m.matchId === transactionResult.matchId);
      if (!nextMatch || nextMatch.roomId) return;

      const newRoomId = await createTournamentMatchRoom({
        tournamentId: transactionResult.tournamentId,
        matchId: transactionResult.matchId,
        teamAPlayerIds: transactionResult.teamAPlayerIds,
        teamBPlayerIds: transactionResult.teamBPlayerIds,
      });

      nextMatch.roomId = newRoomId;
      nextMatch.status = 'live';
      transaction.update(tournamentRef, { matches, updatedAt: new Date() });
    });
  }
}
