import { useEffect } from 'react';
import { Navigate, Outlet } from 'react-router-dom';
import { useAuthStore } from '../stores/authStore';
import { useAdminRole } from '../hooks/useAdminRole';
import { Layout } from './Layout';

export function ProtectedRoute() {
  const user = useAuthStore((s) => s.user);
  const initialized = useAuthStore((s) => s.initialized);
  const setRole = useAuthStore((s) => s.setRole);
  const { role, loading } = useAdminRole(user?.uid);

  useEffect(() => {
    setRole(role);
  }, [role, setRole]);

  if (!initialized || loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-b-black text-b-on-surface-muted">
        <div className="flex items-center gap-3">
          <span className="material-symbols-outlined animate-spin">progress_activity</span>
          <span>Checking admin access...</span>
        </div>
      </div>
    );
  }

  if (!user || !role) {
    return (
      <Navigate
        to="/login"
        replace
        state={{ message: !user ? 'Please sign in to continue.' : 'This account is not authorized for admin access.' }}
      />
    );
  }

  return (
    <Layout>
      <Outlet />
    </Layout>
  );
}
