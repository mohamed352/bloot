import * as functions from 'firebase-functions';
import { db } from '../config/admin';
import { requireAppCheck } from '../utils/appCheck';

/**
 * Follows another user and increments follow counts atomically.
 * Idempotent: repeated calls do not inflate counters.
 */
export const followUser = functions.https.onCall(async (request) => {
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
    throw new functions.https.HttpsError('invalid-argument', 'Cannot follow yourself');
  }

  const currentRef = db.collection('users').doc(currentUid);
  const targetRef = db.collection('users').doc(targetUid);
  const followingRef = currentRef.collection('following').doc(targetUid);
  const followerRef = targetRef.collection('followers').doc(currentUid);

  await db.runTransaction(async (transaction) => {
    const [currentDoc, targetDoc, existingFollowing] = await Promise.all([
      transaction.get(currentRef),
      transaction.get(targetRef),
      transaction.get(followingRef),
    ]);

    if (!targetDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'User not found');
    }

    if (existingFollowing.exists) {
      // Already following; return idempotently without inflating counters.
      return;
    }

    transaction.set(followingRef, {
      uid: currentUid,
      followedUid: targetUid,
      createdAt: new Date(),
    });

    transaction.set(followerRef, {
      uid: currentUid,
      followerUid: currentUid,
      followedUid: targetUid,
      createdAt: new Date(),
    });

    transaction.update(currentRef, {
      followingCount: (currentDoc.data()?.followingCount ?? 0) + 1,
      updatedAt: new Date(),
    });

    transaction.update(targetRef, {
      followersCount: (targetDoc.data()?.followersCount ?? 0) + 1,
      updatedAt: new Date(),
    });
  });

  return { success: true };
});
