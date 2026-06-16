import { useEffect, useState } from 'react';
import { useQueryClient } from '@tanstack/react-query';
import { useAuthStore } from '../../stores/authStore';
import { useLiveDocument } from '../../hooks/useLiveDocument';
import { useAdmins } from '../../hooks/useAdmins';
import { useAdminRole } from '../../hooks/useAdminRole';
import { adminFunctions } from '../../services/adminFunctions';
import { PageHeader } from '../../components/PageHeader';
import { DataTable } from '../../components/DataTable';
import { Badge } from '../../components/Badge';
import { Button } from '../../components/Button';
import { Modal } from '../../components/Modal';
import { Spinner } from '../../components/Spinner';
import { useToastStore } from '../../stores/toastStore';
import { formatDate } from '../../utils/formatters';
import { Timestamp } from 'firebase/firestore';
import type { AdminDoc, AdminRole, SystemSettings } from '../../types';

const roleVariant: Record<AdminRole, 'default' | 'success' | 'warning' | 'danger' | 'info'> = {
  super_admin: 'danger',
  moderator: 'warning',
  support: 'info',
};

export function SettingsPage() {
  const queryClient = useQueryClient();
  const addToast = useToastStore((s) => s.addToast);
  const user = useAuthStore((s) => s.user);
  const { role, hasPermission } = useAdminRole(user?.uid);
  const { data: settings, isLoading: settingsLoading } = useLiveDocument<SystemSettings>('settings', 'system');
  const { data: admins, isLoading: adminsLoading } = useAdmins();
  const [showAddAdmin, setShowAddAdmin] = useState(false);
  const [loadingAction, setLoadingAction] = useState<string | null>(null);

  const refreshAdmins = () => queryClient.invalidateQueries({ queryKey: ['admins'] });

  const handleAdminAction = async (action: () => Promise<unknown>, label: string) => {
    setLoadingAction(label);
    try {
      await action();
      addToast(`${label} succeeded`, 'success');
      refreshAdmins();
    } catch (err) {
      addToast((err as Error).message, 'error');
    } finally {
      setLoadingAction(null);
    }
  };

  const adminColumns = [
    { key: 'displayName', header: 'Name' },
    { key: 'email', header: 'Email' },
    {
      key: 'role',
      header: 'Role',
      render: (a: AdminDoc) => <Badge variant={roleVariant[a.role] || 'default'}>{a.role}</Badge>,
    },
    { key: 'createdAt', header: 'Added', render: (a: AdminDoc) => formatDate(a.createdAt) },
    {
      key: 'actions',
      header: 'Actions',
      render: (a: AdminDoc) =>
        hasPermission('super') ? (
          <Button
            size="sm"
            variant="ghost"
            isLoading={loadingAction === `remove-${a.uid}`}
            onClick={() => handleAdminAction(() => adminFunctions.removeAdmin({ uid: a.uid }), `remove-${a.uid}`)}
          >
            Remove
          </Button>
        ) : null,
    },
  ];

  const isSuperAdmin = role === 'super_admin';

  return (
    <div>
      <PageHeader
        title="Settings"
        subtitle="System configuration and admin management"
        actions={
          isSuperAdmin ? (
            <Button onClick={() => setShowAddAdmin(true)}>Add Admin</Button>
          ) : null
        }
      />

      {settingsLoading ? <Spinner /> : <SettingsForm settings={settings} />}

      {isSuperAdmin && (
        <div className="mt-8">
          <h2 className="text-lg font-semibold text-b-on-surface mb-4">Admin Users</h2>
          <div className="bg-b-surface-elevated rounded-xl border border-b-border overflow-hidden">
            <DataTable
              columns={adminColumns}
              rows={admins || []}
              keyExtractor={(a) => a.uid}
              isLoading={adminsLoading}
            />
          </div>
        </div>
      )}

      {isSuperAdmin && (
        <AddAdminModal
          isOpen={showAddAdmin}
          onClose={() => setShowAddAdmin(false)}
          onAdded={() => {
            refreshAdmins();
            setShowAddAdmin(false);
          }}
        />
      )}
    </div>
  );
}

function SettingsForm({ settings }: { settings: SystemSettings | null }) {
  const addToast = useToastStore((s) => s.addToast);
  const user = useAuthStore((s) => s.user);
  const { hasPermission } = useAdminRole(user?.uid);
  const [form, setForm] = useState<SystemSettings>(
    settings || {
      id: 'system',
      maintenanceMode: false,
      allowNewSignups: true,
      defaultCoinPackages: [],
      featureFlags: {},
      updatedAt: Timestamp.now(),
    }
  );
  const [saving, setSaving] = useState(false);
  const [isDirty, setIsDirty] = useState(false);

  useEffect(() => {
    if (settings && !isDirty && !saving) {
      setForm(settings);
    }
  }, [settings, isDirty, saving]);

  const canEdit = hasPermission('super');

  const handleSave = async () => {
    setSaving(true);
    try {
      await adminFunctions.updateSettings({
        settingsId: 'system',
        updates: {
          maintenanceMode: form.maintenanceMode,
          allowNewSignups: form.allowNewSignups,
          featureFlags: form.featureFlags,
        },
      });
      setIsDirty(false);
      addToast('Settings saved', 'success');
    } catch (err) {
      addToast((err as Error).message, 'error');
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="bg-b-surface-elevated rounded-xl border border-b-border p-6 space-y-6">
      <h2 className="text-lg font-semibold text-b-on-surface">System Settings</h2>
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
        <label className="flex items-center justify-between bg-b-surface rounded-lg border border-b-border px-4 py-3 cursor-pointer">
          <span className="text-sm text-b-on-surface">Maintenance Mode</span>
          <input
            type="checkbox"
            checked={form.maintenanceMode}
            disabled={!canEdit}
            onChange={(e) => { setIsDirty(true); setForm((f) => ({ ...f, maintenanceMode: e.target.checked })); }}
            className="w-5 h-5 accent-b-purple rounded"
          />
        </label>
        <label className="flex items-center justify-between bg-b-surface rounded-lg border border-b-border px-4 py-3 cursor-pointer">
          <span className="text-sm text-b-on-surface">Allow New Signups</span>
          <input
            type="checkbox"
            checked={form.allowNewSignups}
            disabled={!canEdit}
            onChange={(e) => { setIsDirty(true); setForm((f) => ({ ...f, allowNewSignups: e.target.checked })); }}
            className="w-5 h-5 accent-b-purple rounded"
          />
        </label>
      </div>
      <div>
        <label className="block text-xs text-b-on-surface-muted mb-1">Feature Flags (JSON)</label>
        <textarea
          value={JSON.stringify(form.featureFlags || {}, null, 2)}
          disabled={!canEdit}
          onChange={(e) => {
            try {
              const parsed = JSON.parse(e.target.value);
              setForm((f) => ({ ...f, featureFlags: parsed }));
            } catch {
              // ignore invalid JSON while typing
            }
          }}
          rows={5}
          className="w-full px-3 py-2 rounded-lg bg-b-surface border border-b-border text-b-on-surface font-mono text-sm focus:outline-none focus:border-b-purple disabled:opacity-50"
        />
      </div>
      <div className="flex justify-end">
        <Button onClick={handleSave} isLoading={saving} disabled={!canEdit}>
          Save Settings
        </Button>
      </div>
    </div>
  );
}

function AddAdminModal({
  isOpen,
  onClose,
  onAdded,
}: {
  isOpen: boolean;
  onClose: () => void;
  onAdded: () => void;
}) {
  const addToast = useToastStore((s) => s.addToast);
  const [uid, setUid] = useState('');
  const [email, setEmail] = useState('');
  const [role, setRole] = useState<AdminRole>('moderator');
  const [saving, setSaving] = useState(false);

  const handleAdd = async () => {
    if (!uid || !email) return;
    setSaving(true);
    try {
      await adminFunctions.addAdmin({ uid, email, role });
      addToast('Admin added', 'success');
      setUid('');
      setEmail('');
      onAdded();
    } catch (err) {
      addToast((err as Error).message, 'error');
    } finally {
      setSaving(false);
    }
  };

  return (
    <Modal
      isOpen={isOpen}
      onClose={onClose}
      title="Add Admin"
      size="md"
      actions={
        <>
          <Button variant="secondary" onClick={onClose}>
            Cancel
          </Button>
          <Button onClick={handleAdd} isLoading={saving}>
            Add
          </Button>
        </>
      }
    >
      <div className="space-y-4">
        <div>
          <label className="block text-xs text-b-on-surface-muted mb-1">User UID</label>
          <input
            type="text"
            value={uid}
            onChange={(e) => setUid(e.target.value)}
            className="w-full px-3 py-2 rounded-lg bg-b-surface border border-b-border text-b-on-surface focus:outline-none focus:border-b-purple"
          />
        </div>
        <div>
          <label className="block text-xs text-b-on-surface-muted mb-1">Email</label>
          <input
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            className="w-full px-3 py-2 rounded-lg bg-b-surface border border-b-border text-b-on-surface focus:outline-none focus:border-b-purple"
          />
        </div>
        <div>
          <label className="block text-xs text-b-on-surface-muted mb-1">Role</label>
          <select
            value={role}
            onChange={(e) => setRole(e.target.value as AdminRole)}
            className="w-full px-3 py-2 rounded-lg bg-b-surface border border-b-border text-b-on-surface focus:outline-none focus:border-b-purple"
          >
            <option value="super_admin">Super Admin</option>
            <option value="moderator">Moderator</option>
            <option value="support">Support</option>
          </select>
        </div>
      </div>
    </Modal>
  );
}
