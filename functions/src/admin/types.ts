export interface SuspendUserInput {
  uid: string;
  suspended: boolean;
}

export interface BanUserInput {
  uid: string;
  banned: boolean;
}

export interface ResetUserCoinsInput {
  uid: string;
  coins: number;
}

export interface ForceLogoutUserInput {
  uid: string;
}

export interface ResolveReportInput {
  reportId: string;
  resolution: string;
}

export interface EscalateReportInput {
  reportId: string;
}

export interface ForceCloseRoomInput {
  roomId: string;
}

export interface TransferRoomOwnershipInput {
  roomId: string;
  newOwnerUid: string;
}

export interface EndStreamInput {
  streamId: string;
}

export interface MuteInStreamInput {
  streamId: string;
  uid: string;
  muted: boolean;
}

export interface RemoveFromStreamInput {
  streamId: string;
  uid: string;
}

export interface ForceEndGameInput {
  gameId: string;
}

export interface RematchGameInput {
  gameId: string;
}

export interface AdjustBalanceInput {
  uid: string;
  amount: number;
  description?: string;
}

export interface IssueRefundInput {
  transactionId: string;
}

export interface CreateAchievementInput {
  id: string;
  name: string;
  nameAr: string;
  description: string;
  descriptionAr: string;
  iconUrl: string;
  iconInactiveUrl: string;
  category: string;
  rarity: string;
  xpReward?: number;
  coinReward?: number;
  conditionType: string;
  conditionThreshold: number;
  isSecret?: boolean;
  displayOrder?: number;
  isActive?: boolean;
}

export interface UpdateAchievementInput {
  achievementId: string;
  updates: Partial<Omit<CreateAchievementInput, 'id'>>;
}

export interface DeleteAchievementInput {
  achievementId: string;
}

export interface AssignAchievementInput {
  achievementId: string;
  uid: string;
}

export interface RecalculateLeaderboardInput {
  leaderboardId: string;
}

export interface ResetLeaderboardInput {
  leaderboardId: string;
}

export interface SendNotificationInput {
  uid: string;
  title: string;
  titleAr?: string;
  body: string;
  bodyAr?: string;
  priority?: 'high' | 'normal' | 'low';
  imageUrl?: string;
  data?: Record<string, string>;
}

export interface SendBroadcastInput {
  title: string;
  titleAr?: string;
  body: string;
  bodyAr?: string;
  priority?: 'high' | 'normal' | 'low';
  imageUrl?: string;
  data?: Record<string, string>;
}

export interface UpdateSettingsInput {
  settingsId: string;
  updates: Record<string, unknown>;
}

export interface AddAdminInput {
  uid: string;
  email: string;
  role: 'super_admin' | 'moderator' | 'support';
}

export interface RemoveAdminInput {
  uid: string;
}

export interface UpdateAdminRoleInput {
  uid: string;
  role: 'super_admin' | 'moderator' | 'support';
}

export interface SuccessResponse {
  success: boolean;
}
