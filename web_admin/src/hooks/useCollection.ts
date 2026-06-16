import { useQuery } from '@tanstack/react-query';
import type { QueryConstraint } from 'firebase/firestore';
import { fetchCollection } from '../services/adminApi';

export function useCollection<T>(key: string[], path: string, constraints: QueryConstraint[] = []) {
  return useQuery<T[]>({
    queryKey: key,
    queryFn: () => fetchCollection<T>(path, constraints),
  });
}
