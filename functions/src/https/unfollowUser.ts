import * as functions from 'firebase-functions';
import { db } from '../config/admin';
import { requireAppCheck } from '../utils/appCheck';

/**
 * Unfollows another user and decrements follow counts atomically.
 */
export const unfollowUser = functions.https.onCall(async (request) => {
  if (!request.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  requireAppCheck(request);

  const { targetUid } = request.data;
  if (!targetUid || typeof targetUid !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing targetUid');
  }

  const currentUid = request.auth.uid;
  const currentRef = db.collection('users').doc(currentUid);
  const targetRef = db.collection('users').doc(targetUid);
  const followingRef = currentRef.collection('following').doc(targetUid);
  const followerRef = targetRef.collection('followers').doc(currentUid);

  await db.runTransaction(async (transaction) => {
    const followingDoc = await transaction.get(followingRef);
    if (!followingDoc.exists) return;

    const targetDoc = await transaction.get(targetRef);

    transaction.delete(followingRef);
    transaction.delete(followerRef);

    transaction.update(currentRef, {
      followingCount: Math.max(0, (targetDoc.data()?.followingCount ?? 1) - 1),
      updatedAt: new Date(),
    });

    transaction.update(targetRef, {
      followersCount: Math.max(0, (targetDoc.data()?.followersCount ?? 1) - 1),
      updatedAt: new Date(),
    });
  });

  return { success: true };
});
