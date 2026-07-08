import * as functions from 'firebase-functions';
import { db } from '../config/admin';
import { requireAppCheck } from '../utils/appCheck';
import { BalootEngine } from '../engine';
import { GameDocument, loadMatch, saveMatch } from '../engine/gameAdapter';
import { buildGameUpdate, deepCloneGame } from '../utils/gameUpdate';

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

    const game = gameDoc.data() as GameDocument;
    const originalGame = deepCloneGame(game);

    if (game.status !== 'roundEnd' && game.status !== 'gameEnd') {
      throw new functions.https.HttpsError(
        'failed-precondition',
        'Game is not between rounds',
      );
    }

    const playerEntry = Object.entries(game.players).find(
      ([, p]) => (p as any).uid === request.auth!.uid,
    );
    if (!playerEntry) {
      throw new functions.https.HttpsError(
        'permission-denied',
        'Not a player in this game',
      );
    }

    const engine = new BalootEngine();
    const match = loadMatch(game);

    // If the match already ended, reset it for a rematch-style next round.
    if (match.matchOver) {
      match.matchOver = false;
      match.winnerTeam = undefined;
      match.totals[0] = 0;
      match.totals[1] = 0;
      match.handsPlayed = 0;
      match.handResults = [];
      match.dealer = 0;
    } else {
      match.dealer = (match.dealer + 1) % 4;
    }

    engine.startHand(match);

    // Reset per-round UI state.
    game.playerBids = {};
    game.fellTeam = null;
    game.resolvedBonuses = null;
    game.roundTricksA = 0;
    game.roundTricksB = 0;

    saveMatch(game, match);
    game.turnTimerStart = new Date();

    const update = buildGameUpdate(originalGame, game );
    transaction.update(gameRef, update);

    return { success: true, status: game.status, currentRound: game.currentRound };
  });
});
