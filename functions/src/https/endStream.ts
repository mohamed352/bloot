import * as functions from 'firebase-functions';
import { db } from '../config/admin';
import { requireAppCheck } from '../utils/appCheck';

export const endStream = functions.https.onCall(async (request) => {
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

    // Only creator can end stream
    if (room.creatorUid !== authUid) {
      throw new functions.https.HttpsError('permission-denied', 'Only creator can end stream');
    }

    // Must be streaming
    if (room.isStreaming !== true) {
      throw new functions.https.HttpsError('failed-precondition', 'Room is not streaming');
    }

    const streamId = room.streamId as string;
    const streamRef = db.collection('streams').doc(streamId);

    const now = new Date();

    // Update stream status
    transaction.update(streamRef, {
      status: 'ended',
      endedAt: now,
    });

    // Update room
    transaction.update(roomRef, {
      isStreaming: false,
      streamId: null,
      updatedAt: now,
    });

    return { success: true };
  });
});
