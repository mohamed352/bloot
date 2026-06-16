import { useState } from 'react';
import { useQueryClient } from '@tanstack/react-query';
import { useAuthStore } from '../../stores/authStore';
import { useTournaments } from '../../hooks/useTournaments';
import { useAdminRole } from '../../hooks/useAdminRole';
import { adminFunctions } from '../../services/adminFunctions';
import { uploadImage } from '../../services/storage';
import { PageHeader } from '../../components/PageHeader';
import { DataTable } from '../../components/DataTable';
import { Badge } from '../../components/Badge';
import { Button } from '../../components/Button';
import { Modal } from '../../components/Modal';
import { ImageUpload } from '../../components/ImageUpload';
import { useToastStore } from '../../stores/toastStore';
import { exportToCsv } from '../../utils/csvExport';
import { formatDate, formatNumber } from '../../utils/formatters';
import type { Tournament } from '../../types';

const tabs: { label: string; value?: Tournament['status'] }[] = [
  { label: 'All' },
  { label: 'Upcoming', value: 'upcoming' },
  { label: 'Registration', value: 'registration' },
  { label: 'Active', value: 'active' },
  { label: 'Completed', value: 'completed' },
  { label: 'Cancelled', value: 'cancelled' },
];

const statusVariant: Record<string, 'default' | 'success' | 'warning' | 'danger' | 'info'> = {
  upcoming: 'info',
  registration: 'warning',
  active: 'success',
  completed: 'default',
  cancelled: 'danger',
};

const emptyTournament: Tournament = {
  id: '',
  name: '',
  description: '',
  type: 'singleElimination',
  status: 'upcoming',
  gameType: 'sun',
  maxParticipants: 32,
  currentParticipants: 0,
  entryFee: 0,
  prizePool: 0,
  participants: [],
  hostUid: '',
  isPremium: false,
  startDate: { seconds: 0, nanoseconds: 0 } as unknown as Tournament['startDate'],
  endDate: { seconds: 0, nanoseconds: 0 } as unknown as Tournament['endDate'],
  registrationDeadline: { seconds: 0, nanoseconds: 0 } as unknown as Tournament['registrationDeadline'],
  createdAt: { seconds: 0, nanoseconds: 0 } as unknown as Tournament['createdAt'],
  updatedAt: { seconds: 0, nanoseconds: 0 } as unknown as Tournament['updatedAt'],
};

export function TournamentsPage() {
  const [activeTab, setActiveTab] = useState<Tournament['status'] | undefined>(undefined);
  const [selected, setSelected] = useState<Tournament | null>(null);
  const { data: tournaments, isLoading } = useTournaments(activeTab);

  const handleExportCsv = () => {
    const rows = (tournaments || []).map((t) => ({
      id: t.id,
      name: t.name,
      type: t.type,
      status: t.status,
      gameType: t.gameType,
      maxParticipants: t.maxParticipants,
      currentParticipants: t.currentParticipants,
      entryFee: t.entryFee,
      prizePool: t.prizePool,
      startDate: formatDate(t.startDate),
    }));
    exportToCsv('tournaments.csv', rows, [
      { key: 'id', header: 'ID' },
      { key: 'name', header: 'Name' },
      { key: 'type', header: 'Type' },
      { key: 'status', header: 'Status' },
      { key: 'gameType', header: 'Game' },
      { key: 'maxParticipants', header: 'Max Players' },
      { key: 'currentParticipants', header: 'Current Players' },
      { key: 'entryFee', header: 'Entry Fee' },
      { key: 'prizePool', header: 'Prize Pool' },
      { key: 'startDate', header: 'Starts' },
    ]);
  };

  const columns = [
    { key: 'name', header: 'Name' },
    {
      key: 'type',
      header: 'Type',
      render: (t: Tournament) => <span className="capitalize">{t.type.replace(/([A-Z])/g, ' $1')}</span>,
    },
    {
      key: 'status',
      header: 'Status',
      render: (t: Tournament) => <Badge variant={statusVariant[t.status] || 'default'}>{t.status}</Badge>,
    },
    {
      key: 'gameType',
      header: 'Game',
      render: (t: Tournament) => <span className="capitalize">{t.gameType}</span>,
    },
    {
      key: 'participants',
      header: 'Players',
      render: (t: Tournament) => `${t.currentParticipants}/${t.maxParticipants}`,
    },
    { key: 'entryFee', header: 'Entry Fee', render: (t: Tournament) => formatNumber(t.entryFee) },
    { key: 'prizePool', header: 'Prize Pool', render: (t: Tournament) => formatNumber(t.prizePool) },
    { key: 'startDate', header: 'Starts', render: (t: Tournament) => formatDate(t.startDate) },
    {
      key: 'actions',
      header: 'Actions',
      render: (t: Tournament) => (
        <Button size="sm" variant="secondary" onClick={() => setSelected(t)}>
          Manage
        </Button>
      ),
    },
  ];

  return (
    <div>
      <PageHeader
        title="Tournaments"
        subtitle="Create and manage tournaments"
        actions={
          <div className="flex items-center gap-2">
            <Button variant="secondary" onClick={handleExportCsv} disabled={!tournaments || tournaments.length === 0}>
              Export CSV
            </Button>
            <Button onClick={() => setSelected(emptyTournament)}>Create Tournament</Button>
          </div>
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
          rows={tournaments || []}
          keyExtractor={(t) => t.id}
          isLoading={isLoading}
          onRowClick={(t) => setSelected(t)}
        />
      </div>

      <TournamentModal tournament={selected} onClose={() => setSelected(null)} />
    </div>
  );
}

function TournamentModal({
  tournament,
  onClose,
}: {
  tournament: Tournament | null;
  onClose: () => void;
}) {
  const queryClient = useQueryClient();
  const addToast = useToastStore((s) => s.addToast);
  const user = useAuthStore((s) => s.user);
  const { role } = useAdminRole(user?.uid);

  const isNew = !tournament?.id;
  const [form, setForm] = useState<Tournament>(() => tournament ?? ({} as Tournament));
  const [isSaving, setIsSaving] = useState(false);
  const [bannerFile, setBannerFile] = useState<File | null>(null);

  if (!tournament) return null;

  const update = <K extends keyof Tournament>(key: K, value: Tournament[K]) =>
    setForm((f) => ({ ...f, [key]: value }));

  const refresh = () => queryClient.invalidateQueries({ queryKey: ['tournaments'] });

  const handleSave = async () => {
    setIsSaving(true);
    try {
      const payload: Record<string, unknown> = {
        name: form.name,
        description: form.description,
        type: form.type,
        status: form.status,
        gameType: form.gameType,
        maxParticipants: form.maxParticipants,
        entryFee: form.entryFee,
        prizePool: form.prizePool,
        isPremium: form.isPremium,
        startDate: timestampToISO(form.startDate),
        endDate: timestampToISO(form.endDate),
        registrationDeadline: timestampToISO(form.registrationDeadline),
      };

      if (isNew) {
        const result = await adminFunctions.adminCreateTournament(payload);
        const createdId = (result.data as { success: boolean; tournamentId: string }).tournamentId;
        if (bannerFile && createdId) {
          const imageUrl = await uploadImage(`tournaments/${createdId}`, bannerFile);
          await adminFunctions.adminUpdateTournament({
            tournamentId: createdId,
            updates: { imageUrl },
          });
        }
      } else {
        if (bannerFile) {
          const imageUrl = await uploadImage(`tournaments/${tournament.id}`, bannerFile);
          payload.imageUrl = imageUrl;
        }
        await adminFunctions.adminUpdateTournament({
          tournamentId: tournament.id,
          updates: payload,
        });
      }

      addToast(isNew ? 'Tournament created' : 'Tournament updated', 'success');
      refresh();
      onClose();
    } catch (e) {
      addToast(e instanceof Error ? e.message : 'Failed to save tournament', 'error');
    } finally {
      setIsSaving(false);
    }
  };

  const handleCancel = async () => {
    if (!confirm('Cancel this tournament?')) return;
    setIsSaving(true);
    try {
      await adminFunctions.adminCancelTournament({ tournamentId: tournament.id });
      addToast('Tournament cancelled', 'success');
      refresh();
      onClose();
    } catch (e) {
      addToast(e instanceof Error ? e.message : 'Failed to cancel tournament', 'error');
    } finally {
      setIsSaving(false);
    }
  };

  const handleStart = async () => {
    if (!confirm('Start this tournament?')) return;
    setIsSaving(true);
    try {
      await adminFunctions.adminStartTournament({ tournamentId: tournament.id });
      addToast('Tournament started', 'success');
      refresh();
      onClose();
    } catch (e) {
      addToast(e instanceof Error ? e.message : 'Failed to start tournament', 'error');
    } finally {
      setIsSaving(false);
    }
  };

  const isSupport = role === 'support';

  return (
    <Modal
      isOpen={!!tournament}
      onClose={onClose}
      title={isNew ? 'Create Tournament' : 'Edit Tournament'}
      size="lg"
      actions={
        <>
          <Button variant="secondary" onClick={onClose}>
            Cancel
          </Button>
          {!isNew && form.status === 'registration' && (
            <Button variant="success" disabled={isSaving} isLoading={isSaving} onClick={handleStart}>
              Start Tournament
            </Button>
          )}
          <Button disabled={isSaving} isLoading={isSaving} onClick={handleSave}>
            {isSaving ? 'Saving...' : isNew ? 'Create' : 'Save'}
          </Button>
        </>
      }
    >
      <div className="space-y-4">
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div>
            <label className="block text-xs text-b-on-surface-muted mb-1">Name</label>
            <input
              type="text"
              value={form.name}
              onChange={(e) => update('name', e.target.value)}
              className="w-full px-3 py-2 rounded-lg bg-b-surface border border-b-border text-b-on-surface focus:outline-none focus:border-b-purple"
            />
          </div>
          <div>
            <label className="block text-xs text-b-on-surface-muted mb-1">Type</label>
            <select
              value={form.type}
              onChange={(e) => update('type', e.target.value as Tournament['type'])}
              className="w-full px-3 py-2 rounded-lg bg-b-surface border border-b-border text-b-on-surface focus:outline-none focus:border-b-purple"
            >
              <option value="singleElimination">Single Elimination</option>
              <option value="roundRobin">Round Robin</option>
              <option value="swiss">Swiss</option>
            </select>
          </div>
          <div>
            <label className="block text-xs text-b-on-surface-muted mb-1">Status</label>
            <select
              value={form.status}
              onChange={(e) => update('status', e.target.value as Tournament['status'])}
              className="w-full px-3 py-2 rounded-lg bg-b-surface border border-b-border text-b-on-surface focus:outline-none focus:border-b-purple"
            >
              {['upcoming', 'registration', 'active', 'completed', 'cancelled'].map((s) => (
                <option key={s} value={s}>
                  {s}
                </option>
              ))}
            </select>
          </div>
          <div>
            <label className="block text-xs text-b-on-surface-muted mb-1">Game Type</label>
            <select
              value={form.gameType}
              onChange={(e) => update('gameType', e.target.value as Tournament['gameType'])}
              className="w-full px-3 py-2 rounded-lg bg-b-surface border border-b-border text-b-on-surface focus:outline-none focus:border-b-purple"
            >
              <option value="sun">Sun</option>
              <option value="hokm">Hokm</option>
              <option value="both">Both</option>
            </select>
          </div>
          <div>
            <label className="block text-xs text-b-on-surface-muted mb-1">Max Participants</label>
            <input
              type="number"
              value={form.maxParticipants}
              onChange={(e) => update('maxParticipants', Number(e.target.value))}
              className="w-full px-3 py-2 rounded-lg bg-b-surface border border-b-border text-b-on-surface focus:outline-none focus:border-b-purple"
            />
          </div>
          <div>
            <label className="block text-xs text-b-on-surface-muted mb-1">Entry Fee</label>
            <input
              type="number"
              value={form.entryFee}
              onChange={(e) => update('entryFee', Number(e.target.value))}
              className="w-full px-3 py-2 rounded-lg bg-b-surface border border-b-border text-b-on-surface focus:outline-none focus:border-b-purple"
            />
          </div>
          <div>
            <label className="block text-xs text-b-on-surface-muted mb-1">Prize Pool</label>
            <input
              type="number"
              value={form.prizePool}
              onChange={(e) => update('prizePool', Number(e.target.value))}
              className="w-full px-3 py-2 rounded-lg bg-b-surface border border-b-border text-b-on-surface focus:outline-none focus:border-b-purple"
            />
          </div>
          <div>
            <label className="block text-xs text-b-on-surface-muted mb-1">Premium</label>
            <select
              value={String(form.isPremium)}
              onChange={(e) => update('isPremium', e.target.value === 'true')}
              className="w-full px-3 py-2 rounded-lg bg-b-surface border border-b-border text-b-on-surface focus:outline-none focus:border-b-purple"
            >
              <option value="true">Yes</option>
              <option value="false">No</option>
            </select>
          </div>
          <div>
            <label className="block text-xs text-b-on-surface-muted mb-1">Start Date</label>
            <input
              type="datetime-local"
              value={timestampToLocalDateTime(form.startDate)}
              onChange={(e) => update('startDate', localDateTimeToTimestamp(e.target.value))}
              className="w-full px-3 py-2 rounded-lg bg-b-surface border border-b-border text-b-on-surface focus:outline-none focus:border-b-purple"
            />
          </div>
          <div>
            <label className="block text-xs text-b-on-surface-muted mb-1">End Date</label>
            <input
              type="datetime-local"
              value={timestampToLocalDateTime(form.endDate)}
              onChange={(e) => update('endDate', localDateTimeToTimestamp(e.target.value))}
              className="w-full px-3 py-2 rounded-lg bg-b-surface border border-b-border text-b-on-surface focus:outline-none focus:border-b-purple"
            />
          </div>
          <div className="sm:col-span-2">
            <label className="block text-xs text-b-on-surface-muted mb-1">Registration Deadline</label>
            <input
              type="datetime-local"
              value={timestampToLocalDateTime(form.registrationDeadline)}
              onChange={(e) => update('registrationDeadline', localDateTimeToTimestamp(e.target.value))}
              className="w-full px-3 py-2 rounded-lg bg-b-surface border border-b-border text-b-on-surface focus:outline-none focus:border-b-purple"
            />
          </div>
        </div>
        <div>
          <label className="block text-xs text-b-on-surface-muted mb-1">Description</label>
          <textarea
            value={form.description || ''}
            onChange={(e) => update('description', e.target.value)}
            rows={3}
            className="w-full px-3 py-2 rounded-lg bg-b-surface border border-b-border text-b-on-surface focus:outline-none focus:border-b-purple"
          />
        </div>
        <div>
          <ImageUpload
            id="tournament-banner"
            label="Banner"
            previewUrl={form.imageUrl}
            onFileSelect={setBannerFile}
          />
        </div>
        {!isNew && (
          <>
            <div className="grid grid-cols-2 gap-4 text-sm">
              <div>
                <span className="text-b-on-surface-muted">Participants:</span>{' '}
                <span className="text-b-on-surface">
                  {form.currentParticipants}/{form.maxParticipants}
                </span>
              </div>
              <div>
                <span className="text-b-on-surface-muted">Created:</span>{' '}
                <span className="text-b-on-surface">{formatDate(form.createdAt)}</span>
              </div>
            </div>
            <Button
              variant="danger"
              disabled={isSaving || isSupport}
              isLoading={isSaving}
              onClick={handleCancel}
            >
              Cancel Tournament
            </Button>
          </>
        )}
      </div>
    </Modal>
  );
}

function timestampToLocalDateTime(value: unknown): string {
  if (!value) return '';
  let date: Date;
  if (value instanceof Date) {
    date = value;
  } else if (typeof value === 'string') {
    date = new Date(value);
  } else if (typeof value === 'object' && value !== null && 'toDate' in value && typeof (value as { toDate: () => Date }).toDate === 'function') {
    date = (value as { toDate: () => Date }).toDate();
  } else if (typeof value === 'object' && value !== null && 'seconds' in value) {
    date = new Date((value as { seconds: number }).seconds * 1000);
  } else {
    return '';
  }
  if (isNaN(date.getTime())) return '';
  const pad = (n: number) => String(n).padStart(2, '0');
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}T${pad(date.getHours())}:${pad(date.getMinutes())}`;
}

function localDateTimeToTimestamp(value: string): Tournament['startDate'] {
  const date = new Date(value);
  return (isNaN(date.getTime()) ? new Date() : date) as unknown as Tournament['startDate'];
}

function timestampToISO(value: unknown): string {
  if (!value) return new Date().toISOString();
  if (typeof value === 'string') {
    const parsed = new Date(value);
    return isNaN(parsed.getTime()) ? new Date().toISOString() : parsed.toISOString();
  }
  if (value instanceof Date) return value.toISOString();
  if (typeof value === 'object' && value !== null && 'toDate' in value && typeof (value as { toDate: () => Date }).toDate === 'function') {
    return (value as { toDate: () => Date }).toDate().toISOString();
  }
  if (typeof value === 'object' && value !== null && 'seconds' in value) {
    return new Date((value as { seconds: number }).seconds * 1000).toISOString();
  }
  return new Date().toISOString();
}
