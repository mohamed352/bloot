import { useState } from 'react';
import { Sidebar } from './Sidebar';
import { ToastContainer } from './Toast';

interface LayoutProps {
  children: React.ReactNode;
}

export function Layout({ children }: LayoutProps) {
  const [sidebarOpen, setSidebarOpen] = useState(false);

  return (
    <div className="min-h-screen bg-b-black">
      <Sidebar isOpen={sidebarOpen} onClose={() => setSidebarOpen(false)} />

      <button
        onClick={() => setSidebarOpen(true)}
        className="lg:hidden fixed top-4 left-4 z-40 p-2 rounded-lg bg-b-surface-elevated border border-b-border"
      >
        <span className="material-symbols-outlined text-b-on-surface">menu</span>
      </button>

      <main className="lg:ml-64 min-h-screen p-6 lg:p-8">
        {children}
      </main>

      <ToastContainer />
    </div>
  );
}
