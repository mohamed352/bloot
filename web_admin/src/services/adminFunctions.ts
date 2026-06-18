import { httpsCallable } from 'firebase/functions';
import { functions } from './firebase';

const call = <I, O>(name: string) => httpsCallable<I, O>(functions, name);

export const adminFunctions = {
  seedFirstSuperAdmin: call<Record<string, never>, { success: boolean; role: string }>('seedFirstSuperAdmin'),
  // Users
  suspendUser: call<{ uid: string; suspended: boolean }, { success: boolean }>('suspendUser'),
  banUser: call<{ uid: string; banned: boolean }, { success: boolean }>('banUser'),
  resetUserCoins: call<{ uid: string; coins: number }, { success: boolean }>('resetUserCoins'),
  forceLogoutUser: call<{ uid: string }, { success: boolean }>('forceLogoutUser'),

  // Reports
  resolveReport: call<{ reportId: string; resolution: string }, { success: boolean }>('resolveReport'),
  dismissReport: call<{ reportId: string }, { success: boolean }>('dismissReport'),
  escalateReport: call<{ reportId: string }, { success: boolean }>('escalateReport'),

  // Rooms
  forceCloseRoom: call<{ roomId: string }, { success: boolean }>('forceCloseRoom'),
  transferRoomOwnership: call<{ roomId: string; newOwnerUid: string }, { success: boolean }>(
    'transferRoomOwnership'
  ),

  // Streams
  adminEndStream: call<{ streamId: string }, { success: boolean }>('adminEndStream'),
  muteInStream: call<{ streamId: string; uid: string; muted: boolean }, { success: boolean }>(
    'muteInStream'
  ),
  removeFromStream: call<{ streamId: string; uid: string }, { success: boolean }>('removeFromStream'),
  warnHost: call<{ streamId: string }, { success: boolean }>('warnHost'),
  suspendHost: call<{ streamId: string }, { success: boolean }>('suspendHost'),

  // Tournaments
  adminCreateTournament: call<Record<string, unknown>, { success: boolean; tournamentId: string }>('adminCreateTournament'),
  adminUpdateTournament: call<{ tournamentId: string; updates: Record<string, unknown> }, { success: boolean }>(
    'adminUpdateTournament'
  ),
  adminCancelTournament: call<{ tournamentId: string }, { success: boolean }>('adminCancelTournament'),
  adminStartTournament: call<{ tournamentId: string }, { success: boolean }>('adminStartTournament'),

  // Games
  forceEndGame: call<{ gameId: string }, { success: boolean }>('forceEndGame'),
  rematchGame: call<{ gameId: string }, { success: boolean }>('rematchGame'),

  // Economy
  adjustBalance: call<{ uid: string; amount: number; description?: string }, { success: boolean }>(
    'adjustBalance'
  ),
  issueRefund: call<{ transactionId: string }, { success: boolean }>('issueRefund'),

  // Achievements
  createAchievement: call<Record<string, unknown>, { success: boolean }>('createAchievement'),
  updateAchievement: call<{ achievementId: string; updates: Record<string, unknown> }, { success: boolean }>(
    'updateAchievement'
  ),
  deleteAchievement: call<{ achievementId: string }, { success: boolean }>('deleteAchievement'),
  assignAchievement: call<{ achievementId: string; uid: string }, { success: boolean }>('assignAchievement'),

  // Leaderboards
  recalculateLeaderboard: call<{ leaderboardId: string }, { success: boolean }>('recalculateLeaderboard'),
  resetLeaderboard: call<{ leaderboardId: string }, { success: boolean }>('resetLeaderboard'),

  // Notifications
  sendNotification: call<
    { uid: string; title: string; titleAr?: string; body: string; bodyAr?: string; priority?: string; imageUrl?: string; data?: Record<string, unknown> },
    { success: boolean }
  >('sendNotification'),
  sendBroadcast: call<
    { title: string; titleAr?: string; body: string; bodyAr?: string; priority?: string; imageUrl?: string; data?: Record<string, unknown> },
    { success: boolean }
  >('sendBroadcast'),

  // Settings
  updateSettings: call<{ settingsId: string; updates: Record<string, unknown> }, { success: boolean }>(
    'updateSettings'
  ),
  addAdmin: call<{ uid: string; email: string; role: string }, { success: boolean }>('addAdmin'),
  removeAdmin: call<{ uid: string }, { success: boolean }>('removeAdmin'),
  updateAdminRole: call<{ uid: string; role: string }, { success: boolean }>('updateAdminRole'),
};
