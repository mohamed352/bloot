import { useState } from 'react';
import { useAuthStore } from '../../stores/authStore';
import { useReports } from '../../hooks/useReports';
import { useAdminRole } from '../../hooks/useAdminRole';
import { adminFunctions } from '../../services/adminFunctions';
import { exportToCsv } from '../../utils/csvExport';
import { PageHeader } from '../../components/PageHeader';
import { DataTable } from '../../components/DataTable';
import { Badge } from '../../components/Badge';
import { Button } from '../../components/Button';
import { Modal } from '../../components/Modal';
import { useToastStore } from '../../stores/toastStore';
import { formatDate } from '../../utils/formatters';
import type { Report } from '../../types';

const tabs: { label: string; value?: Report['status'] }[] = [
  { label: 'All' },
  { label: 'Pending', value: 'pending' },
  { label: 'Reviewed', value: 'reviewed' },
  { label: 'Resolved', value: 'resolved' },
  { label: 'Dismissed', value: 'dismissed' },
];

const statusVariant: Record<string, 'default' | 'warning' | 'success' | 'danger' | 'info'> = {
  pending: 'warning',
  reviewed: 'info',
  resolved: 'success',
  dismissed: 'default',
};

export function ReportsPage() {
  const currentUid = useAuthStore((s) => s.user?.uid);
  const { hasPermission } = useAdminRole(currentUid);
  const addToast = useToastStore((s) => s.addToast);
  const [activeTab, setActiveTab] = useState<Report['status'] | undefined>(undefined);
  const [selectedReport, setSelectedReport] = useState<Report | null>(null);
  const [loadingAction, setLoadingAction] = useState<string | null>(null);

  const {
    items: reports,
    isLoading,
    isLoadingMore,
    hasMore,
    loadMore,
    search,
    setSearch,
    refresh,
  } = useReports(activeTab, '');

  const canDismiss = hasPermission('manage');

  const handleAction = async (action: () => Promise<unknown>, label: string) => {
    setLoadingAction(label);
    try {
      await action();
      addToast(`${label} succeeded`, 'success');
      refresh();
      setSelectedReport(null);
    } catch (err) {
      addToast((err as Error).message, 'error');
    } finally {
      setLoadingAction(null);
    }
  };

  const handleExportCsv = () => {
    if (reports.length === 0) {
      addToast('No reports to export', 'warning');
      return;
    }

    exportToCsv(
      `reports-${activeTab ?? 'all'}-${new Date().toISOString().slice(0, 10)}.csv`,
      reports.map((r) => ({
        id: r.id,
        type: r.type,
        reason: r.reason,
        status: r.status,
        reportedUid: r.reportedUid,
        reporterUid: r.reporterUid,
        referenceId: r.referenceId ?? '',
        resolution: r.resolution ?? '',
        createdAt: formatDate(r.createdAt),
      })),
      [
        { key: 'id', header: 'Report ID' },
        { key: 'type', header: 'Type' },
        { key: 'reason', header: 'Reason' },
        { key: 'status', header: 'Status' },
        { key: 'reportedUid', header: 'Reported UID' },
        { key: 'reporterUid', header: 'Reporter UID' },
        { key: 'referenceId', header: 'Reference ID' },
        { key: 'resolution', header: 'Resolution' },
        { key: 'createdAt', header: 'Reported At' },
      ]
    );
    addToast('CSV exported', 'success');
  };

  const columns = [
    { key: 'type', header: 'Type' },
    { key: 'reason', header: 'Reason' },
    {
      key: 'status',
      header: 'Status',
      render: (r: Report) => <Badge variant={statusVariant[r.status] || 'default'}>{r.status}</Badge>,
    },
    { key: 'reportedUid', header: 'Reported UID', render: (r: Report) => <span className="font-mono text-xs">{r.reportedUid}</span> },
    { key: 'reporterUid', header: 'Reporter UID', render: (r: Report) => <span className="font-mono text-xs">{r.reporterUid}</span> },
    {
      key: 'createdAt',
      header: 'Reported',
      render: (r: Report) => formatDate(r.createdAt),
    },
    {
      key: 'actions',
      header: 'Actions',
      render: (r: Report) => (
        <Button size="sm" variant="secondary" onClick={() => setSelectedReport(r)}>
          Review
        </Button>
      ),
    },
  ];

  return (
    <div>
      <PageHeader
        title="Reports"
        subtitle="Review and resolve player reports"
        actions={
          <Button variant="secondary" onClick={handleExportCsv}>
            Export CSV
          </Button>
        }
      />

      <div className="flex items-center gap-2 mb-4 flex-wrap">
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

      <div className="mb-4 flex gap-3">
        <input
          type="text"
          placeholder="Search reports"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="flex-1 max-w-md px-4 py-2 rounded-lg bg-b-surface-elevated border border-b-border text-b-on-surface placeholder-b-on-surface-secondary focus:outline-none focus:border-b-purple"
        />
      </div>

      <div className="bg-b-surface-elevated rounded-xl border border-b-border overflow-hidden">
        <DataTable
          columns={columns}
          rows={reports}
          keyExtractor={(r) => r.id}
          isLoading={isLoading}
          onRowClick={(r) => setSelectedReport(r)}
        />
      </div>

      <div className="flex items-center justify-center mt-4">
        <Button
          variant="secondary"
          onClick={loadMore}
          disabled={!hasMore || isLoadingMore}
          isLoading={isLoadingMore}
        >
          {isLoadingMore ? 'Loading...' : hasMore ? 'Load More' : 'No More Reports'}
        </Button>
      </div>

      <ReportModal
        report={selectedReport}
        onClose={() => setSelectedReport(null)}
        loadingAction={loadingAction}
        onAction={handleAction}
        canDismiss={canDismiss}
      />
    </div>
  );
}

function ReportModal({
  report,
  onClose,
  loadingAction,
  onAction,
  canDismiss,
}: {
  report: Report | null;
  onClose: () => void;
  loadingAction: string | null;
  onAction: (action: () => Promise<unknown>, label: string) => void;
  canDismiss: boolean;
}) {
  const [resolution, setResolution] = useState('');

  if (!report) return null;

  return (
    <Modal isOpen={!!report} onClose={onClose} title="Review Report" size="md">
      <div className="space-y-4">
        <div>
          <p className="text-xs text-b-on-surface-muted">Type</p>
          <p className="text-sm text-b-on-surface capitalize">{report.type}</p>
        </div>
        <div>
          <p className="text-xs text-b-on-surface-muted">Reason</p>
          <p className="text-sm text-b-on-surface">{report.reason}</p>
        </div>
        {report.description && (
          <div>
            <p className="text-xs text-b-on-surface-muted">Description</p>
            <p className="text-sm text-b-on-surface">{report.description}</p>
          </div>
        )}
        <div>
          <p className="text-xs text-b-on-surface-muted">Reported At</p>
          <p className="text-sm text-b-on-surface">{formatDate(report.createdAt)}</p>
        </div>

        <div>
          <label className="block text-xs text-b-on-surface-muted mb-1">Resolution Notes</label>
          <textarea
            value={resolution}
            onChange={(e) => setResolution(e.target.value)}
            className="w-full px-3 py-2 rounded-lg bg-b-surface-muted border border-b-border text-b-on-surface focus:outline-none focus:border-b-purple"
            rows={3}
          />
        </div>

        <div className="flex flex-wrap gap-2 pt-2">
          <Button
            variant="success"
            isLoading={loadingAction === 'resolve'}
            onClick={() =>
              onAction(
                () => adminFunctions.resolveReport({ reportId: report.id, resolution }),
                'resolve'
              )
            }
          >
            Resolve
          </Button>
          <Button
            variant="danger"
            isLoading={loadingAction === 'dismiss'}
            disabled={!canDismiss}
            onClick={() => onAction(() => adminFunctions.resolveReport({ reportId: report.id, resolution: 'Dismissed' }), 'dismiss')}
          >
            Dismiss
          </Button>
          <Button
            variant="secondary"
            isLoading={loadingAction === 'escalate'}
            onClick={() => onAction(() => adminFunctions.escalateReport({ reportId: report.id }), 'escalate')}
          >
            Escalate
          </Button>
        </div>

        {!canDismiss && (
          <p className="text-xs text-b-on-surface-muted">
            Dismissing reports is restricted to moderators and above.
          </p>
        )}
      </div>
    </Modal>
  );
}
