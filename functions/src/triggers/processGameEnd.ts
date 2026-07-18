import { onDocumentUpdated } from 'firebase-functions/v2/firestore';
import * as admin from 'firebase-admin';
import { db } from '../config/admin';

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

    // Update room status. If the room was streaming, end the stream in the
    // same batch so finished games never linger in the live list.
    const roomRef = db.collection('rooms').doc(game.roomId);
    const roomDoc = await roomRef.get();
    const roomUpdate: Record<string, unknown> = {
      status: 'finished',
      updatedAt: now,
    };
    if (roomDoc.exists) {
      const room = roomDoc.data()!;
      const streamId = room.streamId as string | undefined;
      if (room.isStreaming === true && streamId != null && streamId.length > 0) {
        batch.update(db.collection('streams').doc(streamId), {
          status: 'ended',
          endedAt: now,
        });
        roomUpdate.isStreaming = false;
        roomUpdate.streamId = null;
      }
    }
    batch.update(roomRef, roomUpdate);

    await batch.commit();
  }
});
