/*
  Seed the Firestore games/sim_1 document used for emulator smoke tests.

  Run from the functions directory with the service account env var set:
    GOOGLE_APPLICATION_CREDENTIALS=../env/bloot-89b2b-firebase-adminsdk-fbsvc-b70047e82d.json \
      node scripts/seed_sim_1.js
*/

const admin = require('firebase-admin');
const { BalootEngine, BalootSerializer } = require('../lib/engine');

admin.initializeApp();
const db = admin.firestore();
db.settings({ ignoreUndefinedProperties: true });

const engine = new BalootEngine();
const players = [
  { uid: 'sim_p0', name: 'Me', displayName: 'Me', team: 'A', isBot: false },
  { uid: 'sim_p1', name: 'Bot1', displayName: 'Bot1', team: 'B', isBot: true },
  { uid: 'sim_p2', name: 'Bot2', displayName: 'Bot2', team: 'A', isBot: true },
  { uid: 'sim_p3', name: 'Bot3', displayName: 'Bot3', team: 'B', isBot: true },
];

const match = engine.createMatch(players, { safeMode: true, autoDeclare: true });
engine.startHand(match);
engine.applyBid(match, match.state.firstPlayer, { type: 'sun' });

const engineState = new BalootSerializer().serializeMatch(match);

const gamePlayers = engineState.players.map((p, index) => ({
  uid: p.uid,
  name: p.displayName || p.name,
  avatarUrl: '',
  team: p.team,
  seatIndex: index,
  hand: engineState.state.hands[String(index)],
  takenCards: [],
  tricksWon: 0,
  bid: null,
  isActive: true,
  isMuted: false,
  hasCamera: false,
  isTop: false,
  isConnected: true,
  isSpeaking: false,
}));

const mySeatIndex = 0;
const doc = {
  id: 'sim_1',
  roomId: 'sim_1',
  status: 'playing',
  turnIndex: engineState.state.turn,
  mySeatIndex,
  myHand: engineState.state.hands[String(mySeatIndex)],
  playedCards: [null, null, null, null],
  scoreUs: 0,
  scoreThem: 0,
  teamAScore: 0,
  teamBScore: 0,
  trump: engineState.state.trump || 'hearts',
  currentRound: 1,
  targetScore: 152,
  dealerIndex: engineState.dealer,
  faceUpCard: engineState.state.topCard,
  biddingTeam: engineState.state.buyer != null ? `team_${String.fromCharCode(65 + engineState.state.buyer % 2)}` : null,
  fellTeam: null,
  currentTrick: null,
  agoraChannelName: 'sim_1',
  engineState,
  players: gamePlayers,
  playerUids: players.map((p) => p.uid),
  updatedAt: admin.firestore.FieldValue.serverTimestamp(),
};

db.collection('games')
  .doc('sim_1')
  .set(doc)
  .then(() => {
    console.log('Seeded games/sim_1');
    console.log(`Phase: ${engineState.state.phase}, turn: ${engineState.state.turn}, buyer: ${engineState.state.buyer}`);
    process.exit(0);
  })
  .catch((err) => {
    console.error('Failed to seed games/sim_1:', err);
    process.exit(1);
  });
