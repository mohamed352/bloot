import * as functions from 'firebase-functions';
import { db } from '../config/admin';
import { verifyPermission, logAdminAction } from './helpers';
import { sendFcmToUser, sendFcmToUsers } from '../utils/messaging';
import { SendNotificationInput, SendBroadcastInput, SuccessResponse } from './types';

function assertAuth(request: functions.https.CallableRequest<unknown>): string {
  if (!request.auth?.uid) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }
  return request.auth.uid;
}

function createNotificationPayload(
  uid: string,
  title: string,
  titleAr: string,
  body: string,
  bodyAr: string,
  priority: 'high' | 'normal' | 'low',
  imageUrl?: string,
  data?: Record<string, string>,
): Record<string, unknown> {
  const now = new Date();
  return {
    uid,
    type: 'system',
    title,
    titleAr,
    body,
    bodyAr,
    imageUrl: imageUrl || null,
    data: data ?? {},
    isRead: false,
    isPushed: false,
    pushStatus: 'pending',
    priority,
    createdAt: now,
  };
}

function buildFcmPayload(
  title: string,
  body: string,
  imageUrl?: string,
  data?: Record<string, string>,
): Omit<import('firebase-admin').messaging.Message, 'token'> {
  return {
    notification: {
      title,
      body,
      imageUrl,
    },
    data: data ?? {},
    android: {
      notification: {
        channelId: 'system_notifications',
        priority: 'high',
      },
    },
    apns: {
      payload: {
        aps: {
          alert: { title, body },
          badge: 1,
          sound: 'default',
        },
      },
    },
  };
}

export const sendNotification = functions.https.onCall(async (request) => {
  const actorUid = assertAuth(request);
  await verifyPermission(actorUid, 'manage');

  const { uid, title, titleAr, body, bodyAr, priority = 'normal', imageUrl, data } =
    request.data as SendNotificationInput;
  if (!uid || typeof uid !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing uid');
  }
  if (!title || typeof title !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing title');
  }
  if (!body || typeof body !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing body');
  }

  const userDoc = await db.collection('users').doc(uid).get();
  if (!userDoc.exists) {
    throw new functions.https.HttpsError('not-found', 'User not found');
  }

  const notificationRef = db.collection('notifications').doc();
  const notificationData = createNotificationPayload(
    uid,
    title,
    titleAr || title,
    body,
    bodyAr || body,
    priority,
    imageUrl,
    data,
  );
  await notificationRef.set(notificationData);

  const fcmResult = await sendFcmToUser(
    uid,
    buildFcmPayload(title, body, imageUrl, data),
  );
  await notificationRef.update({
    isPushed: fcmResult.success,
    pushStatus: fcmResult.success ? 'sent' : 'failed',
    pushedAt: new Date(),
    pushError: fcmResult.error || null,
  });

  await logAdminAction(actorUid, 'sendNotification', 'notification', notificationRef.id, {
    uid,
    title,
    body,
    priority,
    imageUrl,
    data,
    fcmSuccess: fcmResult.success,
  });

  return { success: true, notificationId: notificationRef.id } as SuccessResponse & {
    notificationId: string;
  };
});

const BROADCAST_BATCH_SIZE = 500;
const BROADCAST_FCM_CONCURRENCY = 10;
const BROADCAST_MAX_RECIPIENTS = 50000;

export const sendBroadcast = functions.https.onCall(async (request) => {
  const actorUid = assertAuth(request);
  await verifyPermission(actorUid, 'manage');

  const { title, titleAr, body, bodyAr, priority = 'normal', imageUrl, data } =
    request.data as SendBroadcastInput;
  if (!title || typeof title !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing title');
  }
  if (!body || typeof body !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing body');
  }

  // Count users first to guard against timeout/OOM on very large user bases.
  const countSnapshot = await db.collection('users').count().get();
  const totalUsers = countSnapshot.data().count;
  if (totalUsers > BROADCAST_MAX_RECIPIENTS) {
    throw new functions.https.HttpsError(
      'resource-exhausted',
      `Broadcast exceeds maximum of ${BROADCAST_MAX_RECIPIENTS} recipients (${totalUsers}). Use FCM topics instead.`,
    );
  }

  const fcmPayload = buildFcmPayload(title, body, imageUrl, data);
  let recipientCount = 0;
  let pushSuccessCount = 0;
  let pushFailedCount = 0;

  let lastDoc: FirebaseFirestore.QueryDocumentSnapshot | undefined;
  while (true) {
    let query = db.collection('users').orderBy('__name__').limit(BROADCAST_BATCH_SIZE);
    if (lastDoc) {
      query = query.startAfter(lastDoc);
    }
    const snapshot = await query.get();
    if (snapshot.empty) break;

    const batchUids = snapshot.docs.map((d) => d.id);
    recipientCount += batchUids.length;

    // Write notification docs in batches of 500.
    const notificationRefs: { uid: string; ref: FirebaseFirestore.DocumentReference }[] = [];
    let writeBatch = db.batch();
    let batchCount = 0;
    for (const uid of batchUids) {
      const ref = db.collection('notifications').doc();
      notificationRefs.push({ uid, ref });
      writeBatch.set(
        ref,
        createNotificationPayload(
          uid,
          title,
          titleAr || title,
          body,
          bodyAr || body,
          priority,
          imageUrl,
          data,
        ),
      );
      batchCount++;
      if (batchCount === 500) {
        await writeBatch.commit();
        writeBatch = db.batch();
        batchCount = 0;
      }
    }
    if (batchCount > 0) {
      await writeBatch.commit();
    }

    // Send FCM with a small concurrency limit.
    const fcmResults = await sendFcmToUsers(batchUids, fcmPayload, BROADCAST_FCM_CONCURRENCY);

    // Update notification docs with FCM status in batches.
    let updateBatch = db.batch();
    batchCount = 0;
    for (const { uid, ref } of notificationRefs) {
      const result = fcmResults.get(uid);
      if (result?.success) pushSuccessCount++;
      else pushFailedCount++;
      updateBatch.update(ref, {
        isPushed: result?.success ?? false,
        pushStatus: result?.success ? 'sent' : 'failed',
        pushedAt: new Date(),
        pushError: result?.error || null,
      });
      batchCount++;
      if (batchCount === 500) {
        await updateBatch.commit();
        updateBatch = db.batch();
        batchCount = 0;
      }
    }
    if (batchCount > 0) {
      await updateBatch.commit();
    }

    lastDoc = snapshot.docs[snapshot.docs.length - 1];
    if (snapshot.docs.length < BROADCAST_BATCH_SIZE) break;
  }

  await logAdminAction(actorUid, 'sendBroadcast', 'notification', 'all', {
    title,
    body,
    priority,
    imageUrl,
    data,
    recipientCount,
    pushSuccessCount,
    pushFailedCount,
  });
  return { success: true, recipientCount, pushSuccessCount, pushFailedCount } as SuccessResponse & {
    recipientCount: number;
    pushSuccessCount: number;
    pushFailedCount: number;
  };
});
