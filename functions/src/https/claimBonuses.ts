import * as functions from 'firebase-functions';
import { db } from '../config/admin';
import { requireAppCheck } from '../utils/appCheck';
import { BalootEngine } from '../engine';
import { GameDocument, loadMatch, parseProjectTypes, saveMatch } from '../engine/gameAdapter';
import { buildGameUpdate, deepCloneGame } from '../utils/gameUpdate';

export const claimBonuses = functions.https.onCall(async (request) => {
  if (!request.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  requireAppCheck(request);

  const { gameId, bonuses } = request.data;
  if (!gameId || !Array.isArray(bonuses)) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing gameId or bonuses');
  }

  const gameRef = db.collection('games').doc(gameId);

  return db.runTransaction(async (transaction) => {
    const gameDoc = await transaction.get(gameRef);
    if (!gameDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Game not found');
    }

    const game = gameDoc.data() as GameDocument;
    const originalGame = deepCloneGame(game);

    const engine = new BalootEngine();
    const match = loadMatch(game);
    const state = match.state!;

    const playerEntry = Object.entries(game.players).find(
      ([, p]) => (p as any).uid === request.auth!.uid,
    );
    if (!playerEntry) {
      throw new functions.https.HttpsError('permission-denied', 'Not a player');
    }

    const seatIndex = parseInt(playerEntry[0], 10);

    // When auto-declare is enabled the engine has already resolved projects.
    // Treat the call as a no-op so the UI overlay can close immediately.
    if (!state.awaitingDeclare || !state.declareSeats.includes(seatIndex)) {
      return { success: true, status: game.status };
    }

    // Projects only exist in Sun / Ashkal (which plays as Sun).
    if (state.mode !== 'sun' && !state.ashkal) {
      throw new functions.https.HttpsError('failed-precondition', 'Projects only in Sun');
    }

    const claimedTypes = parseProjectTypes(bonuses);
    engine.declareProject(match, seatIndex, claimedTypes);

    // After the last human declaration, the engine may be awaiting a double.
    // Auto-resolve it so play can begin without a dedicated doubling UI.
    if (match.state?.awaitingDouble) {
      let guard = 0;
      while (match.state.awaitingDouble && match.state.doubling && guard < 10) {
        engine.applyDouble(match, match.state.doubling.turn, 'pass');
        guard++;
      }
    }

    saveMatch(game, match);
    game.turnTimerStart = new Date();

    const update = buildGameUpdate(originalGame, game);
    transaction.update(gameRef, update);

    return { success: true, status: game.status };
  });
});
