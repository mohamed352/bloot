import { useQuery } from '@tanstack/react-query';
import { collection, query, orderBy, limit, where, getDocs, type QueryConstraint } from 'firebase/firestore';
import { db } from '../services/firebase';
import type { Leaderboard } from '../types';

export function useLeaderboards(status?: Leaderboard['status']) {
  return useQuery<Leaderboard[]>({
    queryKey: ['leaderboards', status],
    queryFn: async () => {
      const constraints: QueryConstraint[] = [orderBy('startDate', 'desc'), limit(100)];
      if (status) {
        constraints.unshift(where('status', '==', status));
      }
      const q = query(collection(db, 'leaderboards'), ...constraints);
      const snap = await getDocs(q);
      return snap.docs.map((d) => ({ id: d.id, ...(d.data() as Leaderboard) }));
    },
  });
}
