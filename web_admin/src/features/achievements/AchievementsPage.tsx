import { useState } from 'react';
import { useQueryClient } from '@tanstack/react-query';
import { useAuthStore } from '../../stores/authStore';
import { useAchievements } from '../../hooks/useAchievements';
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
import type { Achievement } from '../../types';

const rarityVariant: Record<string, 'default' | 'success' | 'warning' | 'danger' | 'info'> = {
  common: 'default',
  rare: 'info',
  epic: 'warning',
  legendary: 'danger',
};

const emptyAchievement: Achievement = {
  id: '',
  name: '',
  nameAr: '',
  description: '',
  descriptionAr: '',
  iconUrl: '',
  iconInactiveUrl: '',
  category: 'general',
  rarity: 'common',
  xpReward: 0,
  coinReward: 0,
  conditionType: '',
  conditionThreshold: 1,
  isSecret: false,
  displayOrder: 0,
  isActive: true,
  createdAt: { seconds: 0, nanoseconds: 0 } as unknown as Achievement['createdAt'],
  updatedAt: { seconds: 0, nanoseconds: 0 } as unknown as Achievement['updatedAt'],
};

export function AchievementsPage() {
  const [selected, setSelected] = useState<Achievement | null>(null);
  const { data: achievements, isLoading } = useAchievements();

  const handleExportCsv = () => {
    const rows = (achievements || []).map((a) => ({
      id: a.id,
      name: a.name,
      category: a.category,
      rarity: a.rarity,
      xpReward: a.xpReward,
      coinReward: a.coinReward,
      conditionType: a.conditionType,
      conditionThreshold: a.conditionThreshold,
      isActive: a.isActive ? 'Yes' : 'No',
    }));
    exportToCsv('achievements.csv', rows, [
      { key: 'id', header: 'ID' },
      { key: 'name', header: 'Name' },
      { key: 'category', header: 'Category' },
      { key: 'rarity', header: 'Rarity' },
      { key: 'xpReward', header: 'XP' },
      { key: 'coinReward', header: 'Coins' },
      { key: 'conditionType', header: 'Condition' },
      { key: 'conditionThreshold', header: 'Threshold' },
      { key: 'isActive', header: 'Active' },
    ]);
  };

  const columns = [
    { key: 'name', header: 'Name' },
    { key: 'category', header: 'Category', render: (a: Achievement) => <span className="capitalize">{a.category}</span> },
    {
      key: 'rarity',
      header: 'Rarity',
      render: (a: Achievement) => <Badge variant={rarityVariant[a.rarity] || 'default'}>{a.rarity}</Badge>,
    },
    { key: 'xpReward', header: 'XP', render: (a: Achievement) => formatNumber(a.xpReward) },
    { key: 'coinReward', header: 'Coins', render: (a: Achievement) => formatNumber(a.coinReward) },
    { key: 'conditionType', header: 'Condition' },
    { key: 'conditionThreshold', header: 'Threshold' },
    {
      key: 'isActive',
      header: 'Active',
      render: (a: Achievement) => (a.isActive ? <Badge variant="success">Yes</Badge> : <Badge>No</Badge>),
    },
    {
      key: 'actions',
      header: 'Actions',
      render: (a: Achievement) => (
        <Button size="sm" variant="secondary" onClick={() => setSelected(a)}>
          Edit
        </Button>
      ),
    },
  ];

  return (
    <div>
      <PageHeader
        title="Achievements"
        subtitle="Manage player achievements and rewards"
        actions={
          <div className="flex items-center gap-2">
            <Button variant="secondary" onClick={handleExportCsv} disabled={!achievements || achievements.length === 0}>
              Export CSV
            </Button>
            <Button onClick={() => setSelected(emptyAchievement)}>Create Achievement</Button>
          </div>
        }
      />

      <div className="bg-b-surface-elevated rounded-xl border border-b-border overflow-hidden">
        <DataTable
          columns={columns}
          rows={achievements || []}
          keyExtractor={(a) => a.id}
          isLoading={isLoading}
          onRowClick={(a) => setSelected(a)}
        />
      </div>

      <AchievementModal achievement={selected} onClose={() => setSelected(null)} />
    </div>
  );
}

function AchievementModal({
  achievement,
  onClose,
}: {
  achievement: Achievement | null;
  onClose: () => void;
}) {
  const queryClient = useQueryClient();
  const addToast = useToastStore((s) => s.addToast);
  const user = useAuthStore((s) => s.user);
  const { role } = useAdminRole(user?.uid);

  const isNew = !achievement?.id;
  const [form, setForm] = useState<Achievement>(() => achievement ?? ({} as Achievement));
  const [isSaving, setIsSaving] = useState(false);
  const [iconFile, setIconFile] = useState<File | null>(null);
  const [iconInactiveFile, setIconInactiveFile] = useState<File | null>(null);

  if (!achievement) return null;

  const update = <K extends keyof Achievement>(key: K, value: Achievement[K]) =>
    setForm((f) => ({ ...f, [key]: value }));

  const refresh = () => queryClient.invalidateQueries({ queryKey: ['achievements'] });

  const handleSave = async () => {
    setIsSaving(true);
    try {
      const achievementId = isNew ? kebabCase(form.name) || `achievement-${Date.now()}` : achievement.id;
      let iconUrl = form.iconUrl;
      let iconInactiveUrl = form.iconInactiveUrl;

      if (iconFile) {
        iconUrl = await uploadImage(`achievements/${achievementId}/icon`, iconFile);
      }
      if (iconInactiveFile) {
        iconInactiveUrl = await uploadImage(`achievements/${achievementId}/iconInactive`, iconInactiveFile);
      }

      const payload: Record<string, unknown> = {
        name: form.name,
        nameAr: form.nameAr,
        description: form.description,
        descriptionAr: form.descriptionAr,
        iconUrl,
        iconInactiveUrl,
        category: form.category,
        rarity: form.rarity,
        xpReward: form.xpReward,
        coinReward: form.coinReward,
        conditionType: form.conditionType,
        conditionThreshold: form.conditionThreshold,
        isSecret: form.isSecret,
        displayOrder: form.displayOrder,
        isActive: form.isActive,
      };

      if (isNew) {
        await adminFunctions.createAchievement({ ...payload, id: achievementId });
      } else {
        await adminFunctions.updateAchievement({
          achievementId: achievement.id,
          updates: payload,
        });
      }

      addToast(isNew ? 'Achievement created' : 'Achievement updated', 'success');
      refresh();
      onClose();
    } catch (e) {
      addToast(e instanceof Error ? e.message : 'Failed to save achievement', 'error');
    } finally {
      setIsSaving(false);
    }
  };

  const handleDelete = async () => {
    if (!confirm('Delete this achievement?')) return;
    setIsSaving(true);
    try {
      await adminFunctions.deleteAchievement({ achievementId: achievement.id });
      addToast('Achievement deleted', 'success');
      refresh();
      onClose();
    } catch (e) {
      addToast(e instanceof Error ? e.message : 'Failed to delete achievement', 'error');
    } finally {
      setIsSaving(false);
    }
  };

  const isSupport = role === 'support';

  return (
    <Modal
      isOpen={!!achievement}
      onClose={onClose}
      title={isNew ? 'Create Achievement' : 'Edit Achievement'}
      size="lg"
      actions={
        <>
          <Button variant="secondary" onClick={onClose}>
            Cancel
          </Button>
          <Button disabled={isSaving} isLoading={isSaving} onClick={handleSave}>
            {isSaving ? 'Saving...' : isNew ? 'Create' : 'Save'}
          </Button>
        </>
      }
    >
      <div className="space-y-4">
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div>
            <label className="block text-xs text-b-on-surface-muted mb-1">Name (EN)</label>
            <input
              type="text"
              value={form.name}
              onChange={(e) => update('name', e.target.value)}
              className="w-full px-3 py-2 rounded-lg bg-b-surface border border-b-border text-b-on-surface focus:outline-none focus:border-b-purple"
            />
          </div>
          <div>
            <label className="block text-xs text-b-on-surface-muted mb-1">Name (AR)</label>
            <input
              type="text"
              value={form.nameAr}
              onChange={(e) => update('nameAr', e.target.value)}
              className="w-full px-3 py-2 rounded-lg bg-b-surface border border-b-border text-b-on-surface focus:outline-none focus:border-b-purple"
            />
          </div>
          <div>
            <label className="block text-xs text-b-on-surface-muted mb-1">Category</label>
            <input
              type="text"
              value={form.category}
              onChange={(e) => update('category', e.target.value)}
              className="w-full px-3 py-2 rounded-lg bg-b-surface border border-b-border text-b-on-surface focus:outline-none focus:border-b-purple"
            />
          </div>
          <div>
            <label className="block text-xs text-b-on-surface-muted mb-1">Rarity</label>
            <select
              value={form.rarity}
              onChange={(e) => update('rarity', e.target.value)}
              className="w-full px-3 py-2 rounded-lg bg-b-surface border border-b-border text-b-on-surface focus:outline-none focus:border-b-purple"
            >
              {['common', 'rare', 'epic', 'legendary'].map((r) => (
                <option key={r} value={r}>
                  {r}
                </option>
              ))}
            </select>
          </div>
          <div>
            <label className="block text-xs text-b-on-surface-muted mb-1">XP Reward</label>
            <input
              type="number"
              value={form.xpReward}
              onChange={(e) => update('xpReward', Number(e.target.value))}
              className="w-full px-3 py-2 rounded-lg bg-b-surface border border-b-border text-b-on-surface focus:outline-none focus:border-b-purple"
            />
          </div>
          <div>
            <label className="block text-xs text-b-on-surface-muted mb-1">Coin Reward</label>
            <input
              type="number"
              value={form.coinReward}
              onChange={(e) => update('coinReward', Number(e.target.value))}
              className="w-full px-3 py-2 rounded-lg bg-b-surface border border-b-border text-b-on-surface focus:outline-none focus:border-b-purple"
            />
          </div>
          <div>
            <label className="block text-xs text-b-on-surface-muted mb-1">Condition Type</label>
            <input
              type="text"
              value={form.conditionType}
              onChange={(e) => update('conditionType', e.target.value)}
              className="w-full px-3 py-2 rounded-lg bg-b-surface border border-b-border text-b-on-surface focus:outline-none focus:border-b-purple"
            />
          </div>
          <div>
            <label className="block text-xs text-b-on-surface-muted mb-1">Condition Threshold</label>
            <input
              type="number"
              value={form.conditionThreshold}
              onChange={(e) => update('conditionThreshold', Number(e.target.value))}
              className="w-full px-3 py-2 rounded-lg bg-b-surface border border-b-border text-b-on-surface focus:outline-none focus:border-b-purple"
            />
          </div>
          <div>
            <label className="block text-xs text-b-on-surface-muted mb-1">Display Order</label>
            <input
              type="number"
              value={form.displayOrder}
              onChange={(e) => update('displayOrder', Number(e.target.value))}
              className="w-full px-3 py-2 rounded-lg bg-b-surface border border-b-border text-b-on-surface focus:outline-none focus:border-b-purple"
            />
          </div>
          <div>
            <label className="block text-xs text-b-on-surface-muted mb-1">Active</label>
            <select
              value={String(form.isActive)}
              onChange={(e) => update('isActive', e.target.value === 'true')}
              className="w-full px-3 py-2 rounded-lg bg-b-surface border border-b-border text-b-on-surface focus:outline-none focus:border-b-purple"
            >
              <option value="true">Yes</option>
              <option value="false">No</option>
            </select>
          </div>
        </div>
        <div>
          <label className="block text-xs text-b-on-surface-muted mb-1">Description (EN)</label>
          <textarea
            value={form.description}
            onChange={(e) => update('description', e.target.value)}
            rows={2}
            className="w-full px-3 py-2 rounded-lg bg-b-surface border border-b-border text-b-on-surface focus:outline-none focus:border-b-purple"
          />
        </div>
        <div>
          <label className="block text-xs text-b-on-surface-muted mb-1">Description (AR)</label>
          <textarea
            value={form.descriptionAr}
            onChange={(e) => update('descriptionAr', e.target.value)}
            rows={2}
            className="w-full px-3 py-2 rounded-lg bg-b-surface border border-b-border text-b-on-surface focus:outline-none focus:border-b-purple"
          />
        </div>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <ImageUpload
            id="achievement-icon"
            label="Icon"
            previewUrl={form.iconUrl}
            onFileSelect={setIconFile}
          />
          <ImageUpload
            id="achievement-icon-inactive"
            label="Inactive Icon"
            previewUrl={form.iconInactiveUrl}
            onFileSelect={setIconInactiveFile}
          />
        </div>
        {!isNew && (
          <div className="flex items-center justify-between text-sm">
            <span className="text-b-on-surface-muted">Updated {formatDate(form.updatedAt)}</span>
            {!isSupport && (
              <Button
                variant="danger"
                size="sm"
                disabled={isSaving}
                isLoading={isSaving}
                onClick={handleDelete}
              >
                Delete
              </Button>
            )}
          </div>
        )}
      </div>
    </Modal>
  );
}

function kebabCase(value: string): string {
  return value
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '');
}
