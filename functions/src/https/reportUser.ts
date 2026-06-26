import * as functions from 'firebase-functions';
import { db } from '../config/admin';
import { requireAppCheck } from '../utils/appCheck';

/**
 * Creates a user/content report for moderation review.
 */
export const reportUser = functions.https.onCall(async (request) => {
  if (!request.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  requireAppCheck(request);

  const { targetUid, targetType, reason, details } = request.data;
  if (!targetUid || !targetType || !reason) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Missing targetUid, targetType, or reason',
    );
  }

  const validTypes = ['user', 'room', 'stream', 'message'];
  if (!validTypes.includes(targetType)) {
    throw new functions.https.HttpsError('invalid-argument', 'Invalid targetType');
  }

  const reportRef = db.collection('reports').doc();
  await reportRef.set({
    reporterUid: request.auth.uid,
    targetUid,
    targetType,
    reason,
    details: details ?? '',
    status: 'open',
    createdAt: new Date(),
    updatedAt: new Date(),
  });

  return { success: true, reportId: reportRef.id };
});
