import * as functions from 'firebase-functions';
import { db } from '../config/admin';
import { verifyPermission, logAdminAction } from './helpers';
import { ForceEndGameInput, RematchGameInput, SuccessResponse } from './types';

function assertAuth(request: functions.https.CallableRequest<unknown>): string {
  if (!request.auth?.uid) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }
  return request.auth.uid;
}

export const forceEndGame = functions.https.onCall(async (request) => {
  const actorUid = assertAuth(request);
  await verifyPermission(actorUid, 'moderate');

  const { gameId } = request.data as ForceEndGameInput;
  if (!gameId || typeof gameId !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing gameId');
  }

  const gameRef = db.collection('games').doc(gameId);
  await db.runTransaction(async (transaction) => {
    const gameDoc = await transaction.get(gameRef);
    if (!gameDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Game not found');
    }
    transaction.update(gameRef, {
      status: 'gameEnd',
      endedAt: new Date(),
      updatedAt: new Date(),
    });
  });

  await logAdminAction(actorUid, 'forceEndGame', 'game', gameId, {});
  return { success: true } as SuccessResponse;
});

export const rematchGame = functions.https.onCall(async (request) => {
  const actorUid = assertAuth(request);
  await verifyPermission(actorUid, 'moderate');

  const { gameId } = request.data as RematchGameInput;
  if (!gameId || typeof gameId !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing gameId');
  }

  const gameRef = db.collection('games').doc(gameId);
  const rematchRef = db.collection('games').doc();
  await db.runTransaction(async (transaction) => {
    const gameDoc = await transaction.get(gameRef);
    if (!gameDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Game not found');
    }
    const game = gameDoc.data()!;
    transaction.set(rematchRef, {
      ...game,
      id: rematchRef.id,
      roomId: game.roomId,
      gameType: game.gameType,
      status: 'dealing',
      teamAScore: 0,
      teamBScore: 0,
      currentRound: 1,
      currentTrick: {},
      tricksPlayed: 0,
      trumpSuit: null,
      hokmBidder: null,
      turnIndex: 0,
      startedAt: new Date(),
      endedAt: null,
      updatedAt: new Date(),
    });
  });

  await logAdminAction(actorUid, 'rematchGame', 'game', gameId, { rematchId: rematchRef.id });
  return { success: true, rematchId: rematchRef.id } as SuccessResponse & { rematchId: string };
});
