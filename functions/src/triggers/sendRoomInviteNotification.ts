import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { sendFcmToUserDevices } from '../utils/messaging';

/**
 * Sends an FCM push notification when a room invite notification doc is created.
 */
export const sendRoomInviteNotification = functions.firestore
  .onDocumentCreated('users/{uid}/notifications/{notificationId}', async (event) => {
    const data = event.data?.data();
    if (!data) return;

    if (data.type !== 'roomInvite') return;

    const recipientUid = event.params.uid;
    const roomId = data.roomId as string | undefined;
    const roomName = data.roomName as string | undefined;
    const inviterName = data.inviterName as string | undefined;

    if (!roomId) return;

    // Look up recipient (tokens are read from legacy field + fcmTokens
    // subcollection so multi-device users get the invite everywhere).
    const userDoc = await admin.firestore().collection('users').doc(recipientUid).get();
    const userData = userDoc.data();

    const title = `${inviterName ?? 'Someone'} invited you to play Baloot`;
    const body = roomName ? `Room: ${roomName}` : 'Tap to join the game';

    const payload: Omit<admin.messaging.MulticastMessage, 'tokens'> = {
      notification: {
        title,
        body,
      },
      data: {
        type: 'roomInvite',
        roomId: roomId,
      },
      android: {
        notification: {
          channelId: 'room_invites',
          priority: 'high',
        },
      },
      apns: {
        payload: {
          aps: {
            alert: {
              title,
              body,
            },
            badge: 1,
            sound: 'default',
          },
        },
      },
    };

    const result = await sendFcmToUserDevices(recipientUid, payload, userData);
    if (result.success) {
      functions.logger.info(`Sent room invite notification to ${recipientUid}`);
    } else {
      functions.logger.error(`Failed to send FCM to ${recipientUid}: ${result.error}`);
    }
  });
