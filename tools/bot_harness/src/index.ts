#!/usr/bin/env node
/**
 * Bloot Bot Harness
 *
 * Fills the other 3 seats in a Bloot room with autonomous bots so a solo
 * developer can test the full online 4-player game loop.
 *
 * Usage:
 *   1. Start the Firebase emulator suite:
 *        firebase emulators:start
 *   2. Configure the Flutter app to use the emulator (already done in debug
 *      builds that call `useFirebaseEmulator`).
 *   3. Create a room in the app and copy the 6-character invite code.
 *   4. Run the harness:
 *        npx ts-node src/index.ts --code ABCD12
 *
 * The harness signs in 3 anonymous users, joins them to the room, toggles
 * ready, and then auto-bids / auto-claims / auto-plays for each bot whenever
 * it is their turn.
 */

import { initializeApp } from 'firebase/app';
import {
  connectAuthEmulator,
  getAuth,
  signInAnonymously,
  User,
} from 'firebase/auth';
import {
  collection,
  connectFirestoreEmulator,
  doc,
  getDoc,
  getDocs,
  getFirestore,
  onSnapshot,
  query,
  runTransaction,
  Unsubscribe,
  where,
} from 'firebase/firestore';
import {
  connectFunctionsEmulator,
  getFunctions,
  httpsCallable,
} from 'firebase/functions';

// ─────────────────────────────────────────────────────────────────────────────
// Configuration
// ─────────────────────────────────────────────────────────────────────────────

const args = process.argv.slice(2);
const inviteCode = parseArg('--code', args) || parseArg('-c', args);
const projectId = parseArg('--project', args) || 'bloot-89b2b';
const emulatorHost = parseArg('--host', args) || 'localhost';

if (!inviteCode) {
  console.error('Usage: npx ts-node src/index.ts --code INVITE [--project PROJECT] [--host localhost]');
  process.exit(1);
}
const code = inviteCode.toUpperCase();

function parseArg(flag: string, argv: string[]): string | undefined {
  const idx = argv.indexOf(flag);
  return idx !== -1 && idx + 1 < argv.length ? argv[idx + 1] : undefined;
}

const firebaseApp = initializeApp({ projectId });
const auth = getAuth(firebaseApp);
const db = getFirestore(firebaseApp);
const functions = getFunctions(firebaseApp);

connectAuthEmulator(auth, `http://${emulatorHost}:9099`, { disableWarnings: true });
connectFirestoreEmulator(db, emulatorHost, 8080);
connectFunctionsEmulator(functions, emulatorHost, 5001);

// ─────────────────────────────────────────────────────────────────────────────
// Types
// ─────────────────────────────────────────────────────────────────────────────

interface BotPlayer {
  user: User;
  seatIndex: number;
  team: 'A' | 'B';
  displayName: string;
  roomUnsub?: Unsubscribe;
  gameUnsub?: Unsubscribe;
}

interface RoomDoc {
  id: string;
  name: string;
  inviteCode: string;
  status: 'waiting' | 'playing' | 'finished';
  gameId?: string;
  players: Array<{
    uid: string;
    displayName: string;
    team: 'A' | 'B';
    seatIndex: number;
    isReady: boolean;
  }>;
  playerUids: string[];
  teamA: string[];
  teamB: string[];
  readyPlayers: string[];
  creatorUid: string;
  voiceEnabled: boolean;
  cameraEnabled: boolean;
}

interface GameDoc {
  id: string;
  status:
    | 'dealing'
    | 'bidding'
    | 'bonusClaim'
    | 'playing'
    | 'trickEnd'
    | 'roundEnd'
    | 'gameEnd';
  gameType?: 'sun' | 'hokm';
  turnIndex: number;
  dealerIndex: number;
  trumpSuit?: string;
  faceUpCard?: string;
  players: Record<
    string,
    {
      uid: string;
      displayName: string;
      team: 'A' | 'B';
      hand: string[];
      takenCards: string[];
      bid: string | null;
      bonuses: Array<{ type: string; points: number; cards: string[] }> | null;
      isReady: boolean;
    }
  >;
  currentTrick: {
    cards: Record<string, string>;
    leadingSuit?: string;
    trickLeaderIndex: number;
  };
  teamAScore: number;
  teamBScore: number;
  targetScore: number;
  currentRound: number;
}

// ─────────────────────────────────────────────────────────────────────────────
// Card helpers (must match functions/src/models/card.ts)
// ─────────────────────────────────────────────────────────────────────────────

const SUIT_OF = (card: string) => card.slice(-1);
const RANK_OF = (card: string) => card.slice(0, -1);

const NON_TRUMP_ORDER: Record<string, number> = {
  A: 14, '10': 10, K: 13, Q: 12, J: 11, '9': 9, '8': 8,
  '7': 7, '6': 6, '5': 5, '4': 4, '3': 3, '2': 2,
};

const TRUMP_ORDER: Record<string, number> = {
  J: 8, '9': 7, A: 6, '10': 5, K: 4, Q: 3, '8': 2, '7': 1,
  '6': 0, '5': 0, '4': 0, '3': 0, '2': 0,
};

function cardBeats(candidate: string, current: string, leadingSuit: string, trumpSuit?: string): boolean {
  const candSuit = SUIT_OF(candidate);
  const currSuit = SUIT_OF(current);
  const isTrump = trumpSuit !== undefined;

  if (isTrump) {
    if (candSuit === trumpSuit && currSuit !== trumpSuit) return true;
    if (candSuit !== trumpSuit && currSuit === trumpSuit) return false;
  }

  if (candSuit === leadingSuit && currSuit !== leadingSuit) return true;
  if (candSuit !== leadingSuit && currSuit === leadingSuit) return false;

  const candPower = candSuit === trumpSuit ? TRUMP_ORDER[RANK_OF(candidate)] : NON_TRUMP_ORDER[RANK_OF(candidate)];
  const currPower = currSuit === trumpSuit ? TRUMP_ORDER[RANK_OF(current)] : NON_TRUMP_ORDER[RANK_OF(current)];
  return (candPower ?? 0) > (currPower ?? 0);
}

function isCardLegal(game: GameDoc, seatIndex: number, card: string): boolean {
  const hand = game.players[String(seatIndex)].hand;
  if (!hand.includes(card)) return false;

  const trick = game.currentTrick;
  if (!trick || Object.keys(trick.cards).length === 0) return true;

  const leadingSuit = trick.leadingSuit;
  if (!leadingSuit) return true;

  if (SUIT_OF(card) === leadingSuit) return true;

  const hasLeadingSuit = hand.some((c) => SUIT_OF(c) === leadingSuit);
  return !hasLeadingSuit;
}

function findLowestLegalCard(game: GameDoc, seatIndex: number): string | null {
  const hand = game.players[String(seatIndex)].hand;
  if (hand.length === 0) return null;

  const sorted = [...hand].sort((a, b) => {
    const rankA = RANK_OF(a);
    const rankB = RANK_OF(b);
    return (NON_TRUMP_ORDER[rankA] ?? 0) - (NON_TRUMP_ORDER[rankB] ?? 0);
  });

  for (const card of sorted) {
    if (isCardLegal(game, seatIndex, card)) return card;
  }
  return null;
}

function detectBonuses(hand: string[]): Array<{ type: string; points: number; cards: string[]; description?: string }> {
  const bonuses: Array<{ type: string; points: number; cards: string[] }> = [];

  // Bnaga (sequences)
  for (const suit of ['S', 'H', 'D', 'C']) {
    const suitCards = hand.filter((c) => SUIT_OF(c) === suit);
    if (suitCards.length < 3) continue;

    const sorted = suitCards.sort((a, b) => {
      return (NON_TRUMP_ORDER[RANK_OF(b)] ?? 0) - (NON_TRUMP_ORDER[RANK_OF(a)] ?? 0);
    });

    let currentSeq = [sorted[0]];
    let bestSeq: string[] | null = null;

    for (let i = 1; i < sorted.length; i++) {
      const prevRank = NON_TRUMP_ORDER[RANK_OF(currentSeq[currentSeq.length - 1])] ?? 0;
      const currRank = NON_TRUMP_ORDER[RANK_OF(sorted[i])] ?? 0;
      if (prevRank - currRank === 1) {
        currentSeq.push(sorted[i]);
      } else {
        if (currentSeq.length >= 3 && (bestSeq === null || currentSeq.length > bestSeq.length)) {
          bestSeq = [...currentSeq];
        }
        currentSeq = [sorted[i]];
      }
    }
    if (currentSeq.length >= 3 && (bestSeq === null || currentSeq.length > bestSeq.length)) {
      bestSeq = [...currentSeq];
    }

    if (bestSeq) {
      const len = bestSeq.length;
      bonuses.push({
        type: 'bnaga',
        points: len === 3 ? 20 : len === 4 ? 50 : 100,
        cards: bestSeq,
      });
    }
  }

  // Mosal (four of a kind)
  const byRank: Record<string, string[]> = {};
  for (const card of hand) {
    byRank[RANK_OF(card)] = [...(byRank[RANK_OF(card)] ?? []), card];
  }
  const mosalPoints: Record<string, number> = { J: 200, '9': 150, A: 100, '10': 100, K: 100, Q: 100 };
  for (const [rank, cards] of Object.entries(byRank)) {
    if (cards.length === 4 && mosalPoints[rank]) {
      bonuses.push({ type: 'mosal', points: mosalPoints[rank], cards });
    }
  }

  return bonuses;
}

// ─────────────────────────────────────────────────────────────────────────────
// Firebase helpers
// ─────────────────────────────────────────────────────────────────────────────

async function ensureUserProfile(user: User, name: string): Promise<void> {
  const ref = doc(db, 'users', user.uid);
  await runTransaction(db, async (tx) => {
    const snap = await tx.get(ref);
    if (snap.exists()) return;
    tx.set(ref, {
      uid: user.uid,
      displayName: name,
      username: `bot_${user.uid.slice(0, 8)}`,
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
  });
}

async function joinRoomByCode(roomId: string, user: User, name: string): Promise<void> {
  const roomRef = doc(db, 'rooms', roomId);
  await runTransaction(db, async (tx) => {
    const snap = await tx.get(roomRef);
    if (!snap.exists()) throw new Error('Room not found');
    const data = snap.data() as RoomDoc;

    if (data.playerUids.includes(user.uid)) return; // Already joined
    if (data.players.length >= 4) throw new Error('Room is full');

    const teamA = [...data.teamA];
    const teamB = [...data.teamB];
    const team = teamA.length <= teamB.length ? 'A' : 'B';
    if (team === 'A') teamA.push(user.uid);
    else teamB.push(user.uid);

    const players = [...data.players];
    players.push({
      uid: user.uid,
      displayName: name,
      team,
      seatIndex: players.length,
      isReady: false,
    });

    tx.update(roomRef, {
      players,
      playerUids: [...data.playerUids, user.uid],
      teamA,
      teamB,
      currentPlayerCount: players.length,
      updatedAt: new Date(),
    });
  });
}

async function toggleReady(roomId: string, user: User): Promise<void> {
  const roomRef = doc(db, 'rooms', roomId);
  await runTransaction(db, async (tx) => {
    const snap = await tx.get(roomRef);
    if (!snap.exists()) throw new Error('Room not found');
    const data = snap.data() as RoomDoc;

    const players = [...data.players];
    const idx = players.findIndex((p) => p.uid === user.uid);
    if (idx === -1) throw new Error('Player not in room');

    players[idx] = { ...players[idx], isReady: true };

    const readyPlayers = data.readyPlayers.includes(user.uid)
      ? data.readyPlayers
      : [...data.readyPlayers, user.uid];

    tx.update(roomRef, {
      players,
      readyPlayers,
      updatedAt: new Date(),
    });
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Bot logic
// ─────────────────────────────────────────────────────────────────────────────

function chooseBid(game: GameDoc, seatIndex: number): string {
  const hand = game.players[String(seatIndex)].hand;
  const existingBids = Object.values(game.players).map((p) => p.bid);
  const hasHokm = existingBids.includes('hokm');
  const hasSun = existingBids.includes('sun');
  const faceUpSuit = game.faceUpCard ? SUIT_OF(game.faceUpCard) : undefined;
  const canHokm = !hasHokm && faceUpSuit && hand.some((c) => SUIT_OF(c) === faceUpSuit);

  if (canHokm) return Math.random() < 0.3 ? 'hokm' : 'pass';
  if (!hasSun && !hasHokm) return Math.random() < 0.3 ? 'sun' : 'pass';
  return 'pass';
}

async function actOnTurn(bot: BotPlayer, game: GameDoc): Promise<void> {
  const seat = bot.seatIndex;
  if (game.turnIndex !== seat) return;

  try {
    if (game.status === 'bidding') {
      const bid = chooseBid(game, seat);
      console.log(`[Bot ${bot.displayName}] placing bid: ${bid}`);
      await httpsCallable(functions, 'placeBid')({ gameId: game.id, bid });
      return;
    }

    if (game.status === 'bonusClaim') {
      const player = game.players[String(seat)];
      if (player.isReady) return;
      const bonuses = detectBonuses(player.hand);
      console.log(`[Bot ${bot.displayName}] claiming ${bonuses.length} bonuses`);
      await httpsCallable(functions, 'claimBonuses')({ gameId: game.id, bonuses });
      return;
    }

    if (game.status === 'playing') {
      const card = findLowestLegalCard(game, seat);
      if (card) {
        console.log(`[Bot ${bot.displayName}] playing ${card}`);
        await httpsCallable(functions, 'playCard')({ gameId: game.id, card });
      } else {
        console.error(`[Bot ${bot.displayName}] no legal card found!`);
      }
      return;
    }

    if (game.status === 'roundEnd') {
      // Any player can trigger the next round. Only one bot should do it to
      // avoid race conditions; let seat 1 (first bot) handle it.
      if (seat === 1) {
        console.log(`[Bot ${bot.displayName}] dealing next round`);
        await httpsCallable(functions, 'dealNextRound')({ gameId: game.id });
      }
    }
  } catch (error) {
    console.error(`[Bot ${bot.displayName}] action failed:`, error);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main
// ─────────────────────────────────────────────────────────────────────────────

async function main(): Promise<void> {
  console.log(`🤖 Bloot Bot Harness — joining room with invite code ${code}`);

  // Find room by invite code
  const q = query(collection(db, 'rooms'), where('inviteCode', '==', code));
  const roomSnap = await getDocs(q);
  if (roomSnap.empty) {
    console.error('Room not found. Make sure the emulator is running and the invite code is correct.');
    process.exit(1);
  }

  const roomDoc = roomSnap.docs[0];
  const roomId = roomDoc.id;
  const roomData = roomDoc.data() as RoomDoc;
  console.log(`Found room ${roomId} (${roomData.name}) — waiting for 3 bot seats`);

  // Create 3 bots
  const botNames = ['Faisal', 'Omar', 'Khalid'];
  const bots: BotPlayer[] = [];

  for (let i = 0; i < 3; i++) {
    const user = (await signInAnonymously(auth)).user;
    const name = botNames[i];
    await ensureUserProfile(user, name);
    await joinRoomByCode(roomId, user, name);
    await toggleReady(roomId, user);

    const roomAfterJoin = (await getDoc(doc(db, 'rooms', roomId))).data() as RoomDoc;
    const player = roomAfterJoin.players.find((p) => p.uid === user.uid)!;

    const bot: BotPlayer = {
      user,
      seatIndex: player.seatIndex,
      team: player.team,
      displayName: name,
    };
    bots.push(bot);
    console.log(`  ✓ ${name} joined as seat ${bot.seatIndex}, team ${bot.team}, ready`);
  }

  // Wait for the game to start
  const roomUnsub = onSnapshot(doc(db, 'rooms', roomId), async (snap) => {
    const data = snap.data() as RoomDoc | undefined;
    if (!data) return;

    if (data.status === 'playing' && data.gameId) {
      roomUnsub();
      console.log(`Game started: ${data.gameId}`);
      watchGame(data.gameId, bots);
    }
  });

  console.log('Waiting for host to start the game...');
}

function watchGame(gameId: string, bots: BotPlayer[]): void {
  const gameRef = doc(db, 'games', gameId);

  const unsub = onSnapshot(gameRef, async (snap) => {
    const game = snap.data() as GameDoc | undefined;
    if (!game) return;

    // Update bot seat info from authoritative game doc (in case of rejoins)
    for (const bot of bots) {
      for (const [seatStr, player] of Object.entries(game.players)) {
        if (player.uid === bot.user.uid) {
          bot.seatIndex = parseInt(seatStr, 10);
          bot.team = player.team;
          break;
        }
      }
    }

    if (game.status === 'gameEnd') {
      console.log(
        `🏁 Game over! Final score — Team A: ${game.teamAScore}, Team B: ${game.teamBScore}`
      );
      unsub();
      process.exit(0);
    }

    if (game.status === 'trickEnd' || game.status === 'dealing') {
      // The scheduled autoPlay function or host will advance these states.
      return;
    }

    const activeBot = bots.find((b) => b.seatIndex === game.turnIndex);
    if (activeBot) {
      // Small delay so the action feels human and avoids racing the host.
      await new Promise((r) => setTimeout(r, 800 + Math.floor(Math.random() * 1200)));
      await actOnTurn(activeBot, { ...game, id: gameId });
    }
  });
}

main().catch((err) => {
  console.error('Harness failed:', err);
  process.exit(1);
});
