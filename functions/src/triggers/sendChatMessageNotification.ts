import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

/**
 * Sends an FCM push notification when a new chat message is created.
 */
export const sendChatMessageNotification = functions.firestore
  .onDocumentCreated('conversations/{conversationId}/messages/{messageId}', async (event) => {
    const data = event.data?.data();
    if (!data) return;

    const senderUid = data.senderUid as string | undefined;
    const senderName = data.senderName as string | undefined;
    const text = data.text as string | undefined;
    const conversationId = event.params.conversationId;

    if (!senderUid || !conversationId) return;

    // Get conversation to find recipients
    const conversationDoc = await admin.firestore()
      .collection('conversations')
      .doc(conversationId)
      .get();

    const conversationData = conversationDoc.data();
    if (!conversationData) return;

    const participantIds = conversationData.participantIds as string[] | undefined;
    if (!participantIds || participantIds.length === 0) return;

    // Send to all participants except sender
    const recipientUids = participantIds.filter((uid) => uid !== senderUid);

    for (const recipientUid of recipientUids) {
      // Check if user has muted this conversation or disabled message notifications
      const userDoc = await admin.firestore().collection('users').doc(recipientUid).get();
      const userData = userDoc.data();
      if (!userData) continue;

      const settings = userData.settings as Record<string, any> | undefined;
      if (settings?.notifications?.messages === false) continue;

      const fcmToken = userData.fcmToken as string | undefined;
      if (!fcmToken) {
        functions.logger.info(`No FCM token for user ${recipientUid}`);
        continue;
      }

      const payload: admin.messaging.Message = {
        token: fcmToken,
        notification: {
          title: senderName ?? 'New message',
          body: text ?? 'You have a new message',
        },
        data: {
          type: 'chatMessage',
          conversationId,
          senderName: senderName ?? '',
        },
        android: {
          notification: {
            channelId: 'chat_messages',
            priority: 'high',
          },
        },
        apns: {
          payload: {
            aps: {
              alert: {
                title: senderName ?? 'New message',
                body: text ?? 'You have a new message',
              },
              badge: 1,
              sound: 'default',
            },
          },
        },
      };

      try {
        await admin.messaging().send(payload);
        functions.logger.info(`Sent chat notification to ${recipientUid}`);
      } catch (error) {
        functions.logger.error(`Failed to send FCM to ${recipientUid}`, error);
      }
    }
  });
