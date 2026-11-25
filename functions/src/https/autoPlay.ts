import { onSchedule } from 'firebase-functions/v2/scheduler';
import { db } from '../config/admin';
import { applyAutoPlayToGame } from '../utils/autoPlayEngine';

/**
 * Scheduled function that runs every minute to auto-play for players who have
 * timed out or disconnected, and to advance the brief trickEnd pause.
 *
 * Safety net only: the `checkTurnTimeout` callable and `advanceTrick` handle
 * the hot paths event-driven. Games are processed in parallel batches of 10
 * instead of sequentially so a large active-game set doesn't serialize.
 */
export const autoPlay = onSchedule(
  {
    schedule: 'every 1 minutes',
    timeZone: 'Asia/Riyadh',
  },
  async () => {
    const gamesSnap = await db
      .collection('games')
      .where('status', 'in', ['bidding', 'playing', 'trickEnd'])
      .limit(500)
      .get();

    const docs = gamesSnap.docs;
    const batchSize = 10;
    for (let i = 0; i < docs.length; i += batchSize) {
      const batch = docs.slice(i, i + batchSize);
      const now = Date.now();
      await Promise.all(
        batch.map(async (doc) => {
          try {
            await applyAutoPlayToGame(doc.ref, now);
          } catch (e) {
            console.error(`Auto-play failed for game ${doc.id}:`, e);
          }
        }),
      );
    }
  },
);
