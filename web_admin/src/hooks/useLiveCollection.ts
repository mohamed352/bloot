import { useEffect, useState, useRef } from 'react';
import type { QueryConstraint } from 'firebase/firestore';
import { subscribeToCollection } from '../services/adminApi';

interface UseLiveCollectionResult<T> {
  data: T[];
  isLoading: boolean;
  error: Error | null;
}

function deepEqual(a: unknown, b: unknown): boolean {
  if (a === b) return true;
  if (typeof a !== 'object' || typeof b !== 'object' || a == null || b == null) return false;

  const keysA = Object.keys(a);
  const keysB = Object.keys(b);
  if (keysA.length !== keysB.length) return false;

  for (const key of keysA) {
    if (!keysB.includes(key)) return false;
    const valA = (a as Record<string, unknown>)[key];
    const valB = (b as Record<string, unknown>)[key];
    if (!deepEqual(valA, valB)) return false;
  }
  return true;
}

function useDeepCompareMemoize<T>(value: T): T {
  const ref = useRef<T>(value);
  if (!deepEqual(value, ref.current)) {
    ref.current = value;
  }
  return ref.current;
}

export function useLiveCollection<T>(
  path: string,
  constraints: QueryConstraint[] = []
): UseLiveCollectionResult<T> {
  const [data, setData] = useState<T[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);
  const stableConstraints = useDeepCompareMemoize(constraints);

  useEffect(() => {
    setIsLoading(true);
    setError(null);

    const unsubscribe = subscribeToCollection<T>(
      path,
      stableConstraints,
      (items) => {
        setData(items);
        setIsLoading(false);
      },
      (err) => {
        setError(err);
        setIsLoading(false);
      }
    );

    return () => unsubscribe();
  }, [path, stableConstraints]);

  return { data, isLoading, error };
}
