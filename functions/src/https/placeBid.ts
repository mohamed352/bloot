import * as functions from 'firebase-functions';
import { db } from '../config/admin';
import { requireAppCheck } from '../utils/appCheck';
import { validateBid, resolveBidding, applyBiddingResult } from '../engine/bidding';
import { dealRound } from '../engine/deal';
import { buildGameUpdate, deepCloneGame } from '../utils/gameUpdate';

export const placeBid = functions.https.onCall(async (request) => {
  if (!request.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  requireAppCheck(request);

  const { gameId, bid } = request.data;
  if (!gameId || !bid || !['pass', 'sun', 'hokm'].includes(bid)) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing gameId or bid');
  }

  const gameRef = db.collection('games').doc(gameId);

  return db.runTransaction(async (transaction) => {
    const gameDoc = await transaction.get(gameRef);
    if (!gameDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Game not found');
    }

    const game = gameDoc.data() as any;
    const originalGame = deepCloneGame(game);

    if (game.status !== 'bidding') {
      throw new functions.https.HttpsError('failed-precondition', 'Not in bidding phase');
    }

    // Find player seat
    const playerEntry = Object.entries(game.players).find(
      ([, p]: [string, any]) => (p as any).uid === request.auth!.uid,
    );
    if (!playerEntry) {
      throw new functions.https.HttpsError('permission-denied', 'Not a player in this game');
    }

    const seatIndex = parseInt(playerEntry[0], 10);

    // Validate bid
    const validation = validateBid(game, seatIndex, bid);
    if (!validation.valid) {
      throw new functions.https.HttpsError('failed-precondition', validation.reason || 'Invalid bid');
    }

    // Update player's bid
    game.players[String(seatIndex)].bid = bid;

    // Check if bidding is complete
    const allBids = Object.values(game.players).map((p: any) => p.bid);
    const biddingComplete = allBids.every((b) => b !== null);

    if (biddingComplete) {
      const bidResult = resolveBidding(game);
      if (bidResult.resolved) {
        applyBiddingResult(game, bidResult as any);

        // If redeal, deal again
        if (bidResult.redeal) {
          dealRound(game);
        }

        // Bidding result may have changed turnIndex and status; refresh timer
        game.turnTimerStart = new Date();
      }
    } else {
      // Advance turn to next player who hasn't bid
      let nextTurn = (seatIndex + 1) % 4;
      while (game.players[String(nextTurn)].bid !== null) {
        nextTurn = (nextTurn + 1) % 4;
      }
      game.turnIndex = nextTurn;
      game.turnTimerStart = new Date();
    }

    const update = buildGameUpdate(originalGame, game);
    transaction.update(gameRef, update);
    return { success: true, status: game.status };
  });
});
