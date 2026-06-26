import { NavLink } from 'react-router-dom';
import { signOut } from 'firebase/auth';
import { auth } from '../services/firebase';
import { clsx } from '../utils/clsx';
import { useAuthStore } from '../stores/authStore';
import { useToastStore } from '../stores/toastStore';
import type { AdminRole, Permission } from '../types';
import { ROLE_PERMISSIONS } from '../types';

interface NavItem {
  to: string;
  icon: string;
  label: string;
  badge?: number;
  requiredPermission?: Permission;
}

const navItems: NavItem[] = [
  { to: '/', icon: 'dashboard', label: 'Dashboard' },
  { to: '/users', icon: 'person', label: 'Users', requiredPermission: 'moderate' },
  { to: '/reports', icon: 'flag', label: 'Reports', requiredPermission: 'moderate' },
  { to: '/games', icon: 'casino', label: 'Games', requiredPermission: 'view' },
  { to: '/rooms', icon: 'meeting_room', label: 'Rooms', requiredPermission: 'view' },
  { to: '/streams', icon: 'videocam', label: 'Streams', requiredPermission: 'moderate' },
  { to: '/economy', icon: 'payments', label: 'Economy', requiredPermission: 'manage' },
  { to: '/achievements', icon: 'military_tech', label: 'Achievements', requiredPermission: 'manage' },
  { to: '/leaderboards', icon: 'leaderboard', label: 'Leaderboards', requiredPermission: 'manage' },
  { to: '/notifications', icon: 'notifications', label: 'Notifications', requiredPermission: 'manage' },
  { to: '/analytics', icon: 'analytics', label: 'Analytics', requiredPermission: 'manage' },
  { to: '/settings', icon: 'settings', label: 'Settings', requiredPermission: 'super' },
];

function hasPermission(role: AdminRole | null, permission?: Permission): boolean {
  if (!permission) return true;
  if (!role) return false;
  return ROLE_PERMISSIONS[role].includes(permission);
}

interface SidebarProps {
  isOpen: boolean;
  onClose: () => void;
}

export function Sidebar({ isOpen, onClose }: SidebarProps) {
  const user = useAuthStore((s) => s.user);
  const role = useAuthStore((s) => s.role);
  const addToast = useToastStore((s) => s.addToast);

  const visibleItems = navItems.filter((item) => hasPermission(role, item.requiredPermission));

  const handleLogout = async () => {
    try {
      await signOut(auth);
    } catch (err) {
      addToast((err as Error).message, 'error');
    }
  };

  return (
    <>
      <aside
        className={clsx(
          'fixed top-0 left-0 h-full w-64 bg-b-surface-elevated border-r border-b-border flex flex-col z-30 transition-transform duration-300',
          'lg:translate-x-0',
          isOpen ? 'translate-x-0' : '-translate-x-full'
        )}
      >
        <div className="p-6 border-b border-b-border">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-full bg-b-purple flex items-center justify-center">
              <span className="material-symbols-outlined text-white text-xl">casino</span>
            </div>
            <div>
              <h1 className="text-lg font-bold text-b-on-surface">Bloot</h1>
              <span className="text-xs font-semibold text-b-gold">Admin</span>
            </div>
          </div>
        </div>

        <nav className="flex-1 overflow-y-auto py-4 custom-scrollbar">
          <ul className="space-y-1 px-3">
            {visibleItems.map((item) => (
              <li key={item.to}>
                <NavLink
                  to={item.to}
                  onClick={onClose}
                  className={({ isActive }) =>
                    clsx(
                      'flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-colors duration-150',
                      isActive
                        ? 'bg-purple-500/10 text-purple-400'
                        : 'hover:bg-b-surface-hover text-b-on-surface-muted hover:text-b-on-surface'
                    )
                  }
                >
                  <span className="material-symbols-outlined text-xl">{item.icon}</span>
                  <span className="flex-1">{item.label}</span>
                  {item.badge ? (
                    <span className="px-1.5 py-0.5 rounded text-[10px] font-bold bg-b-live text-white">
                      {item.badge}
                    </span>
                  ) : null}
                </NavLink>
              </li>
            ))}
          </ul>
        </nav>

        <div className="p-4 border-t border-b-border space-y-3">
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 rounded-full bg-b-purple/30 flex items-center justify-center">
              <span className="material-symbols-outlined text-b-purple text-lg">person</span>
            </div>
            <div className="min-w-0">
              <p className="text-sm font-medium text-b-on-surface truncate">
                {user?.displayName || user?.email || 'Admin User'}
              </p>
              <span className="text-[10px] font-bold uppercase px-1.5 py-0.5 rounded bg-b-gold/20 text-b-gold">
                {role || 'Loading...'}
              </span>
            </div>
          </div>
          <button
            onClick={handleLogout}
            className="w-full flex items-center justify-center gap-2 px-3 py-2 rounded-lg text-sm font-medium text-b-on-surface-muted hover:text-b-on-surface hover:bg-b-surface-hover transition-colors"
          >
            <span className="material-symbols-outlined text-base">logout</span>
            Log Out
          </button>
        </div>
      </aside>

      {isOpen && (
        <div
          onClick={onClose}
          className="fixed inset-0 bg-black/50 z-20 lg:hidden"
          aria-hidden="true"
        />
      )}
    </>
  );
}
