#!/usr/bin/env node
/**
 * Seed a test room with one human player.
 *
 * Useful for verifying the bot harness without launching the Flutter app.
 * After running this, use `npm run start -- TEST12` to fill the other 3 seats.
 */

import { initializeApp } from 'firebase/app';
import {
  connectAuthEmulator,
  getAuth,
  signInAnonymously,
} from 'firebase/auth';
import {
  collection,
  connectFirestoreEmulator,
  doc,
  getDocs,
  getFirestore,
  query,
  setDoc,
  where,
} from 'firebase/firestore';

const args = process.argv.slice(2);
function parseArg(flag: string): string | undefined {
  const idx = args.indexOf(flag);
  return idx !== -1 && idx + 1 < args.length ? args[idx + 1] : undefined;
}
function positionalCode(): string | undefined {
  return args.find((a) => !a.startsWith('-'));
}

const inviteCode = (parseArg('--code') || parseArg('-c') || positionalCode() || 'TEST12').toUpperCase();
const projectId = parseArg('--project') || 'bloot-89b2b';
const emulatorHost = parseArg('--host') || 'localhost';

const firebaseApp = initializeApp({ projectId, apiKey: 'fake-emulator-api-key' });
const auth = getAuth(firebaseApp);
const db = getFirestore(firebaseApp);

connectAuthEmulator(auth, `http://${emulatorHost}:9099`, { disableWarnings: true });
connectFirestoreEmulator(db, emulatorHost, 8080);

async function main(): Promise<void> {
  // Check if a room with this code already exists.
  const existing = await getDocs(query(collection(db, 'rooms'), where('inviteCode', '==', inviteCode)));
  if (!existing.empty) {
    const roomDoc = existing.docs[0];
    console.log(`Room already exists: ${roomDoc.id} with code ${inviteCode}`);
    console.log(`Run harness with: npm run start -- ${inviteCode} --project ${projectId}`);
    process.exit(0);
  }

  const user = (await signInAnonymously(auth)).user;

  // Create a minimal user profile.
  await setDoc(doc(db, 'users', user.uid), {
    uid: user.uid,
    displayName: 'Human',
    username: `human_${user.uid.slice(0, 8)}`,
    phoneNumber: '',
    level: 1,
    xp: 0,
    xpToNextLevel: 100,
    coins: 0,
    gamesPlayed: 0,
    gamesWon: 0,
    sunGamesPlayed: 0,
    sunGamesWon: 0,
    hokmGamesPlayed: 0,
    hokmGamesWon: 0,
    followersCount: 0,
    followingCount: 0,
    isOnline: true,
    lastSeen: new Date(),
    settings: {},
    createdAt: new Date(),
    updatedAt: new Date(),
  });

  const roomRef = doc(collection(db, 'rooms'));
  await setDoc(roomRef, {
    name: 'Test Room',
    inviteCode,
    status: 'waiting',
    creatorUid: user.uid,
    players: [
      {
        uid: user.uid,
        displayName: 'Human',
        team: 'A',
        seatIndex: 0,
        isReady: false,
      },
    ],
    playerUids: [user.uid],
    teamA: [user.uid],
    teamB: [],
    readyPlayers: [],
    currentPlayerCount: 1,
    voiceEnabled: false,
    cameraEnabled: false,
    chatMessages: [],
    createdAt: new Date(),
    updatedAt: new Date(),
  });

  console.log(`✓ Seeded room ${roomRef.id} with invite code ${inviteCode}`);
  console.log(`  Human UID: ${user.uid}`);
  console.log(`  Run harness with: npm run start -- ${inviteCode} --project ${projectId}`);
}

main().catch((err) => {
  console.error('Seed failed:', err);
  process.exit(1);
});
