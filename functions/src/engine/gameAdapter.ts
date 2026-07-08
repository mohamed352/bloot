import { BalootCard } from './balootCard';
import { BalootEngine } from './balootEngine';
import { BidActionType, ProjectType } from './balootRules';
import { SUIT_SYMBOLS } from './balootCard';
import { BalootMatch, BalootPlayerConfig, CompletedTrick, teamOf, TrickPlay } from './balootState';
import { BalootSerializer } from './balootSerializer';

const serializer = new BalootSerializer();

export type GameStatus =
  | 'dealing'
  | 'bidding'
  | 'bonusClaim'
  | 'playing'
  | 'trickEnd'
  | 'roundEnd'
  | 'gameEnd';

export interface RoomPlayer {
  uid: string;
  displayName: string;
  avatarUrl?: string;
  team: 'A' | 'B';
  seatIndex: number;
  isBot?: boolean;
  level?: string;
  isMuted?: boolean;
  hasCamera?: boolean;
  agoraUid?: number;
  isConnected?: boolean;
}

export interface GameDocument {
  id: string;
  roomId: string;
  status: GameStatus;
  gameType: string | null;
  targetScore: number;
  currentRound: number;
  dealerIndex: number;
  turnIndex: number;
  turnTimerStart: Date | null;
  turnTimeLimit: number;
  trumpSuit: string | null;
  faceUpCard: string | null;
  hokmBidder: number | null;
  sunBidder: number | null;
  biddingTeam: 'A' | 'B' | null;
  teamAScore: number;
  teamBScore: number;
  roundTricksA: number;
  roundTricksB: number;
  currentTrick: CurrentTrick;
  players: Record<string, PlayerState>;
  playerUids: string[];
  playerBids?: Record<string, string>;
  resolvedBonuses?: { teamA: number; teamB: number } | null;
  fellTeam?: 'A' | 'B' | null;
  engineState?: Record<string, unknown>;
  gameLog?: unknown[];
  createdAt: Date;
  updatedAt: Date;
  endedAt: Date | null;
  agoraChannelName?: string;
  trickEndDelayMs?: number;
  lastActionError?: string | null;
}

export interface PlayerState {
  uid: string;
  displayName: string;
  avatarUrl: string;
  team: 'A' | 'B';
  hand: string[];
  takenCards: string[];
  tricksWon: number;
  bid: string | null;
  isReady: boolean;
  bonuses: unknown[] | null;
  isConnected: boolean;
  isMuted: boolean;
  hasCamera: boolean;
  agoraUid?: number;
  isBot?: boolean;
  level?: string;
}

export interface CurrentTrick {
  trickNumber: number;
  trickLeaderIndex: number;
  leadingSuit: string | null;
  cards: Record<string, string | null>;
  winnerSeat?: number;
}

function suitSymbol(suit: string): string {
  return (SUIT_SYMBOLS as Record<string, string>)[suit] ?? suit;
}

function playerConfigFromRoomPlayer(p: RoomPlayer): BalootPlayerConfig {
  return {
    name: p.displayName,
    uid: p.uid,
    displayName: p.displayName,
    avatarUrl: p.avatarUrl ?? '',
    team: p.team,
    isBot: p.isBot ?? false,
    level: p.level ?? 'amateur',
    agoraUid: p.agoraUid,
    isMuted: p.isMuted,
    hasCamera: p.hasCamera,
  };
}

/**
 * Creates a fresh game document for a 32-card Saudi Baloot match.
 * The authoritative engine state is stored in `engineState`.
 */
export function createGameDocument(
  gameId: string,
  roomId: string,
  roomPlayers: RoomPlayer[],
  targetScore = 152,
  agoraChannelName?: string,
): GameDocument {
  const configs = roomPlayers.map(playerConfigFromRoomPlayer);
  const engine = new BalootEngine();
  const match = engine.createMatch(configs, { safeMode: true, autoDeclare: true });
  engine.startHand(match);

  const now = new Date();
  const game: GameDocument = {
    id: gameId,
    roomId,
    status: 'bidding',
    gameType: null,
    targetScore,
    currentRound: 1,
    dealerIndex: match.dealer,
    turnIndex: match.state!.bidding.turn,
    turnTimerStart: null,
    turnTimeLimit: 90,
    trumpSuit: null,
    faceUpCard: match.state!.topCard.key,
    hokmBidder: null,
    sunBidder: null,
    biddingTeam: null,
    teamAScore: 0,
    teamBScore: 0,
    roundTricksA: 0,
    roundTricksB: 0,
    currentTrick: emptyTrick(match.state!.turn),
    players: {},
    playerUids: roomPlayers.map((p) => p.uid),
    playerBids: {},
    resolvedBonuses: null,
    fellTeam: null,
    engineState: serializer.serializeMatch(match),
    gameLog: [],
    createdAt: now,
    updatedAt: now,
    endedAt: null,
    agoraChannelName,
  };

  syncEngineStateToDoc(game, match);
  return game;
}

export function loadMatch(game: GameDocument): BalootMatch {
  return serializer.deserializeMatch(game.engineState ?? {});
}

export function saveMatch(game: GameDocument, match: BalootMatch): void {
  game.engineState = serializer.serializeMatch(match);
  syncEngineStateToDoc(game, match);
}

/**
 * Derives UI-facing fields from the authoritative engine state.
 * Callers may override status when a trick has just completed and should be
 * shown as `trickEnd`.
 */
export function syncEngineStateToDoc(game: GameDocument, match: BalootMatch): void {
  const state = match.state;
  if (!state) return;

  game.dealerIndex = match.dealer;
  game.currentRound = match.handsPlayed + 1;
  game.teamAScore = match.totals[0];
  game.teamBScore = match.totals[1];

  if (state.phase === 'bidding') {
    game.status = 'bidding';
    game.turnIndex = state.bidding.turn;
    game.gameType = null;
    game.trumpSuit = null;
    game.hokmBidder = null;
    game.sunBidder = null;
    game.biddingTeam = null;
    game.faceUpCard = state.topCard.key;
    game.currentTrick = emptyTrick(state.turn);
  } else {
    const mode = state.mode!;
    const ashkal = state.ashkal;
    game.gameType = ashkal ? 'ashkal' : mode;
    game.trumpSuit = mode === 'hokum' ? suitSymbol(state.trump!) : null;
    game.faceUpCard = state.topCard.key;
    game.hokmBidder = mode === 'hokum' ? state.buyer! : null;
    game.sunBidder = mode === 'sun' || ashkal ? state.buyer! : null;
    const buyerConfig = match.players[state.buyer!];
    game.biddingTeam = buyerConfig?.team ?? null;

    if (state.phase === 'playing') {
      game.status = 'playing';
      game.turnIndex = state.turn;
      game.currentTrick = buildCurrentTrick(state);
    } else if (state.phase === 'handEnd') {
      game.status = 'roundEnd';
      game.turnIndex = state.turn;
      game.currentTrick = buildCurrentTrick(state);
      const result = state.result!;
      if (result.buyerLost && game.biddingTeam) {
        game.fellTeam = game.biddingTeam;
      } else {
        game.fellTeam = null;
      }
    } else if (state.phase === 'matchEnd') {
      game.status = 'gameEnd';
      game.turnIndex = state.turn;
      game.currentTrick = buildCurrentTrick(state);
      game.endedAt = new Date();
    }
  }

  game.players = buildPlayers(game, match);
}

/**
 * Forces the document into `trickEnd` status using the last completed trick.
 * The engine state already cleared the trick into history.
 */
export function setTrickEndStatus(game: GameDocument, match: BalootMatch): void {
  const state = match.state!;
  const lastTrick = state.trickHistory[state.trickHistory.length - 1];
  if (!lastTrick) return;
  game.status = 'trickEnd';
  game.turnIndex = lastTrick.winner;
  game.currentTrick = buildTrickFromCompleted(lastTrick, state.trickHistory.length);
}

function emptyTrick(leader: number): CurrentTrick {
  return {
    trickNumber: 1,
    trickLeaderIndex: leader,
    leadingSuit: null,
    cards: { '0': null, '1': null, '2': null, '3': null },
  };
}

function buildCurrentTrick(state: { trickHistory: CompletedTrick[]; currentTrick: TrickPlay[]; turn: number }): CurrentTrick {
  if (state.currentTrick.length > 0) {
    const cards: Record<string, string | null> = { '0': null, '1': null, '2': null, '3': null };
    for (const play of state.currentTrick) {
      cards[String(play.seat)] = play.card.key;
    }
    return {
      trickNumber: state.trickHistory.length + 1,
      trickLeaderIndex: state.currentTrick[0].seat,
      leadingSuit: suitSymbol(state.currentTrick[0].card.suit),
      cards,
    };
  }

  return {
    trickNumber: state.trickHistory.length + 1,
    trickLeaderIndex: state.turn,
    leadingSuit: null,
    cards: { '0': null, '1': null, '2': null, '3': null },
  };
}

function buildTrickFromCompleted(
  trick: CompletedTrick,
  trickNumber: number,
): CurrentTrick {
  const cards: Record<string, string | null> = { '0': null, '1': null, '2': null, '3': null };
  for (const play of trick.plays) {
    cards[String(play.seat)] = play.card.key;
  }
  return {
    trickNumber,
    trickLeaderIndex: trick.plays[0].seat,
    leadingSuit: suitSymbol(trick.plays[0].card.suit),
    cards,
    winnerSeat: trick.winner,
  };
}

function buildPlayers(game: GameDocument, match: BalootMatch): Record<string, PlayerState> {
  const state = match.state!;
  const result: Record<string, PlayerState> = {};

  const winsBySeat: Record<number, number> = { 0: 0, 1: 0, 2: 0, 3: 0 };
  const takenBySeat: Record<number, string[]> = { 0: [], 1: [], 2: [], 3: [] };

  for (const trick of state.trickHistory) {
    winsBySeat[trick.winner] = (winsBySeat[trick.winner] || 0) + 1;
    for (const play of trick.plays) {
      takenBySeat[trick.winner].push(play.card.key);
    }
  }

  for (let seat = 0; seat < 4; seat++) {
    const config = match.players[seat];
    const existing = game.players[String(seat)];
    const bid = game.playerBids?.[String(seat)] ?? null;
    result[String(seat)] = {
      uid: config?.uid ?? existing?.uid ?? '',
      displayName: config?.displayName ?? existing?.displayName ?? config?.name ?? '',
      avatarUrl: config?.avatarUrl ?? existing?.avatarUrl ?? '',
      team: config?.team ?? existing?.team ?? (seat % 2 === 0 ? 'A' : 'B'),
      hand: state.hands[seat].map((c) => c.key),
      takenCards: takenBySeat[seat],
      tricksWon: winsBySeat[seat],
      bid,
      isReady: existing?.isReady ?? false,
      bonuses: existing?.bonuses ?? null,
      isConnected: config?.isConnected ?? existing?.isConnected ?? true,
      isMuted: config?.isMuted ?? existing?.isMuted ?? false,
      hasCamera: config?.hasCamera ?? existing?.hasCamera ?? true,
      agoraUid: config?.agoraUid ?? existing?.agoraUid,
      isBot: config?.isBot ?? existing?.isBot ?? false,
    };
  }

  return result;
}

/**
 * Auto-resolves any open doubling auction by passing for every player in turn.
 * This keeps online games moving without a dedicated doubling UI.
 */
export function autoResolveDoubling(match: BalootMatch, engine: BalootEngine): void {
  let guard = 0;
  while (match.state?.awaitingDouble && match.state.doubling && guard < 10) {
    engine.applyDouble(match, match.state.doubling.turn, 'pass');
    guard++;
  }
}

/**
 * Maps a client-facing bid string to an engine bid action.
 */
export function parseBidAction(bid: string, topCard: BalootCard): { type: BidActionType; suit?: string } {
  if (bid === 'pass') return { type: 'pass' };
  if (bid === 'sun') return { type: 'sun' };
  if (bid === 'ashkal') return { type: 'ashkal' };
  if (bid === 'hokum') return { type: 'hokum', suit: topCard.suit };
  // Some callers may send "hokm-hearts" etc. in the future.
  if (bid.startsWith('hokum-')) {
    const suit = bid.split('-')[1];
    return { type: 'hokum', suit };
  }
  throw new Error(`Invalid bid: ${bid}`);
}

export function bidToString(type: BidActionType): string {
  return type;
}

/**
 * Converts a project-declaration payload (from the existing bonus claim UI) into
 * the engine's project types for the requesting seat.
 */
export function parseProjectTypes(bonuses: Array<{ type: string; cards?: string[] }>): ProjectType[] {
  const valid: ProjectType[] = ['sira', 'fifty', 'hundred', 'fourAces'];
  return bonuses
    .map((b) => b.type)
    .filter((t): t is ProjectType => valid.includes(t as ProjectType));
}

export function teamLetter(seat: number): 'A' | 'B' {
  return teamOf(seat) === 0 ? 'A' : 'B';
}
