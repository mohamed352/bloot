import * as functions from 'firebase-functions';
import { db } from '../config/admin';
import { verifyPermission, logAdminAction } from './helpers';
import { ResolveReportInput, EscalateReportInput, SuccessResponse } from './types';

function assertAuth(request: functions.https.CallableRequest<unknown>): string {
  if (!request.auth?.uid) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }
  return request.auth.uid;
}

export const resolveReport = functions.https.onCall(async (request) => {
  const actorUid = assertAuth(request);
  await verifyPermission(actorUid, 'moderate');

  const { reportId, resolution } = request.data as ResolveReportInput;
  if (!reportId || typeof reportId !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing reportId');
  }
  if (!resolution || typeof resolution !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing resolution');
  }

  const reportRef = db.collection('reports').doc(reportId);
  await db.runTransaction(async (transaction) => {
    const reportDoc = await transaction.get(reportRef);
    if (!reportDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Report not found');
    }
    transaction.update(reportRef, {
      status: 'resolved',
      resolution,
      resolvedBy: actorUid,
      resolvedAt: new Date(),
      updatedAt: new Date(),
    });
  });

  await logAdminAction(actorUid, 'resolveReport', 'report', reportId, { resolution });
  return { success: true } as SuccessResponse;
});

export const escalateReport = functions.https.onCall(async (request) => {
  const actorUid = assertAuth(request);
  await verifyPermission(actorUid, 'moderate');

  const { reportId } = request.data as EscalateReportInput;
  if (!reportId || typeof reportId !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing reportId');
  }

  const reportRef = db.collection('reports').doc(reportId);
  await db.runTransaction(async (transaction) => {
    const reportDoc = await transaction.get(reportRef);
    if (!reportDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Report not found');
    }
    transaction.update(reportRef, {
      status: 'escalated',
      escalatedBy: actorUid,
      escalatedAt: new Date(),
      updatedAt: new Date(),
    });
  });

  await logAdminAction(actorUid, 'escalateReport', 'report', reportId, {});
  return { success: true } as SuccessResponse;
});
