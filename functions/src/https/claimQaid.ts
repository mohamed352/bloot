import * as functions from 'firebase-functions';
import { db } from '../config/admin';
import { requireAppCheck } from '../utils/appCheck';
import { BalootEngine } from '../engine';
import { GameDocument, loadMatch, saveMatch } from '../engine/gameAdapter';
import { buildGameUpdate, deepCloneGame } from '../utils/gameUpdate';

export const claimQaid = functions.https.onCall(async (request) => {
  if (!request.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  requireAppCheck(request);

  const { gameId, claimType } = request.data;
  if (!gameId) {
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

    const playerEntry = Object.entries(game.players).find(
      ([, p]) => (p as any).uid === request.auth!.uid,
    );
    if (!playerEntry) {
      throw new functions.https.HttpsError('permission-denied', 'Not a player in this game');
    }

    const seatIndex = parseInt(playerEntry[0], 10);
    const engine = new BalootEngine();
    const match = loadMatch(game);
    const state = match.state!;

    if (state.phase !== 'playing') {
      throw new functions.https.HttpsError('failed-precondition', 'Not time to claim qaid');
    }

    engine.claimQaid(match, seatIndex, claimType);

    saveMatch(game, match);
    game.turnTimerStart = new Date();

    const update = buildGameUpdate(originalGame, game);
    transaction.update(gameRef, update);
    return { success: true, status: game.status };
  });
});
