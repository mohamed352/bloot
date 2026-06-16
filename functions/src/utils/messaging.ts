import * as admin from 'firebase-admin';
import { db } from '../config/admin';

export interface FcmResult {
  success: boolean;
  error?: string;
}

/**
 * Sends an FCM message to a single user.
 * Respects user notification preferences and clears invalid tokens.
 */
export async function sendFcmToUser(
  uid: string,
  payload: Omit<admin.messaging.Message, 'token'>,
): Promise<FcmResult> {
  const userDoc = await db.collection('users').doc(uid).get();
  if (!userDoc.exists) {
    return { success: false, error: 'User not found' };
  }

  const userData = userDoc.data()!;
  const fcmToken = userData.fcmToken as string | undefined;
  if (!fcmToken) {
    return { success: false, error: 'No FCM token' };
  }

  const settings = userData.settings as Record<string, any> | undefined;
  if (settings?.notifications?.system === false) {
    return { success: false, error: 'User disabled system notifications' };
  }

  try {
    await admin.messaging().send({
      ...payload,
      token: fcmToken,
    });
    return { success: true };
  } catch (error: any) {
    const code = error?.errorInfo?.code || error?.code;
    if (
      code === 'messaging/invalid-registration-token' ||
      code === 'messaging/registration-token-not-registered'
    ) {
      await db.collection('users').doc(uid).update({ fcmToken: admin.firestore.FieldValue.delete() });
    }
    return { success: false, error: error?.message || String(error) };
  }
}

/**
 * Sends the same FCM payload to many users with a concurrency limit.
 */
export async function sendFcmToUsers(
  uids: string[],
  payload: Omit<admin.messaging.Message, 'token'>,
  concurrency = 10,
): Promise<Map<string, FcmResult>> {
  const results = new Map<string, FcmResult>();

  for (let i = 0; i < uids.length; i += concurrency) {
    const batch = uids.slice(i, i + concurrency);
    const batchResults = await Promise.all(
      batch.map(async (uid) => {
        const result = await sendFcmToUser(uid, payload);
        return [uid, result] as const;
      }),
    );
    batchResults.forEach(([uid, result]) => results.set(uid, result));
  }

  return results;
}
