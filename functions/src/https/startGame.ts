import * as functions from 'firebase-functions';
import { Timestamp } from 'firebase-admin/firestore';
import { db } from '../config/admin';
import { requireAppCheck } from '../utils/appCheck';
import { createGameDocument, RoomPlayer } from '../engine/gameAdapter';
import { mirrorGameToRtdb } from '../utils/rtdbMirror';
import { normalizeParitySeats } from '../utils/roomPlayers';
import { buildStreamPayload, shouldAutoCreateStream } from '../utils/streaming';

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
    const txResult = await db.runTransaction(async (transaction) => {
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

      // Enforce engine seat/team parity ([A1,B1,A2,B2]) before dealing and
      // persist the normalized seats back to the room in the same transaction.
      const normalizedPlayers = normalizeParitySeats(players);

      const roomPlayers: RoomPlayer[] = normalizedPlayers.map((p) => ({
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
        room.voiceEnabled ?? false,
        room.cameraEnabled ?? false,
      );
      game.turnTimerStart = Timestamp.now().toDate();

      transaction.set(gameRef, game);

      const roomUpdate: Record<string, any> = {
        status: 'playing',
        gameId: gameRef.id,
        players: normalizedPlayers,
        updatedAt: new Date(),
      };

      // Live rooms become visible to watchers as soon as the game starts.
      // Never duplicate an existing stream.
      if (shouldAutoCreateStream(room)) {
        const streamRef = db.collection('streams').doc();
        transaction.set(
          streamRef,
          buildStreamPayload({
            roomId,
            room,
            hostUid: authUid,
            roomPlayers: normalizedPlayers,
          }),
        );
        roomUpdate.isStreaming = true;
        roomUpdate.streamId = streamRef.id;
      }

      transaction.update(roomRef, roomUpdate);

      return { gameId: gameRef.id, game };
    });

    // Mirror the initial state to RTDB so the WebView can read it with
    // low latency as soon as the game starts.
    if (txResult.game) {
      await mirrorGameToRtdb(txResult.game as any);
    }

    return { gameId: txResult.gameId };
  } catch (e) {
    console.error('[startGame] transaction failed', e);
    throw e;
  }
});
