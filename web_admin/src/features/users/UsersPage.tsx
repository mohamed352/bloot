import { useState } from 'react';
import { useAuthStore } from '../../stores/authStore';
import { useUsers } from '../../hooks/useUsers';
import { useAdminRole } from '../../hooks/useAdminRole';
import { adminFunctions } from '../../services/adminFunctions';
import { exportToCsv } from '../../utils/csvExport';
import { PageHeader } from '../../components/PageHeader';
import { DataTable } from '../../components/DataTable';
import { Badge } from '../../components/Badge';
import { Button } from '../../components/Button';
import { Modal } from '../../components/Modal';
import { useToastStore } from '../../stores/toastStore';
import { formatDate, formatNumber } from '../../utils/formatters';
import type { AppUser } from '../../types';

export function UsersPage() {
  const currentUid = useAuthStore((s) => s.user?.uid);
  const { role, hasPermission } = useAdminRole(currentUid);
  const addToast = useToastStore((s) => s.addToast);
  const [selectedUser, setSelectedUser] = useState<AppUser | null>(null);
  const [loadingAction, setLoadingAction] = useState<string | null>(null);

  const {
    items: users,
    isLoading,
    isLoadingMore,
    hasMore,
    loadMore,
    search,
    setSearch,
    refresh,
  } = useUsers(0, '');

  const canManageUsers = hasPermission('manage');

  const handleAction = async (action: () => Promise<unknown>, label: string) => {
    setLoadingAction(label);
    try {
      await action();
      addToast(`${label} succeeded`, 'success');
      refresh();
      setSelectedUser(null);
    } catch (err) {
      addToast((err as Error).message, 'error');
    } finally {
      setLoadingAction(null);
    }
  };

  const handleExportCsv = () => {
    if (users.length === 0) {
      addToast('No users to export', 'warning');
      return;
    }

    exportToCsv(
      `users-${new Date().toISOString().slice(0, 10)}.csv`,
      users.map((u) => ({
        uid: u.uid,
        displayName: u.displayName,
        username: u.username,
        status: u.banned ? 'banned' : u.suspended ? 'suspended' : 'active',
        level: u.level,
        coins: u.coins,
        gamesPlayed: u.gamesPlayed,
        gamesWon: u.gamesWon,
        createdAt: formatDate(u.createdAt),
      })),
      [
        { key: 'uid', header: 'UID' },
        { key: 'displayName', header: 'Display Name' },
        { key: 'username', header: 'Username' },
        { key: 'status', header: 'Status' },
        { key: 'level', header: 'Level' },
        { key: 'coins', header: 'Coins' },
        { key: 'gamesPlayed', header: 'Games Played' },
        { key: 'gamesWon', header: 'Games Won' },
        { key: 'createdAt', header: 'Joined' },
      ]
    );
    addToast('CSV exported', 'success');
  };

  const columns = [
    { key: 'displayName', header: 'User' },
    { key: 'username', header: 'Username' },
    {
      key: 'status',
      header: 'Status',
      render: (u: AppUser) => (
        <div className="flex gap-2">
          {u.banned && <Badge variant="danger">Banned</Badge>}
          {u.suspended && <Badge variant="warning">Suspended</Badge>}
          {u.isOnline ? <Badge variant="success">Online</Badge> : <Badge>Offline</Badge>}
        </div>
      ),
    },
    { key: 'level', header: 'Level' },
    { key: 'coins', header: 'Coins', render: (u: AppUser) => formatNumber(u.coins) },
    {
      key: 'games',
      header: 'Games',
      render: (u: AppUser) => `${u.gamesWon}/${u.gamesPlayed}`,
    },
    {
      key: 'createdAt',
      header: 'Joined',
      render: (u: AppUser) => formatDate(u.createdAt),
    },
    {
      key: 'actions',
      header: 'Actions',
      render: (u: AppUser) => (
        <Button size="sm" variant="secondary" onClick={() => setSelectedUser(u)}>
          Manage
        </Button>
      ),
    },
  ];

  return (
    <div>
      <PageHeader
        title="Users"
        subtitle="Manage player accounts, suspensions, and balances"
      />

      <div className="mb-4 flex gap-3">
        <input
          type="text"
          placeholder="Search by name, username, or UID"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="flex-1 max-w-md px-4 py-2 rounded-lg bg-b-surface-elevated border border-b-border text-b-on-surface placeholder-b-on-surface-secondary focus:outline-none focus:border-b-purple"
        />
        <Button variant="secondary" onClick={handleExportCsv}>
          Export CSV
        </Button>
      </div>

      <div className="bg-b-surface-elevated rounded-xl border border-b-border overflow-hidden">
        <DataTable
          columns={columns}
          rows={users}
          keyExtractor={(u) => u.uid}
          isLoading={isLoading}
          onRowClick={(u) => setSelectedUser(u)}
        />
      </div>

      <div className="flex items-center justify-center mt-4">
        <Button
          variant="secondary"
          onClick={loadMore}
          disabled={!hasMore || isLoadingMore}
          isLoading={isLoadingMore}
        >
          {isLoadingMore ? 'Loading...' : hasMore ? 'Load More' : 'No More Users'}
        </Button>
      </div>

      <UserModal
        user={selectedUser}
        onClose={() => setSelectedUser(null)}
        loadingAction={loadingAction}
        onAction={handleAction}
        canManageUsers={canManageUsers}
        currentRole={role}
      />
    </div>
  );
}

function UserModal({
  user,
  onClose,
  loadingAction,
  onAction,
  canManageUsers,
  currentRole,
}: {
  user: AppUser | null;
  onClose: () => void;
  loadingAction: string | null;
  onAction: (action: () => Promise<unknown>, label: string) => void;
  canManageUsers: boolean;
  currentRole: string | null;
}) {
  const [coinAmount, setCoinAmount] = useState('');

  if (!user) return null;

  const supportDisabled = currentRole === 'support';

  return (
    <Modal isOpen={!!user} onClose={onClose} title={user.displayName || 'User Details'} size="md">
      <div className="space-y-4">
        <div className="grid grid-cols-2 gap-4">
          <div>
            <p className="text-xs text-b-on-surface-muted">UID</p>
            <p className="text-sm text-b-on-surface break-all">{user.uid}</p>
          </div>
          <div>
            <p className="text-xs text-b-on-surface-muted">Username</p>
            <p className="text-sm text-b-on-surface">{user.username}</p>
          </div>
          <div>
            <p className="text-xs text-b-on-surface-muted">Coins</p>
            <p className="text-sm text-b-on-surface">{formatNumber(user.coins)}</p>
          </div>
          <div>
            <p className="text-xs text-b-on-surface-muted">Level</p>
            <p className="text-sm text-b-on-surface">{user.level}</p>
          </div>
        </div>

        <div className="flex flex-wrap gap-2 pt-2">
          <Button
            variant={user.suspended ? 'secondary' : 'danger'}
            size="sm"
            isLoading={loadingAction === 'suspend'}
            disabled={!canManageUsers || supportDisabled}
            onClick={() => onAction(() => adminFunctions.suspendUser({ uid: user.uid, suspended: !user.suspended }), 'suspend')}
          >
            {user.suspended ? 'Unsuspend' : 'Suspend'}
          </Button>
          <Button
            variant={user.banned ? 'secondary' : 'danger'}
            size="sm"
            isLoading={loadingAction === 'ban'}
            disabled={!canManageUsers || supportDisabled}
            onClick={() => onAction(() => adminFunctions.banUser({ uid: user.uid, banned: !user.banned }), 'ban')}
          >
            {user.banned ? 'Unban' : 'Ban'}
          </Button>
          <Button
            variant="secondary"
            size="sm"
            isLoading={loadingAction === 'logout'}
            onClick={() => onAction(() => adminFunctions.forceLogoutUser({ uid: user.uid }), 'logout')}
          >
            Force Logout
          </Button>
        </div>

        <div className="flex items-end gap-2 pt-2">
          <div className="flex-1">
            <label className="block text-xs text-b-on-surface-muted mb-1">New Coin Balance</label>
            <input
              type="number"
              value={coinAmount}
              onChange={(e) => setCoinAmount(e.target.value)}
              disabled={!canManageUsers || supportDisabled}
              className="w-full px-3 py-2 rounded-lg bg-b-surface-muted border border-b-border text-b-on-surface focus:outline-none focus:border-b-purple disabled:opacity-50"
              placeholder="0"
            />
          </div>
          <Button
            isLoading={loadingAction === 'resetCoins'}
            disabled={!canManageUsers || supportDisabled}
            onClick={() =>
              onAction(
                () => adminFunctions.resetUserCoins({ uid: user.uid, coins: parseInt(coinAmount, 10) || 0 }),
                'resetCoins'
              )
            }
          >
            Reset Coins
          </Button>
        </div>

        {supportDisabled && (
          <p className="text-xs text-b-on-surface-muted">
            Account management actions are disabled for support accounts.
          </p>
        )}
      </div>
    </Modal>
  );
}
