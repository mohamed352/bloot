import * as functions from 'firebase-functions';
import { db } from '../config/admin';
import { verifyPermission, logAdminAction } from './helpers';
import {
  CreateAchievementInput,
  UpdateAchievementInput,
  DeleteAchievementInput,
  AssignAchievementInput,
  SuccessResponse,
} from './types';

function assertAuth(request: functions.https.CallableRequest<unknown>): string {
  if (!request.auth?.uid) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }
  return request.auth.uid;
}

export const createAchievement = functions.https.onCall(async (request) => {
  const actorUid = assertAuth(request);
  await verifyPermission(actorUid, 'manage');

  const data = request.data as CreateAchievementInput;
  if (!data.id || typeof data.id !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing id');
  }
  if (!data.name || typeof data.name !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing name');
  }
  if (!data.nameAr || typeof data.nameAr !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing nameAr');
  }
  if (!data.description || typeof data.description !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing description');
  }
  if (!data.descriptionAr || typeof data.descriptionAr !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing descriptionAr');
  }
  if (!data.iconUrl || typeof data.iconUrl !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing iconUrl');
  }
  if (!data.iconInactiveUrl || typeof data.iconInactiveUrl !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing iconInactiveUrl');
  }
  if (!data.category || typeof data.category !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing category');
  }
  if (!data.rarity || typeof data.rarity !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing rarity');
  }
  if (!data.conditionType || typeof data.conditionType !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing conditionType');
  }
  if (typeof data.conditionThreshold !== 'number') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing conditionThreshold');
  }

  const now = new Date();
  const achievementRef = db.collection('achievements').doc(data.id);
  await db.runTransaction(async (transaction) => {
    const existing = await transaction.get(achievementRef);
    if (existing.exists) {
      throw new functions.https.HttpsError('already-exists', 'Achievement already exists');
    }
    transaction.set(achievementRef, {
      id: data.id,
      name: data.name,
      nameAr: data.nameAr,
      description: data.description,
      descriptionAr: data.descriptionAr,
      iconUrl: data.iconUrl,
      iconInactiveUrl: data.iconInactiveUrl,
      category: data.category,
      rarity: data.rarity,
      xpReward: data.xpReward ?? 0,
      coinReward: data.coinReward ?? 0,
      conditionType: data.conditionType,
      conditionThreshold: data.conditionThreshold,
      isSecret: data.isSecret ?? false,
      displayOrder: data.displayOrder ?? 0,
      isActive: data.isActive ?? true,
      createdAt: now,
      updatedAt: now,
    });
  });

  await logAdminAction(actorUid, 'createAchievement', 'achievement', data.id, data as unknown as Record<string, unknown>);
  return { success: true } as SuccessResponse;
});

export const updateAchievement = functions.https.onCall(async (request) => {
  const actorUid = assertAuth(request);
  await verifyPermission(actorUid, 'manage');

  const { achievementId, updates } = request.data as UpdateAchievementInput;
  if (!achievementId || typeof achievementId !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing achievementId');
  }
  if (!updates || typeof updates !== 'object') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing updates');
  }

  const achievementRef = db.collection('achievements').doc(achievementId);
  await db.runTransaction(async (transaction) => {
    const achievementDoc = await transaction.get(achievementRef);
    if (!achievementDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Achievement not found');
    }
    transaction.update(achievementRef, {
      ...updates,
      updatedAt: new Date(),
    });
  });

  await logAdminAction(actorUid, 'updateAchievement', 'achievement', achievementId, { updates });
  return { success: true } as SuccessResponse;
});

export const deleteAchievement = functions.https.onCall(async (request) => {
  const actorUid = assertAuth(request);
  await verifyPermission(actorUid, 'manage');

  const { achievementId } = request.data as DeleteAchievementInput;
  if (!achievementId || typeof achievementId !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing achievementId');
  }

  const achievementRef = db.collection('achievements').doc(achievementId);
  await db.runTransaction(async (transaction) => {
    const achievementDoc = await transaction.get(achievementRef);
    if (!achievementDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Achievement not found');
    }
    transaction.delete(achievementRef);
  });

  await logAdminAction(actorUid, 'deleteAchievement', 'achievement', achievementId, {});
  return { success: true } as SuccessResponse;
});

export const assignAchievement = functions.https.onCall(async (request) => {
  const actorUid = assertAuth(request);
  await verifyPermission(actorUid, 'manage');

  const { achievementId, uid } = request.data as AssignAchievementInput;
  if (!achievementId || typeof achievementId !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing achievementId');
  }
  if (!uid || typeof uid !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing uid');
  }

  const achievementRef = db.collection('achievements').doc(achievementId);
  const userRef = db.collection('users').doc(uid);
  const unlockedRef = achievementRef.collection('unlockedBy').doc(uid);

  await db.runTransaction(async (transaction) => {
    const [achievementDoc, userDoc] = await Promise.all([
      transaction.get(achievementRef),
      transaction.get(userRef),
    ]);
    if (!achievementDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Achievement not found');
    }
    if (!userDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'User not found');
    }
    const user = userDoc.data()!;
    const achievement = achievementDoc.data()!;
    transaction.set(unlockedRef, {
      uid,
      displayName: user.displayName ?? '',
      avatarUrl: user.avatarUrl ?? '',
      unlockedAt: new Date(),
    });
    transaction.update(userRef, {
      [`achievements.${achievementId}`]: new Date(),
      xp: (user.xp ?? 0) + (achievement.xpReward ?? 0),
      coins: (user.coins ?? 0) + (achievement.coinReward ?? 0),
      updatedAt: new Date(),
    });
  });

  await logAdminAction(actorUid, 'assignAchievement', 'achievement', achievementId, { uid });
  return { success: true } as SuccessResponse;
});
