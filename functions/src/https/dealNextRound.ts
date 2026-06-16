import * as functions from 'firebase-functions';
import { db } from '../config/admin';
import { requireAppCheck } from '../utils/appCheck';
import { dealRound } from '../engine/deal';

export const dealNextRound = functions.https.onCall(async (request) => {
  if (!request.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  requireAppCheck(request);

  const { gameId } = request.data;
  if (!gameId || typeof gameId !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing gameId');
  }

  const gameRef = db.collection('games').doc(gameId);

  return db.runTransaction(async (transaction) => {
    const gameDoc = await transaction.get(gameRef);
    if (!gameDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Game not found');
    }

    const game = gameDoc.data() as any;

    if (game.status !== 'roundEnd') {
      throw new functions.https.HttpsError(
        'failed-precondition',
        'Game is not between rounds',
      );
    }

    // Verify the caller is a player in the game
    const playerEntry = Object.entries(game.players).find(
      ([, p]: [string, any]) => (p as any).uid === request.auth!.uid,
    );
    if (!playerEntry) {
      throw new functions.https.HttpsError(
        'permission-denied',
        'Not a player in this game',
      );
    }

    // Deal a new round
    dealRound(game);

    // Reset round-scoped fields
    game.fellTeam = null;
    game.resolvedBonuses = null;
    game.roundTricksA = 0;
    game.roundTricksB = 0;

    // Reset per-player round state
    for (const [, player] of Object.entries(game.players) as [string, any][]) {
      player.takenCards = [];
      player.tricksWon = 0;
      player.bonuses = null;
      player.isReady = false;
      player.bid = null;
    }

    game.turnTimerStart = new Date();
    game.updatedAt = new Date();

    transaction.update(gameRef, game);

    return { success: true, status: game.status, currentRound: game.currentRound };
  });
});
