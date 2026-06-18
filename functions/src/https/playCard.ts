import * as functions from 'firebase-functions';
import { db } from '../config/admin';
import { requireAppCheck } from '../utils/appCheck';
import { isCardLegal, playCardOntoTrick } from '../engine/trick';
import { calculateRoundScore, checkGameEnd } from '../engine/scoring';
import { buildGameUpdate, deepCloneGame } from '../utils/gameUpdate';

export const playCard = functions.https.onCall(async (request) => {
  if (!request.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  requireAppCheck(request);

  const { gameId, card } = request.data;
  if (!gameId || !card) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing gameId or card');
  }

  const gameRef = db.collection('games').doc(gameId);

  return db.runTransaction(async (transaction) => {
    const gameDoc = await transaction.get(gameRef);
    if (!gameDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Game not found');
    }

    const game = gameDoc.data() as any;
    const originalGame = deepCloneGame(game);

    if (game.status !== 'playing') {
      throw new functions.https.HttpsError('failed-precondition', 'Not in playing phase');
    }

    // Find player seat
    const playerEntry = Object.entries(game.players).find(
      ([, p]: [string, any]) => (p as any).uid === request.auth!.uid,
    );
    if (!playerEntry) {
      throw new functions.https.HttpsError('permission-denied', 'Not a player in this game');
    }

    const seatIndex = parseInt(playerEntry[0], 10);

    // Validate card play
    const legality = isCardLegal(game, seatIndex, card);
    if (!legality.legal) {
      throw new functions.https.HttpsError('failed-precondition', legality.reason || 'Illegal card');
    }

    // Play card
    const result = playCardOntoTrick(game, seatIndex, card);

    if (result.trickComplete) {
      // The current trick number is read BEFORE startNextTrick mutates it.
      const completedTrickNumber = game.currentTrick?.trickNumber;

      if (completedTrickNumber !== 13) {
        // Pause at trickEnd so clients can show the winner. A scheduled
        // function or client action will advance to the next trick.
        game.status = 'trickEnd';
        game.turnTimerStart = new Date();
      } else {
        // All 13 tricks complete — score the round.
        const score = calculateRoundScore(game);
        game.teamAScore += score.teamAPoints;
        game.teamBScore += score.teamBPoints;
        game.fellTeam = score.fell;

        // Check game end
        const winner = checkGameEnd(game.teamAScore, game.teamBScore, game.targetScore);
        if (winner) {
          game.status = 'gameEnd';
          game.endedAt = new Date();
        } else {
          game.status = 'roundEnd';
          game.currentRound += 1;
          game.dealerIndex = (game.dealerIndex + 1) % 4;
        }
      }
    } else {
      // Turn advanced inside playCardOntoTrick; refresh timer.
      game.turnTimerStart = new Date();
    }

    const update = buildGameUpdate(originalGame, game);
    transaction.update(gameRef, update);
    return {
      success: true,
      trickComplete: result.trickComplete,
      winnerSeat: result.winnerSeat,
      status: game.status,
    };
  });
});
