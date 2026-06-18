import * as functions from 'firebase-functions';
import { db } from '../config/admin';
import { verifyPermission, logAdminAction } from './helpers';
import {
  EndStreamInput,
  MuteInStreamInput,
  RemoveFromStreamInput,
  SuccessResponse,
} from './types';

function assertAuth(request: functions.https.CallableRequest<unknown>): string {
  if (!request.auth?.uid) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }
  return request.auth.uid;
}

export const adminEndStream = functions.https.onCall(async (request) => {
  const actorUid = assertAuth(request);
  await verifyPermission(actorUid, 'moderate');

  const { streamId } = request.data as EndStreamInput;
  if (!streamId || typeof streamId !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing streamId');
  }

  const streamRef = db.collection('streams').doc(streamId);
  await db.runTransaction(async (transaction) => {
    const streamDoc = await transaction.get(streamRef);
    if (!streamDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Stream not found');
    }
    const stream = streamDoc.data()!;
    const roomRef = db.collection('rooms').doc(stream.roomId as string);

    transaction.update(streamRef, {
      status: 'ended',
      endedAt: new Date(),
      updatedAt: new Date(),
    });
    transaction.update(roomRef, {
      isStreaming: false,
      streamId: null,
      updatedAt: new Date(),
    });
  });

  await logAdminAction(actorUid, 'admin-endStream', 'stream', streamId, {});
  return { success: true } as SuccessResponse;
});

export const muteInStream = functions.https.onCall(async (request) => {
  const actorUid = assertAuth(request);
  await verifyPermission(actorUid, 'moderate');

  const { streamId, uid, muted } = request.data as MuteInStreamInput;
  if (!streamId || typeof streamId !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing streamId');
  }
  if (!uid || typeof uid !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing uid');
  }
  if (typeof muted !== 'boolean') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing or invalid muted');
  }

  const viewerRef = db.collection('streams').doc(streamId).collection('viewers').doc(uid);
  await db.runTransaction(async (transaction) => {
    const viewerDoc = await transaction.get(viewerRef);
    if (!viewerDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Viewer not found');
    }
    transaction.update(viewerRef, {
      muted,
      updatedAt: new Date(),
    });
  });

  await logAdminAction(actorUid, 'muteInStream', 'stream', streamId, { uid, muted });
  return { success: true } as SuccessResponse;
});

export const removeFromStream = functions.https.onCall(async (request) => {
  const actorUid = assertAuth(request);
  await verifyPermission(actorUid, 'moderate');

  const { streamId, uid } = request.data as RemoveFromStreamInput;
  if (!streamId || typeof streamId !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing streamId');
  }
  if (!uid || typeof uid !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing uid');
  }

  const viewerRef = db.collection('streams').doc(streamId).collection('viewers').doc(uid);
  await db.runTransaction(async (transaction) => {
    const viewerDoc = await transaction.get(viewerRef);
    if (!viewerDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Viewer not found');
    }
    transaction.delete(viewerRef);
  });

  await logAdminAction(actorUid, 'removeFromStream', 'stream', streamId, { uid });
  return { success: true } as SuccessResponse;
});

export const warnHost = functions.https.onCall(async (request) => {
  const actorUid = assertAuth(request);
  await verifyPermission(actorUid, 'moderate');

  const { streamId } = request.data as EndStreamInput;
  if (!streamId || typeof streamId !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing streamId');
  }

  const streamDoc = await db.collection('streams').doc(streamId).get();
  if (!streamDoc.exists) {
    throw new functions.https.HttpsError('not-found', 'Stream not found');
  }
  const hostUid = streamDoc.data()!.hostUid as string;

  // Write to the host's per-user notifications so it appears in the mobile app.
  const userNotificationRef = db
    .collection('users')
    .doc(hostUid)
    .collection('notifications')
    .doc();
  await userNotificationRef.set({
    uid: hostUid,
    type: 'system',
    title: 'Stream Warning',
    body: 'A moderator has warned you about your stream content. Please follow community guidelines.',
    read: false,
    createdAt: new Date(),
  });

  // Also keep a top-level admin-visible copy.
  const notificationRef = db.collection('notifications').doc();
  await notificationRef.set({
    uid: hostUid,
    type: 'system',
    title: 'Stream Warning',
    titleAr: 'تحذير البث',
    body: 'A moderator has warned you about your stream content. Please follow community guidelines.',
    bodyAr: 'قام أحد المشرفين بتحذيرك بشأن محتوى بثك. يرجى اتباع إرشادات المجتمع.',
    isRead: false,
    isPushed: false,
    pushStatus: 'pending',
    priority: 'high',
    createdAt: new Date(),
  });

  await logAdminAction(actorUid, 'warnHost', 'stream', streamId, { hostUid });
  return { success: true } as SuccessResponse;
});

export const suspendHost = functions.https.onCall(async (request) => {
  const actorUid = assertAuth(request);
  await verifyPermission(actorUid, 'moderate');

  const { streamId } = request.data as EndStreamInput;
  if (!streamId || typeof streamId !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing streamId');
  }

  const streamDoc = await db.collection('streams').doc(streamId).get();
  if (!streamDoc.exists) {
    throw new functions.https.HttpsError('not-found', 'Stream not found');
  }
  const hostUid = streamDoc.data()!.hostUid as string;

  const userRef = db.collection('users').doc(hostUid);
  const userDoc = await userRef.get();
  if (!userDoc.exists) {
    throw new functions.https.HttpsError('not-found', 'Host user not found');
  }

  await userRef.update({
    suspended: true,
    updatedAt: new Date(),
  });

  await logAdminAction(actorUid, 'suspendHost', 'stream', streamId, { hostUid });
  return { success: true } as SuccessResponse;
});
