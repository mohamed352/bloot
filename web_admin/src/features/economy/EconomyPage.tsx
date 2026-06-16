import { useMemo, useState } from 'react';
import { where } from 'firebase/firestore';
import { usePaginatedSearch } from '../../hooks/usePaginatedSearch';
import { adminFunctions } from '../../services/adminFunctions';
import { PageHeader } from '../../components/PageHeader';
import { DataTable } from '../../components/DataTable';
import { Badge } from '../../components/Badge';
import { Button } from '../../components/Button';
import { Modal } from '../../components/Modal';
import { exportToCsv } from '../../utils/csvExport';
import { formatDate, formatNumber } from '../../utils/formatters';
import type { CoinTransaction } from '../../types';

const typeVariant: Record<string, 'default' | 'success' | 'warning' | 'danger' | 'info'> = {
  purchase: 'success',
  reward: 'info',
  gameWin: 'success',
  gameLoss: 'danger',
  tournamentEntry: 'warning',
  tournamentPrize: 'success',
  transfer: 'info',
  adminAdjustment: 'warning',
};

const typeOptions = ['purchase', 'reward', 'gameWin', 'gameLoss', 'tournamentEntry', 'tournamentPrize', 'transfer', 'adminAdjustment'];

export function EconomyPage() {
  const [typeFilter, setTypeFilter] = useState('');
  const [uidFilter, setUidFilter] = useState('');
  const [selected, setSelected] = useState<CoinTransaction | null>(null);
  const [showAdjustment, setShowAdjustment] = useState(false);

  const { items: transactions, isLoading, isLoadingMore, hasMore, loadMore, refresh } = usePaginatedSearch<CoinTransaction>({
    path: 'coin_transactions',
    baseConstraints: typeFilter ? [where('type', '==', typeFilter)] : [],
  });

  const visibleTransactions = useMemo(() => {
    const term = uidFilter.trim().toLowerCase();
    if (!term) return transactions;
    return transactions.filter((t) => t.uid.toLowerCase().includes(term));
  }, [transactions, uidFilter]);

  const columns = [
    { key: 'type', header: 'Type', render: (t: CoinTransaction) => <Badge variant={typeVariant[t.type] || 'default'}>{t.type}</Badge> },
    { key: 'uid', header: 'User UID', render: (t: CoinTransaction) => <span className="font-mono text-xs">{t.uid}</span> },
    { key: 'amount', header: 'Amount', render: (t: CoinTransaction) => <span className={t.amount >= 0 ? 'text-green-400' : 'text-red-400'}>{t.amount > 0 ? '+' : ''}{formatNumber(t.amount)}</span> },
    { key: 'balanceAfter', header: 'Balance After', render: (t: CoinTransaction) => formatNumber(t.balanceAfter) },
    { key: 'description', header: 'Description', render: (t: CoinTransaction) => t.description || '-' },
    { key: 'referenceType', header: 'Reference', render: (t: CoinTransaction) => t.referenceType || '-' },
    { key: 'createdAt', header: 'Time', render: (t: CoinTransaction) => formatDate(t.createdAt) },
    {
      key: 'actions',
      header: 'Actions',
      render: (t: CoinTransaction) => (
        <Button size="sm" variant="secondary" onClick={() => setSelected(t)}>
          Details
        </Button>
      ),
    },
  ];

  const handleExportCsv = () => {
    const exportRows = visibleTransactions.map((t) => ({
      type: t.type,
      uid: t.uid,
      amount: t.amount,
      balanceAfter: t.balanceAfter,
      description: t.description || '',
      referenceType: t.referenceType || '',
      createdAt: formatDate(t.createdAt),
    }));
    exportToCsv(
      'coin-transactions.csv',
      exportRows,
      [
        { key: 'type', header: 'Type' },
        { key: 'uid', header: 'User UID' },
        { key: 'amount', header: 'Amount' },
        { key: 'balanceAfter', header: 'Balance After' },
        { key: 'description', header: 'Description' },
        { key: 'referenceType', header: 'Reference' },
        { key: 'createdAt', header: 'Time' },
      ]
    );
  };

  return (
    <div>
      <PageHeader
        title="Economy"
        subtitle="Coin transactions and balance management"
        actions={
          <div className="flex items-center gap-2">
            <Button variant="secondary" onClick={handleExportCsv} disabled={visibleTransactions.length === 0}>
              Export CSV
            </Button>
            <Button onClick={() => setShowAdjustment(true)}>Adjust Balance</Button>
          </div>
        }
      />

      <div className="flex flex-col sm:flex-row gap-3 mb-6">
        <select
          value={typeFilter}
          onChange={(e) => setTypeFilter(e.target.value)}
          className="px-4 py-2 rounded-lg bg-b-surface-elevated border border-b-border text-b-on-surface focus:outline-none focus:border-b-purple"
        >
          <option value="">All Types</option>
          {typeOptions.map((t) => (
            <option key={t} value={t}>
              {t}
            </option>
          ))}
        </select>
        <input
          type="text"
          placeholder="Filter by User UID"
          value={uidFilter}
          onChange={(e) => setUidFilter(e.target.value)}
          className="flex-1 max-w-md px-4 py-2 rounded-lg bg-b-surface-elevated border border-b-border text-b-on-surface placeholder-b-on-surface-secondary focus:outline-none focus:border-b-purple"
        />
      </div>

      <div className="bg-b-surface-elevated rounded-xl border border-b-border overflow-hidden">
        <DataTable
          columns={columns}
          rows={visibleTransactions}
          keyExtractor={(t) => t.id}
          isLoading={isLoading}
        />
      </div>

      {hasMore && (
        <div className="mt-4 flex justify-center">
          <Button onClick={loadMore} isLoading={isLoadingMore}>
            Load More
          </Button>
        </div>
      )}

      <TransactionModal
        transaction={selected}
        onClose={() => setSelected(null)}
        onRefund={async () => {
          setSelected(null);
          refresh();
        }}
      />
      <AdjustmentModal
        isOpen={showAdjustment}
        onClose={() => setShowAdjustment(false)}
        onApplied={() => {
          setShowAdjustment(false);
          refresh();
        }}
      />
    </div>
  );
}

function TransactionModal({
  transaction,
  onClose,
  onRefund,
}: {
  transaction: CoinTransaction | null;
  onClose: () => void;
  onRefund: () => Promise<void>;
}) {
  const [isRefunding, setIsRefunding] = useState(false);

  if (!transaction) return null;

  return (
    <Modal isOpen={!!transaction} onClose={onClose} title="Transaction Details" size="md">
      <div className="grid grid-cols-2 gap-4 text-sm">
        <div>
          <p className="text-xs text-b-on-surface-muted">Transaction ID</p>
          <p className="text-b-on-surface break-all">{transaction.id}</p>
        </div>
        <div>
          <p className="text-xs text-b-on-surface-muted">Type</p>
          <Badge variant={typeVariant[transaction.type] || 'default'}>{transaction.type}</Badge>
        </div>
        <div>
          <p className="text-xs text-b-on-surface-muted">User UID</p>
          <p className="text-b-on-surface break-all">{transaction.uid}</p>
        </div>
        <div>
          <p className="text-xs text-b-on-surface-muted">Counterparty</p>
          <p className="text-b-on-surface break-all">{transaction.counterpartyUid || '-'}</p>
        </div>
        <div>
          <p className="text-xs text-b-on-surface-muted">Amount</p>
          <p className={transaction.amount >= 0 ? 'text-green-400' : 'text-red-400'}>
            {transaction.amount > 0 ? '+' : ''}{formatNumber(transaction.amount)}
          </p>
        </div>
        <div>
          <p className="text-xs text-b-on-surface-muted">Balance After</p>
          <p className="text-b-on-surface">{formatNumber(transaction.balanceAfter)}</p>
        </div>
        <div className="col-span-2">
          <p className="text-xs text-b-on-surface-muted">Description</p>
          <p className="text-b-on-surface">{transaction.description || '-'}</p>
        </div>
        <div>
          <p className="text-xs text-b-on-surface-muted">Reference Type</p>
          <p className="text-b-on-surface">{transaction.referenceType || '-'}</p>
        </div>
        <div>
          <p className="text-xs text-b-on-surface-muted">Reference ID</p>
          <p className="text-b-on-surface break-all">{transaction.referenceId || '-'}</p>
        </div>
        <div>
          <p className="text-xs text-b-on-surface-muted">Created</p>
          <p className="text-b-on-surface">{formatDate(transaction.createdAt)}</p>
        </div>
      </div>
      {transaction.type === 'purchase' && (
        <Button
          variant="secondary"
          disabled={isRefunding}
          onClick={async () => {
            if (!confirm('Issue a refund for this transaction?')) return;
            setIsRefunding(true);
            try {
              await adminFunctions.issueRefund({ transactionId: transaction.id });
              await onRefund();
            } catch (e) {
              alert(e instanceof Error ? e.message : 'Failed to issue refund');
            } finally {
              setIsRefunding(false);
            }
          }}
        >
          {isRefunding ? 'Refunding...' : 'Issue Refund'}
        </Button>
      )}
    </Modal>
  );
}

function AdjustmentModal({
  isOpen,
  onClose,
  onApplied,
}: {
  isOpen: boolean;
  onClose: () => void;
  onApplied: () => void;
}) {
  const [uid, setUid] = useState('');
  const [amount, setAmount] = useState('');
  const [reason, setReason] = useState('');
  const [isApplying, setIsApplying] = useState(false);

  return (
    <Modal
      isOpen={isOpen}
      onClose={onClose}
      title="Adjust Balance"
      size="md"
      actions={
        <>
          <Button variant="secondary" onClick={onClose}>
            Cancel
          </Button>
          <Button
            disabled={isApplying || !uid.trim() || amount === ''}
            isLoading={isApplying}
            onClick={async () => {
              setIsApplying(true);
              try {
                await adminFunctions.adjustBalance({
                  uid: uid.trim(),
                  amount: Number(amount),
                  description: reason,
                });
                onApplied();
              } catch (e) {
                alert(e instanceof Error ? e.message : 'Failed to adjust balance');
              } finally {
                setIsApplying(false);
              }
            }}
          >
            Apply
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
          <label className="block text-xs text-b-on-surface-muted mb-1">Amount (+/- coins)</label>
          <input
            type="number"
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
            className="w-full px-3 py-2 rounded-lg bg-b-surface border border-b-border text-b-on-surface focus:outline-none focus:border-b-purple"
          />
        </div>
        <div>
          <label className="block text-xs text-b-on-surface-muted mb-1">Reason</label>
          <textarea
            value={reason}
            onChange={(e) => setReason(e.target.value)}
            rows={3}
            className="w-full px-3 py-2 rounded-lg bg-b-surface border border-b-border text-b-on-surface focus:outline-none focus:border-b-purple"
          />
        </div>
      </div>
    </Modal>
  );
}
