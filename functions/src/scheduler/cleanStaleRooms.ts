import { onSchedule } from 'firebase-functions/v2/scheduler';
import { FieldValue } from 'firebase-admin/firestore';
import { db } from '../config/admin';
import { isPlayingRoomAbandoned } from '../utils/streaming';

/** How old the host's stream heartbeat may be before the stream is
 * considered dead (clients beat every minute). */
const HEARTBEAT_STALE_MS = 5 * 60 * 1000;

export const cleanStaleRooms = onSchedule(
  { schedule: 'every 10 minutes', timeZone: 'UTC' },
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

    // Sweep abandoned "playing" rooms: the game is gone or has not been
    // written to for 30 minutes, meaning every client disappeared without
    // calling leaveGame (app killed, crash, no network). End the stream and
    // finish the room so it leaves the live list immediately; the
    // stale-deletion pass above removes the room doc 2h later.
    const playingQuery = await db
      .collection('rooms')
      .where('status', '==', 'playing')
      .limit(200)
      .get();

    let abandonedRooms = 0;
    for (const doc of playingQuery.docs) {
      const room = doc.data();
      const gameId = room.gameId as string | undefined;
      let gameData: { updatedAt?: unknown } | null = null;
      if (gameId != null && gameId.length > 0) {
        const gameDoc = await db.collection('games').doc(gameId).get();
        gameData = gameDoc.exists
          ? (gameDoc.data() as { updatedAt?: unknown })
          : null;
      }
      if (!isPlayingRoomAbandoned(room, gameData, now)) continue;

      const streamId = room.streamId as string | undefined;
      if (streamId != null && streamId.length > 0) {
        streamIdsToEnd.add(streamId);
      }
      batch.update(doc.ref, {
        status: 'finished',
        isStreaming: false,
        streamId: null,
        updatedAt: FieldValue.serverTimestamp(),
      });
      abandonedRooms++;
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

          // Host heartbeat: streaming clients touch lastHeartbeatAt every
          // minute. A stale heartbeat means the host's app died without
          // leaveGame (kill/crash/offline) — end the stream even if the
          // room doc still looks consistent. Only enforced once the field
          // exists so older clients are unaffected.
          if (!shouldEnd) {
            const lastBeat = stream.lastHeartbeatAt;
            let beatMillis: number | null = null;
            if (lastBeat instanceof Date) {
              beatMillis = lastBeat.getTime();
            } else if (
              lastBeat != null &&
              typeof (lastBeat as { toMillis?: unknown }).toMillis === 'function'
            ) {
              beatMillis = (lastBeat as { toMillis: () => number }).toMillis();
            }
            if (
              beatMillis != null &&
              now.getTime() - beatMillis > HEARTBEAT_STALE_MS
            ) {
              shouldEnd = true;
              if (room.isStreaming === true) {
                roomRef = roomDoc.ref;
              }
            }
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

    if (count > 0 || endedLiveStreams > 0 || abandonedRooms > 0) {
      await batch.commit();
    }

    console.log(
      `cleanStaleRooms: deleted ${count} rooms, ended ${streamIdsToEnd.size} streams, swept ${endedLiveStreams} orphaned live streams, finished ${abandonedRooms} abandoned playing rooms`,
    );
  },
);
