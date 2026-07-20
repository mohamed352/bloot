import * as functions from 'firebase-functions';
import { FieldValue } from 'firebase-admin/firestore';
import { db } from '../config/admin';
import { requireAppCheck } from '../utils/appCheck';

/**
 * Sends a room invitation to a specific user.
 *
 * Writes a notification document to the friend's notifications sub-collection.
 * The `sendRoomInviteNotification` Firestore trigger picks up that document and
 * delivers an FCM push notification.
 *
 * Only the room creator can send invites, and the room must be in `waiting`
 * status with available seats.
 */
export const sendRoomInvite = functions.https.onCall(async (request) => {
  if (!request.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  requireAppCheck(request);

  const { roomId, friendUid } = request.data as {
    roomId?: string;
    friendUid?: string;
  };

  if (!roomId || typeof roomId !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing roomId');
  }
  if (!friendUid || typeof friendUid !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing friendUid');
  }

  const currentUid = request.auth.uid;
  if (currentUid === friendUid) {
    throw new functions.https.HttpsError('invalid-argument', 'Cannot invite yourself');
  }

  // Fetch the room document.
  const roomDoc = await db.collection('rooms').doc(roomId).get();
  if (!roomDoc.exists) {
    throw new functions.https.HttpsError('not-found', 'Room not found');
  }

  const roomData = roomDoc.data()!;

  // Verify caller is the room creator.
  if (roomData.creatorUid !== currentUid) {
    throw new functions.https.HttpsError('permission-denied', 'Only the host can send invites');
  }

  // Verify room is still joinable.
  if (roomData.status !== 'waiting') {
    throw new functions.https.HttpsError('failed-precondition', 'Room is no longer accepting players');
  }

  const playerUids = Array.from(roomData.playerUids as string[] ?? []);
  if (playerUids.includes(friendUid)) {
    throw new functions.https.HttpsError('failed-precondition', 'User is already in the room');
  }

  if ((roomData.currentPlayerCount ?? 0) >= 4) {
    throw new functions.https.HttpsError('resource-exhausted', 'Room is full');
  }

  // Fetch inviter's display name for the notification.
  const inviterDoc = await db.collection('users').doc(currentUid).get();
  const inviterName = inviterDoc.data()?.displayName as string | undefined ?? 'Someone';

  // Write the notification document. The Firestore trigger
  // `sendRoomInviteNotification` will detect this and send the FCM.
  const notifRef = db
    .collection('users')
    .doc(friendUid)
    .collection('notifications')
    .doc();

  const roomName = (roomData.name as string | undefined) ?? '';

  await notifRef.set({
    type: 'roomInvite',
    title: 'Room Invitation',
    titleAr: 'دعوة غرفة',
    body: '$inviterName invited you to play in "$roomName"',
    bodyAr: 'دعاك $inviterName للعب في "$roomName"',
    roomId,
    roomName,
    inviterName,
    inviterUid: currentUid,
    createdAt: FieldValue.serverTimestamp(),
    read: false,
  });

  return { success: true };
});
