import type { BalootCard, BalootSuit } from './balootCard';
import type { BalootMode, BidActionType, ProjectType, ViolationType } from './balootRules';

export type BalootPhase = 'bidding' | 'projectDeclaration' | 'doubling' | 'playing' | 'handEnd' | 'matchEnd';

export interface TrickPlay {
  seat: number;
  card: BalootCard;
}

export interface CompletedTrick {
  plays: TrickPlay[];
  winner: number;
  points: number;
}

export interface ProjectClaim {
  seat: number;
  type: ProjectType;
  cards: BalootCard[];
  revealed: boolean;
}

export interface BestBid {
  type: BidActionType;
  seat: number;
  suit?: BalootSuit;
}

export interface BiddingState {
  round: number;
  turn: number;
  spoken: number;
  best?: BestBid;
}

export interface DoublingState {
  turn: number;
  stage: string;
  nextLevel: number;
}

export interface QatClaimResult {
  type: ViolationType;
  typeName: string;
  failed: boolean;
  claimSeat: number;
  violSeat?: number;
  winTeam?: number;
  violCard?: BalootCard;
  trickIndex?: number;
  provedBy?: BalootCard;
}

export interface ViolationRecord {
  seat: number;
  card: BalootCard;
  trickIndex: number;
  type: ViolationType;
  escaped: BalootCard[];
  confirmed: boolean;
  provedBy?: BalootCard;
}

export interface HandResult {
  qaid: [number, number];
  pts: [number, number];
  trickWins: [number, number];
  capotTeam?: number;
  buyerLost: boolean;
  safeSaved: boolean;
  projQaid: [number, number];
  balootQaid: [number, number];
  doubleLevel: number;
  qatClaim?: QatClaimResult;
  sawa?: {
    seat: number;
    valid: boolean;
    hands?: BalootCard[][];
  };
}

export interface BalootPlayerConfig {
  name: string;
  isBot?: boolean;
  level?: string;
  uid?: string;
  displayName?: string;
  avatarUrl?: string;
  team?: 'A' | 'B';
  agoraUid?: number;
  isMuted?: boolean;
  hasCamera?: boolean;
  isConnected?: boolean;
}

export function teamOf(seat: number): number {
  return seat % 2;
}

export class BalootHandState {
  phase: BalootPhase = 'bidding';
  hands: BalootCard[][] = [[], [], [], []];
  topCard!: BalootCard;
  rest: BalootCard[] = [];
  firstPlayer = 0;

  mode?: BalootMode;
  trump?: BalootSuit;
  buyer?: number;
  ashkal = false;

  bidding!: BiddingState;
  currentTrick: TrickPlay[] = [];
  trickHistory: CompletedTrick[] = [];
  leader = 0;
  turn = 0;

  projects: ProjectClaim[] = [];
  countedProjects: ProjectClaim[] = [];
  droppedProjects: ProjectClaim[] = [];

  pendingAnnounce: ProjectClaim[] = [];
  pendingReveal: ProjectClaim[] = [];
  announcedProjects: ProjectClaim[] = [];
  revealedProjects: ProjectClaim[] = [];

  balootState?: { seat: number; rank: string; trickIndex: number };
  balootTeam?: number;
  balootSeat?: number;

  awaitingDeclare = false;
  declareSeats: number[] = [];
  declarations: Record<number, ProjectType[]> = {};

  doubleLevel = 1;
  doubleTeam?: number;
  awaitingDouble = false;
  doubling?: DoublingState;

  violation?: ViolationRecord;
  pendingViolations: ViolationRecord[] = [];

  voids: Set<BalootSuit>[] = [new Set(), new Set(), new Set(), new Set()];
  playedCards: BalootCard[] = [];

  result?: HandResult;
}

export class BalootMatch {
  players: BalootPlayerConfig[];
  safeMode: boolean;
  autoDeclare: boolean;

  totals: [number, number] = [0, 0];
  dealer = 0;
  handsPlayed = 0;
  handResults: Record<string, unknown>[] = [];
  state?: BalootHandState;
  matchOver = false;
  winnerTeam?: number;

  constructor(options: {
    players: BalootPlayerConfig[];
    safeMode?: boolean;
    autoDeclare?: boolean;
  }) {
    this.players = options.players;
    this.safeMode = options.safeMode ?? false;
    this.autoDeclare = options.autoDeclare ?? false;
  }
}
