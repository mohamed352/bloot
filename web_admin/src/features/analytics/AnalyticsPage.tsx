import { LineChart, BarChart, DoughnutChart } from '../../components/charts';
import { useAnalytics } from '../../hooks/useAnalytics';
import { PageHeader } from '../../components/PageHeader';
import { Spinner } from '../../components/Spinner';
import { formatNumber } from '../../utils/formatters';


export function AnalyticsPage() {
  const { data: stats, isLoading } = useAnalytics();

  const commonOptions = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: { labels: { color: '#9ca3af' } },
    },
    scales: {
      y: {
        grid: { color: 'rgba(255, 255, 255, 0.05)' },
        ticks: { color: '#9ca3af' },
      },
      x: {
        grid: { display: false },
        ticks: { color: '#9ca3af' },
      },
    },
  };

  const playerActivityData = {
    labels: stats?.newUsersByDay.labels || [],
    datasets: [
      {
        label: 'New Users',
        data: stats?.newUsersByDay.values || [],
        borderColor: '#8b5cf6',
        backgroundColor: 'rgba(139, 92, 246, 0.1)',
        fill: true,
        tension: 0.4,
      },
    ],
  };

  const revenueData = {
    labels: stats?.revenueByDay.labels || [],
    datasets: [
      {
        label: 'Revenue',
        data: stats?.revenueByDay.values || [],
        backgroundColor: '#10b981',
        borderRadius: 4,
      },
    ],
  };

  const modeDistributionData = {
    labels: stats?.modeDistribution.labels || [],
    datasets: [
      {
        data: stats?.modeDistribution.values || [],
        backgroundColor: ['#8b5cf6', '#f59e0b', '#10b981', '#ef4444'],
        borderWidth: 0,
      },
    ],
  };

  return (
    <div>
      <PageHeader title="Analytics" subtitle="Key performance indicators and activity trends" />

      {isLoading ? (
        <Spinner />
      ) : (
        <>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
            <StatCard label="Active Players Now" value={formatNumber(stats?.activePlayersNow ?? 0)} icon="group" />
            <StatCard label="Live Streams" value={formatNumber(stats?.liveStreams ?? 0)} icon="live_tv" />
            <StatCard label="Games in Progress" value={formatNumber(stats?.gamesInProgress ?? 0)} icon="casino" />
            <StatCard label="Active Rooms" value={formatNumber(stats?.activeRooms ?? 0)} icon="meeting_room" />
            <StatCard label="Open Reports" value={formatNumber(stats?.openReports ?? 0)} icon="flag" />
            <StatCard label="Total Viewers" value={formatNumber(stats?.totalViewers ?? 0)} icon="visibility" />
            <StatCard label="Daily Revenue" value={formatNumber(stats?.dailyRevenue ?? 0)} icon="payments" />
            <StatCard label="Weekly Revenue" value={formatNumber(stats?.weeklyRevenue ?? 0)} icon="calendar_month" />
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <div className="bg-b-surface-elevated rounded-xl border border-b-border p-6">
              <h2 className="text-lg font-semibold text-b-on-surface mb-4">New Users (7 Days)</h2>
              <div className="h-64">
                <LineChart data={playerActivityData} options={commonOptions} />
              </div>
            </div>
            <div className="bg-b-surface-elevated rounded-xl border border-b-border p-6">
              <h2 className="text-lg font-semibold text-b-on-surface mb-4">Revenue Trends (7 Days)</h2>
              <div className="h-64">
                <BarChart data={revenueData} options={commonOptions} />
              </div>
            </div>
            <div className="bg-b-surface-elevated rounded-xl border border-b-border p-6">
              <h2 className="text-lg font-semibold text-b-on-surface mb-4">Game Mode Distribution (30 Days)</h2>
              <div className="h-64 flex items-center justify-center">
                <DoughnutChart
                  data={modeDistributionData}
                  options={{
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                      legend: { position: 'right', labels: { color: '#9ca3af' } },
                    },
                  }}
                />
              </div>
            </div>
            <div className="bg-b-surface-elevated rounded-xl border border-b-border p-6">
              <h2 className="text-lg font-semibold text-b-on-surface mb-4">Retention Cohorts</h2>
              <div className="h-64 flex items-center justify-center text-b-on-surface-muted text-sm">
                Retention analysis coming soon. Requires daily analytics snapshots.
              </div>
            </div>
          </div>
        </>
      )}
    </div>
  );
}

function StatCard({ label, value, icon }: { label: string; value: string; icon: string }) {
  return (
    <div className="bg-b-surface-elevated rounded-xl border border-b-border p-5 hover:border-b-purple/30 transition-colors">
      <div className="flex items-center justify-between mb-3">
        <span className="text-sm text-b-on-surface-muted">{label}</span>
        <span className="material-symbols-outlined text-b-purple text-xl">{icon}</span>
      </div>
      <p className="text-3xl font-bold text-b-on-surface">{value}</p>
    </div>
  );
}
