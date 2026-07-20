import * as functions from 'firebase-functions';
import { db } from '../config/admin';

/**
 * Propagates a user's avatarUrl change to the denormalized copies that are
 * snapshotted at join/create time (room players, stream players/host avatar,
 * per-user conversation metadata). Without this, a changed profile picture
 * only updated users/{uid} and kept showing the old image everywhere else.
 */
export const syncUserAvatar = functions.firestore
  .onDocumentWritten('users/{uid}', async (event) => {
    const before = event.data?.before?.data();
    const after = event.data?.after?.data();
    if (!after) return; // document deleted

    const newAvatar = (after.avatarUrl as string | undefined) ?? '';
    const oldAvatar = (before?.avatarUrl as string | undefined) ?? '';
    if (newAvatar === oldAvatar) return;

    const uid = event.params.uid;
    const writes: Promise<unknown>[] = [];

    // 1) Active rooms (waiting/playing) containing the user.
    const roomsSnap = await db
      .collection('rooms')
      .where('playerUids', 'array-contains', uid)
      .where('status', 'in', ['waiting', 'playing'])
      .limit(50)
      .get();

    for (const roomDoc of roomsSnap.docs) {
      const players = Array.from(
        (roomDoc.data().players as Record<string, unknown>[] | undefined) ?? [],
      );
      let changed = false;
      const updated = players.map((p) => {
        if (p.uid === uid) {
          changed = true;
          return { ...p, avatarUrl: newAvatar };
        }
        return p;
      });
      if (changed) {
        writes.push(roomDoc.ref.update({ players: updated }));
      }
    }

    // 2) Live streams containing the user (roster + host avatar).
    const streamsSnap = await db
      .collection('streams')
      .where('playerUids', 'array-contains', uid)
      .where('status', '==', 'live')
      .limit(50)
      .get();

    for (const streamDoc of streamsSnap.docs) {
      const data = streamDoc.data();
      const players = Array.from(
        (data.players as Record<string, unknown>[] | undefined) ?? [],
      );
      let changed = false;
      const updated = players.map((p) => {
        if (p.uid === uid) {
          changed = true;
          return { ...p, avatarUrl: newAvatar };
        }
        return p;
      });
      const update: Record<string, unknown> = {};
      if (changed) update.players = updated;
      if (data.hostUid === uid) update.hostAvatar = newAvatar;
      if (Object.keys(update).length > 0) {
        writes.push(streamDoc.ref.update(update));
      }
    }

    // 3) Conversation list metadata visible to the OTHER participant.
    const convSnap = await db
      .collection('conversations')
      .where('participantUids', 'array-contains', uid)
      .limit(100)
      .get();

    for (const convDoc of convSnap.docs) {
      const participantUids =
        (convDoc.data().participantUids as string[] | undefined) ?? [];
      for (const otherUid of participantUids) {
        if (otherUid === uid) continue;
        writes.push(
          db
            .collection('users')
            .doc(otherUid)
            .collection('conversations')
            .doc(convDoc.id)
            .set({ avatarUrl: newAvatar }, { merge: true }),
        );
      }
    }

    if (writes.length > 0) {
      await Promise.all(writes);
      functions.logger.info(
        `syncUserAvatar: propagated avatar for ${uid} to ${writes.length} docs`,
      );
    }
  });
