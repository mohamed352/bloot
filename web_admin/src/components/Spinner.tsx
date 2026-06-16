export function Spinner({ className }: { className?: string }) {
  return (
    <div className={`flex items-center justify-center p-8 ${className || ''}`}>
      <span className="material-symbols-outlined animate-spin text-b-purple text-3xl">
        progress_activity
      </span>
    </div>
  );
}
