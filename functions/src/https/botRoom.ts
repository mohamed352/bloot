import * as functions from 'firebase-functions';
import { Timestamp, FieldValue } from 'firebase-admin/firestore';
import { db, auth } from '../config/admin';
import { requireAppCheck } from '../utils/appCheck';
import { getOrCreateUserAgoraUid } from '../utils/agoraUid';
import { createGameDocument, RoomPlayer } from '../engine/gameAdapter';

const BOT_NAMES = ['Faisal', 'Omar', 'Khalid'];
const BOT_AVATAR_URL = 'https://cdn-icons-png.flaticon.com/512/4712/4712035.png';

interface BotProfile {
  uid: string;
  displayName: string;
  agoraUid: number;
}

interface RoomPlayerData {
  uid: string;
  displayName: string;
  avatarUrl?: string;
  team: 'A' | 'B';
  seatIndex: number;
  isReady: boolean;
  isMicOn: boolean;
  isCameraOn: boolean;
  agoraUid: number;
  joinedAt: Date;
  isBot: boolean;
}

/**
 * Creates a real Bloot room with the authenticated caller plus 3 bot players,
 * then immediately starts a game so a single device can test the full
 * 4-player flow against real Firestore data.
 */
export const createRoomWithBots = functions.https.onCall(
  { enforceAppCheck: false },
  async (request) => {
  console.log('[createRoomWithBots] invoked', { uid: request.auth?.uid });

  if (!request.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  try {
    requireAppCheck(request);
  } catch (e) {
    console.error('[createRoomWithBots] App Check failed', e);
    throw e;
  }

  const humanUid = request.auth.uid;

  // Validate the human profile exists before creating any bot accounts.
  const humanDoc = await db.collection('users').doc(humanUid).get();
  if (!humanDoc.exists) {
    throw new functions.https.HttpsError('not-found', 'User profile not found');
  }
  const humanData = humanDoc.data()!;
  const humanDisplayName = (humanData.displayName as string) || 'Player';
  const humanAvatarUrl = (humanData.avatarUrl as string) || '';

  // Ensure the human has a stable Agora UID before creating the room.
  const humanAgoraUid = await getOrCreateUserAgoraUid(humanUid);

  // Create 3 real Firebase Auth bot users outside the transaction so retries
  // do not spawn duplicate accounts.
  const bots = await createBotUsers(3);

  return await db.runTransaction(async (transaction) => {
    const roomRef = db.collection('rooms').doc();
    const gameRef = db.collection('games').doc();
    const inviteCode = generateInviteCode();

    const humanPlayer = createRoomPlayer(
      humanUid,
      humanDisplayName,
      humanAvatarUrl,
      'A',
      0,
      false,
      humanAgoraUid,
    );

    const botPlayers = assignBotsToRoom(bots, [humanPlayer]);
    const players = [humanPlayer, ...botPlayers];

    const playerUids = players.map((p) => p.uid);
    const teamA = players.filter((p) => p.team === 'A').map((p) => p.uid);
    const teamB = players.filter((p) => p.team === 'B').map((p) => p.uid);

    // Create bot user docs.
    for (const bot of bots) {
      transaction.set(db.collection('users').doc(bot.uid), buildBotUserDoc(bot));
    }

    const roomData = buildRoomDoc({
      roomId: roomRef.id,
      name: 'Bot Match',
      creatorUid: humanUid,
      inviteCode,
      players,
      playerUids,
      teamA,
      teamB,
      gameId: gameRef.id,
      voiceEnabled: true,
      cameraEnabled: true,
    });

    transaction.set(roomRef, roomData);

    const game = createAndDealGame(gameRef.id, roomRef.id, players, roomData.agoraChannelName);
    transaction.set(gameRef, game);

    console.log('[createRoomWithBots] created', {
      roomId: roomRef.id,
      gameId: gameRef.id,
    });

    return { roomId: roomRef.id, gameId: gameRef.id };
  });
});

/**
 * Adds bots to an existing room to fill empty seats. If the room becomes full
 * and all players are ready, the game starts automatically.
 */
export const inviteBotsToRoom = functions.https.onCall(
  { enforceAppCheck: false },
  async (request) => {
  console.log('[inviteBotsToRoom] invoked', { uid: request.auth?.uid });

  if (!request.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  try {
    requireAppCheck(request);
  } catch (e) {
    console.error('[inviteBotsToRoom] App Check failed', e);
    throw e;
  }

  const authUid = request.auth.uid;
  const { roomId } = request.data;
  if (!roomId || typeof roomId !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing roomId');
  }

  const roomRef = db.collection('rooms').doc(roomId);
  const roomSnap = await roomRef.get();
  if (!roomSnap.exists) {
    throw new functions.https.HttpsError('not-found', 'Room not found');
  }

  const roomData = roomSnap.data()!;

  // Only the creator can invite bots.
  if (roomData.creatorUid !== authUid) {
    throw new functions.https.HttpsError('permission-denied', 'Only the creator can invite bots');
  }

  if (roomData.status !== 'waiting') {
    throw new functions.https.HttpsError(
      'failed-precondition',
      'Can only invite bots to a waiting room',
    );
  }

  const existingPlayers = (roomData.players || []) as RoomPlayerData[];
  if (existingPlayers.length >= 4) {
    throw new functions.https.HttpsError('failed-precondition', 'Room is already full');
  }

  const botsNeeded = 4 - existingPlayers.length;
  const bots = await createBotUsers(botsNeeded);

  return await db.runTransaction(async (transaction) => {
    const freshSnap = await transaction.get(roomRef);
    if (!freshSnap.exists) {
      throw new functions.https.HttpsError('not-found', 'Room not found');
    }

    const freshData = freshSnap.data()!;
    if (freshData.status !== 'waiting') {
      throw new functions.https.HttpsError(
        'failed-precondition',
        'Can only invite bots to a waiting room',
      );
    }

    const freshPlayers = (freshData.players || []) as RoomPlayerData[];
    if (freshPlayers.length >= 4) {
      throw new functions.https.HttpsError('failed-precondition', 'Room is already full');
    }

    const freshBotsNeeded = 4 - freshPlayers.length;
    // If the number of empty seats changed between the pre-check and the
    // transaction, only fill the current empty seats. Creating extra bot users
    // is harmless, but we should not exceed 4 players.
    const botsToAdd = bots.slice(0, freshBotsNeeded);

    // Create bot user docs.
    for (const bot of botsToAdd) {
      transaction.set(db.collection('users').doc(bot.uid), buildBotUserDoc(bot));
    }

    const botPlayers = assignBotsToRoom(botsToAdd, freshPlayers);
    const players = [...freshPlayers, ...botPlayers];

    const playerUids = players.map((p) => p.uid);
    const teamA = players.filter((p) => p.team === 'A').map((p) => p.uid);
    const teamB = players.filter((p) => p.team === 'B').map((p) => p.uid);
    const readyPlayers = players.map((p) => p.uid);

    const update: Record<string, any> = {
      players,
      playerUids,
      teamA,
      teamB,
      readyPlayers,
      currentPlayerCount: players.length,
      // Keep voice/camera enabled so bot-filled rooms behave like real rooms.
      voiceEnabled: freshData.voiceEnabled ?? true,
      cameraEnabled: freshData.cameraEnabled ?? true,
      updatedAt: FieldValue.serverTimestamp(),
    };

    let gameId: string | undefined;
    if (players.length === 4) {
      // All seats filled: auto-start the game.
      const gameRef = db.collection('games').doc();
      gameId = gameRef.id;
      const game = createAndDealGame(gameRef.id, roomId, players, freshData.agoraChannelName);
      transaction.set(gameRef, game);

      update.status = 'playing';
      update.gameId = gameId;
    }

    transaction.update(roomRef, update);

    console.log('[inviteBotsToRoom] updated', { roomId, botsAdded: botsToAdd.length, gameId });
    return { roomId, gameId };
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

async function createBotUsers(count: number): Promise<BotProfile[]> {
  const records = await Promise.all(
    BOT_NAMES.slice(0, count).map((name) =>
      auth.createUser({
        displayName: name,
        photoURL: BOT_AVATAR_URL,
      }),
    ),
  );
  const profiles = await Promise.all(
    records.map(async (record, i) => {
      const agoraUid = await getOrCreateUserAgoraUid(record.uid);
      return {
        uid: record.uid,
        displayName: BOT_NAMES[i],
        agoraUid,
      };
    }),
  );
  return profiles;
}

function buildBotUserDoc(bot: BotProfile): Record<string, any> {
  return {
    uid: bot.uid,
    displayName: bot.displayName,
    avatarUrl: BOT_AVATAR_URL,
    agoraUid: bot.agoraUid,
    isBot: true,
    level: 1,
    coins: 0,
    xp: 0,
    stats: {
      gamesPlayed: 0,
      gamesWon: 0,
      gamesLost: 0,
    },
    settings: {
      language: 'ar',
      notificationsEnabled: false,
      soundEnabled: true,
    },
    isProfileComplete: true,
    createdAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  };
}

function assignBotsToRoom(bots: BotProfile[], existingPlayers: RoomPlayerData[]): RoomPlayerData[] {
  const teamA = existingPlayers.filter((p) => p.team === 'A');
  const teamB = existingPlayers.filter((p) => p.team === 'B');
  let nextSeat = existingPlayers.length;

  return bots.map((bot) => {
    const team = teamA.length <= teamB.length ? 'A' : 'B';
    if (team === 'A') teamA.push({} as any);
    else teamB.push({} as any);

    return createRoomPlayer(
      bot.uid,
      bot.displayName,
      BOT_AVATAR_URL,
      team,
      nextSeat++,
      true,
      bot.agoraUid,
      { isMicOn: true, isCameraOn: true },
    );
  });
}

function createRoomPlayer(
  uid: string,
  displayName: string,
  avatarUrl: string | undefined,
  team: 'A' | 'B',
  seatIndex: number,
  isBot: boolean,
  agoraUid: number,
  options?: { isReady?: boolean; isMicOn?: boolean; isCameraOn?: boolean },
): RoomPlayerData {
  return {
    uid,
    displayName,
    avatarUrl,
    team,
    seatIndex,
    isReady: options?.isReady ?? isBot,
    isMicOn: options?.isMicOn ?? true,
    isCameraOn: options?.isCameraOn ?? false,
    agoraUid,
    joinedAt: new Date(),
    isBot,
  };
}

function buildRoomDoc(params: {
  roomId: string;
  name: string;
  creatorUid: string;
  inviteCode: string;
  players: RoomPlayerData[];
  playerUids: string[];
  teamA: string[];
  teamB: string[];
  gameId?: string;
  voiceEnabled?: boolean;
  cameraEnabled?: boolean;
}): Record<string, any> {
  const now = FieldValue.serverTimestamp();
  return {
    id: params.roomId,
    name: params.name,
    type: 'private',
    creatorUid: params.creatorUid,
    status: params.gameId ? 'playing' : 'waiting',
    voiceEnabled: params.voiceEnabled ?? true,
    cameraEnabled: params.cameraEnabled ?? true,
    allowSpectators: false,
    gameSpeed: 'normal',
    inviteCode: params.inviteCode,
    players: params.players,
    playerUids: params.playerUids,
    teamA: params.teamA,
    teamB: params.teamB,
    readyPlayers: params.playerUids,
    currentPlayerCount: params.players.length,
    maxPlayers: 4,
    agoraChannelName: `room_${params.roomId}`,
    ...(params.gameId ? { gameId: params.gameId } : {}),
    createdAt: now,
    updatedAt: now,
  };
}

function createAndDealGame(
  gameId: string,
  roomId: string,
  players: RoomPlayerData[],
  agoraChannelName: string | undefined,
): Record<string, any> {
  const roomPlayers: RoomPlayer[] = players.map((p) => ({
    uid: p.uid,
    displayName: p.displayName,
    avatarUrl: p.avatarUrl,
    team: p.team,
    seatIndex: p.seatIndex,
    isBot: p.isBot,
    level: 'amateur',
    isMuted: !p.isMicOn,
    hasCamera: p.isCameraOn,
    agoraUid: p.agoraUid,
    isConnected: true,
  }));

  const game = createGameDocument(gameId, roomId, roomPlayers, 152, agoraChannelName ?? `room_${roomId}`);
  game.turnTimerStart = Timestamp.now().toDate();
  return game as any;
}

function generateInviteCode(): string {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  let code = '';
  for (let i = 0; i < 6; i++) {
    code += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return code;
}
