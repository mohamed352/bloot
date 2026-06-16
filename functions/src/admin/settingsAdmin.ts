import * as functions from 'firebase-functions';
import { db } from '../config/admin';
import { verifyRole, logAdminAction } from './helpers';
import { UpdateSettingsInput, SuccessResponse } from './types';

function assertAuth(request: functions.https.CallableRequest<unknown>): string {
  if (!request.auth?.uid) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }
  return request.auth.uid;
}

export const updateSettings = functions.https.onCall(async (request) => {
  const actorUid = assertAuth(request);
  await verifyRole(actorUid, 'super_admin');

  const { settingsId, updates } = request.data as UpdateSettingsInput;
  if (!settingsId || typeof settingsId !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing settingsId');
  }
  if (!updates || typeof updates !== 'object') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing updates');
  }

  const settingsRef = db.collection('settings').doc(settingsId);
  await settingsRef.set(
    {
      ...updates,
      updatedAt: new Date(),
    },
    { merge: true },
  );

  await logAdminAction(actorUid, 'updateSettings', 'settings', settingsId, { updates });
  return { success: true } as SuccessResponse;
});
