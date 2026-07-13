import * as functions from 'firebase-functions';
import { db } from '../config/admin';
import { requireAppCheck } from '../utils/appCheck';

/**
 * Blocks another user for the caller. The relationship is stored in the
 * caller's `blockedUsers` subcollection so clients can hide the blocked
 * user's content (chat messages, profile, streams).
 */
export const blockUser = functions.https.onCall(async (request) => {
  if (!request.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  requireAppCheck(request);

  const { targetUid } = request.data;
  if (!targetUid || typeof targetUid !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing targetUid');
  }

  const currentUid = request.auth.uid;
  if (currentUid === targetUid) {
    throw new functions.https.HttpsError('invalid-argument', 'Cannot block yourself');
  }

  const targetDoc = await db.collection('users').doc(targetUid).get();
  if (!targetDoc.exists) {
    throw new functions.https.HttpsError('not-found', 'User not found');
  }

  const targetData = targetDoc.data()!;
  await db
    .collection('users')
    .doc(currentUid)
    .collection('blockedUsers')
    .doc(targetUid)
    .set({
      uid: currentUid,
      blockedUid: targetUid,
      displayName: targetData.displayName ?? '',
      avatarUrl: targetData.avatarUrl ?? null,
      createdAt: new Date(),
    });

  return { success: true };
});

/**
 * Removes a previously blocked user from the caller's `blockedUsers` list.
 */
export const unblockUser = functions.https.onCall(async (request) => {
  if (!request.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  requireAppCheck(request);

  const { targetUid } = request.data;
  if (!targetUid || typeof targetUid !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing targetUid');
  }

  await db
    .collection('users')
    .doc(request.auth.uid)
    .collection('blockedUsers')
    .doc(targetUid)
    .delete();

  return { success: true };
});
