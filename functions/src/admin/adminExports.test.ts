import * as admin from './index';
import * as root from '../index';

describe('Admin function exports', () => {
  it('exports all expected admin functions', () => {
    expect(admin.suspendUser).toBeDefined();
    expect(admin.banUser).toBeDefined();
    expect(admin.resetUserCoins).toBeDefined();
    expect(admin.forceLogoutUser).toBeDefined();
    expect(admin.resolveReport).toBeDefined();
    expect(admin.escalateReport).toBeDefined();
    expect(admin.forceCloseRoom).toBeDefined();
    expect(admin.transferRoomOwnership).toBeDefined();
    expect(admin.adminEndStream).toBeDefined();
    expect(admin.muteInStream).toBeDefined();
    expect(admin.removeFromStream).toBeDefined();
    expect(admin.warnHost).toBeDefined();
    expect(admin.suspendHost).toBeDefined();
    expect(admin.forceEndGame).toBeDefined();
    expect(admin.rematchGame).toBeDefined();
    expect(admin.adjustBalance).toBeDefined();
    expect(admin.issueRefund).toBeDefined();
    expect(admin.createAchievement).toBeDefined();
    expect(admin.updateAchievement).toBeDefined();
    expect(admin.deleteAchievement).toBeDefined();
    expect(admin.assignAchievement).toBeDefined();
    expect(admin.recalculateLeaderboard).toBeDefined();
    expect(admin.resetLeaderboard).toBeDefined();
    expect(admin.sendNotification).toBeDefined();
    expect(admin.sendBroadcast).toBeDefined();
    expect(admin.updateSettings).toBeDefined();
    expect(admin.addAdmin).toBeDefined();
    expect(admin.removeAdmin).toBeDefined();
    expect(admin.updateAdminRole).toBeDefined();
    expect(admin.seedFirstSuperAdmin).toBeDefined();
  });

  it('exports search keyword sync triggers', () => {
    expect(root.syncUserSearchKeywords).toBeDefined();
    expect(root.syncReportSearchKeywords).toBeDefined();
  });
});
