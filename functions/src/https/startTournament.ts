import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { db } from '../config/admin';
import { requireAppCheck } from '../utils/appCheck';
import { createTournamentMatchRoom } from '../engine/createTournamentMatchRoom';

/**
 * Starts a tournament: groups participants into fixed 2-player teams,
 * generates a single-elimination bracket, auto-advances byes, and creates
 * match rooms for round 1 games that have two real teams.
 * Only the creator or an admin can start.
 */
export const startTournament = functions.https.onCall(
  { cors: true },
  async (request) => {
    if (!request.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'Must be authenticated to start a tournament.',
      );
    }

    requireAppCheck(request);

    const { tournamentId } = request.data as { tournamentId?: string };
    if (!tournamentId || typeof tournamentId !== 'string') {
      throw new functions.https.HttpsError('invalid-argument', 'Missing tournamentId.');
    }

    const tournamentRef = db.collection('tournaments').doc(tournamentId);
    const tournamentDoc = await tournamentRef.get();

    if (!tournamentDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Tournament not found.');
    }

    const data = tournamentDoc.data()!;

    // Authorization: only creator or admin can start
    const hostUid = data.hostUid ?? data.creatorUid;
    if (hostUid !== request.auth.uid) {
      throw new functions.https.HttpsError(
        'permission-denied',
        'Only the tournament creator can start it.',
      );
    }

    if (data.status !== 'upcoming') {
      throw new functions.https.HttpsError(
        'failed-precondition',
        `Tournament cannot be started (status: ${data.status}).`,
      );
    }

    let participantIds: string[] = data.participantIds ?? [];
    if (participantIds.length < 2) {
      throw new functions.https.HttpsError(
        'failed-precondition',
        'Need at least 2 participants to start.',
      );
    }

    // 2v2 tournament: each team has 2 players. Drop odd participant if necessary.
    if (participantIds.length % 2 !== 0) {
      participantIds = participantIds.slice(0, participantIds.length - 1);
    }

    const maxParticipants: number = data.maxParticipants ?? 64;

    // Shuffle participants for random seeding
    participantIds = [...participantIds];
    for (let i = participantIds.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [participantIds[i], participantIds[j]] = [participantIds[j], participantIds[i]];
    }

    // Group into fixed teams of 2.
    const teams: string[][] = [];
    for (let i = 0; i < participantIds.length; i += 2) {
      teams.push([participantIds[i], participantIds[i + 1]]);
    }

    const teamCount = maxParticipants / 2;
    while (teams.length < teamCount) {
      teams.push(['', '']); // bye team
    }

    // Generate bracket and auto-advance byes.
    const { matches, firstRoundMatchIds } = generateBracket(teams);

    // Create rooms for round 0 matches that have two real teams.
    for (const match of matches) {
      if (match.roundIndex !== 0) continue;
      if (match.teamAPlayerIds.every(Boolean) && match.teamBPlayerIds.every(Boolean)) {
        try {
          const roomId = await createTournamentMatchRoom({
            tournamentId,
            matchId: match.matchId,
            teamAPlayerIds: match.teamAPlayerIds,
            teamBPlayerIds: match.teamBPlayerIds,
          });
          match.roomId = roomId;
          match.status = 'live';

          await _sendMatchReadyNotifications({
            tournamentName: data.name,
            tournamentId,
            matchId: match.matchId,
            roomId,
            playerUids: [...match.teamAPlayerIds, ...match.teamBPlayerIds],
          });
        } catch (e) {
          functions.logger.error(`Failed to create room for match ${match.matchId}`, e);
        }
      }
    }

    const now = new Date();
    await tournamentRef.update({
      status: 'live',
      currentRound: 0,
      startedAt: now,
      matches,
      brackets: matches,
      participantIds,
      participants: `${participantIds.length}/${maxParticipants}`,
      currentParticipants: participantIds.length,
      updatedAt: now,
    });

    return { success: true, matchCount: matches.length, firstRoundMatchIds };
  },
);

interface MatchSlot {
  matchId: string;
  playerAUid: string | null;
  playerBUid: string | null;
  playerAName: string;
  playerBName: string;
  winnerUid: string | null;
  roomId: string | null;
  gameId: string | null;
  nextMatchId: string | null;
  roundIndex: number;
  matchIndex: number;
  status: string;
  isUserMatch: boolean;
  playerAAvatarUrl: string | null;
  playerBAvatarUrl: string | null;
  teamAPlayerIds: string[];
  teamBPlayerIds: string[];
}

function isRealTeam(team: string[]): boolean {
  return team.length === 2 && team.every((uid) => uid !== '' && uid != null);
}

function generateBracket(teams: string[][]): { matches: MatchSlot[]; firstRoundMatchIds: string[] } {
  const matches: MatchSlot[] = [];
  let currentRoundSize = teams.length / 2;
  let matchIndex = 0;

  // Calculate total rounds
  let totalRounds = 0;
  let temp = teams.length;
  while (temp > 1) {
    temp /= 2;
    totalRounds++;
  }

  // First pass: generate skeleton for all rounds.
  for (let round = 0; round < totalRounds; round++) {
    for (let i = 0; i < currentRoundSize; i++) {
      const matchId = `match_${round}_${i}`;
      const nextMatchId =
        round < totalRounds - 1 ? `match_${round + 1}_${Math.floor(i / 2)}` : null;

      matches.push({
        matchId,
        playerAUid: null,
        playerBUid: null,
        playerAName: 'TBD',
        playerBName: 'TBD',
        winnerUid: null,
        roomId: null,
        gameId: null,
        nextMatchId,
        roundIndex: round,
        matchIndex: i,
        status: 'upcoming',
        isUserMatch: false,
        playerAAvatarUrl: null,
        playerBAvatarUrl: null,
        teamAPlayerIds: [],
        teamBPlayerIds: [],
      });

      matchIndex++;
    }
    currentRoundSize /= 2;
  }

  // Second pass: assign teams to round 0 and auto-advance byes.
  const matchMap = new Map(matches.map((m) => [m.matchId, m]));
  const firstRoundMatchIds: string[] = [];

  for (let i = 0; i < teams.length / 2; i++) {
    const matchId = `match_0_${i}`;
    firstRoundMatchIds.push(matchId);
    const match = matchMap.get(matchId)!;
    const teamA = teams[i * 2];
    const teamB = teams[i * 2 + 1];

    match.teamAPlayerIds = teamA;
    match.teamBPlayerIds = teamB;
    match.playerAUid = teamA[0] || null;
    match.playerBUid = teamB[0] || null;

    const teamAReal = isRealTeam(teamA);
    const teamBReal = isRealTeam(teamB);

    if (teamAReal && teamBReal) {
      match.status = 'live';
    } else if (teamAReal && !teamBReal) {
      // Team A gets a bye.
      match.winnerUid = teamA[0];
      match.status = 'completed';
      advanceTeamToNextMatch(matchMap, match, teamA);
    } else if (teamBReal && !teamAReal) {
      // Team B gets a bye.
      match.winnerUid = teamB[0];
      match.status = 'completed';
      advanceTeamToNextMatch(matchMap, match, teamB);
    } else {
      // Both teams are byes: leave as upcoming with no winner.
      match.status = 'upcoming';
    }
  }

  // Resolve any chain of byes (a bye may feed into another bye).
  for (let round = 1; round < totalRounds; round++) {
    for (let i = 0; i < teams.length / Math.pow(2, round + 1); i++) {
      const matchId = `match_${round}_${i}`;
      const match = matchMap.get(matchId)!;
      if (match.status === 'upcoming' && match.teamAPlayerIds.length && match.teamBPlayerIds.length) {
        const teamAReal = isRealTeam(match.teamAPlayerIds);
        const teamBReal = isRealTeam(match.teamBPlayerIds);
        if (teamAReal && teamBReal) {
          match.status = 'live';
        } else if (teamAReal && !teamBReal) {
          match.winnerUid = match.teamAPlayerIds[0];
          match.status = 'completed';
          advanceTeamToNextMatch(matchMap, match, match.teamAPlayerIds);
        } else if (teamBReal && !teamAReal) {
          match.winnerUid = match.teamBPlayerIds[0];
          match.status = 'completed';
          advanceTeamToNextMatch(matchMap, match, match.teamBPlayerIds);
        }
      }
    }
  }

  return { matches, firstRoundMatchIds };
}

function advanceTeamToNextMatch(
  matchMap: Map<string, MatchSlot>,
  currentMatch: MatchSlot,
  team: string[],
): void {
  if (!currentMatch.nextMatchId) return;
  const nextMatch = matchMap.get(currentMatch.nextMatchId);
  if (!nextMatch) return;

  // Assign to team A or B based on whether current match index is even/odd.
  const isLeftSlot = currentMatch.matchIndex % 2 === 0;
  if (isLeftSlot) {
    nextMatch.teamAPlayerIds = team;
    nextMatch.playerAUid = team[0] || null;
  } else {
    nextMatch.teamBPlayerIds = team;
    nextMatch.playerBUid = team[0] || null;
  }
}

async function _sendMatchReadyNotifications({
  tournamentName,
  tournamentId,
  matchId,
  roomId,
  playerUids,
}: {
  tournamentName: string;
  tournamentId: string;
  matchId: string;
  roomId: string;
  playerUids: string[];
}) {
  for (const playerUid of playerUids) {
    if (!playerUid) continue;

    const userDoc = await admin.firestore().collection('users').doc(playerUid).get();
    const userData = userDoc.data();
    if (!userData) continue;

    const settings = userData.settings as Record<string, any> | undefined;
    if (settings?.notifications?.tournaments === false) continue;

    const fcmToken = userData.fcmToken as string | undefined;
    if (!fcmToken) {
      functions.logger.info(`No FCM token for user ${playerUid}`);
      continue;
    }

    const payload: admin.messaging.Message = {
      token: fcmToken,
      notification: {
        title: 'Tournament Match Ready!',
        body: `Your match in ${tournamentName} is starting now.`,
      },
      data: {
        type: 'tournamentMatchReady',
        tournamentId,
        matchId,
        roomId,
      },
      android: {
        notification: {
          channelId: 'tournament_matches',
          priority: 'high',
        },
      },
      apns: {
        payload: {
          aps: {
            alert: {
              title: 'Tournament Match Ready!',
              body: `Your match in ${tournamentName} is starting now.`,
            },
            badge: 1,
            sound: 'default',
          },
        },
      },
    };

    try {
      await admin.messaging().send(payload);
      functions.logger.info(`Sent tournament match ready notification to ${playerUid}`);
    } catch (error) {
      functions.logger.error(`Failed to send FCM to ${playerUid}`, error);
    }
  }
}
