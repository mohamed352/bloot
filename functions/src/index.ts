import * as functions from 'firebase-functions';
import { RtcTokenBuilder, RtcRole, RtmTokenBuilder } from 'agora-token';
import { db } from './config/admin';
import { requireAppCheck } from './utils/appCheck';

// Admin functions
export {
  seedFirstSuperAdmin,
  suspendUser,
  banUser,
  resetUserCoins,
  forceLogoutUser,
  resolveReport,
  dismissReport,
  escalateReport,
  forceCloseRoom,
  transferRoomOwnership,
  adminEndStream,
  muteInStream,
  removeFromStream,
  warnHost,
  suspendHost,
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
export { createRoomWithBots } from './https/botRoom';
export { processGameEnd } from './triggers/processGameEnd';
export { botAutoPlay } from './triggers/botAutoPlay';
export { sendRoomInviteNotification } from './triggers/sendRoomInviteNotification';
export { sendChatMessageNotification } from './triggers/sendChatMessageNotification';
export { sendGameStartingNotification } from './triggers/sendGameStartingNotification';
export { updateViewerCount } from './triggers/updateViewerCount';
export { syncUserSearchKeywords } from './triggers/syncUserSearchKeywords';
export { syncReportSearchKeywords } from './triggers/syncReportSearchKeywords';
export { cleanStaleRooms } from './scheduler/cleanStaleRooms';
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

interface GenerateTokenData {
  channelName?: string;
  uid?: number | string;
  role?: 'publisher' | 'subscriber';
  roomId?: string;
  gameId?: string;
  streamId?: string;
}

/**
 * Verifies that the authenticated caller is allowed to join the requested
 * Agora channel. Channels are always associated with a room, game, or stream.
 */
async function verifyChannelAccess(
  authUid: string,
  data: GenerateTokenData,
): Promise<void> {
  const { channelName, roomId, gameId, streamId } = data;

  // Direct lookup when the caller provides the associated resource id.
  if (roomId && typeof roomId === 'string') {
    const roomDoc = await db.collection('rooms').doc(roomId).get();
    if (roomDoc.exists && isRoomParticipant(authUid, roomDoc.data()!)) {
      return;
    }
  }

  if (gameId && typeof gameId === 'string') {
    const gameDoc = await db.collection('games').doc(gameId).get();
    if (gameDoc.exists && isGameParticipant(authUid, gameDoc.data()!)) {
      return;
    }
  }

  if (streamId && typeof streamId === 'string') {
    const streamDoc = await db.collection('streams').doc(streamId).get();
    if (streamDoc.exists && isStreamParticipant(authUid, streamDoc.data()!)) {
      return;
    }
  }

  // Fallback for legacy clients that only send channelName.
  if (!channelName || typeof channelName !== 'string') {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Missing channel membership context. Provide roomId, gameId, streamId, or channelName.',
    );
  }

  // Default channel naming convention: room_<roomId>.
  let derivedRoomId: string | undefined;
  if (channelName.startsWith('room_')) {
    derivedRoomId = channelName.substring(5);
  }

  const [roomById, roomsByName, gamesByName, streamsByName] = await Promise.all([
    derivedRoomId ? db.collection('rooms').doc(derivedRoomId).get() : Promise.resolve(null),
    db.collection('rooms').where('agoraChannelName', '==', channelName).limit(1).get(),
    db.collection('games').where('agoraChannelName', '==', channelName).limit(1).get(),
    db.collection('streams').where('agoraChannelName', '==', channelName).limit(1).get(),
  ]);

  if (roomById?.exists && isRoomParticipant(authUid, roomById.data()!)) {
    return;
  }

  const roomDoc = roomsByName.docs[0];
  if (roomDoc && isRoomParticipant(authUid, roomDoc.data())) {
    return;
  }

  const gameDoc = gamesByName.docs[0];
  if (gameDoc && isGameParticipant(authUid, gameDoc.data())) {
    return;
  }

  const streamDoc = streamsByName.docs[0];
  if (streamDoc && isStreamParticipant(authUid, streamDoc.data())) {
    return;
  }

  throw new functions.https.HttpsError(
    'permission-denied',
    'You are not a participant in this channel.',
  );
}

function isRoomParticipant(authUid: string, data: Record<string, unknown>): boolean {
  if (data.creatorUid === authUid) return true;
  const playerUids = data.playerUids;
  if (Array.isArray(playerUids) && playerUids.includes(authUid)) return true;
  const players = data.players;
  if (Array.isArray(players)) {
    return players.some((p) => p && typeof p === 'object' && (p as Record<string, unknown>).uid === authUid);
  }
  return false;
}

function isGameParticipant(authUid: string, data: Record<string, unknown>): boolean {
  const playerUids = data.playerUids;
  if (Array.isArray(playerUids) && playerUids.includes(authUid)) return true;
  const players = data.players;
  if (players && typeof players === 'object') {
    return Object.values(players).some(
      (p) => p && typeof p === 'object' && (p as Record<string, unknown>).uid === authUid,
    );
  }
  return false;
}

function isStreamParticipant(authUid: string, data: Record<string, unknown>): boolean {
  if (data.hostUid === authUid) return true;
  const players = data.players;
  if (Array.isArray(players)) {
    return players.some((p) => p && typeof p === 'object' && (p as Record<string, unknown>).uid === authUid);
  }
  return false;
}

function parseUid(raw: number | string | undefined): number {
  if (raw === undefined || raw === null) return 0;
  if (typeof raw === 'number') {
    if (!Number.isFinite(raw) || raw < 0 || raw > 4294967295) {
      throw new functions.https.HttpsError('invalid-argument', 'Invalid uid value.');
    }
    return Math.floor(raw);
  }
  const parsed = Number(raw);
  if (!Number.isFinite(parsed) || parsed < 0 || parsed > 4294967295) {
    throw new functions.https.HttpsError('invalid-argument', 'Invalid uid value.');
  }
  return Math.floor(parsed);
}

/**
 * Generates an Agora RTC token for a given channel.
 * The caller must be a participant in the associated room, game, or stream.
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

    requireAppCheck(request);

    const data = request.data as GenerateTokenData;
    const { channelName, role = 'publisher' } = data;

    if (!channelName || typeof channelName !== 'string') {
      throw new functions.https.HttpsError('invalid-argument', 'Missing or invalid channelName.');
    }

    if (role !== 'publisher' && role !== 'subscriber') {
      throw new functions.https.HttpsError('invalid-argument', 'Invalid role.');
    }

    await verifyChannelAccess(request.auth.uid, data);

    const appId = APP_ID.value();
    const appCertificate = APP_CERTIFICATE.value();
    const uid = parseUid(data.uid);
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

    requireAppCheck(request);

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
