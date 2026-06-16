import * as functions from 'firebase-functions';
import { db } from '../config/admin';
import { verifyPermission, logAdminAction } from './helpers';
import { AdjustBalanceInput, IssueRefundInput, SuccessResponse } from './types';

function assertAuth(request: functions.https.CallableRequest<unknown>): string {
  if (!request.auth?.uid) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }
  return request.auth.uid;
}

export const adjustBalance = functions.https.onCall(async (request) => {
  const actorUid = assertAuth(request);
  await verifyPermission(actorUid, 'manage');

  const { uid, amount, description } = request.data as AdjustBalanceInput;
  if (!uid || typeof uid !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing uid');
  }
  if (typeof amount !== 'number' || !Number.isInteger(amount)) {
    throw new functions.https.HttpsError('invalid-argument', 'Invalid amount');
  }

  const userRef = db.collection('users').doc(uid);
  await db.runTransaction(async (transaction) => {
    const userDoc = await transaction.get(userRef);
    if (!userDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'User not found');
    }
    const currentCoins = (userDoc.data()?.coins as number) ?? 0;
    const newBalance = currentCoins + amount;
    if (newBalance < 0) {
      throw new functions.https.HttpsError('failed-precondition', 'Balance cannot be negative');
    }
    transaction.update(userRef, {
      coins: newBalance,
      updatedAt: new Date(),
    });

    const transactionRef = db.collection('coin_transactions').doc();
    transaction.set(transactionRef, {
      uid,
      type: 'admin_adjustment',
      amount,
      balanceAfter: newBalance,
      description: description ?? 'Admin balance adjustment',
      referenceType: 'admin',
      referenceId: actorUid,
      createdAt: new Date(),
    });
  });

  await logAdminAction(actorUid, 'adjustBalance', 'user', uid, { amount, description });
  return { success: true } as SuccessResponse;
});

export const issueRefund = functions.https.onCall(async (request) => {
  const actorUid = assertAuth(request);
  await verifyPermission(actorUid, 'manage');

  const { transactionId } = request.data as IssueRefundInput;
  if (!transactionId || typeof transactionId !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing transactionId');
  }

  const originalRef = db.collection('coin_transactions').doc(transactionId);
  await db.runTransaction(async (transaction) => {
    const originalDoc = await transaction.get(originalRef);
    if (!originalDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Transaction not found');
    }
    const original = originalDoc.data()!;
    if (original.type === 'refund') {
      throw new functions.https.HttpsError('failed-precondition', 'Cannot refund a refund transaction');
    }
    if (original.refundedAt) {
      throw new functions.https.HttpsError('already-exists', 'Transaction has already been refunded');
    }
    const uid = original.uid as string;
    const originalAmount = original.amount as number;
    if (typeof originalAmount !== 'number' || originalAmount <= 0) {
      throw new functions.https.HttpsError('failed-precondition', 'Only positive transactions can be refunded');
    }

    const userRef = db.collection('users').doc(uid);
    const userDoc = await transaction.get(userRef);
    if (!userDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'User not found');
    }
    const currentCoins = (userDoc.data()?.coins as number) ?? 0;
    const refundAmount = -originalAmount;
    const newBalance = currentCoins + refundAmount;
    if (newBalance < 0) {
      throw new functions.https.HttpsError('failed-precondition', 'Refund would result in negative balance');
    }

    transaction.update(userRef, {
      coins: newBalance,
      updatedAt: new Date(),
    });

    transaction.update(originalRef, {
      refundedAt: new Date(),
      refundAmount,
    });

    const refundRef = db.collection('coin_transactions').doc();
    transaction.set(refundRef, {
      uid,
      type: 'refund',
      amount: refundAmount,
      balanceAfter: newBalance,
      description: `Refund for transaction ${transactionId}`,
      referenceType: 'coin_transaction',
      referenceId: transactionId,
      createdAt: new Date(),
    });
  });

  await logAdminAction(actorUid, 'issueRefund', 'coin_transaction', transactionId, {});
  return { success: true } as SuccessResponse;
});
