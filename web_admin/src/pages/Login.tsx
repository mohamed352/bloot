import { useEffect, useState } from 'react';
import { signInWithEmailAndPassword } from 'firebase/auth';
import { useLocation, useNavigate } from 'react-router-dom';
import { auth, db } from '../services/firebase';
import { doc, getDoc } from 'firebase/firestore';
import { useToastStore } from '../stores/toastStore';
import { useAuthStore } from '../stores/authStore';

export function Login() {
  const navigate = useNavigate();
  const location = useLocation();
  const stateMessage = (location.state as { message?: string } | null)?.message || null;
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [formError, setFormError] = useState<string | null>(stateMessage);
  const user = useAuthStore((s) => s.user);
  const initialized = useAuthStore((s) => s.initialized);
  const addToast = useToastStore((s) => s.addToast);

  useEffect(() => {
    if (initialized && user) {
      navigate('/', { replace: true });
    }
  }, [initialized, user, navigate]);

  const handleEmailLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email || !password) return;
    setLoading(true);
    setFormError(null);
    try {
      const cred = await signInWithEmailAndPassword(auth, email, password);
      const adminDoc = await getDoc(doc(db, 'admins', cred.user.uid));
      if (!adminDoc.exists()) {
        await auth.signOut();
        throw new Error('This account is not authorized for admin access.');
      }
    } catch (err) {
      const message = (err as Error).message;
      console.error('Sign in error:', err);
      setFormError(message);
      addToast(message, 'error');
    } finally {
      setLoading(false);
    }
  };

  if (initialized && user) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-b-black text-b-on-surface-muted">
        <div className="flex items-center gap-3">
          <span className="material-symbols-outlined animate-spin">progress_activity</span>
          <span>Redirecting to dashboard...</span>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-b-black p-4">
      <div className="w-full max-w-md bg-b-surface-elevated rounded-2xl border border-b-border p-8 shadow-2xl">
        <div className="flex justify-center mb-6">
          <div className="w-16 h-16 rounded-full bg-b-purple flex items-center justify-center">
            <span className="material-symbols-outlined text-white text-3xl">casino</span>
          </div>
        </div>
        <h1 className="text-2xl font-bold text-center text-b-on-surface mb-2">Bloot Admin</h1>
        <p className="text-sm text-center text-b-on-surface-muted mb-8">
          Sign in with your authorized admin account
        </p>

        {formError && (
          <div className="mb-4 p-3 rounded-lg bg-red-500/10 border border-red-500/30 text-red-400 text-sm">
            {formError}
          </div>
        )}

        <form onSubmit={handleEmailLogin} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-b-on-surface-muted mb-1">Email</label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="w-full px-4 py-2.5 rounded-lg bg-b-surface-muted border border-b-border text-b-on-surface placeholder-b-on-surface-secondary focus:outline-none focus:border-b-purple"
              placeholder="admin@bloot.app"
              required
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-b-on-surface-muted mb-1">
              Password
            </label>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full px-4 py-2.5 rounded-lg bg-b-surface-muted border border-b-border text-b-on-surface placeholder-b-on-surface-secondary focus:outline-none focus:border-b-purple"
              placeholder="••••••••"
              required
            />
          </div>
          <button
            type="submit"
            disabled={loading}
            className="w-full py-2.5 rounded-lg bg-b-purple hover:bg-b-purple-dark text-white font-medium transition-colors disabled:opacity-50"
          >
            {loading ? 'Signing in...' : 'Sign In'}
          </button>
        </form>
      </div>
    </div>
  );
}
