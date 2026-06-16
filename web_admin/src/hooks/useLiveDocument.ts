import { useEffect, useState } from 'react';
import { subscribeToDocument } from '../services/adminApi';

interface UseLiveDocumentResult<T> {
  data: T | null;
  isLoading: boolean;
  error: Error | null;
}

export function useLiveDocument<T>(path: string, id: string): UseLiveDocumentResult<T> {
  const [data, setData] = useState<T | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    setIsLoading(true);
    setError(null);

    const unsubscribe = subscribeToDocument<T>(
      path,
      id,
      (item) => {
        setData(item);
        setIsLoading(false);
      },
      (err) => {
        setError(err);
        setIsLoading(false);
      }
    );

    return () => unsubscribe();
  }, [path, id]);

  return { data, isLoading, error };
}
