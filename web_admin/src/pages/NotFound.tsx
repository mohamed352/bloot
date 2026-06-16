import { Link } from 'react-router-dom';

export function NotFound() {
  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-b-black text-b-on-surface p-4">
      <span className="material-symbols-outlined text-6xl text-b-purple mb-4">search_off</span>
      <h1 className="text-4xl font-bold mb-2">404</h1>
      <p className="text-b-on-surface-muted mb-6">This page does not exist.</p>
      <Link
        to="/"
        className="px-6 py-2.5 rounded-lg bg-b-purple hover:bg-b-purple-dark text-white font-medium transition-colors"
      >
        Back to Dashboard
      </Link>
    </div>
  );
}
