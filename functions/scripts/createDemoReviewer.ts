/**
 * Create the App Review demo account (guideline 2.1(a)).
 *
 * Creates a Firebase Auth email/password user and a COMPLETE Firestore
 * user profile (isProfileComplete: true) so Apple reviewers can sign in
 * with email and immediately access every feature without onboarding.
 *
 * Run with:
 *   npx ts-node scripts/createDemoReviewer.ts
 *
 * Requires GOOGLE_APPLICATION_CREDENTIALS to be set, e.g. (PowerShell):
 *   $env:GOOGLE_APPLICATION_CREDENTIALS="C:\path\to\serviceAccountKey.json"
 *   npx ts-node scripts/createDemoReviewer.ts
 *
 * Override credentials via REVIEWER_EMAIL / REVIEWER_PASSWORD env vars.
 * After running this, run `npx ts-node scripts/seedDemoContent.ts` to
 * pre-populate chats, followers and game history for the reviewer.
 */
import * as admin from 'firebase-admin';

admin.initializeApp();

const db = admin.firestore();
const auth = admin.auth();

async function createDemoReviewer(
  email: string,
  password: string,
  displayName: string,
  username: string,
): Promise<string> {
  let user: admin.auth.UserRecord;

  try {
    user = await auth.createUser({
      email,
      password,
      displayName,
      emailVerified: true,
    });
    console.log('Created Firebase Auth user:', user.uid);
  } catch (err: any) {
    if (err.code === 'auth/email-already-exists') {
      user = await auth.getUserByEmail(email);
      // Keep the password in sync so App Review credentials always work.
      await auth.updateUser(user.uid, { password });
      console.log('Using existing Firebase Auth user (password reset):', user.uid);
    } else {
      throw err;
    }
  }

  const now = admin.firestore.FieldValue.serverTimestamp();
  await db.collection('users').doc(user.uid).set(
    {
      uid: user.uid,
      displayName,
      username,
      avatarUrl: null,
      bio: 'App Review demo account',
      region: null,
      favoriteMode: null,
      level: 5,
      xp: 420,
      xpToNextLevel: 500,
      coins: 1000,
      gamesPlayed: 12,
      gamesWon: 7,
      sunGamesPlayed: 7,
      sunGamesWon: 4,
      hokmGamesPlayed: 5,
      hokmGamesWon: 3,
      followersCount: 0, // updated by seedDemoContent.ts
      followingCount: 0, // updated by seedDemoContent.ts
      isOnline: false,
      lastSeen: now,
      fcmToken: null,
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

  console.log('Wrote complete user profile for:', user.uid);
  console.log('');
  console.log('App Review demo credentials (add to App Store Connect');
  console.log('→ App Review Information → Demo Account):');
  console.log('  Email:   ', email);
  console.log('  Password:', password);
  return user.uid;
}

const EMAIL = process.env.REVIEWER_EMAIL || 'reviewer@bloot.app';
const PASSWORD = process.env.REVIEWER_PASSWORD || 'BlootReview2026!';
const DISPLAY_NAME = process.env.REVIEWER_NAME || 'App Reviewer';
const USERNAME = process.env.REVIEWER_USERNAME || 'reviewer';

createDemoReviewer(EMAIL, PASSWORD, DISPLAY_NAME, USERNAME)
  .then(() => process.exit(0))
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
