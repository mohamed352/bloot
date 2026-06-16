import { onSchedule } from 'firebase-functions/v2/scheduler';
import { db } from '../config/admin';

export const cleanStaleRooms = onSchedule(
  { schedule: 'every 60 minutes', timeZone: 'UTC' },
  async () => {
    const now = new Date();
    const twoHoursAgo = new Date(now.getTime() - 2 * 60 * 60 * 1000);

    // Delete stale waiting/finished rooms
    const staleQuery = await db
      .collection('rooms')
      .where('status', 'in', ['waiting', 'finished'])
      .where('updatedAt', '<', twoHoursAgo)
      .limit(500)
      .get();

    const batch = db.batch();
    let count = 0;

    for (const doc of staleQuery.docs) {
      batch.delete(doc.ref);
      count++;
    }

    // Also delete any rooms with no players regardless of timestamp
    const emptyQuery = await db
      .collection('rooms')
      .where('playerUids', '==', [])
      .limit(500)
      .get();

    for (const doc of emptyQuery.docs) {
      // Avoid double-deleting
      if (!staleQuery.docs.find((d) => d.id === doc.id)) {
        batch.delete(doc.ref);
        count++;
      }
    }

    if (count > 0) {
      await batch.commit();
    }

    console.log(`cleanStaleRooms: deleted ${count} rooms`);
  },
);
