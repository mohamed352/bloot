import { Routes, Route, Navigate, Outlet } from 'react-router-dom';
import { ProtectedRoute } from './components/ProtectedRoute';
import { Login } from './pages/Login';
import { Dashboard } from './pages/Dashboard';
import { NotFound } from './pages/NotFound';
import { UsersPage } from './features/users/UsersPage';
import { ReportsPage } from './features/reports/ReportsPage';
import { GamesPage } from './features/games/GamesPage';
import { RoomsPage } from './features/rooms/RoomsPage';
import { StreamsPage } from './features/streams/StreamsPage';
import { EconomyPage } from './features/economy/EconomyPage';
import { AchievementsPage } from './features/achievements/AchievementsPage';
import { LeaderboardsPage } from './features/leaderboards/LeaderboardsPage';
import { NotificationsPage } from './features/notifications/NotificationsPage';
import { AnalyticsPage } from './features/analytics/AnalyticsPage';
import { SettingsPage } from './features/settings/SettingsPage';
import { useAuthStore } from './stores/authStore';
import { ROLE_PERMISSIONS } from './types';
import type { Permission } from './types';

function RoleRoute({ requiredPermission }: { requiredPermission: Permission }) {
  const role = useAuthStore((s) => s.role);
  if (!role || !ROLE_PERMISSIONS[role].includes(requiredPermission)) {
    return <Navigate to="/" replace />;
  }
  return <Outlet />;
}

export function App() {
  return (
    <Routes>
      <Route path="/login" element={<Login />} />
      <Route element={<ProtectedRoute />}>
        <Route path="/" element={<Dashboard />} />
        <Route element={<RoleRoute requiredPermission="moderate" />}>
          <Route path="/users" element={<UsersPage />} />
          <Route path="/reports" element={<ReportsPage />} />
          <Route path="/streams" element={<StreamsPage />} />
        </Route>
        <Route element={<RoleRoute requiredPermission="manage" />}>
          <Route path="/economy" element={<EconomyPage />} />
          <Route path="/achievements" element={<AchievementsPage />} />
          <Route path="/leaderboards" element={<LeaderboardsPage />} />
          <Route path="/notifications" element={<NotificationsPage />} />
          <Route path="/analytics" element={<AnalyticsPage />} />
        </Route>
        <Route element={<RoleRoute requiredPermission="view" />}>
          <Route path="/games" element={<GamesPage />} />
          <Route path="/rooms" element={<RoomsPage />} />
        </Route>
        <Route element={<RoleRoute requiredPermission="super" />}>
          <Route path="/settings" element={<SettingsPage />} />
        </Route>
      </Route>
      <Route path="/404" element={<NotFound />} />
      <Route path="*" element={<Navigate to="/404" replace />} />
    </Routes>
  );
}
