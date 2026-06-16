import { create } from 'zustand';
import type { User } from 'firebase/auth';
import type { AdminRole } from '../types';

interface AuthState {
  user: User | null;
  role: AdminRole | null;
  loading: boolean;
  initialized: boolean;
  error: string | null;
  setUser: (user: User | null) => void;
  setRole: (role: AdminRole | null) => void;
  setLoading: (loading: boolean) => void;
  setInitialized: (initialized: boolean) => void;
  setError: (error: string | null) => void;
  reset: () => void;
}

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  role: null,
  loading: true,
  initialized: false,
  error: null,
  setUser: (user) => set({ user }),
  setRole: (role) => set({ role }),
  setLoading: (loading) => set({ loading }),
  setInitialized: (initialized) => set({ initialized }),
  setError: (error) => set({ error }),
  reset: () => set({ user: null, role: null, loading: false, error: null }),
}));
