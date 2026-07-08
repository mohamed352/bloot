import * as functions from 'firebase-functions';
import { db } from '../config/admin';
import { verifyPermission, logAdminAction } from './helpers';
import { ForceEndGameInput, RematchGameInput, SuccessResponse } from './types';
import { BalootEngine } from '../engine';
import { BalootSerializer } from '../engine/balootSerializer';
import { BalootPlayerConfig } from '../engine/balootState';

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

    // Build a fresh 32-card engine state from the same players.
    const players: BalootPlayerConfig[] = Object.entries(game.players as Record<string, any>).map(
      ([, p]): BalootPlayerConfig => ({
        name: p.displayName as string,
        uid: p.uid as string,
        displayName: p.displayName as string,
        avatarUrl: p.avatarUrl as string,
        team: p.team as 'A' | 'B',
        isBot: (p.isBot as boolean) ?? false,
        level: (p.level as string) ?? 'amateur',
        agoraUid: p.agoraUid as number | undefined,
        isMuted: (p.isMuted as boolean) ?? false,
        hasCamera: (p.hasCamera as boolean) ?? true,
        isConnected: (p.isConnected as boolean) ?? true,
      }),
    );

    const engine = new BalootEngine();
    const match = engine.createMatch(players, { safeMode: true, autoDeclare: true });
    engine.startHand(match);
    const engineState = new BalootSerializer().serializeMatch(match);

    transaction.set(rematchRef, {
      ...game,
      id: rematchRef.id,
      roomId: game.roomId,
      gameType: null,
      status: 'bidding',
      teamAScore: 0,
      teamBScore: 0,
      currentRound: 1,
      currentTrick: {
        trickNumber: 1,
        trickLeaderIndex: -1,
        leadingSuit: null,
        cards: { '0': null, '1': null, '2': null, '3': null },
      },
      tricksPlayed: 0,
      trumpSuit: null,
      hokmBidder: null,
      sunBidder: null,
      biddingTeam: null,
      faceUpCard: (engineState as any)?.state?.topCard ?? null,
      fellTeam: null,
      playerBids: {},
      engineState,
      turnIndex: (match.dealer + 1) % 4,
      startedAt: new Date(),
      endedAt: null,
      updatedAt: new Date(),
    });
  });

  await logAdminAction(actorUid, 'rematchGame', 'game', gameId, { rematchId: rematchRef.id });
  return { success: true, rematchId: rematchRef.id } as SuccessResponse & { rematchId: string };
});
