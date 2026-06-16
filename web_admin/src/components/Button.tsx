import { clsx } from '../utils/clsx';

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'danger' | 'ghost' | 'success';
  size?: 'sm' | 'md' | 'lg';
  isLoading?: boolean;
}

export function Button({
  children,
  variant = 'primary',
  size = 'md',
  isLoading,
  className,
  disabled,
  ...props
}: ButtonProps) {
  return (
    <button
      disabled={disabled || isLoading}
      className={clsx(
        'inline-flex items-center justify-center gap-2 rounded-lg font-medium transition-colors disabled:opacity-50',
        size === 'sm' && 'px-3 py-1.5 text-xs',
        size === 'md' && 'px-4 py-2 text-sm',
        size === 'lg' && 'px-6 py-3 text-base',
        variant === 'primary' && 'bg-b-purple hover:bg-b-purple-dark text-white',
        variant === 'secondary' && 'bg-b-surface-muted hover:bg-b-surface-hover text-b-on-surface border border-b-border',
        variant === 'danger' && 'bg-red-600 hover:bg-red-700 text-white',
        variant === 'success' && 'bg-green-600 hover:bg-green-700 text-white',
        variant === 'ghost' && 'bg-transparent hover:bg-b-surface-muted text-b-on-surface-muted hover:text-b-on-surface',
        className
      )}
      {...props}
    >
      {isLoading && (
        <span className="material-symbols-outlined animate-spin text-base">progress_activity</span>
      )}
      {children}
    </button>
  );
}
