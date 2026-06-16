import { clsx } from '../utils/clsx';

interface CardProps {
  children: React.ReactNode;
  className?: string;
}

export function Card({ children, className }: CardProps) {
  return (
    <div className={clsx('bg-b-surface-elevated rounded-xl border border-b-border p-5', className)}>
      {children}
    </div>
  );
}
