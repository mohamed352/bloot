import { useState } from 'react';
import { useQueryClient } from '@tanstack/react-query';
import { useGames } from '../../hooks/useGames';
import { adminFunctions } from '../../services/adminFunctions';
import { PageHeader } from '../../components/PageHeader';
import { DataTable } from '../../components/DataTable';
import { Badge } from '../../components/Badge';
import { Button } from '../../components/Button';
import { Modal } from '../../components/Modal';
import { useToastStore } from '../../stores/toastStore';
import { exportToCsv } from '../../utils/csvExport';
import { formatDate, formatNumber } from '../../utils/formatters';
import type { Game } from '../../types';

const tabs: { label: string; value?: string }[] = [
  { label: 'All' },
  { label: 'Playing', value: 'playing' },
  { label: 'Completed', value: 'gameEnd' },
];

const statusVariant: Record<string, 'default' | 'success' | 'warning' | 'danger' | 'info'> = {
  waiting: 'warning',
  playing: 'success',
  gameEnd: 'default',
  cancelled: 'danger',
};

export function GamesPage() {
  const queryClient = useQueryClient();
  const [activeTab, setActiveTab] = useState<string | undefined>(undefined);
  const [selected, setSelected] = useState<Game | null>(null);
  const { data: games, isLoading } = useGames(activeTab);

  const refresh = () => queryClient.invalidateQueries({ queryKey: ['games'] });

  const handleExportCsv = () => {
    const rows = (games || []).map((g) => ({
      id: g.id,
      gameType: g.gameType,
      status: g.status,
      teamAScore: g.teamAScore,
      teamBScore: g.teamBScore,
      currentRound: g.currentRound,
      totalRounds: g.totalRounds,
      players: Object.keys(g.players || {}).length,
      startedAt: formatDate(g.startedAt),
    }));
    exportToCsv('games.csv', rows, [
      { key: 'id', header: 'Game ID' },
      { key: 'gameType', header: 'Type' },
      { key: 'status', header: 'Status' },
      { key: 'teamAScore', header: 'Team A' },
      { key: 'teamBScore', header: 'Team B' },
      { key: 'currentRound', header: 'Round' },
      { key: 'totalRounds', header: 'Total Rounds' },
      { key: 'players', header: 'Players' },
      { key: 'startedAt', header: 'Started' },
    ]);
  };

  const columns = [
    { key: 'id', header: 'Game ID', render: (g: Game) => <span className="font-mono text-xs">{g.id.slice(0, 12)}...</span> },
    {
      key: 'gameType',
      header: 'Type',
      render: (g: Game) => <span className="capitalize">{g.gameType}</span>,
    },
    {
      key: 'status',
      header: 'Status',
      render: (g: Game) => <Badge variant={statusVariant[g.status] || 'default'}>{g.status}</Badge>,
    },
    {
      key: 'score',
      header: 'Score',
      render: (g: Game) => `${g.teamAScore} - ${g.teamBScore}`,
    },
    { key: 'currentRound', header: 'Round', render: (g: Game) => `${g.currentRound}/${g.totalRounds}` },
    {
      key: 'players',
      header: 'Players',
      render: (g: Game) => Object.keys(g.players || {}).length,
    },
    { key: 'startedAt', header: 'Started', render: (g: Game) => formatDate(g.startedAt) },
    {
      key: 'actions',
      header: 'Actions',
      render: (g: Game) => (
        <Button size="sm" variant="secondary" onClick={() => setSelected(g)}>
          View
        </Button>
      ),
    },
  ];

  return (
    <div>
      <PageHeader
        title="Games"
        subtitle="Monitor active and completed games"
        actions={
          <Button variant="secondary" onClick={handleExportCsv} disabled={!games || games.length === 0}>
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
          rows={games || []}
          keyExtractor={(g) => g.id}
          isLoading={isLoading}
          onRowClick={(g) => setSelected(g)}
        />
      </div>

      <GameModal
        game={selected}
        onClose={() => setSelected(null)}
        onEnded={() => {
          setSelected(null);
          refresh();
        }}
      />
    </div>
  );
}

function GameModal({
  game,
  onClose,
  onEnded,
}: {
  game: Game | null;
  onClose: () => void;
  onEnded: () => void;
}) {
  const addToast = useToastStore((s) => s.addToast);
  const [isEnding, setIsEnding] = useState(false);

  if (!game) return null;
  const players = Object.values(game.players || {});

  return (
    <Modal isOpen={!!game} onClose={onClose} title="Game Details" size="lg">
      <div className="space-y-4">
        <div className="grid grid-cols-2 gap-4 text-sm">
          <div>
            <p className="text-xs text-b-on-surface-muted">Game ID</p>
            <p className="text-b-on-surface break-all">{game.id}</p>
          </div>
          <div>
            <p className="text-xs text-b-on-surface-muted">Room ID</p>
            <p className="text-b-on-surface">{game.roomId}</p>
          </div>
          <div>
            <p className="text-xs text-b-on-surface-muted">Type</p>
            <p className="text-b-on-surface capitalize">{game.gameType}</p>
          </div>
          <div>
            <p className="text-xs text-b-on-surface-muted">Status</p>
            <Badge variant={statusVariant[game.status] || 'default'}>{game.status}</Badge>
          </div>
          <div>
            <p className="text-xs text-b-on-surface-muted">Score</p>
            <p className="text-b-on-surface">{game.teamAScore} - {game.teamBScore}</p>
          </div>
          <div>
            <p className="text-xs text-b-on-surface-muted">Round</p>
            <p className="text-b-on-surface">{game.currentRound}/{game.totalRounds}</p>
          </div>
          <div>
            <p className="text-xs text-b-on-surface-muted">Started</p>
            <p className="text-b-on-surface">{formatDate(game.startedAt)}</p>
          </div>
          <div>
            <p className="text-xs text-b-on-surface-muted">Turn Index</p>
            <p className="text-b-on-surface">{game.turnIndex}</p>
          </div>
        </div>

        <div>
          <p className="text-xs text-b-on-surface-muted mb-2">Players</p>
          <div className="space-y-2">
            {players.map((p) => (
              <div key={p.uid} className="flex items-center justify-between bg-b-surface rounded-lg px-3 py-2 border border-b-border">
                <div className="flex items-center gap-2">
                  <span className="text-b-on-surface text-sm">{p.displayName}</span>
                  <Badge variant={p.team === 'A' ? 'info' : 'warning'}>Team {p.team}</Badge>
                </div>
                <span className="text-b-on-surface-muted text-xs">Score: {formatNumber(p.score)}</span>
              </div>
            ))}
            {players.length === 0 && <p className="text-sm text-b-on-surface-muted">No players recorded.</p>}
          </div>
        </div>

        <Button
          variant="danger"
          disabled={isEnding || game.status !== 'playing'}
          isLoading={isEnding}
          onClick={async () => {
            if (!confirm('Force end this game?')) return;
            setIsEnding(true);
            try {
              await adminFunctions.forceEndGame({ gameId: game.id });
              addToast('Game force ended', 'success');
              onEnded();
            } catch (e) {
              addToast(e instanceof Error ? e.message : 'Failed to end game', 'error');
              setIsEnding(false);
            }
          }}
        >
          {isEnding ? 'Ending...' : 'Force End Game'}
        </Button>
      </div>
    </Modal>
  );
}
