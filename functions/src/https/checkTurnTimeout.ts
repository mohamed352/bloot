import * as functions from 'firebase-functions';
import { db } from '../config/admin';
import { requireAppCheck } from '../utils/appCheck';
import { applyAutoPlayToGame } from '../utils/autoPlayEngine';

/**
 * Event-driven AFK/timeout enforcement. A participating client calls this
 * when its local view shows the current turn has exceeded turnTimeLimit,
 * instead of waiting up to a minute for the autoPlay cron. The helper's
 * transaction re-checks the fresh document, so duplicate/concurrent calls
 * (and races with the cron) are harmless.
 */
export const checkTurnTimeout = functions.https.onCall(
  { minInstances: 0 },
  async (request) => {
    if (!request.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'Must be authenticated',
      );
    }

    requireAppCheck(request);

    const { gameId } = request.data;
    if (!gameId || typeof gameId !== 'string') {
      throw new functions.https.HttpsError('invalid-argument', 'Missing gameId');
    }

    const gameRef = db.collection('games').doc(gameId);
    const gameDoc = await gameRef.get();
    if (!gameDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Game not found');
    }

    const players = gameDoc.data()?.players;
    const isParticipant =
      players &&
      typeof players === 'object' &&
      Object.values(players).some(
        (p) =>
          p &&
          typeof p === 'object' &&
          (p as Record<string, unknown>).uid === request.auth!.uid,
      );
    if (!isParticipant) {
      throw new functions.https.HttpsError(
        'permission-denied',
        'You are not a player in this game.',
      );
    }

    const acted = await applyAutoPlayToGame(gameRef, Date.now());
    return { acted };
  },
);
