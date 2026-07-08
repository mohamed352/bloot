import * as functions from 'firebase-functions';
import { Timestamp } from 'firebase-admin/firestore';
import { db } from '../config/admin';
import { requireAppCheck } from '../utils/appCheck';
import { createGameDocument, RoomPlayer } from '../engine/gameAdapter';

export const startGame = functions.https.onCall(async (request) => {
  console.log('[startGame] invoked', { uid: request.auth?.uid, roomId: request.data?.roomId });

  if (!request.auth) {
    console.error('[startGame] unauthenticated');
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  try {
    requireAppCheck(request);
    console.log('[startGame] App Check passed');
  } catch (e) {
    console.error('[startGame] App Check failed', e);
    throw e;
  }

  const authUid = request.auth.uid;
  const { roomId } = request.data;
  if (!roomId || typeof roomId !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing roomId');
  }

  const roomRef = db.collection('rooms').doc(roomId);
  const gameRef = db.collection('games').doc();

  try {
    return await db.runTransaction(async (transaction) => {
      const roomDoc = await transaction.get(roomRef);
      if (!roomDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Room not found');
      }

      const room = roomDoc.data()!;

      if (room.creatorUid !== authUid) {
        throw new functions.https.HttpsError('permission-denied', 'Only creator can start game');
      }

      const players = (room.players ?? []) as Array<{
        uid: string;
        displayName: string;
        avatarUrl?: string;
        team: 'A' | 'B';
        seatIndex: number;
        isReady: boolean;
        isMicOn?: boolean;
        isCameraOn?: boolean;
        agoraUid?: number;
        isBot?: boolean;
        level?: string;
      }>;

      if (players.length !== 4) {
        throw new functions.https.HttpsError('failed-precondition', 'Need 4 players');
      }

      const readyCount = players.filter((p) => p.isReady).length;
      if (readyCount !== 4) {
        throw new functions.https.HttpsError('failed-precondition', 'All players must be ready');
      }

      if (room.status !== 'waiting') {
        throw new functions.https.HttpsError(
          'failed-precondition',
          `Room cannot start a game (status: ${room.status}).`,
        );
      }

      if (room.gameId) {
        throw new functions.https.HttpsError(
          'failed-precondition',
          'A game is already in progress for this room.',
        );
      }

      const teamA = (room.teamA ?? []) as string[];
      const teamB = (room.teamB ?? []) as string[];
      if (teamA.length !== 2 || teamB.length !== 2) {
        throw new functions.https.HttpsError(
          'failed-precondition',
          'Teams must be balanced (2 players each).',
        );
      }

      const targetScore = room.targetScore || 152;
      const roomPlayers: RoomPlayer[] = players.map((p) => ({
        uid: p.uid,
        displayName: p.displayName,
        avatarUrl: p.avatarUrl,
        team: p.team,
        seatIndex: p.seatIndex,
        isBot: p.isBot,
        level: p.level,
        isMuted: p.isMicOn === false,
        hasCamera: p.isCameraOn === true,
        agoraUid: p.agoraUid,
        isConnected: true,
      }));

      const game = createGameDocument(
        gameRef.id,
        roomId,
        roomPlayers,
        targetScore,
        room.agoraChannelName ?? `room_${roomId}`,
      );
      game.turnTimerStart = Timestamp.now().toDate();

      transaction.set(gameRef, game);
      transaction.update(roomRef, {
        status: 'playing',
        gameId: gameRef.id,
        updatedAt: new Date(),
      });

      return { gameId: gameRef.id };
    });
  } catch (e) {
    console.error('[startGame] transaction failed', e);
    throw e;
  }
});
