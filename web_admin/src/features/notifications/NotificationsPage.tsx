import { useState } from 'react';
import { useQueryClient } from '@tanstack/react-query';
import { useNotifications } from '../../hooks/useNotifications';
import { adminFunctions } from '../../services/adminFunctions';
import { uploadImage } from '../../services/storage';
import { PageHeader } from '../../components/PageHeader';
import { DataTable } from '../../components/DataTable';
import { Badge } from '../../components/Badge';
import { Button } from '../../components/Button';
import { Modal } from '../../components/Modal';
import { ImageUpload } from '../../components/ImageUpload';
import { useToastStore } from '../../stores/toastStore';
import { formatDate } from '../../utils/formatters';
import type { Notification } from '../../types';

const priorityVariant: Record<string, 'default' | 'success' | 'warning' | 'danger' | 'info'> = {
  high: 'danger',
  normal: 'info',
  low: 'default',
};

const pushStatusVariant: Record<string, 'default' | 'success' | 'warning' | 'danger' | 'info'> = {
  sent: 'success',
  pending: 'warning',
  failed: 'danger',
};

export function NotificationsPage() {
  const queryClient = useQueryClient();
  const [selected, setSelected] = useState<Notification | null>(null);
  const [showCompose, setShowCompose] = useState(false);
  const [showDirect, setShowDirect] = useState(false);
  const { data: notifications, isLoading } = useNotifications();

  const columns = [
    { key: 'type', header: 'Type', render: (n: Notification) => <span className="capitalize">{n.type}</span> },
    { key: 'title', header: 'Title' },
    { key: 'titleAr', header: 'Title (AR)' },
    {
      key: 'priority',
      header: 'Priority',
      render: (n: Notification) => <Badge variant={priorityVariant[n.priority] || 'default'}>{n.priority}</Badge>,
    },
    {
      key: 'isRead',
      header: 'Read',
      render: (n: Notification) => (n.isRead ? <Badge variant="success">Yes</Badge> : <Badge>No</Badge>),
    },
    {
      key: 'pushStatus',
      header: 'Push',
      render: (n: Notification) =>
        n.pushStatus ? <Badge variant={pushStatusVariant[n.pushStatus] || 'default'}>{n.pushStatus}</Badge> : <Badge>-</Badge>,
    },
    { key: 'createdAt', header: 'Sent', render: (n: Notification) => formatDate(n.createdAt) },
    {
      key: 'actions',
      header: 'Actions',
      render: (n: Notification) => (
        <Button size="sm" variant="secondary" onClick={() => setSelected(n)}>
          View
        </Button>
      ),
    },
  ];

  const refresh = () => queryClient.invalidateQueries({ queryKey: ['notifications'] });

  return (
    <div>
      <PageHeader
        title="Notifications"
        subtitle="Notification history and broadcast composer"
        actions={
          <div className="flex items-center gap-2">
            <Button variant="secondary" onClick={() => setShowDirect(true)}>
              Send Direct
            </Button>
            <Button onClick={() => setShowCompose(true)}>Compose Broadcast</Button>
          </div>
        }
      />

      <div className="bg-b-surface-elevated rounded-xl border border-b-border overflow-hidden">
        <DataTable
          columns={columns}
          rows={notifications || []}
          keyExtractor={(n) => n.id}
          isLoading={isLoading}
          onRowClick={(n) => setSelected(n)}
        />
      </div>

      <NotificationModal notification={selected} onClose={() => setSelected(null)} />
      <ComposeModal
        isOpen={showCompose}
        onClose={() => setShowCompose(false)}
        onSent={refresh}
      />
      <DirectSendModal
        isOpen={showDirect}
        onClose={() => setShowDirect(false)}
        onSent={refresh}
      />
    </div>
  );
}

function NotificationModal({ notification, onClose }: { notification: Notification | null; onClose: () => void }) {
  if (!notification) return null;

  return (
    <Modal isOpen={!!notification} onClose={onClose} title="Notification Details" size="md">
      <div className="space-y-4 text-sm">
        <div className="grid grid-cols-2 gap-4">
          <div>
            <p className="text-xs text-b-on-surface-muted">Type</p>
            <p className="text-b-on-surface capitalize">{notification.type}</p>
          </div>
          <div>
            <p className="text-xs text-b-on-surface-muted">Priority</p>
            <Badge variant={priorityVariant[notification.priority] || 'default'}>{notification.priority}</Badge>
          </div>
          <div>
            <p className="text-xs text-b-on-surface-muted">User UID</p>
            <p className="text-b-on-surface break-all">{notification.uid}</p>
          </div>
          <div>
            <p className="text-xs text-b-on-surface-muted">Sent</p>
            <p className="text-b-on-surface">{formatDate(notification.createdAt)}</p>
          </div>
        </div>
        <div>
          <p className="text-xs text-b-on-surface-muted">Title (EN)</p>
          <p className="text-b-on-surface">{notification.title}</p>
        </div>
        <div>
          <p className="text-xs text-b-on-surface-muted">Title (AR)</p>
          <p className="text-b-on-surface">{notification.titleAr}</p>
        </div>
        <div>
          <p className="text-xs text-b-on-surface-muted">Body (EN)</p>
          <p className="text-b-on-surface">{notification.body}</p>
        </div>
        <div>
          <p className="text-xs text-b-on-surface-muted">Body (AR)</p>
          <p className="text-b-on-surface">{notification.bodyAr}</p>
        </div>
      </div>
    </Modal>
  );
}

interface ComposeFormProps {
  onClose: () => void;
  onSent: () => void;
  send: (payload: {
    title: string;
    titleAr?: string;
    body: string;
    bodyAr?: string;
    priority: Notification['priority'];
    imageUrl?: string;
  }) => Promise<unknown>;
}

function ComposeForm({ onClose, onSent, send }: ComposeFormProps) {
  const addToast = useToastStore((s) => s.addToast);
  const [title, setTitle] = useState('');
  const [titleAr, setTitleAr] = useState('');
  const [body, setBody] = useState('');
  const [bodyAr, setBodyAr] = useState('');
  const [priority, setPriority] = useState<Notification['priority']>('normal');
  const [imageFile, setImageFile] = useState<File | null>(null);
  const [sending, setSending] = useState(false);

  const handleSend = async () => {
    if (!title || !body) return;
    setSending(true);
    try {
      let imageUrl: string | undefined;
      if (imageFile) {
        imageUrl = await uploadImage(`notifications/broadcast-${Date.now()}`, imageFile);
      }
      await send({ title, titleAr, body, bodyAr, priority, imageUrl });
      addToast('Notification sent', 'success');
      setTitle('');
      setTitleAr('');
      setBody('');
      setBodyAr('');
      onSent();
      onClose();
    } catch (err) {
      addToast((err as Error).message, 'error');
    } finally {
      setSending(false);
    }
  };

  return (
    <div className="space-y-4">
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <div>
          <label className="block text-xs text-b-on-surface-muted mb-1">Title (EN)</label>
          <input
            type="text"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            className="w-full px-3 py-2 rounded-lg bg-b-surface border border-b-border text-b-on-surface focus:outline-none focus:border-b-purple"
          />
        </div>
        <div>
          <label className="block text-xs text-b-on-surface-muted mb-1">Title (AR)</label>
          <input
            type="text"
            value={titleAr}
            onChange={(e) => setTitleAr(e.target.value)}
            className="w-full px-3 py-2 rounded-lg bg-b-surface border border-b-border text-b-on-surface focus:outline-none focus:border-b-purple"
          />
        </div>
      </div>
      <div>
        <label className="block text-xs text-b-on-surface-muted mb-1">Body (EN)</label>
        <textarea
          value={body}
          onChange={(e) => setBody(e.target.value)}
          rows={3}
          className="w-full px-3 py-2 rounded-lg bg-b-surface border border-b-border text-b-on-surface focus:outline-none focus:border-b-purple"
        />
      </div>
      <div>
        <label className="block text-xs text-b-on-surface-muted mb-1">Body (AR)</label>
        <textarea
          value={bodyAr}
          onChange={(e) => setBodyAr(e.target.value)}
          rows={3}
          className="w-full px-3 py-2 rounded-lg bg-b-surface border border-b-border text-b-on-surface focus:outline-none focus:border-b-purple"
        />
      </div>
      <div>
        <label className="block text-xs text-b-on-surface-muted mb-1">Priority</label>
        <select
          value={priority}
          onChange={(e) => setPriority(e.target.value as Notification['priority'])}
          className="w-full px-3 py-2 rounded-lg bg-b-surface border border-b-border text-b-on-surface focus:outline-none focus:border-b-purple"
        >
          <option value="high">High</option>
          <option value="normal">Normal</option>
          <option value="low">Low</option>
        </select>
      </div>
      <div>
        <ImageUpload label="Image (optional)" onFileSelect={setImageFile} />
      </div>
      <div className="flex justify-end gap-2">
        <Button variant="secondary" onClick={onClose}>
          Cancel
        </Button>
        <Button onClick={handleSend} isLoading={sending} disabled={!title || !body}>
          Send
        </Button>
      </div>
    </div>
  );
}

function ComposeModal({ isOpen, onClose, onSent }: { isOpen: boolean; onClose: () => void; onSent: () => void }) {
  return (
    <Modal isOpen={isOpen} onClose={onClose} title="Compose Broadcast" size="lg">
      <ComposeForm
        onClose={onClose}
        onSent={onSent}
        send={(payload) => adminFunctions.sendBroadcast(payload)}
      />
    </Modal>
  );
}

function DirectSendModal({ isOpen, onClose, onSent }: { isOpen: boolean; onClose: () => void; onSent: () => void }) {
  const [uid, setUid] = useState('');

  return (
    <Modal isOpen={isOpen} onClose={onClose} title="Send Direct Notification" size="lg">
      <div className="space-y-4">
        <div>
          <label className="block text-xs text-b-on-surface-muted mb-1">Recipient UID</label>
          <input
            type="text"
            value={uid}
            onChange={(e) => setUid(e.target.value)}
            className="w-full px-3 py-2 rounded-lg bg-b-surface border border-b-border text-b-on-surface focus:outline-none focus:border-b-purple"
          />
        </div>
        <ComposeForm
          onClose={onClose}
          onSent={onSent}
          send={(payload) => adminFunctions.sendNotification({ ...payload, uid })}
        />
      </div>
    </Modal>
  );
}
