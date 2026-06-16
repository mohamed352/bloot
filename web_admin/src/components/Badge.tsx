import { clsx } from '../utils/clsx';

interface BadgeProps {
  children: React.ReactNode;
  variant?: 'default' | 'success' | 'warning' | 'danger' | 'info' | 'live';
  className?: string;
}

const variantClasses = {
  default: 'bg-b-surface-muted text-b-on-surface-muted border-b-border',
  success: 'bg-green-500/10 text-green-400 border-green-500/30',
  warning: 'bg-yellow-500/10 text-yellow-400 border-yellow-500/30',
  danger: 'bg-red-500/10 text-red-400 border-red-500/30',
  info: 'bg-blue-500/10 text-blue-400 border-blue-500/30',
  live: 'bg-red-500/10 text-red-400 border-red-500/30',
};

export function Badge({ children, variant = 'default', className }: BadgeProps) {
  return (
    <span
      className={clsx(
        'inline-flex items-center gap-1 px-2 py-0.5 rounded text-xs font-medium border',
        variantClasses[variant],
        className
      )}
    >
      {variant === 'live' && <span className="w-1.5 h-1.5 rounded-full bg-b-live animate-pulse" />}
      {children}
    </span>
  );
}
