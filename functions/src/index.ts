import * as functions from 'firebase-functions';
import { RtcTokenBuilder, RtcRole, RtmTokenBuilder } from 'agora-token';

// Admin functions
export {
  seedFirstSuperAdmin,
  suspendUser,
  banUser,
  resetUserCoins,
  forceLogoutUser,
  resolveReport,
  escalateReport,
  forceCloseRoom,
  transferRoomOwnership,
  adminEndStream,
  muteInStream,
  removeFromStream,
  warnHost,
  suspendHost,
  adminCreateTournament,
  adminUpdateTournament,
  adminCancelTournament,
  adminStartTournament,
  forceEndGame,
  rematchGame,
  adjustBalance,
  issueRefund,
  createAchievement,
  updateAchievement,
  deleteAchievement,
  assignAchievement,
  recalculateLeaderboard,
  resetLeaderboard,
  sendNotification,
  sendBroadcast,
  updateSettings,
  addAdmin,
  removeAdmin,
  updateAdminRole,
} from './admin';

// Game engine functions
export { startGame } from './https/startGame';
export { placeBid } from './https/placeBid';
export { claimBonuses } from './https/claimBonuses';
export { playCard } from './https/playCard';
export { dealNextRound } from './https/dealNextRound';
export { autoPlay } from './https/autoPlay';
export { rematch } from './https/rematch';
export { processGameEnd } from './triggers/processGameEnd';
export { sendRoomInviteNotification } from './triggers/sendRoomInviteNotification';
export { sendChatMessageNotification } from './triggers/sendChatMessageNotification';
export { sendGameStartingNotification } from './triggers/sendGameStartingNotification';
export { syncUserSearchKeywords } from './triggers/syncUserSearchKeywords';
export { syncReportSearchKeywords } from './triggers/syncReportSearchKeywords';
export { cleanStaleRooms } from './scheduler/cleanStaleRooms';
export { createTournament } from './https/createTournament';
export { startTournament } from './https/startTournament';
export { startStream } from './https/startStream';
export { endStream } from './https/endStream';
export { deleteAccount } from './https/deleteAccount';
export { reportUser } from './https/reportUser';
export { followUser } from './https/followUser';
export { unfollowUser } from './https/unfollowUser';

const APP_ID = functions.params.defineString('AGORA_APP_ID', {
  description: 'Agora App ID used to generate RTC/RTM tokens.',
});

const APP_CERTIFICATE = functions.params.defineSecret('AGORA_APP_CERTIFICATE');

const TOKEN_EXPIRATION_SECONDS = 3600;

function getExpirationTimestamp(): number {
  return Math.floor(Date.now() / 1000) + TOKEN_EXPIRATION_SECONDS;
}

/**
 * Generates an Agora RTC token for a given channel.
 */
export const generateAgoraToken = functions.https.onCall(
  {
    secrets: [APP_CERTIFICATE],
    cors: true,
  },
  async (request) => {
    if (!request.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'Must be authenticated to generate an Agora token.',
      );
    }

    const { channelName, role = 'publisher' } = request.data as {
      channelName?: string;
      role?: 'publisher' | 'subscriber';
    };

    if (!channelName || typeof channelName !== 'string') {
      throw new functions.https.HttpsError('invalid-argument', 'Missing or invalid channelName.');
    }

    const appId = APP_ID.value();
    const appCertificate = APP_CERTIFICATE.value();
    const uid = (request.data.uid as number) || 0;
    const rtcRole = role === 'publisher' ? RtcRole.PUBLISHER : RtcRole.SUBSCRIBER;

    const expire = getExpirationTimestamp();
    const token = RtcTokenBuilder.buildTokenWithUid(
      appId,
      appCertificate,
      channelName,
      uid,
      rtcRole,
      expire,
      expire,
    );

    return {
      token,
      uid,
      expiresAt: getExpirationTimestamp(),
    };
  },
);

/**
 * Generates an Agora RTM token for chat/signaling.
 */
export const generateAgoraRtmToken = functions.https.onCall(
  {
    secrets: [APP_CERTIFICATE],
    cors: true,
  },
  async (request) => {
    if (!request.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'Must be authenticated to generate an Agora RTM token.',
      );
    }

    const { account } = request.data as { account?: string };
    const userAccount = account ?? request.auth.uid;

    const appId = APP_ID.value();
    const appCertificate = APP_CERTIFICATE.value();

    const token = RtmTokenBuilder.buildToken(
      appId,
      appCertificate,
      userAccount,
      TOKEN_EXPIRATION_SECONDS,
    );

    return {
      token,
      account: userAccount,
      expiresAt: getExpirationTimestamp(),
    };
  },
);
