import { useEffect, useRef, useCallback } from 'react';
import { clsx } from '../utils/clsx';

interface ModalProps {
  isOpen: boolean;
  onClose: () => void;
  title: string;
  children: React.ReactNode;
  actions?: React.ReactNode;
  size?: 'sm' | 'md' | 'lg';
}

const sizeClasses = {
  sm: 'max-w-md',
  md: 'max-w-lg',
  lg: 'max-w-2xl',
};

const FOCUSABLE_SELECTORS = [
  'button:not([disabled])',
  'a[href]',
  'input:not([disabled])',
  'select:not([disabled])',
  'textarea:not([disabled])',
  '[tabindex]:not([tabindex="-1"])',
].join(', ');

export function Modal({ isOpen, onClose, title, children, actions, size = 'md' }: ModalProps) {
  const overlayRef = useRef<HTMLDivElement>(null);
  const contentRef = useRef<HTMLDivElement>(null);
  const previouslyFocusedRef = useRef<HTMLElement | null>(null);
  const activeElementRef = useRef<HTMLElement | null>(null);

  const getFocusableElements = useCallback((): HTMLElement[] => {
    if (!contentRef.current) return [];
    return Array.from(contentRef.current.querySelectorAll(FOCUSABLE_SELECTORS));
  }, []);

  const handleTabKey = useCallback(
    (e: KeyboardEvent) => {
      if (e.key !== 'Tab' || !contentRef.current) return;
      const focusable = getFocusableElements();
      if (focusable.length === 0) {
        e.preventDefault();
        return;
      }
      const first = focusable[0];
      const last = focusable[focusable.length - 1];
      if (e.shiftKey && document.activeElement === first) {
        e.preventDefault();
        last.focus();
      } else if (!e.shiftKey && document.activeElement === last) {
        e.preventDefault();
        first.focus();
      }
    },
    [getFocusableElements]
  );

  useEffect(() => {
    function handleKey(e: KeyboardEvent) {
      if (e.key === 'Escape') onClose();
      else handleTabKey(e);
    }

    if (isOpen) {
      previouslyFocusedRef.current = document.activeElement as HTMLElement;
      document.addEventListener('keydown', handleKey);
      document.body.style.overflow = 'hidden';
      // Defer focus to next tick so content is rendered.
      setTimeout(() => {
        const focusable = getFocusableElements();
        const target = focusable[0] || contentRef.current;
        target?.focus();
      }, 0);
    }
    return () => {
      document.removeEventListener('keydown', handleKey);
      document.body.style.overflow = '';
      // Only restore focus if this modal still owns it.
      if (previouslyFocusedRef.current && document.activeElement === activeElementRef.current) {
        previouslyFocusedRef.current.focus();
      }
    };
  }, [isOpen, onClose, handleTabKey, getFocusableElements]);

  if (!isOpen) return null;

  return (
    <div
      ref={overlayRef}
      onClick={(e) => e.target === overlayRef.current && onClose()}
      className="fixed inset-0 z-40 bg-black/60 flex items-center justify-center p-4"
      role="presentation"
    >
      <div
        ref={contentRef}
        tabIndex={-1}
        role="dialog"
        aria-modal="true"
        aria-labelledby="modal-title"
        onFocus={(e) => {
          activeElementRef.current = e.target as HTMLElement;
        }}
        className={clsx(
          'bg-b-surface-elevated rounded-2xl border border-b-border w-full max-h-[80vh] overflow-hidden shadow-2xl outline-none',
          sizeClasses[size]
        )}
      >
        <div className="flex items-center justify-between p-6 border-b border-b-border">
          <h3 id="modal-title" className="text-lg font-semibold text-b-on-surface">
            {title}
          </h3>
          <button
            onClick={onClose}
            className="text-b-on-surface-muted hover:text-b-on-surface transition-colors"
            aria-label="Close"
          >
            <span className="material-symbols-outlined">close</span>
          </button>
        </div>
        <div className="p-6 overflow-y-auto max-h-[60vh] text-b-on-surface-muted custom-scrollbar">
          {children}
        </div>
        {actions && (
          <div className="flex items-center justify-end gap-3 p-6 border-t border-b-border">
            {actions}
          </div>
        )}
      </div>
    </div>
  );
}
