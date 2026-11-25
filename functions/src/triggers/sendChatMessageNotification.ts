import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { sendFcmToUserDevices } from '../utils/messaging';

// Best-effort per-sender throttle: skip the notification when the same
// sender already triggered one for the same conversation within this
// window. Module-level so it persists across warm invocations of the same
// instance (no extra Firestore reads/writes per message).
const THROTTLE_WINDOW_MS = 5000;
const lastNotificationAt = new Map<string, number>();

function isThrottled(senderUid: string, conversationId: string): boolean {
  const key = `${senderUid}:${conversationId}`;
  const now = Date.now();
  const last = lastNotificationAt.get(key);
  if (last !== undefined && now - last < THROTTLE_WINDOW_MS) return true;
  lastNotificationAt.set(key, now);
  // Bound the map: entries older than the window are useless.
  if (lastNotificationAt.size > 1000) {
    for (const [k, ts] of lastNotificationAt) {
      if (now - ts >= THROTTLE_WINDOW_MS) lastNotificationAt.delete(k);
    }
  }
  return false;
}

/**
 * Sends an FCM push notification when a new chat message is created.
 */
export const sendChatMessageNotification = functions.firestore
  .onDocumentCreated('conversations/{conversationId}/messages/{messageId}', async (event) => {
    const data = event.data?.data();
    if (!data) return;

    // The client writes messages with `senderId`; the conversation doc stores
    // `participantUids`. Older code read senderUid/participantIds and silently
    // early-returned, so no notifications were ever sent.
    const senderUid = data.senderId as string | undefined;
    const text = data.text as string | undefined;
    const conversationId = event.params.conversationId;

    if (!senderUid || !conversationId) return;

    if (isThrottled(senderUid, conversationId)) {
      functions.logger.info(
        `Throttled chat notification for ${senderUid} in ${conversationId}`,
      );
      return;
    }

    // Resolve the sender's display name for the notification title.
    const senderDoc = await admin.firestore().collection('users').doc(senderUid).get();
    const senderName = senderDoc.data()?.displayName as string | undefined;

    // Get conversation to find recipients
    const conversationDoc = await admin.firestore()
      .collection('conversations')
      .doc(conversationId)
      .get();

    const conversationData = conversationDoc.data();
    if (!conversationData) return;

    const participantIds = conversationData.participantUids as string[] | undefined;
    if (!participantIds || participantIds.length === 0) return;

    // Send to all participants except sender
    const recipientUids = participantIds.filter((uid) => uid !== senderUid);

    await Promise.all(
      recipientUids.map(async (recipientUid) => {
        // Check if user has muted this conversation or disabled message notifications
        const userDoc = await admin.firestore().collection('users').doc(recipientUid).get();
        const userData = userDoc.data();
        if (!userData) return;

        const settings = userData.settings as Record<string, any> | undefined;
        if (settings?.notifications?.messages === false) return;

        const fcmTitle = senderName ?? 'New message';
        const fcmBody = text ?? 'You have a new message';

        const payload: Omit<admin.messaging.MulticastMessage, 'tokens'> = {
          notification: {
            title: fcmTitle,
            body: fcmBody,
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
                  title: fcmTitle,
                  body: fcmBody,
                },
                badge: 1,
                sound: 'default',
              },
            },
          },
        };

        const result = await sendFcmToUserDevices(recipientUid, payload, userData);
        if (result.success) {
          functions.logger.info(`Sent chat notification to ${recipientUid}`);
        } else {
          functions.logger.error(`Failed to send FCM to ${recipientUid}: ${result.error}`);
        }
      }),
    );
  });
