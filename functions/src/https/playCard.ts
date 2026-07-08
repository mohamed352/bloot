import * as functions from 'firebase-functions';
import { db } from '../config/admin';
import { requireAppCheck } from '../utils/appCheck';
import { BalootCard, BalootEngine } from '../engine';
import { GameDocument, loadMatch, saveMatch, setTrickEndStatus } from '../engine/gameAdapter';
import { buildGameUpdate, deepCloneGame } from '../utils/gameUpdate';

export const playCard = functions.https.onCall(async (request) => {
  if (!request.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  requireAppCheck(request);

  const { gameId, card } = request.data;
  if (!gameId || !card || typeof card !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing gameId or card');
  }

  const gameRef = db.collection('games').doc(gameId);

  return db.runTransaction(async (transaction) => {
    const gameDoc = await transaction.get(gameRef);
    if (!gameDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Game not found');
    }

    const game = gameDoc.data() as GameDocument;
    const originalGame = deepCloneGame(game);

    if (game.status !== 'playing' && game.status !== 'trickEnd') {
      throw new functions.https.HttpsError('failed-precondition', 'Not in playing phase');
    }

    // If we are paused on a completed trick, advance to the next trick first.
    if (game.status === 'trickEnd') {
      // The engine state already has the winner as the next leader and an empty trick.
      game.status = 'playing';
    }

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

    if (state.phase !== 'playing' || state.turn !== seatIndex) {
      throw new functions.https.HttpsError('failed-precondition', 'Not your turn');
    }

    const balootCard = BalootCard.fromString(card);
    const events = engine.playCard(match, seatIndex, balootCard);

    const trickEnded = events.some((e) => e.type === 'trickEnd');
    const handEnded = events.some((e) => e.type === 'handEnd');
    const matchEnded = events.some((e) => e.type === 'matchEnd');

    saveMatch(game, match);

    if (trickEnded && !handEnded && !matchEnded) {
      setTrickEndStatus(game, match);
    }

    game.turnTimerStart = new Date();

    const update = buildGameUpdate(originalGame, game );
    transaction.update(gameRef, update);

    return {
      success: true,
      trickComplete: trickEnded,
      winnerSeat: trickEnded ? match.state!.trickHistory[match.state!.trickHistory.length - 1].winner : undefined,
      status: game.status,
    };
  });
});
