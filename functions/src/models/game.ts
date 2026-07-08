import { Timestamp } from 'firebase-admin/firestore';

export type GameStatus =
  | 'dealing'
  | 'bidding'
  | 'bonusClaim'
  | 'playing'
  | 'trickEnd'
  | 'roundEnd'
  | 'gameEnd';

export type GameType = 'sun' | 'hokm' | 'ashkal';

export type Bid = 'pass' | 'sun' | 'hokm' | 'ashkal';

export type Suit = 'hearts' | 'diamonds' | 'clubs' | 'spades';

/** Legacy 52-card bonus claim; kept for type compatibility but unused by the 32-card engine. */
export interface BonusClaim {
  type: 'bnaga' | 'mosal' | 'sira' | 'fifty' | 'hundred' | 'fourAces';
  points: number;
  cards: CardString[];
  description?: string;
}

export type CardString = string;

export interface PlayerState {
  uid: string;
  displayName: string;
  avatarUrl: string;
  team: 'A' | 'B';
  hand: CardString[];
  takenCards: CardString[];
  tricksWon: number;
  bid: Bid | null;
  isReady: boolean;
  bonuses: BonusClaim[] | null;
  isConnected: boolean;
  /** Whether the player's microphone is muted. */
  isMuted?: boolean;
  /** Whether the player's camera is enabled. */
  hasCamera?: boolean;
  /** Agora UID used for voice/video in this game. */
  agoraUid?: number;
  /** Whether this player is a bot (single-device testing). */
  isBot?: boolean;
  /** Bot skill level. */
  level?: string;
}

export interface CurrentTrick {
  trickNumber: number;
  trickLeaderIndex: number;
  leadingSuit: Suit | null;
  cards: Record<string, CardString | null>;
  /** Seat index of the player who won this trick, set when the trick completes. */
  winnerSeat?: number;
}

export interface GameEvent {
  type: 'deal' | 'bid' | 'playCard' | 'trickWin' | 'roundEnd' | 'gameEnd' | 'bonusClaim';
  seatIndex: number;
  data: Record<string, unknown>;
  timestamp: Timestamp;
}

export interface GameDocument {
  id: string;
  roomId: string;
  agoraChannelName?: string;
  status: GameStatus;
  gameType: GameType | null;
  targetScore: number;
  currentRound: number;
  dealerIndex: number;
  turnIndex: number;
  turnTimerStart: Timestamp | null;
  turnTimeLimit: number;
  trumpSuit: Suit | null;
  faceUpCard: CardString | null;
  hokmBidder: number | null;
  sunBidder: number | null;
  biddingTeam: 'A' | 'B' | null;
  teamAScore: number;
  teamBScore: number;
  roundTricksA: number;
  roundTricksB: number;
  currentTrick: CurrentTrick;
  players: Record<string, PlayerState>;
  /** UIDs of all participants; used by Firestore security rules for access control. */
  playerUids: string[];
  /** Per-seat bids stored for the UI (the engine only keeps the winning bid). */
  playerBids?: Record<string, Bid>;
  /** Resolved bonus points after bonus claim phase (legacy 52-card field; unused). */
  resolvedBonuses?: { teamA: number; teamB: number } | null;
  /** Authoritative 32-card engine state serialized as JSON. */
  engineState?: Record<string, unknown>;
  /** Team that fell in the last completed round, if any. */
  fellTeam?: 'A' | 'B' | null;
  gameLog: GameEvent[];
  createdAt: Timestamp;
  updatedAt: Timestamp;
  endedAt: Timestamp | null;
}
