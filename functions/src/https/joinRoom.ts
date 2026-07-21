import * as functions from 'firebase-functions';
import { FieldValue } from 'firebase-admin/firestore';
import { db } from '../config/admin';
import { requireAppCheck } from '../utils/appCheck';
import { getOrCreateUserAgoraUid } from '../utils/agoraUid';
import { allocateParitySeat } from '../utils/roomPlayers';

/**
 * Server-side handler for joining a room by invite code.
 *
 * Running the join logic in a callable guarantees the player cannot be added
 * twice, even if the client retries or races with a leave operation. The
 * function checks both playerUids and the players array and treats either as
 * "already in the room".
 */
export const joinRoom = functions.https.onCall(async (request) => {
  if (!request.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  requireAppCheck(request);

  const { inviteCode, password, roomId } = request.data;
  const hasCode = inviteCode != null && typeof inviteCode === 'string' && inviteCode !== '';
  const hasRoomId = roomId != null && typeof roomId === 'string' && roomId !== '';
  if (!hasCode && !hasRoomId) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Missing inviteCode or roomId',
    );
  }

  const currentUid = request.auth.uid;

  let roomRef: FirebaseFirestore.DocumentReference;
  if (hasRoomId) {
    // Direct join by room id (used by room invitations for rooms that predate
    // invite codes). Status is enforced inside the transaction below.
    roomRef = db.collection('rooms').doc(roomId as string);
  } else {
    const normalizedCode = (inviteCode as string).toUpperCase();
    // Look up the room by invite code. We do this outside the transaction
    // because inviteCode is not the document id.
    const roomQuery = await db
      .collection('rooms')
      .where('inviteCode', '==', normalizedCode)
      .where('status', '==', 'waiting')
      .limit(1)
      .get();

    if (roomQuery.empty) {
      throw new functions.https.HttpsError('not-found', 'Room not found');
    }
    roomRef = roomQuery.docs[0].ref;
  }
  // Fetch caller profile once.
  const userDoc = await db.collection('users').doc(currentUid).get();
  const userData = userDoc.data();
  const displayName = userData?.displayName as string | undefined ?? 'Player';
  const avatarUrl = userData?.avatarUrl as string | undefined;

  // Ensure the user has a stable, unique Agora UID before adding them to the
  // room. This prevents hash collisions that can cause two users to share the
  // same Agora identity and kick each other from voice channels.
  const userAgoraUid = await getOrCreateUserAgoraUid(currentUid);

  return db.runTransaction(async (transaction) => {
    const doc = await transaction.get(roomRef);
    if (!doc.exists) {
      throw new functions.https.HttpsError('not-found', 'Room not found');
    }

    const data = doc.data()!;

    // Only waiting rooms can be joined (enforced here for the roomId path and
    // to close the race between the invite-code query and this transaction).
    if (data.status !== 'waiting') {
      throw new functions.https.HttpsError(
        'failed-precondition',
        'Room is not open for joining',
      );
    }

    // Kicked players are not allowed back in.
    const kickedPlayerUids = (data.kickedPlayerUids as string[] | undefined) ?? [];
    if (kickedPlayerUids.includes(currentUid)) {
      throw new functions.https.HttpsError(
        'permission-denied',
        'You have been removed from this room',
      );
    }

    // Private room password check (inside transaction to avoid races).
    const roomType = data.type as string | undefined;
    const roomPassword = data.password as string | undefined;
    if (
      roomType === 'private' &&
      roomPassword != null &&
      roomPassword !== '' &&
      roomPassword !== password
    ) {
      throw new functions.https.HttpsError('invalid-argument', 'Wrong password');
    }
    const players = Array.from(data.players as any[] ?? []);
    const playerUids = Array.from(data.playerUids as string[] ?? []);

    // Idempotent rejoin: already present in either list -> return room id.
    if (playerUids.includes(currentUid) || players.some((p: any) => p.uid === currentUid)) {
      return { roomId: roomRef.id };
    }

    if (players.length >= 4) {
      throw new functions.https.HttpsError('resource-exhausted', 'Room is full');
    }

    const teamA = Array.from(data.teamA as string[] ?? []);
    const teamB = Array.from(data.teamB as string[] ?? []);

    // Read the stream doc up-front if the room is streaming: Firestore
    // transactions require all reads before all writes.
    const streamId = data.streamId as string | undefined;
    const hasActiveStream =
      data.isStreaming === true && streamId != null && streamId.length > 0;
    let streamRef: FirebaseFirestore.DocumentReference | null = null;
    let streamDoc: FirebaseFirestore.DocumentSnapshot | null = null;
    if (hasActiveStream) {
      streamRef = db.collection('streams').doc(streamId!);
      streamDoc = await transaction.get(streamRef);
    }

    // Allocate a free parity seat for the assigned team (A: 0/2, B: 1/3) so
    // seat/team parity always matches the engine (teamOf(seat) = seat % 2).
    const allocation = allocateParitySeat(players);
    if (!allocation) {
      throw new functions.https.HttpsError('resource-exhausted', 'Room is full');
    }
    const { team, seatIndex } = allocation;
    if (team === 'A') {
      teamA.push(currentUid);
    } else {
      teamB.push(currentUid);
    }

    const voiceEnabled = data.voiceEnabled === true;
    const cameraEnabled = data.cameraEnabled === true;

    players.push({
      uid: currentUid,
      displayName,
      avatarUrl,
      team,
      seatIndex,
      isReady: false,
      isMicOn: voiceEnabled,
      isCameraOn: cameraEnabled,
      agoraUid: userAgoraUid,
      // NOTE: FieldValue.serverTimestamp() is not supported inside arrays —
      // it makes the whole update fail with an INTERNAL error on the client.
      joinedAt: new Date(),
    });
    // Keep players sorted by seatIndex.
    players.sort((a: any, b: any) => a.seatIndex - b.seatIndex);
    playerUids.push(currentUid);

    transaction.update(roomRef, {
      players,
      playerUids,
      teamA,
      teamB,
      currentPlayerCount: players.length,
      updatedAt: FieldValue.serverTimestamp(),
    });

    // Keep the stream doc's roster and viewer count in sync with the room,
    // otherwise the live card keeps showing the player count from stream
    // creation time (e.g. stuck at 1 while 2+ players are in).
    if (hasActiveStream && streamRef != null && streamDoc != null && streamDoc.exists) {
      const spectatorCount =
        (streamDoc.data()?.spectatorCount as number | undefined) ?? 0;
      transaction.update(streamRef, {
        players: players.map((p: any) => ({
          uid: p.uid,
          name: p.displayName ?? p.name ?? 'Player',
          avatarUrl: p.avatarUrl ?? '',
          agoraUid: p.agoraUid ?? 0,
          team: p.team ?? 'A',
          isCameraOn: p.isCameraOn === true,
          isMicOn: p.isMicOn !== false,
        })),
        playerUids,
        viewerCount: playerUids.length + spectatorCount,
      });
    }

    return { roomId: roomRef.id };
  });
});
