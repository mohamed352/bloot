import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

/**
 * Sends an FCM push notification when a room's game starts.
 */
export const sendGameStartingNotification = functions.firestore
  .onDocumentUpdated('rooms/{roomId}', async (event) => {
    const before = event.data?.before?.data();
    const after = event.data?.after?.data();
    if (!before || !after) return;

    // Only trigger when status changes from 'waiting' to 'playing'
    if (before.status !== 'waiting' || after.status !== 'playing') return;

    const roomId = event.params.roomId;
    const gameId = after.gameId as string | undefined;
    const roomName = after.name as string | undefined;
    const playerUids = after.playerUids as string[] | undefined;

    if (!playerUids || playerUids.length === 0) return;

    for (const playerUid of playerUids) {
      const userDoc = await admin.firestore().collection('users').doc(playerUid).get();
      const userData = userDoc.data();
      if (!userData) continue;

      const settings = userData.settings as Record<string, any> | undefined;
      if (settings?.notifications?.gameStarts === false) continue;

      const fcmToken = userData.fcmToken as string | undefined;
      if (!fcmToken) {
        functions.logger.info(`No FCM token for user ${playerUid}`);
        continue;
      }

      const locale = (userData.locale as string | undefined) ?? 'en';
      const isArabic = locale.startsWith('ar');
      const title = isArabic ? 'اللعبة تبدأ!' : 'Game Starting!';
      const body = roomName
        ? isArabic
          ? `لعبتك في ${roomName} ستبدأ الآن.`
          : `Your game in ${roomName} is starting now.`
        : isArabic
          ? 'لعبتك في البلوت ستبدأ الآن.'
          : 'Your Baloot game is starting now.';

      const payload: admin.messaging.Message = {
        token: fcmToken,
        notification: {
          title,
          body,
        },
        data: {
          type: 'gameStarting',
          roomId,
          gameId: gameId ?? '',
        },
        android: {
          notification: {
            channelId: 'game_starts',
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

      try {
        await admin.messaging().send(payload);
        functions.logger.info(`Sent game starting notification to ${playerUid}`);
      } catch (error) {
        functions.logger.error(`Failed to send FCM to ${playerUid}`, error);
      }
    }
  });
