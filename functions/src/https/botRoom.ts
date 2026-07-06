import * as functions from 'firebase-functions';
import { Timestamp, FieldValue } from 'firebase-admin/firestore';
import { db, auth } from '../config/admin';
import { requireAppCheck } from '../utils/appCheck';
import { createGameDocument, dealRound } from '../engine/deal';
import { PlayerState } from '../models/game';

const BOT_NAMES = ['Faisal', 'Omar', 'Khalid'];
const BOT_AVATAR_URL = 'https://cdn-icons-png.flaticon.com/512/4712/4712035.png';

interface BotProfile {
  uid: string;
  displayName: string;
  team: 'A' | 'B';
  seatIndex: number;
}

/**
 * Creates a real Bloot room with the authenticated caller plus 3 bot players,
 * then immediately starts a game so a single device can test the full
 * 4-player flow against real Firestore data.
 */
export const createRoomWithBots = functions.https.onCall(async (request) => {
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

  // ───────────────────────────────────────────────────────────────────────────
  // Validate the human profile exists before creating any bot accounts.
  // ───────────────────────────────────────────────────────────────────────────
  const humanDoc = await db.collection('users').doc(humanUid).get();
  if (!humanDoc.exists) {
    throw new functions.https.HttpsError('not-found', 'User profile not found');
  }
  const humanData = humanDoc.data()!;
  const humanDisplayName = (humanData.displayName as string) || 'Player';
  const humanAvatarUrl = (humanData.avatarUrl as string) || '';

  // ───────────────────────────────────────────────────────────────────────────
  // Create 3 real Firebase Auth bot users outside the transaction so retries
  // do not spawn duplicate accounts.
  // ───────────────────────────────────────────────────────────────────────────
  const botUserRecords = await Promise.all(
    BOT_NAMES.map((name) =>
      auth.createUser({
        displayName: name,
        photoURL: BOT_AVATAR_URL,
      }),
    ),
  );

  const bots: BotProfile[] = botUserRecords.map((record, i) => ({
    uid: record.uid,
    displayName: BOT_NAMES[i],
    team: i === 0 ? 'A' : 'B', // human + Faisal vs Omar + Khalid
    seatIndex: i + 1,
  }));

  return await db.runTransaction(async (transaction) => {

    // ─────────────────────────────────────────────────────────────────────────
    // Create bot Firestore profiles
    // ─────────────────────────────────────────────────────────────────────────
    for (const bot of bots) {
      transaction.set(db.collection('users').doc(bot.uid), {
        uid: bot.uid,
        displayName: bot.displayName,
        avatarUrl: BOT_AVATAR_URL,
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
      });
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Create room document
    // ─────────────────────────────────────────────────────────────────────────
    const roomRef = db.collection('rooms').doc();
    const gameRef = db.collection('games').doc();
    const inviteCode = generateInviteCode();

    const now = FieldValue.serverTimestamp();
    const humanAgoraUid = uidToAgoraUid(humanUid);

    const players = [
      {
        uid: humanUid,
        displayName: humanDisplayName,
        avatarUrl: humanAvatarUrl,
        team: 'A',
        seatIndex: 0,
        isReady: true,
        isMicOn: false,
        isCameraOn: false,
        agoraUid: humanAgoraUid,
        joinedAt: new Date(),
        isBot: false,
      },
      ...bots.map((b) => ({
        uid: b.uid,
        displayName: b.displayName,
        avatarUrl: BOT_AVATAR_URL,
        team: b.team,
        seatIndex: b.seatIndex,
        isReady: true,
        isMicOn: false,
        isCameraOn: false,
        agoraUid: uidToAgoraUid(b.uid),
        joinedAt: new Date(),
        isBot: true,
      })),
    ];

    const playerUids = [humanUid, ...bots.map((b) => b.uid)];
    const teamA = [humanUid, bots[0].uid];
    const teamB = [bots[1].uid, bots[2].uid];

    const roomData = {
      id: roomRef.id,
      name: 'Bot Match',
      type: 'private',
      creatorUid: humanUid,
      status: 'playing',
      voiceEnabled: false,
      cameraEnabled: false,
      allowSpectators: false,
      gameSpeed: 'normal',
      inviteCode,
      players,
      playerUids,
      teamA,
      teamB,
      readyPlayers: playerUids,
      currentPlayerCount: 4,
      maxPlayers: 4,
      agoraChannelName: `room_${roomRef.id}`,
      gameId: gameRef.id,
      createdAt: now,
      updatedAt: now,
    };

    transaction.set(roomRef, roomData);

    // ─────────────────────────────────────────────────────────────────────────
    // Create and deal game document
    // ─────────────────────────────────────────────────────────────────────────
    const playerStates: PlayerState[] = players.map((p) => ({
      uid: p.uid,
      displayName: p.displayName,
      avatarUrl: p.avatarUrl || '',
      team: p.team as 'A' | 'B',
      hand: [],
      takenCards: [],
      tricksWon: 0,
      bid: null,
      isReady: false,
      bonuses: null,
      isConnected: true,
      isMuted: true,
      hasCamera: false,
      agoraUid: p.agoraUid,
    }));

    let game = createGameDocument(gameRef.id, roomRef.id, playerStates, 152);
    game = dealRound(game);
    game.turnTimerStart = Timestamp.now();
    game.agoraChannelName = roomData.agoraChannelName;

    transaction.set(gameRef, game);

    console.log('[createRoomWithBots] created', {
      roomId: roomRef.id,
      gameId: gameRef.id,
    });

    return { roomId: roomRef.id, gameId: gameRef.id };
  });
});

function generateInviteCode(): string {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  let code = '';
  for (let i = 0; i < 6; i++) {
    code += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return code;
}

function uidToAgoraUid(uid: string): number {
  let hash = 0;
  for (let i = 0; i < uid.length; i++) {
    const char = uid.charCodeAt(i);
    hash = (hash << 5) - hash + char;
    hash |= 0;
  }
  return Math.abs(hash) % 2147483647;
}
