import { useEffect } from 'react';
import { useToastStore } from '../stores/toastStore';
import { clsx } from '../utils/clsx';

const icons: Record<string, string> = {
  success: 'check_circle',
  error: 'error',
  warning: 'warning',
  info: 'info',
};

const colors: Record<string, string> = {
  success: 'bg-green-600 border-green-500',
  error: 'bg-red-600 border-red-500',
  warning: 'bg-yellow-600 border-yellow-500',
  info: 'bg-purple-600 border-purple-500',
};

export function ToastContainer() {
  const toasts = useToastStore((s) => s.toasts);

  return (
    <div className="fixed top-4 right-4 z-50 flex flex-col gap-2">
      {toasts.map((toast) => (
        <ToastItem key={toast.id} toast={toast} />
      ))}
    </div>
  );
}

function ToastItem({ toast }: { toast: { id: string; message: string; type: string } }) {
  const removeToast = useToastStore((s) => s.removeToast);

  useEffect(() => {
    const timer = setTimeout(() => removeToast(toast.id), 3000);
    return () => clearTimeout(timer);
  }, [toast.id, removeToast]);

  return (
    <div
      className={clsx(
        'flex items-center gap-3 px-5 py-3 rounded-lg border shadow-2xl text-white transition-all duration-300',
        colors[toast.type] || colors.info
      )}
    >
      <span className="material-symbols-outlined text-xl">{icons[toast.type] || icons.info}</span>
      <span className="text-sm font-medium">{toast.message}</span>
    </div>
  );
}
