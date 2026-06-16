import { useQuery } from '@tanstack/react-query';
import { collection, query, orderBy, limit, where, getDocs, type QueryConstraint } from 'firebase/firestore';
import { db } from '../services/firebase';
import type { Game } from '../types';

export function useGames(status?: string) {
  return useQuery<Game[]>({
    queryKey: ['games', status],
    queryFn: async () => {
      const constraints: QueryConstraint[] = [orderBy('startedAt', 'desc'), limit(100)];
      if (status) {
        constraints.unshift(where('status', '==', status));
      }
      const q = query(collection(db, 'games'), ...constraints);
      const snap = await getDocs(q);
      return snap.docs.map((d) => ({ id: d.id, ...(d.data() as Game) }));
    },
  });
}
