import { useMemo, useState } from 'react';
import { orderBy, limit, where } from 'firebase/firestore';
import type { QueryConstraint } from 'firebase/firestore';
import { useLiveCollection } from '../../hooks/useLiveCollection';
import { useAdminRole } from '../../hooks/useAdminRole';
import { useAuthStore } from '../../stores/authStore';
import { adminFunctions } from '../../services/adminFunctions';
import { PageHeader } from '../../components/PageHeader';
import { DataTable } from '../../components/DataTable';
import { Badge } from '../../components/Badge';
import { Button } from '../../components/Button';
import { Modal } from '../../components/Modal';
import { useToastStore } from '../../stores/toastStore';
import { exportToCsv } from '../../utils/csvExport';
import { formatDate } from '../../utils/formatters';
import type { Room } from '../../types';

const tabs: { label: string; value?: Room['status'] }[] = [
  { label: 'All' },
  { label: 'Waiting', value: 'waiting' },
  { label: 'Playing', value: 'playing' },
  { label: 'Finished', value: 'finished' },
];

const statusVariant: Record<string, 'default' | 'success' | 'warning' | 'danger' | 'info'> = {
  waiting: 'warning',
  playing: 'success',
  finished: 'default',
};

export function RoomsPage() {
  const user = useAuthStore((s) => s.user);
  const { hasPermission } = useAdminRole(user?.uid);
  const addToast = useToastStore((s) => s.addToast);
  const [activeTab, setActiveTab] = useState<Room['status'] | undefined>(undefined);
  const [selected, setSelected] = useState<Room | null>(null);
  const [showForceClose, setShowForceClose] = useState(false);
  const [closing, setClosing] = useState(false);
  const [showTransfer, setShowTransfer] = useState(false);
  const [newOwnerUid, setNewOwnerUid] = useState('');
  const [transferring, setTransferring] = useState(false);

  const constraints = useMemo<QueryConstraint[]>(() => {
    const c: QueryConstraint[] = [orderBy('createdAt', 'desc'), limit(100)];
    if (activeTab) {
      c.unshift(where('status', '==', activeTab));
    }
    return c;
  }, [activeTab]);

  const { data: rooms, isLoading } = useLiveCollection<Room>('rooms', constraints);

  const handleExportCsv = () => {
    const rows = (rooms || []).map((r) => ({
      id: r.id,
      name: r.name,
      type: r.type,
      status: r.status,
      currentPlayerCount: r.currentPlayerCount,
      maxPlayers: r.maxPlayers,
      creatorUid: r.creatorUid,
      createdAt: formatDate(r.createdAt),
    }));
    exportToCsv('rooms.csv', rows, [
      { key: 'id', header: 'Room ID' },
      { key: 'name', header: 'Name' },
      { key: 'type', header: 'Type' },
      { key: 'status', header: 'Status' },
      { key: 'currentPlayerCount', header: 'Players' },
      { key: 'maxPlayers', header: 'Max Players' },
      { key: 'creatorUid', header: 'Creator UID' },
      { key: 'createdAt', header: 'Created' },
    ]);
  };

  const handleForceClose = async () => {
    if (!selected) return;
    setClosing(true);
    try {
      await adminFunctions.forceCloseRoom({ roomId: selected.id });
      addToast('Room force closed', 'success');
      setShowForceClose(false);
      setSelected(null);
    } catch (err) {
      addToast((err as Error).message, 'error');
    } finally {
      setClosing(false);
    }
  };

  const handleTransferOwnership = async () => {
    if (!selected || !newOwnerUid.trim()) return;
    setTransferring(true);
    try {
      await adminFunctions.transferRoomOwnership({ roomId: selected.id, newOwnerUid: newOwnerUid.trim() });
      addToast('Room ownership transferred', 'success');
      setShowTransfer(false);
      setNewOwnerUid('');
      setSelected(null);
    } catch (err) {
      addToast((err as Error).message, 'error');
    } finally {
      setTransferring(false);
    }
  };

  const columns = [
    { key: 'name', header: 'Room Name' },
    {
      key: 'type',
      header: 'Type',
      render: (r: Room) => <span className="capitalize">{r.type}</span>,
    },
    {
      key: 'status',
      header: 'Status',
      render: (r: Room) => <Badge variant={statusVariant[r.status] || 'default'}>{r.status}</Badge>,
    },
    {
      key: 'players',
      header: 'Players',
      render: (r: Room) => `${r.currentPlayerCount}/${r.maxPlayers}`,
    },
    {
      key: 'features',
      header: 'Features',
      render: (r: Room) => (
        <div className="flex gap-1">
          {r.voiceEnabled && <Badge variant="info">Voice</Badge>}
          {r.cameraEnabled && <Badge variant="info">Cam</Badge>}
        </div>
      ),
    },
    { key: 'createdAt', header: 'Created', render: (r: Room) => formatDate(r.createdAt) },
    {
      key: 'actions',
      header: 'Actions',
      render: (r: Room) => (
        <Button size="sm" variant="secondary" onClick={() => setSelected(r)}>
          View
        </Button>
      ),
    },
  ];

  return (
    <div>
      <PageHeader
        title="Rooms"
        subtitle="Monitor active rooms and players"
        actions={
          <Button variant="secondary" onClick={handleExportCsv} disabled={!rooms || rooms.length === 0}>
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
          rows={rooms || []}
          keyExtractor={(r) => r.id}
          isLoading={isLoading}
          onRowClick={(r) => setSelected(r)}
        />
      </div>

      <RoomModal
        room={selected}
        canTransfer={hasPermission('manage')}
        onClose={() => setSelected(null)}
        onForceClose={() => setShowForceClose(true)}
        onTransfer={() => setShowTransfer(true)}
      />
      <ForceCloseModal
        room={selected}
        isOpen={showForceClose}
        onClose={() => setShowForceClose(false)}
        onConfirm={handleForceClose}
        isLoading={closing}
      />
      <TransferOwnershipModal
        room={selected}
        isOpen={showTransfer}
        onClose={() => {
          setShowTransfer(false);
          setNewOwnerUid('');
        }}
        newOwnerUid={newOwnerUid}
        onNewOwnerUidChange={setNewOwnerUid}
        onConfirm={handleTransferOwnership}
        isLoading={transferring}
      />
    </div>
  );
}

function RoomModal({
  room,
  canTransfer,
  onClose,
  onForceClose,
  onTransfer,
}: {
  room: Room | null;
  canTransfer: boolean;
  onClose: () => void;
  onForceClose: () => void;
  onTransfer: () => void;
}) {
  if (!room) return null;

  return (
    <Modal
      isOpen={!!room}
      onClose={onClose}
      title={room.name}
      size="lg"
      actions={
        <>
          {canTransfer && (
            <Button variant="secondary" onClick={onTransfer}>
              Transfer Ownership
            </Button>
          )}
          <Button variant="danger" onClick={onForceClose}>
            Force Close
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
            <p className="text-xs text-b-on-surface-muted">Room ID</p>
            <p className="text-b-on-surface break-all">{room.id}</p>
          </div>
          <div>
            <p className="text-xs text-b-on-surface-muted">Creator</p>
            <p className="text-b-on-surface">{room.creatorUid}</p>
          </div>
          <div>
            <p className="text-xs text-b-on-surface-muted">Type</p>
            <p className="text-b-on-surface capitalize">{room.type}</p>
          </div>
          <div>
            <p className="text-xs text-b-on-surface-muted">Status</p>
            <Badge variant={statusVariant[room.status] || 'default'}>{room.status}</Badge>
          </div>
          <div>
            <p className="text-xs text-b-on-surface-muted">Game Speed</p>
            <p className="text-b-on-surface">{room.gameSpeed}</p>
          </div>
          <div>
            <p className="text-xs text-b-on-surface-muted">Min Level</p>
            <p className="text-b-on-surface">{room.minLevel}</p>
          </div>
        </div>

        <div>
          <p className="text-xs text-b-on-surface-muted mb-2">Players</p>
          <div className="space-y-2">
            {room.players.map((p) => (
              <div
                key={p.uid}
                className="flex items-center justify-between bg-b-surface rounded-lg px-3 py-2 border border-b-border"
              >
                <div className="flex items-center gap-2">
                  <span className="text-b-on-surface text-sm">{p.displayName}</span>
                  <Badge variant={p.team === 'A' ? 'info' : 'warning'}>Team {p.team}</Badge>
                  {p.isReady && <Badge variant="success">Ready</Badge>}
                </div>
                <div className="flex items-center gap-1">
                  {p.isMicOn && <span className="material-symbols-outlined text-b-on-surface-muted text-sm">mic</span>}
                  {p.isCameraOn && <span className="material-symbols-outlined text-b-on-surface-muted text-sm">videocam</span>}
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </Modal>
  );
}

function ForceCloseModal({
  room,
  isOpen,
  onClose,
  onConfirm,
  isLoading,
}: {
  room: Room | null;
  isOpen: boolean;
  onClose: () => void;
  onConfirm: () => void;
  isLoading: boolean;
}) {
  if (!room) return null;

  return (
    <Modal
      isOpen={isOpen}
      onClose={onClose}
      title="Force Close Room"
      size="sm"
      actions={
        <>
          <Button variant="secondary" onClick={onClose}>
            Cancel
          </Button>
          <Button variant="danger" onClick={onConfirm} isLoading={isLoading}>
            Confirm Close
          </Button>
        </>
      }
    >
      <p className="text-b-on-surface-muted text-sm">
        Are you sure you want to force close <span className="text-b-on-surface font-medium">{room.name}</span>? This will remove all players.
      </p>
    </Modal>
  );
}

function TransferOwnershipModal({
  room,
  isOpen,
  onClose,
  newOwnerUid,
  onNewOwnerUidChange,
  onConfirm,
  isLoading,
}: {
  room: Room | null;
  isOpen: boolean;
  onClose: () => void;
  newOwnerUid: string;
  onNewOwnerUidChange: (value: string) => void;
  onConfirm: () => void;
  isLoading: boolean;
}) {
  if (!room) return null;

  return (
    <Modal
      isOpen={isOpen}
      onClose={onClose}
      title="Transfer Room Ownership"
      size="sm"
      actions={
        <>
          <Button variant="secondary" onClick={onClose}>
            Cancel
          </Button>
          <Button variant="primary" onClick={onConfirm} isLoading={isLoading} disabled={!newOwnerUid.trim()}>
            Transfer
          </Button>
        </>
      }
    >
      <div className="space-y-4">
        <p className="text-b-on-surface-muted text-sm">
          Transfer ownership of <span className="text-b-on-surface font-medium">{room.name}</span> to another user.
        </p>
        <div>
          <label className="block text-xs text-b-on-surface-muted mb-1">New Owner UID</label>
          <input
            type="text"
            value={newOwnerUid}
            onChange={(e) => onNewOwnerUidChange(e.target.value)}
            className="w-full px-3 py-2 rounded-lg bg-b-surface border border-b-border text-b-on-surface focus:outline-none focus:border-b-purple"
            placeholder="Enter UID"
          />
        </div>
      </div>
    </Modal>
  );
}
