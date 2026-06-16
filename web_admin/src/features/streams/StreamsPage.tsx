import { useMemo, useState } from 'react';
import { orderBy, limit, where } from 'firebase/firestore';
import type { QueryConstraint } from 'firebase/firestore';
import { useLiveCollection } from '../../hooks/useLiveCollection';
import { adminFunctions } from '../../services/adminFunctions';
import { PageHeader } from '../../components/PageHeader';
import { DataTable } from '../../components/DataTable';
import { Badge } from '../../components/Badge';
import { Button } from '../../components/Button';
import { Modal } from '../../components/Modal';
import { exportToCsv } from '../../utils/csvExport';
import { formatDate, formatNumber } from '../../utils/formatters';
import type { Stream } from '../../types';

const tabs: { label: string; value?: Stream['status'] }[] = [
  { label: 'All' },
  { label: 'Live', value: 'live' },
  { label: 'Paused', value: 'paused' },
  { label: 'Ended', value: 'ended' },
];

const statusVariant: Record<string, 'default' | 'success' | 'warning' | 'danger' | 'info' | 'live'> = {
  live: 'live',
  paused: 'warning',
  ended: 'default',
};

export function StreamsPage() {
  const [activeTab, setActiveTab] = useState<Stream['status'] | undefined>(undefined);
  const [selected, setSelected] = useState<Stream | null>(null);
  const [showModeration, setShowModeration] = useState(false);

  const constraints = useMemo<QueryConstraint[]>(() => {
    const c: QueryConstraint[] = [orderBy('startedAt', 'desc'), limit(100)];
    if (activeTab) {
      c.unshift(where('status', '==', activeTab));
    }
    return c;
  }, [activeTab]);

  const { data: streams, isLoading } = useLiveCollection<Stream>('streams', constraints);

  const handleExportCsv = () => {
    const rows = (streams || []).map((s) => ({
      id: s.id,
      title: s.title,
      hostName: s.hostName,
      status: s.status,
      viewerCount: s.viewerCount,
      peakViewerCount: s.peakViewerCount,
      totalLikes: s.totalLikes,
      totalGifts: s.totalGifts,
      startedAt: formatDate(s.startedAt),
    }));
    exportToCsv('streams.csv', rows, [
      { key: 'id', header: 'Stream ID' },
      { key: 'title', header: 'Title' },
      { key: 'hostName', header: 'Host' },
      { key: 'status', header: 'Status' },
      { key: 'viewerCount', header: 'Viewers' },
      { key: 'peakViewerCount', header: 'Peak Viewers' },
      { key: 'totalLikes', header: 'Likes' },
      { key: 'totalGifts', header: 'Gifts' },
      { key: 'startedAt', header: 'Started' },
    ]);
  };

  const columns = [
    { key: 'title', header: 'Title' },
    { key: 'hostName', header: 'Host' },
    {
      key: 'status',
      header: 'Status',
      render: (s: Stream) => <Badge variant={statusVariant[s.status] || 'default'}>{s.status}</Badge>,
    },
    { key: 'viewerCount', header: 'Viewers', render: (s: Stream) => formatNumber(s.viewerCount) },
    { key: 'peakViewerCount', header: 'Peak', render: (s: Stream) => formatNumber(s.peakViewerCount) },
    { key: 'totalLikes', header: 'Likes', render: (s: Stream) => formatNumber(s.totalLikes) },
    { key: 'totalGifts', header: 'Gifts', render: (s: Stream) => formatNumber(s.totalGifts) },
    { key: 'startedAt', header: 'Started', render: (s: Stream) => formatDate(s.startedAt) },
    {
      key: 'actions',
      header: 'Actions',
      render: (s: Stream) => (
        <Button size="sm" variant="secondary" onClick={() => setSelected(s)}>
          View
        </Button>
      ),
    },
  ];

  return (
    <div>
      <PageHeader
        title="Streams"
        subtitle="Monitor live streams and viewer metrics"
        actions={
          <Button variant="secondary" onClick={handleExportCsv} disabled={!streams || streams.length === 0}>
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
          rows={streams || []}
          keyExtractor={(s) => s.id}
          isLoading={isLoading}
          onRowClick={(s) => setSelected(s)}
        />
      </div>

      <StreamModal
        stream={selected}
        onClose={() => setSelected(null)}
        onModerate={() => setShowModeration(true)}
      />
      <ModerationModal
        stream={selected}
        isOpen={showModeration}
        onClose={() => setShowModeration(false)}
        onAction={async () => {
          setShowModeration(false);
          setSelected(null);
        }}
      />
    </div>
  );
}

function StreamModal({
  stream,
  onClose,
  onModerate,
}: {
  stream: Stream | null;
  onClose: () => void;
  onModerate: () => void;
}) {
  if (!stream) return null;

  return (
    <Modal
      isOpen={!!stream}
      onClose={onClose}
      title={stream.title}
      size="lg"
      actions={
        <>
          <Button variant="danger" onClick={onModerate}>
            Moderate
          </Button>
          <Button variant="secondary" onClick={onClose}>
            Done
          </Button>
        </>
      }
    >
      <div className="space-y-4">
        <div className="grid grid-cols-2 gap-4 text-sm">
          <div>
            <p className="text-xs text-b-on-surface-muted">Stream ID</p>
            <p className="text-b-on-surface break-all">{stream.id}</p>
          </div>
          <div>
            <p className="text-xs text-b-on-surface-muted">Host</p>
            <p className="text-b-on-surface">{stream.hostName}</p>
          </div>
          <div>
            <p className="text-xs text-b-on-surface-muted">Status</p>
            <Badge variant={statusVariant[stream.status] || 'default'}>{stream.status}</Badge>
          </div>
          <div>
            <p className="text-xs text-b-on-surface-muted">Language</p>
            <p className="text-b-on-surface uppercase">{stream.language}</p>
          </div>
          <div>
            <p className="text-xs text-b-on-surface-muted">Current Viewers</p>
            <p className="text-b-on-surface">{formatNumber(stream.viewerCount)}</p>
          </div>
          <div>
            <p className="text-xs text-b-on-surface-muted">Peak Viewers</p>
            <p className="text-b-on-surface">{formatNumber(stream.peakViewerCount)}</p>
          </div>
          <div>
            <p className="text-xs text-b-on-surface-muted">Likes</p>
            <p className="text-b-on-surface">{formatNumber(stream.totalLikes)}</p>
          </div>
          <div>
            <p className="text-xs text-b-on-surface-muted">Gifts</p>
            <p className="text-b-on-surface">{formatNumber(stream.totalGifts)}</p>
          </div>
          <div>
            <p className="text-xs text-b-on-surface-muted">Started</p>
            <p className="text-b-on-surface">{formatDate(stream.startedAt)}</p>
          </div>
          <div>
            <p className="text-xs text-b-on-surface-muted">Room ID</p>
            <p className="text-b-on-surface">{stream.roomId}</p>
          </div>
        </div>
        {stream.description && (
          <div>
            <p className="text-xs text-b-on-surface-muted">Description</p>
            <p className="text-b-on-surface text-sm">{stream.description}</p>
          </div>
        )}
      </div>
    </Modal>
  );
}

function ModerationModal({
  stream,
  isOpen,
  onClose,
  onAction,
}: {
  stream: Stream | null;
  isOpen: boolean;
  onClose: () => void;
  onAction: () => Promise<void>;
}) {
  const [isActing, setIsActing] = useState(false);

  if (!stream) return null;

  return (
    <Modal
      isOpen={isOpen}
      onClose={onClose}
      title="Stream Moderation"
      size="md"
      actions={
        <>
          <Button variant="secondary" onClick={onClose}>
            Cancel
          </Button>
          <Button
            variant="danger"
            disabled={isActing}
            onClick={async () => {
              if (!confirm('End this stream?')) return;
              setIsActing(true);
              try {
                await adminFunctions.adminEndStream({ streamId: stream.id });
                await onAction();
              } catch (e) {
                alert(e instanceof Error ? e.message : 'Failed to end stream');
              } finally {
                setIsActing(false);
              }
            }}
          >
            {isActing ? 'Ending...' : 'End Stream'}
          </Button>
        </>
      }
    >
      <div className="space-y-4">
        <p className="text-sm text-b-on-surface-muted">
          Moderate <span className="text-b-on-surface font-medium">{stream.title}</span> by {stream.hostName}.
        </p>
        <div className="grid grid-cols-2 gap-3">
          <Button
            variant="secondary"
            disabled={isActing}
            onClick={async () => {
              if (!confirm('Warn the host?')) return;
              setIsActing(true);
              try {
                await adminFunctions.warnHost({ streamId: stream.id });
                await onAction();
              } catch (e) {
                alert(e instanceof Error ? e.message : 'Failed to warn host');
              } finally {
                setIsActing(false);
              }
            }}
          >
            {isActing ? 'Sending...' : 'Warn Host'}
          </Button>
          <Button
            variant="danger"
            disabled={isActing}
            onClick={async () => {
              if (!confirm('Suspend the host account?')) return;
              setIsActing(true);
              try {
                await adminFunctions.suspendHost({ streamId: stream.id });
                await onAction();
              } catch (e) {
                alert(e instanceof Error ? e.message : 'Failed to suspend host');
              } finally {
                setIsActing(false);
              }
            }}
          >
            {isActing ? 'Suspending...' : 'Suspend Host'}
          </Button>
        </div>
      </div>
    </Modal>
  );
}
