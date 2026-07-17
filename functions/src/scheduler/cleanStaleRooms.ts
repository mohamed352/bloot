import { onSchedule } from 'firebase-functions/v2/scheduler';
import { FieldValue } from 'firebase-admin/firestore';
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
    const streamIdsToEnd = new Set<string>();

    const collectRoomDeletion = (
      doc: FirebaseFirestore.QueryDocumentSnapshot<FirebaseFirestore.DocumentData>,
    ) => {
      batch.delete(doc.ref);
      count++;
      const streamId = doc.data().streamId as string | undefined;
      if (streamId != null && streamId.length > 0) {
        streamIdsToEnd.add(streamId);
      }
    };

    for (const doc of staleQuery.docs) {
      collectRoomDeletion(doc);
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
        collectRoomDeletion(doc);
      }
    }

    // End any streams tied to deleted rooms so they don't remain live.
    for (const streamId of streamIdsToEnd) {
      const streamRef = db.collection('streams').doc(streamId);
      batch.update(streamRef, {
        status: 'ended',
        endedAt: FieldValue.serverTimestamp(),
      });
    }

    // Sweep orphaned live streams: the room is gone/finished/empty, the host
    // left (e.g. app killed without leaveGame), or the room no longer points
    // at this stream. This is the server-side backstop for "live still
    // appears after the creator left".
    const liveStreams = await db
      .collection('streams')
      .where('status', '==', 'live')
      .limit(200)
      .get();

    let endedLiveStreams = 0;
    for (const streamDoc of liveStreams.docs) {
      if (streamIdsToEnd.has(streamDoc.id)) continue;
      const stream = streamDoc.data();
      const roomId = stream.roomId as string | undefined;
      const hostUid = stream.hostUid as string | undefined;

      let shouldEnd = false;
      let roomRef: FirebaseFirestore.DocumentReference | undefined;

      if (roomId == null || roomId.length === 0) {
        shouldEnd = true;
      } else {
        const roomDoc = await db.collection('rooms').doc(roomId).get();
        if (!roomDoc.exists) {
          shouldEnd = true;
        } else {
          const room = roomDoc.data()!;
          const playerUids = (room.playerUids as string[] | undefined) ?? [];
          shouldEnd =
            room.status === 'finished' ||
            playerUids.length === 0 ||
            (hostUid != null && !playerUids.includes(hostUid)) ||
            room.isStreaming !== true ||
            room.streamId !== streamDoc.id;
          if (shouldEnd && room.isStreaming === true) {
            roomRef = roomDoc.ref;
          }
        }
      }

      if (shouldEnd) {
        batch.update(streamDoc.ref, {
          status: 'ended',
          endedAt: FieldValue.serverTimestamp(),
        });
        if (roomRef != null) {
          batch.update(roomRef, {
            isStreaming: false,
            streamId: null,
            updatedAt: FieldValue.serverTimestamp(),
          });
        }
        endedLiveStreams++;
      }
    }

    if (count > 0 || endedLiveStreams > 0) {
      await batch.commit();
    }

    console.log(
      `cleanStaleRooms: deleted ${count} rooms, ended ${streamIdsToEnd.size} streams, swept ${endedLiveStreams} orphaned live streams`,
    );
  },
);
