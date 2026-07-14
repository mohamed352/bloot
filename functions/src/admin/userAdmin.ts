import * as functions from 'firebase-functions';
import { db, auth } from '../config/admin';
import { verifyPermission, logAdminAction } from './helpers';
import { getOrCreateUserAgoraUid } from '../utils/agoraUid';
import {
  SuspendUserInput,
  BanUserInput,
  ResetUserCoinsInput,
  ForceLogoutUserInput,
  SuccessResponse,
} from './types';

function assertAuth(request: functions.https.CallableRequest<unknown>): string {
  if (!request.auth?.uid) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }
  return request.auth.uid;
}

export const suspendUser = functions.https.onCall(async (request) => {
  const actorUid = assertAuth(request);
  await verifyPermission(actorUid, 'manage');

  const { uid, suspended } = request.data as SuspendUserInput;
  if (!uid || typeof uid !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing uid');
  }
  if (typeof suspended !== 'boolean') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing or invalid suspended');
  }

  const userRef = db.collection('users').doc(uid);
  await db.runTransaction(async (transaction) => {
    const userDoc = await transaction.get(userRef);
    if (!userDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'User not found');
    }
    transaction.update(userRef, {
      suspended,
      updatedAt: new Date(),
    });
  });

  await logAdminAction(actorUid, 'suspendUser', 'user', uid, { suspended });
  return { success: true } as SuccessResponse;
});

export const banUser = functions.https.onCall(async (request) => {
  const actorUid = assertAuth(request);
  await verifyPermission(actorUid, 'manage');

  const { uid, banned } = request.data as BanUserInput;
  if (!uid || typeof uid !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing uid');
  }
  if (typeof banned !== 'boolean') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing or invalid banned');
  }

  const userRef = db.collection('users').doc(uid);
  await db.runTransaction(async (transaction) => {
    const userDoc = await transaction.get(userRef);
    if (!userDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'User not found');
    }
    transaction.update(userRef, {
      banned,
      suspended: banned,
      updatedAt: new Date(),
    });
  });

  if (banned) {
    await auth.revokeRefreshTokens(uid);
  }

  await logAdminAction(actorUid, 'banUser', 'user', uid, { banned });
  return { success: true } as SuccessResponse;
});

export const resetUserCoins = functions.https.onCall(async (request) => {
  const actorUid = assertAuth(request);
  await verifyPermission(actorUid, 'manage');

  const { uid, coins } = request.data as ResetUserCoinsInput;
  if (!uid || typeof uid !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing uid');
  }
  if (typeof coins !== 'number' || !Number.isInteger(coins) || coins < 0) {
    throw new functions.https.HttpsError('invalid-argument', 'Invalid coins value');
  }

  const userRef = db.collection('users').doc(uid);
  await db.runTransaction(async (transaction) => {
    const userDoc = await transaction.get(userRef);
    if (!userDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'User not found');
    }
    const previousBalance = (userDoc.data()?.coins as number) ?? 0;
    transaction.update(userRef, {
      coins,
      updatedAt: new Date(),
    });

    const transactionRef = db.collection('coin_transactions').doc();
    transaction.set(transactionRef, {
      uid,
      type: 'admin_adjustment',
      amount: coins - previousBalance,
      balanceAfter: coins,
      description: 'Admin reset user coins',
      referenceType: 'admin',
      referenceId: actorUid,
      createdAt: new Date(),
    });
  });

  await logAdminAction(actorUid, 'resetUserCoins', 'user', uid, { coins });
  return { success: true } as SuccessResponse;
});

export const forceLogoutUser = functions.https.onCall(async (request) => {
  const actorUid = assertAuth(request);
  await verifyPermission(actorUid, 'manage');

  const { uid } = request.data as ForceLogoutUserInput;
  if (!uid || typeof uid !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing uid');
  }

  const userDoc = await db.collection('users').doc(uid).get();
  if (!userDoc.exists) {
    throw new functions.https.HttpsError('not-found', 'User not found');
  }

  await auth.revokeRefreshTokens(uid);
  await logAdminAction(actorUid, 'forceLogoutUser', 'user', uid, {});
  return { success: true } as SuccessResponse;
});

/**
 * One-time migration: assigns a unique Agora UID to every user document that
 * does not already have one. Call this after deploying the UID collision fix.
 */
export const backfillMissingAgoraUids = functions.https.onCall(
  async (request) => {
    const actorUid = assertAuth(request);
    await verifyPermission(actorUid, 'manage');

    const snapshot = await db.collection('users').limit(500).get();

    let processed = 0;
    for (const doc of snapshot.docs) {
      const agoraUid = doc.data()?.agoraUid as number | undefined;
      if (agoraUid && Number.isInteger(agoraUid) && agoraUid > 0) {
        continue;
      }
      await getOrCreateUserAgoraUid(doc.id);
      processed++;
    }

    await logAdminAction(actorUid, 'backfillMissingAgoraUids', 'user', '', {
      processed,
    });
    return { success: true, processed } as SuccessResponse;
  },
);
