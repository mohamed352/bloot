import * as functions from 'firebase-functions';
import { db } from '../config/admin';
import { requireAppCheck } from '../utils/appCheck';
import { GameDocument } from '../engine/gameAdapter';
import { buildGameUpdate, deepCloneGame } from '../utils/gameUpdate';

function toMillis(value: unknown): number {
  return (
    (value as any)?.toMillis?.() ||
    (value as Date)?.getTime?.() ||
    0
  );
}

/**
 * Advances a game paused on a completed trick (trickEnd) to the next trick.
 *
 * Previously this transition only happened when the next player tapped a card
 * or when the 1-minute autoPlay cron fired, which stalled games for up to a
 * minute. The client of the next-to-play seat calls this when its trick-end
 * timer elapses; the transaction guard below makes concurrent/duplicate calls
 * harmless, and the cron remains as a safety net.
 */
export const advanceTrick = functions.https.onCall({ minInstances: 0 }, async (request) => {
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

    // Only players in this game may advance it.
    const isPlayer = Object.values(game.players ?? {}).some(
      (p) => (p as any)?.uid === request.auth!.uid,
    );
    if (!isPlayer) {
      throw new functions.https.HttpsError('permission-denied', 'Not a player in this game');
    }

    // Nothing to do if someone else already advanced it.
    if (game.status !== 'trickEnd') {
      return { advanced: false, reason: 'not_in_trick_end' };
    }

    // Respect the trick-end pause so the UI has time to show the result.
    const trickEndStart = toMillis(game.turnTimerStart);
    const trickEndDelay = game.trickEndDelayMs || 2000;
    const elapsed = Date.now() - trickEndStart;
    if (elapsed < trickEndDelay) {
      return { advanced: false, reason: 'too_early', retryAfterMs: trickEndDelay - elapsed };
    }

    const originalGame = deepCloneGame(game);
    game.status = 'playing';
    game.turnTimerStart = new Date();
    const update = buildGameUpdate(originalGame, game);
    transaction.update(gameRef, update);

    return { advanced: true };
  });
});
