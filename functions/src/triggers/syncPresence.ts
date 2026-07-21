import { onValueWritten } from 'firebase-functions/v2/database';
import { FieldValue } from 'firebase-admin/firestore';
import { db } from '../config/admin';

/**
 * Mirrors the RTDB `presence/{uid}` node (written by clients, and by the
 * server via onDisconnect when a client vanishes) onto `users/{uid}` so the
 * app can show a truthful online/offline status from Firestore.
 */
export const syncPresence = onValueWritten(
  '/presence/{uid}',
  async (event) => {
    const uid = event.params.uid;
    const data = event.data.after.val() as {
      online?: boolean;
      lastSeen?: number;
    } | null;

    await db.collection('users').doc(uid).set(
      {
        isOnline: data?.online === true,
        lastSeen:
          typeof data?.lastSeen === 'number'
            ? new Date(data.lastSeen)
            : FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
  },
);
