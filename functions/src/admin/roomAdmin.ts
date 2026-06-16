import * as functions from 'firebase-functions';
import { db } from '../config/admin';
import { verifyPermission, logAdminAction } from './helpers';
import {
  ForceCloseRoomInput,
  TransferRoomOwnershipInput,
  SuccessResponse,
} from './types';

function assertAuth(request: functions.https.CallableRequest<unknown>): string {
  if (!request.auth?.uid) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }
  return request.auth.uid;
}

export const forceCloseRoom = functions.https.onCall(async (request) => {
  const actorUid = assertAuth(request);
  await verifyPermission(actorUid, 'moderate');

  const { roomId } = request.data as ForceCloseRoomInput;
  if (!roomId || typeof roomId !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing roomId');
  }

  const roomRef = db.collection('rooms').doc(roomId);
  await db.runTransaction(async (transaction) => {
    const roomDoc = await transaction.get(roomRef);
    if (!roomDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Room not found');
    }
    transaction.update(roomRef, {
      status: 'closed',
      isStreaming: false,
      updatedAt: new Date(),
    });
  });

  await logAdminAction(actorUid, 'forceCloseRoom', 'room', roomId, {});
  return { success: true } as SuccessResponse;
});

export const transferRoomOwnership = functions.https.onCall(async (request) => {
  const actorUid = assertAuth(request);
  await verifyPermission(actorUid, 'manage');

  const { roomId, newOwnerUid } = request.data as TransferRoomOwnershipInput;
  if (!roomId || typeof roomId !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing roomId');
  }
  if (!newOwnerUid || typeof newOwnerUid !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing newOwnerUid');
  }

  const roomRef = db.collection('rooms').doc(roomId);
  const newOwnerRef = db.collection('users').doc(newOwnerUid);
  await db.runTransaction(async (transaction) => {
    const [roomDoc, newOwnerDoc] = await Promise.all([
      transaction.get(roomRef),
      transaction.get(newOwnerRef),
    ]);
    if (!roomDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Room not found');
    }
    if (!newOwnerDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'New owner not found');
    }
    transaction.update(roomRef, {
      creatorUid: newOwnerUid,
      updatedAt: new Date(),
    });
  });

  await logAdminAction(actorUid, 'transferRoomOwnership', 'room', roomId, { newOwnerUid });
  return { success: true } as SuccessResponse;
});
