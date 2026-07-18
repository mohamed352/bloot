import * as functions from 'firebase-functions';
import { db } from '../config/admin';
import { requireAppCheck } from '../utils/appCheck';
import { buildStreamPayload, StreamRoomPlayer } from '../utils/streaming';

export const startStream = functions.https.onCall(async (request) => {
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
  const streamRef = db.collection('streams').doc();

  return db.runTransaction(async (transaction) => {
    const roomDoc = await transaction.get(roomRef);
    if (!roomDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Room not found');
    }

    const room = roomDoc.data()!;

    // Only creator can start stream
    if (room.creatorUid !== authUid) {
      throw new functions.https.HttpsError('permission-denied', 'Only creator can start stream');
    }

    // Must not already be streaming
    if (room.isStreaming === true) {
      throw new functions.https.HttpsError('failed-precondition', 'Room is already streaming');
    }

    const roomPlayers = (room.players || []) as StreamRoomPlayer[];
    const now = new Date();

    // Create stream document
    transaction.set(
      streamRef,
      buildStreamPayload({ roomId, room, hostUid: authUid, roomPlayers, now }),
    );

    // Update room
    transaction.update(roomRef, {
      isStreaming: true,
      streamId: streamRef.id,
      updatedAt: now,
    });

    return { streamId: streamRef.id };
  });
});
