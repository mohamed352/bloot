import { useQuery } from '@tanstack/react-query';
import { collection, query, orderBy, limit, where, getDocs, type QueryConstraint } from 'firebase/firestore';
import { db } from '../services/firebase';
import type { Tournament } from '../types';

export function useTournaments(status?: Tournament['status']) {
  return useQuery<Tournament[]>({
    queryKey: ['tournaments', status],
    queryFn: async () => {
      const constraints: QueryConstraint[] = [orderBy('createdAt', 'desc'), limit(100)];
      if (status) {
        constraints.unshift(where('status', '==', status));
      }
      const q = query(collection(db, 'tournaments'), ...constraints);
      const snap = await getDocs(q);
      return snap.docs.map((d) => ({ id: d.id, ...(d.data() as Tournament) }));
    },
  });
}
