import { useState } from 'react';
import { useQueryClient } from '@tanstack/react-query';
import { useAuthStore } from '../../stores/authStore';
import { useLeaderboards } from '../../hooks/useLeaderboards';
import { useAdminRole } from '../../hooks/useAdminRole';
import { adminFunctions } from '../../services/adminFunctions';
import { PageHeader } from '../../components/PageHeader';
import { DataTable } from '../../components/DataTable';
import { Badge } from '../../components/Badge';
import { Button } from '../../components/Button';
import { Modal } from '../../components/Modal';
import { useToastStore } from '../../stores/toastStore';
import { exportToCsv } from '../../utils/csvExport';
import { formatDate, formatNumber } from '../../utils/formatters';
import type { Leaderboard } from '../../types';

const tabs: { label: string; value?: Leaderboard['status'] }[] = [
  { label: 'All' },
  { label: 'Active', value: 'active' },
  { label: 'Finalized', value: 'finalized' },
  { label: 'Archived', value: 'archived' },
];

const statusVariant: Record<string, 'default' | 'success' | 'warning' | 'danger' | 'info'> = {
  active: 'success',
  finalized: 'info',
  archived: 'default',
};

export function LeaderboardsPage() {
  const queryClient = useQueryClient();
  const addToast = useToastStore((s) => s.addToast);
  const user = useAuthStore((s) => s.user);
  const { role } = useAdminRole(user?.uid);
  const [activeTab, setActiveTab] = useState<Leaderboard['status'] | undefined>(undefined);
  const [selected, setSelected] = useState<Leaderboard | null>(null);
  const [recalculatingId, setRecalculatingId] = useState<string | null>(null);
  const { data: leaderboards, isLoading } = useLeaderboards(activeTab);

  const refresh = () => queryClient.invalidateQueries({ queryKey: ['leaderboards'] });

  const handleExportCsv = () => {
    const rows = (leaderboards || []).map((l) => ({
      id: l.id,
      type: l.type,
      period: l.period,
      gameType: l.gameType,
      metric: l.metric,
      status: l.status,
      totalParticipants: l.totalParticipants,
      startDate: formatDate(l.startDate),
    }));
    exportToCsv('leaderboards.csv', rows, [
      { key: 'id', header: 'ID' },
      { key: 'type', header: 'Type' },
      { key: 'period', header: 'Period' },
      { key: 'gameType', header: 'Game' },
      { key: 'metric', header: 'Metric' },
      { key: 'status', header: 'Status' },
      { key: 'totalParticipants', header: 'Participants' },
      { key: 'startDate', header: 'Starts' },
    ]);
  };

  const handleRecalculate = async (id: string) => {
    setRecalculatingId(id);
    try {
      await adminFunctions.recalculateLeaderboard({ leaderboardId: id });
      addToast('Leaderboard recalculated', 'success');
      refresh();
    } catch (err) {
      addToast((err as Error).message, 'error');
    } finally {
      setRecalculatingId(null);
    }
  };

  const handleReset = async (id: string) => {
    if (!confirm('Reset this leaderboard? All entries will be cleared.')) return;
    setRecalculatingId(id);
    try {
      await adminFunctions.resetLeaderboard({ leaderboardId: id });
      addToast('Leaderboard reset', 'success');
      refresh();
    } catch (err) {
      addToast((err as Error).message, 'error');
    } finally {
      setRecalculatingId(null);
    }
  };

  const columns = [
    { key: 'type', header: 'Type', render: (l: Leaderboard) => <span className="capitalize">{l.type}</span> },
    { key: 'period', header: 'Period' },
    { key: 'gameType', header: 'Game', render: (l: Leaderboard) => <span className="capitalize">{l.gameType}</span> },
    { key: 'metric', header: 'Metric', render: (l: Leaderboard) => <span className="capitalize">{l.metric}</span> },
    {
      key: 'status',
      header: 'Status',
      render: (l: Leaderboard) => <Badge variant={statusVariant[l.status] || 'default'}>{l.status}</Badge>,
    },
    { key: 'totalParticipants', header: 'Participants', render: (l: Leaderboard) => formatNumber(l.totalParticipants) },
    { key: 'startDate', header: 'Starts', render: (l: Leaderboard) => formatDate(l.startDate) },
    {
      key: 'actions',
      header: 'Actions',
      render: (l: Leaderboard) => (
        <div className="flex gap-2">
          <Button size="sm" variant="secondary" onClick={() => setSelected(l)}>
            Entries
          </Button>
          <Button
            size="sm"
            variant="secondary"
            isLoading={recalculatingId === l.id}
            onClick={() => handleRecalculate(l.id)}
          >
            Recalc
          </Button>
          {role === 'super_admin' && (
            <Button size="sm" variant="danger" isLoading={recalculatingId === l.id} onClick={() => handleReset(l.id)}>
              Reset
            </Button>
          )}
        </div>
      ),
    },
  ];

  return (
    <div>
      <PageHeader
        title="Leaderboards"
        subtitle="View rankings and recalculate standings"
        actions={
          <Button variant="secondary" onClick={handleExportCsv} disabled={!leaderboards || leaderboards.length === 0}>
            Export CSV
          </Button>
        }
      />

      <div className="flex flex-wrap items-center gap-2 mb-6">
        {tabs.map((tab) => (
          <button
            key={tab.label}
            onClick={() => setActiveTab(tab.value)}
            className={`px-4 py-1.5 rounded-full text-sm font-medium transition-colors ${
              activeTab === tab.value
                ? 'bg-b-purple text-white'
                : 'text-b-on-surface-muted hover:text-b-on-surface hover:bg-b-surface-muted'
            }`}
          >
            {tab.label}
          </button>
        ))}
      </div>

      <div className="bg-b-surface-elevated rounded-xl border border-b-border overflow-hidden">
        <DataTable
          columns={columns}
          rows={leaderboards || []}
          keyExtractor={(l) => l.id}
          isLoading={isLoading}
          onRowClick={(l) => setSelected(l)}
        />
      </div>

      <LeaderboardModal
        leaderboard={selected}
        onClose={() => setSelected(null)}
        onRecalculate={handleRecalculate}
        onReset={handleReset}
        isRecalculating={recalculatingId === selected?.id}
        isSuperAdmin={role === 'super_admin'}
      />
    </div>
  );
}

function LeaderboardModal({
  leaderboard,
  onClose,
  onRecalculate,
  onReset,
  isRecalculating,
  isSuperAdmin,
}: {
  leaderboard: Leaderboard | null;
  onClose: () => void;
  onRecalculate: (id: string) => Promise<void>;
  onReset: (id: string) => Promise<void>;
  isRecalculating: boolean;
  isSuperAdmin: boolean;
}) {
  if (!leaderboard) return null;

  return (
    <Modal
      isOpen={!!leaderboard}
      onClose={onClose}
      title={`${leaderboard.period} ${leaderboard.type} Leaderboard`}
      size="lg"
      actions={
        <>
          <Button variant="secondary" onClick={onClose}>
            Close
          </Button>
          {isSuperAdmin && (
            <Button
              variant="danger"
              disabled={isRecalculating}
              isLoading={isRecalculating}
              onClick={() => onReset(leaderboard.id)}
            >
              Reset
            </Button>
          )}
          <Button
            variant="secondary"
            disabled={isRecalculating}
            isLoading={isRecalculating}
            onClick={() => onRecalculate(leaderboard.id)}
          >
            Recalculate
          </Button>
        </>
      }
    >
      <div className="space-y-4">
        <div className="grid grid-cols-2 gap-4 text-sm">
          <div>
            <p className="text-xs text-b-on-surface-muted">ID</p>
            <p className="text-b-on-surface break-all">{leaderboard.id}</p>
          </div>
          <div>
            <p className="text-xs text-b-on-surface-muted">Metric</p>
            <p className="text-b-on-surface capitalize">{leaderboard.metric}</p>
          </div>
          <div>
            <p className="text-xs text-b-on-surface-muted">Status</p>
            <Badge variant={statusVariant[leaderboard.status] || 'default'}>{leaderboard.status}</Badge>
          </div>
          <div>
            <p className="text-xs text-b-on-surface-muted">Participants</p>
            <p className="text-b-on-surface">{formatNumber(leaderboard.totalParticipants)}</p>
          </div>
        </div>

        <div>
          <p className="text-xs text-b-on-surface-muted mb-2">Top Entries</p>
          <div className="bg-b-surface rounded-xl border border-b-border overflow-hidden">
            <DataTable
              columns={[
                { key: 'rank', header: 'Rank' },
                { key: 'displayName', header: 'Player' },
                { key: 'level', header: 'Level' },
                { key: 'value', header: 'Value', render: (e) => formatNumber(e.value) },
              ]}
              rows={leaderboard.entries.slice(0, 50)}
              keyExtractor={(e) => `${e.rank}-${e.uid}`}
              emptyMessage="No entries"
            />
          </div>
        </div>
      </div>
    </Modal>
  );
}
