import * as functions from 'firebase-functions';
import { db } from '../config/admin';
import { requireAppCheck } from '../utils/appCheck';

export const rematch = functions.https.onCall(async (request) => {
  if (!request.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  requireAppCheck(request);

  const authUid = request.auth.uid;
  const { roomId } = request.data;
  if (!roomId || typeof roomId !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing roomId');
  }

  const roomRef = db.collection('rooms').doc(roomId);

  return db.runTransaction(async (transaction) => {
    const roomDoc = await transaction.get(roomRef);
    if (!roomDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Room not found');
    }

    const room = roomDoc.data()!;

    const playerUids = (room.playerUids || []) as string[];
    if (!playerUids.includes(authUid)) {
      throw new functions.https.HttpsError('permission-denied', 'Not a player in this room');
    }

    if (room.status !== 'finished') {
      throw new functions.https.HttpsError(
        'failed-precondition',
        'Room is not in finished state',
      );
    }

    const players = (room.players || []) as Array<{
      uid: string;
      displayName: string;
      avatarUrl?: string;
      team: string;
      seatIndex: number;
      isReady?: boolean;
      isMicOn?: boolean;
      isCameraOn?: boolean;
      agoraUid?: number;
      joinedAt?: any;
    }>;

    // Reset all players to not-ready
    const resetPlayers = players.map((p) => ({
      ...p,
      isReady: false,
    }));

    transaction.update(roomRef, {
      status: 'waiting',
      gameId: null,
      readyPlayers: [],
      players: resetPlayers,
      updatedAt: new Date(),
    });

    return { success: true };
  });
});
