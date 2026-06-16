import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

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

    // Look up recipient's FCM token
    const userDoc = await admin.firestore().collection('users').doc(recipientUid).get();
    const userData = userDoc.data();
    const fcmToken = userData?.fcmToken as string | undefined;

    if (!fcmToken) {
      functions.logger.info(`No FCM token for user ${recipientUid}`);
      return;
    }

    const payload: admin.messaging.Message = {
      token: fcmToken,
      notification: {
        title: `${inviterName ?? 'Someone'} invited you to play Baloot`,
        body: roomName ? `Room: ${roomName}` : 'Tap to join the game',
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
              title: `${inviterName ?? 'Someone'} invited you to play Baloot`,
              body: roomName ? `Room: ${roomName}` : 'Tap to join the game',
            },
            badge: 1,
            sound: 'default',
          },
        },
      },
    };

    try {
      await admin.messaging().send(payload);
      functions.logger.info(`Sent room invite notification to ${recipientUid}`);
    } catch (error) {
      functions.logger.error(`Failed to send FCM to ${recipientUid}`, error);
    }
  });
