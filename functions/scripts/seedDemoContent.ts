/**
 * Seed pre-populated demo content for the App Review account (guideline 2.1(a)).
 *
 * Creates (idempotently):
 *   - 3 demo bot users (Faisal / Omar / Khalid) with complete profiles.
 *   - DM conversations + messages between the reviewer and each bot.
 *   - Follower/following relationships between the reviewer and the bots.
 *   - A few game history entries on the reviewer's profile.
 *
 * A live game/stream is NOT seeded here because Agora channels must be
 * genuinely live — the reviewer taps "Play with Bots" on Home, which
 * creates a real 4-player game (and auto-creates a live stream).
 *
 * Run AFTER scripts/createDemoReviewer.ts:
 *   npx ts-node scripts/seedDemoContent.ts
 *
 * Requires GOOGLE_APPLICATION_CREDENTIALS to be set (see createDemoReviewer.ts).
 * Override the reviewer email via REVIEWER_EMAIL.
 */
import * as admin from 'firebase-admin';

admin.initializeApp();

const db = admin.firestore();
const auth = admin.auth();

const REVIEWER_EMAIL = process.env.REVIEWER_EMAIL || 'reviewer@bloot.app';

const DEMO_BOTS = [
  { email: 'bot_faisal@bloot.app', displayName: 'Faisal', username: 'faisal_bot' },
  { email: 'bot_omar@bloot.app', displayName: 'Omar', username: 'omar_bot' },
  { email: 'bot_khalid@bloot.app', displayName: 'Khalid', username: 'khalid_bot' },
];

const DEMO_PASSWORD = 'BlootBot2026!';

async function ensureUser(
  email: string,
  displayName: string,
  extraAuth: admin.auth.CreateRequest = {},
): Promise<admin.auth.UserRecord> {
  try {
    return await auth.createUser({
      email,
      password: DEMO_PASSWORD,
      displayName,
      emailVerified: true,
      ...extraAuth,
    });
  } catch (err: any) {
    if (err.code === 'auth/email-already-exists') {
      return auth.getUserByEmail(email);
    }
    throw err;
  }
}

async function ensureBotUserDoc(bot: {
  uid: string;
  displayName: string;
  username: string;
}): Promise<void> {
  const now = admin.firestore.FieldValue.serverTimestamp();
  await db.collection('users').doc(bot.uid).set(
    {
      uid: bot.uid,
      displayName: bot.displayName,
      username: bot.username,
      avatarUrl: null,
      bio: 'Friendly Baloot bot',
      isBot: true,
      level: 3,
      xp: 250,
      xpToNextLevel: 300,
      coins: 500,
      gamesPlayed: 25,
      gamesWon: 13,
      sunGamesPlayed: 15,
      sunGamesWon: 8,
      hokmGamesPlayed: 10,
      hokmGamesWon: 5,
      followersCount: 1,
      followingCount: 1,
      isOnline: true,
      lastSeen: now,
      achievements: {} as Record<string, any>,
      settings: {
        voiceChat: true,
        camera: false,
        speakerMode: 'speaker',
        autoRotateGame: true,
        gameSpeedDefault: 'normal',
        soundEffects: true,
        backgroundMusic: false,
        showOnlineStatus: true,
        profileVisibility: 'everyone',
        notifyRoomInvitations: true,
        notifyNewFollowers: true,
        notifyGameResults: true,
      },
      isProfileComplete: true,
      updatedAt: now,
      createdAt: now,
    },
    { merge: true },
  );
}

async function seedConversation(params: {
  reviewerUid: string;
  reviewerName: string;
  botUid: string;
  botName: string;
  messages: { fromBot: boolean; text: string }[];
}): Promise<void> {
  const { reviewerUid, reviewerName, botUid, botName, messages } = params;
  const ids = [reviewerUid, botUid].sort();
  const conversationId = `dm_${ids[0]}_${ids[1]}`;
  const participantUids = ids;
  const now = Date.now();

  const conversationRef = db.collection('conversations').doc(conversationId);

  // Wipe previous seeded messages so re-runs stay clean.
  const existing = await conversationRef.collection('messages').get();
  if (!existing.empty) {
    const batch = db.batch();
    existing.docs.forEach((doc) => batch.delete(doc.ref));
    await batch.commit();
  }

  let lastMessage = '';
  for (let i = 0; i < messages.length; i++) {
    const msg = messages[i];
    const senderId = msg.fromBot ? botUid : reviewerUid;
    lastMessage = msg.text;
    await conversationRef.collection('messages').add({
      senderId,
      text: msg.text,
      type: 'text',
      participantUids,
      createdAt: admin.firestore.Timestamp.fromMillis(now - (messages.length - i) * 60_000),
      readBy: [senderId],
    });
  }

  await conversationRef.set(
    {
      participantUids,
      lastMessage,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      unread: 0,
      type: 'direct',
    },
    { merge: true },
  );

  // Per-user conversation list metadata (drives the chat list UI —
  // getConversations() reads name/avatarUrl/lastMessage/unread/type).
  const batch = db.batch();
  for (const uid of participantUids) {
    const isReviewer = uid === reviewerUid;
    batch.set(
      db.collection('users').doc(uid).collection('conversations').doc(conversationId),
      {
        participantUids,
        name: isReviewer ? botName : reviewerName,
        avatarUrl: null,
        type: 'direct',
        lastMessage,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        unread: isReviewer ? 1 : 0,
      },
      { merge: true },
    );
  }
  await batch.commit();
}

async function seedFollows(reviewerUid: string, botUids: string[]): Promise<void> {
  const now = admin.firestore.FieldValue.serverTimestamp();
  for (const botUid of botUids) {
    // Bots follow the reviewer.
    await db
      .collection('users').doc(reviewerUid)
      .collection('followers').doc(botUid)
      .set({ followerUid: botUid, followedAt: now }, { merge: true });
    await db
      .collection('users').doc(botUid)
      .collection('following').doc(reviewerUid)
      .set({ followingUid: reviewerUid, followedAt: now }, { merge: true });
    // Reviewer follows the bots back.
    await db
      .collection('users').doc(reviewerUid)
      .collection('following').doc(botUid)
      .set({ followingUid: botUid, followedAt: now }, { merge: true });
    await db
      .collection('users').doc(botUid)
      .collection('followers').doc(reviewerUid)
      .set({ followerUid: reviewerUid, followedAt: now }, { merge: true });
  }
  await db.collection('users').doc(reviewerUid).set(
    { followersCount: botUids.length, followingCount: botUids.length },
    { merge: true },
  );
}

async function seedGameHistory(reviewerUid: string): Promise<void> {
  const now = Date.now();
  const games = [
    { result: 'won', scoreTeamA: 152, scoreTeamB: 104, gameType: 'sun', duration: 900 },
    { result: 'lost', scoreTeamA: 98, scoreTeamB: 152, gameType: 'hokm', duration: 780 },
    { result: 'won', scoreTeamA: 152, scoreTeamB: 87, gameType: 'hokm', duration: 840 },
  ];
  for (let i = 0; i < games.length; i++) {
    await db
      .collection('users').doc(reviewerUid)
      .collection('gameHistory').doc(`demo_game_${i + 1}`)
      .set({
        gameId: `demo_game_${i + 1}`,
        ...games[i],
        playedAt: admin.firestore.Timestamp.fromMillis(now - (i + 1) * 86_400_000),
      });
  }
}

async function main(): Promise<void> {
  const reviewer = await auth.getUserByEmail(REVIEWER_EMAIL);
  const reviewerName = reviewer.displayName || 'App Reviewer';
  console.log('Reviewer:', reviewer.uid);

  const botUids: string[] = [];
  for (const bot of DEMO_BOTS) {
    const record = await ensureUser(bot.email, bot.displayName);
    await ensureBotUserDoc({
      uid: record.uid,
      displayName: bot.displayName,
      username: bot.username,
    });
    botUids.push(record.uid);
    console.log('Bot ready:', bot.displayName, record.uid);
  }

  await seedConversation({
    reviewerUid: reviewer.uid,
    reviewerName,
    botUid: botUids[0],
    botName: DEMO_BOTS[0].displayName,
    messages: [
      { fromBot: true, text: 'Welcome to Bloot! 🎮' },
      { fromBot: true, text: 'Want to play a round of Baloot?' },
      { fromBot: false, text: 'Sure, invite me to a room!' },
      { fromBot: true, text: 'Tap "Play with Bots" on Home and I will join you.' },
    ],
  });
  await seedConversation({
    reviewerUid: reviewer.uid,
    reviewerName,
    botUid: botUids[1],
    botName: DEMO_BOTS[1].displayName,
    messages: [
      { fromBot: true, text: 'GG last game! 🏆' },
      { fromBot: false, text: 'Thanks! Rematch later?' },
    ],
  });
  console.log('Seeded DM conversations + messages.');

  await seedFollows(reviewer.uid, botUids);
  console.log('Seeded followers/following.');

  await seedGameHistory(reviewer.uid);
  console.log('Seeded game history.');

  console.log('');
  console.log('Demo content ready. Reviewer instructions:');
  console.log('  1. Sign in with Email using the demo credentials.');
  console.log('  2. Home → "Play with Bots" starts a full 4-player game.');
  console.log('  3. Chat tab shows pre-populated conversations.');
  console.log('  4. Profile shows stats, followers and game history.');
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
