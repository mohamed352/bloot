import * as functions from 'firebase-functions';
import { db } from '../config/admin';
import { requireAppCheck } from '../utils/appCheck';
import { BalootEngine } from '../engine';
import {
  autoResolveDoubling,
  bidToString,
  GameDocument,
  loadMatch,
  parseBidAction,
  saveMatch,
} from '../engine/gameAdapter';
import { buildGameUpdate, deepCloneGame } from '../utils/gameUpdate';

export const placeBid = functions.https.onCall(async (request) => {
  if (!request.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  requireAppCheck(request);

  const { gameId, bid } = request.data;
  if (!gameId || !bid || !['pass', 'sun', 'hokm', 'ashkal'].includes(bid)) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing gameId or bid');
  }

  const gameRef = db.collection('games').doc(gameId);

  return db.runTransaction(async (transaction) => {
    const gameDoc = await transaction.get(gameRef);
    if (!gameDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Game not found');
    }

    const game = gameDoc.data() as GameDocument;
    const originalGame = deepCloneGame(game);

    if (game.status !== 'bidding') {
      throw new functions.https.HttpsError('failed-precondition', 'Not in bidding phase');
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

    if (state.bidding.turn !== seatIndex) {
      throw new functions.https.HttpsError('failed-precondition', 'Not your turn to bid');
    }

    const action = parseBidAction(bid, state.topCard);
    const events = engine.applyBid(match, seatIndex, {
      type: action.type,
      suit: action.suit ? (action.suit as any) : undefined,
    });

    // Record the player's bid for the UI.
    game.playerBids = game.playerBids ?? {};
    game.playerBids[String(seatIndex)] = bidToString(action.type);

    // Bidding may have ended and the engine may now be awaiting a double.
    // Auto-resolve doubling so online play does not require a doubling UI.
    if (match.state?.awaitingDouble) {
      autoResolveDoubling(match, engine);
    }

    saveMatch(game, match);
    game.turnTimerStart = new Date();

    // If the hand was re-dealt (everyone passed twice), reset the bid UI state.
    if (events.some((e) => e.type === 'redeal')) {
      game.playerBids = {};
    }

    const update = buildGameUpdate(originalGame, game );
    transaction.update(gameRef, update);
    return { success: true, status: game.status };
  });
});
