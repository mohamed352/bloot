import * as admin from 'firebase-admin';
import { db } from '../config/admin';

export interface FcmResult {
  success: boolean;
  error?: string;
}

/**
 * Collects every FCM token registered for a user: the legacy single
 * `fcmToken` field plus the `users/{uid}/fcmTokens` subcollection written by
 * newer clients (multi-device support, e.g. same account on Android + iOS).
 */
export async function getUserFcmTokens(
  uid: string,
  userData?: admin.firestore.DocumentData,
): Promise<string[]> {
  const data =
    userData ?? (await db.collection('users').doc(uid).get()).data();
  const tokens = new Set<string>();

  const legacy = data?.fcmToken as string | undefined;
  if (legacy) tokens.add(legacy);

  const snap = await db
    .collection('users')
    .doc(uid)
    .collection('fcmTokens')
    .get();
  for (const doc of snap.docs) {
    const token = (doc.data().token as string | undefined) ?? doc.id;
    if (token) tokens.add(token);
  }

  return [...tokens];
}

function isDeadTokenError(error: any): boolean {
  const code = error?.errorInfo?.code || error?.code;
  return (
    code === 'messaging/invalid-registration-token' ||
    code === 'messaging/registration-token-not-registered'
  );
}

async function pruneToken(uid: string, token: string): Promise<void> {
  const userDoc = db.collection('users').doc(uid);
  await Promise.all([
    userDoc.collection('fcmTokens').doc(token).delete().catch(() => {}),
    // Clear the legacy field only if it still points at this dead token.
    userDoc.get().then((snap) => {
      if (snap.data()?.fcmToken === token) {
        return userDoc.update({
          fcmToken: admin.firestore.FieldValue.delete(),
        });
      }
      return undefined;
    }),
  ]);
}

/**
 * Sends an FCM payload to all of a user's devices and prunes dead tokens.
 * Falls back gracefully when only the legacy single token exists.
 */
export async function sendFcmToUserDevices(
  uid: string,
  payload: Omit<admin.messaging.MulticastMessage, 'tokens'>,
  userData?: admin.firestore.DocumentData,
): Promise<FcmResult> {
  const tokens = await getUserFcmTokens(uid, userData);
  if (tokens.length === 0) {
    return { success: false, error: 'No FCM token' };
  }

  try {
    const response = await admin.messaging().sendEachForMulticast({
      ...payload,
      tokens,
    });
    const prunes: Promise<void>[] = [];
    response.responses.forEach((res, i) => {
      if (!res.success && isDeadTokenError(res.error)) {
        prunes.push(pruneToken(uid, tokens[i]));
      }
    });
    await Promise.all(prunes);
    if (response.successCount === 0) {
      return {
        success: false,
        error: response.responses[0]?.error?.message ?? 'All sends failed',
      };
    }
    return { success: true };
  } catch (error: any) {
    return { success: false, error: error?.message || String(error) };
  }
}

/**
 * Sends an FCM message to a single user (all of their registered devices).
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

  const settings = userData.settings as Record<string, any> | undefined;
  if (settings?.notifications?.system === false) {
    return { success: false, error: 'User disabled system notifications' };
  }

  // Forward only multicast-compatible fields (Message may also carry
  // token/topic/condition, which sendEachForMulticast rejects).
  const { notification, data, android, apns, webpush, fcmOptions } = payload;
  return sendFcmToUserDevices(
    uid,
    { notification, data, android, apns, webpush, fcmOptions },
    userData,
  );
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
