import { useEffect } from 'react';
import { LineChart } from '../components/charts';
import { Link } from 'react-router-dom';
import { useAuthStore } from '../stores/authStore';
import { useDashboardStats } from '../hooks/useDashboardStats';
import { useDashboardActivity } from '../hooks/useDashboardActivity';
import { useLiveCollection } from '../hooks/useLiveCollection';
import { formatNumber, formatRelativeTime } from '../utils/formatters';
import { Spinner } from '../components/Spinner';

import type { AdminLog } from '../types';
import { orderBy, limit } from 'firebase/firestore';

export function Dashboard() {
  const user = useAuthStore((s) => s.user);
  const role = useAuthStore((s) => s.role);
  const { data: stats, isLoading: statsLoading } = useDashboardStats();
  const { data: activity, isLoading: activityLoading } = useDashboardActivity();
  const { data: recentLogs, isLoading: logsLoading } = useLiveCollection<AdminLog>('admin_logs', [
    orderBy('createdAt', 'desc'),
    limit(10),
  ]);

  useEffect(() => {
    document.title = 'Bloot Admin — Dashboard';
  }, []);

  const isLoading = statsLoading || activityLoading || logsLoading;

  const chartData = {
    labels: activity?.labels || [],
    datasets: [
      {
        label: 'Active Players',
        data: activity?.values || [],
        borderColor: '#8b5cf6',
        backgroundColor: 'rgba(139, 92, 246, 0.1)',
        fill: true,
        tension: 0.4,
        pointRadius: 3,
        pointBackgroundColor: '#8b5cf6',
      },
    ],
  };

  const chartOptions = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: { display: false },
    },
    scales: {
      y: {
        beginAtZero: true,
        grid: { color: 'rgba(255, 255, 255, 0.05)' },
        ticks: { color: '#9ca3af' },
      },
      x: {
        grid: { display: false },
        ticks: { color: '#9ca3af' },
      },
    },
  };

  return (
    <div>
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-8">
        <div>
          <h1 className="text-2xl font-bold text-b-on-surface">Dashboard</h1>
          <p className="text-sm text-b-on-surface-muted mt-1">
            Welcome back, {user?.displayName || user?.email || 'Admin'}
          </p>
        </div>
      </div>

      {isLoading ? (
        <Spinner />
      ) : (
        <>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
            <StatCard
              label="Active Players Now"
              value={formatNumber(stats?.activePlayersNow ?? 0)}
              subtext={`${(stats?.activePlayersChange ?? 0) >= 0 ? '+' : ''}${stats?.activePlayersChange ?? 0}% vs yesterday`}
              subtextColor="text-green-400"
              live
            />
            <StatCard
              label="Live Streams"
              value={formatNumber(stats?.liveStreams ?? 0)}
              subtext={`${formatNumber(stats?.totalViewers ?? 0)} total viewers`}
              badge="LIVE"
            />
            <StatCard
              label="Games in Progress"
              value={formatNumber(stats?.gamesInProgress ?? 0)}
              subtext={`Across ${formatNumber(stats?.activeRooms ?? 0)} rooms`}
              icon="casino"
            />
            <StatCard
              label="Open Reports"
              value={formatNumber(stats?.openReports ?? 0)}
              subtext={`${(stats?.reportsChange ?? 0) >= 0 ? '+' : ''}${stats?.reportsChange ?? 0}% vs yesterday`}
              subtextColor="text-red-400"
              icon="flag"
              href="/reports"
            />
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            <div className="lg:col-span-2 bg-b-surface-elevated rounded-xl border border-b-border p-6">
              <h2 className="text-lg font-semibold text-b-on-surface mb-4">Player Activity (24h)</h2>
              <div className="h-64">
                <LineChart data={chartData} options={chartOptions} />
              </div>
            </div>
            <div className="bg-b-surface-elevated rounded-xl border border-b-border p-6">
              <h2 className="text-lg font-semibold text-b-on-surface mb-4">Recent Admin Activity</h2>
              <div className="space-y-4">
                {recentLogs && recentLogs.length > 0 ? (
                  recentLogs.map((log) => (
                    <ActivityItem
                      key={log.id}
                      icon="shield"
                      text={`${log.action} on ${log.targetType}`}
                      time={formatRelativeTime(log.createdAt)}
                    />
                  ))
                ) : (
                  <p className="text-sm text-b-on-surface-muted">No recent activity.</p>
                )}
              </div>
            </div>
          </div>

          {role === 'support' && (
            <div className="mt-6 p-4 rounded-lg border border-yellow-500/30 bg-yellow-500/10 text-yellow-400 text-sm">
              Support view: some moderation actions are restricted.
            </div>
          )}
        </>
      )}
    </div>
  );
}

interface StatCardProps {
  label: string;
  value: string;
  subtext: string;
  subtextColor?: string;
  live?: boolean;
  badge?: string;
  icon?: string;
  href?: string;
}

function StatCard({ label, value, subtext, subtextColor = 'text-b-on-surface-muted', live, badge, icon, href }: StatCardProps) {
  const content = (
    <div className="bg-b-surface-elevated rounded-xl border border-b-border p-5 hover:border-b-purple/30 transition-colors">
      <div className="flex items-center justify-between mb-3">
        <span className="text-sm text-b-on-surface-muted">{label}</span>
        {live && (
          <span className="flex items-center gap-1.5 text-xs text-green-400">
            <span className="w-2 h-2 rounded-full bg-green-400 animate-pulse"></span>Live
          </span>
        )}
        {badge && (
          <span className="px-2 py-0.5 rounded text-[10px] font-bold uppercase bg-red-500/20 text-red-400 flex items-center gap-1">
            <span className="w-1.5 h-1.5 rounded-full bg-b-live animate-pulse"></span>
            {badge}
          </span>
        )}
        {icon && <span className="material-symbols-outlined text-b-purple text-xl">{icon}</span>}
      </div>
      <p className="text-3xl font-bold text-b-on-surface">{value}</p>
      <p className={`text-xs mt-2 ${subtextColor}`}>{subtext}</p>
    </div>
  );

  return href ? <Link to={href}>{content}</Link> : content;
}

function ActivityItem({ icon, text, time }: { icon: string; text: string; time: string }) {
  return (
    <div className="flex items-center gap-3">
      <div className="w-8 h-8 rounded-full bg-b-surface-muted flex items-center justify-center shrink-0">
        <span className="material-symbols-outlined text-b-purple text-sm">{icon}</span>
      </div>
      <div className="min-w-0">
        <p className="text-sm text-b-on-surface truncate">{text}</p>
        <p className="text-xs text-b-on-surface-muted">{time}</p>
      </div>
    </div>
  );
}
