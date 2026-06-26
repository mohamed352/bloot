import type { Timestamp } from 'firebase/firestore';

export type AdminRole = 'super_admin' | 'moderator' | 'support';
export type Permission = 'view' | 'moderate' | 'manage' | 'super';

export const ROLE_PERMISSIONS: Record<AdminRole, Permission[]> = {
  support: ['view', 'moderate'],
  moderator: ['view', 'moderate', 'manage'],
  super_admin: ['view', 'moderate', 'manage', 'super'],
};

export interface AdminDoc {
  uid: string;
  email: string;
  displayName: string;
  role: AdminRole;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

export interface AppUser {
  uid: string;
  phoneNumber?: string;
  displayName: string;
  username: string;
  avatarUrl?: string;
  bio?: string;
  region?: string;
  favoriteMode?: 'sun' | 'hokm' | 'both';
  level: number;
  xp: number;
  xpToNextLevel: number;
  coins: number;
  gamesPlayed: number;
  gamesWon: number;
  sunGamesPlayed: number;
  sunGamesWon: number;
  hokmGamesPlayed: number;
  hokmGamesWon: number;
  followersCount: number;
  followingCount: number;
  isOnline: boolean;
  lastSeen: Timestamp;
  fcmToken?: string;
  achievements?: Record<string, Timestamp>;
  settings?: UserSettings;
  createdAt: Timestamp;
  updatedAt: Timestamp;
  suspended?: boolean;
  banned?: boolean;
}

export interface UserSettings {
  voiceChat?: boolean;
  camera?: boolean;
  speakerMode?: string;
  autoRotateGame?: boolean;
  gameSpeedDefault?: string;
  soundEffects?: boolean;
  backgroundMusic?: boolean;
  showOnlineStatus?: boolean;
  profileVisibility?: string;
  notifyRoomInvitations?: boolean;
  notifyNewFollowers?: boolean;
  notifyGameResults?: boolean;
}

export interface Room {
  id: string;
  name: string;
  type: 'private' | 'public' | 'stream';
  creatorUid: string;
  status: 'waiting' | 'playing' | 'finished';
  password?: string;
  voiceEnabled: boolean;
  cameraEnabled: boolean;
  allowSpectators: boolean;
  minLevel: number;
  gameSpeed: string;
  players: RoomPlayer[];
  playerUids: string[];
  teamA: string[];
  teamB: string[];
  readyPlayers: string[];
  currentPlayerCount: number;
  maxPlayers: number;
  agoraChannelName: string;
  agoraToken: string;
  inviteCode: string;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

export interface RoomPlayer {
  uid: string;
  displayName: string;
  avatarUrl?: string;
  team: 'A' | 'B';
  seatIndex: number;
  isReady: boolean;
  isMicOn: boolean;
  isCameraOn: boolean;
  joinedAt: Timestamp;
}

export interface Stream {
  id: string;
  roomId: string;
  hostUid: string;
  hostName: string;
  hostAvatar?: string;
  title: string;
  description?: string;
  type: 'baloot' | 'casual';
  status: 'live' | 'paused' | 'ended';
  viewerCount: number;
  peakViewerCount: number;
  totalLikes: number;
  totalGifts: number;
  tags?: string[];
  language: 'ar' | 'en' | 'mixed';
  agoraChannelName: string;
  agoraToken: string;
  thumbnailUrl?: string;
  startedAt: Timestamp;
  endedAt?: Timestamp;
  updatedAt: Timestamp;
}


export interface Game {
  id: string;
  roomId: string;
  gameType: 'sun' | 'hokm';
  status: string;
  players: Record<string, GamePlayer>;
  teamAScore: number;
  teamBScore: number;
  currentRound: number;
  totalRounds: number;
  currentTrick?: Record<string, unknown>;
  tricksPlayed: number;
  trumpSuit?: string;
  hokmBidder?: number;
  targetScore: number;
  turnIndex: number;
  turnTimerStart?: Timestamp;
  turnTimeLimit: number;
  gameLog?: unknown[];
  startedAt: Timestamp;
  endedAt?: Timestamp;
  updatedAt: Timestamp;
}

export interface GamePlayer {
  uid: string;
  displayName: string;
  avatarUrl?: string;
  team: 'A' | 'B';
  hand?: string[];
  tricksWon: number;
  score: number;
}

export interface Report {
  id: string;
  reporterUid: string;
  reportedUid: string;
  type: 'user' | 'room' | 'stream' | 'message';
  reason: string;
  description?: string;
  referenceId?: string;
  status: 'pending' | 'reviewed' | 'resolved' | 'dismissed';
  resolution?: string;
  resolvedBy?: string;
  createdAt: Timestamp;
  resolvedAt?: Timestamp;
}

export interface CoinTransaction {
  id: string;
  uid: string;
  type: string;
  amount: number;
  balanceAfter: number;
  description?: string;
  descriptionAr?: string;
  referenceType?: string;
  referenceId?: string;
  counterpartyUid?: string;
  metadata?: Record<string, unknown>;
  createdAt: Timestamp;
}

export interface Achievement {
  id: string;
  name: string;
  nameAr: string;
  description: string;
  descriptionAr: string;
  iconUrl: string;
  iconInactiveUrl: string;
  category: string;
  rarity: string;
  xpReward: number;
  coinReward: number;
  conditionType: string;
  conditionThreshold: number;
  isSecret: boolean;
  displayOrder: number;
  isActive: boolean;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

export interface Leaderboard {
  id: string;
  type: 'weekly' | 'monthly' | 'allTime';
  period: string;
  gameType: 'sun' | 'hokm' | 'overall';
  metric: string;
  startDate: Timestamp;
  endDate?: Timestamp;
  status: 'active' | 'finalized' | 'archived';
  entries: LeaderboardEntry[];
  totalParticipants: number;
  prizes?: Record<string, { coins?: number; xp?: number }>;
  updatedAt: Timestamp;
  finalizedAt?: Timestamp;
}

export interface LeaderboardEntry {
  rank: number;
  uid: string;
  displayName: string;
  avatarUrl?: string;
  level: number;
  value: number;
  previousRank?: number;
  change?: string;
}

export interface Notification {
  id: string;
  uid: string;
  type: string;
  title: string;
  titleAr: string;
  body: string;
  bodyAr: string;
  imageUrl?: string;
  data?: Record<string, unknown>;
  isRead: boolean;
  isPushed: boolean;
  pushStatus?: string;
  priority: 'high' | 'normal' | 'low';
  expiresAt?: Timestamp;
  createdAt: Timestamp;
  readAt?: Timestamp;
  pushedAt?: Timestamp;
}

export interface SystemSettings {
  id: string;
  maintenanceMode?: boolean;
  allowNewSignups?: boolean;
  defaultCoinPackages?: CoinPackage[];
  featureFlags?: Record<string, boolean>;
  updatedAt: Timestamp;
  updatedBy?: string;
}

export interface CoinPackage {
  id: string;
  coinAmount: number;
  priceUsd: number;
  bonusCoins?: number;
  isPopular?: boolean;
}

export interface AdminLog {
  id: string;
  actorUid: string;
  actorEmail?: string;
  action: string;
  targetType: string;
  targetId: string;
  payload?: Record<string, unknown>;
  createdAt: Timestamp;
}

export interface DashboardStats {
  activePlayersNow: number;
  activePlayersChange: number;
  liveStreams: number;
  totalViewers: number;
  gamesInProgress: number;
  activeRooms: number;
  openReports: number;
  reportsChange: number;
  dailyRevenue: number;
  weeklyRevenue: number;
}
