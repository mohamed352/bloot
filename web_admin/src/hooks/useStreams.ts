import { useQuery } from '@tanstack/react-query';
import { collection, query, orderBy, limit, where, getDocs, type QueryConstraint } from 'firebase/firestore';
import { db } from '../services/firebase';
import type { Stream } from '../types';

export function useStreams(status?: Stream['status']) {
  return useQuery<Stream[]>({
    queryKey: ['streams', status],
    queryFn: async () => {
      const constraints: QueryConstraint[] = [orderBy('startedAt', 'desc'), limit(100)];
      if (status) {
        constraints.unshift(where('status', '==', status));
      }
      const q = query(collection(db, 'streams'), ...constraints);
      const snap = await getDocs(q);
      return snap.docs.map((d) => ({ id: d.id, ...(d.data() as Stream) }));
    },
  });
}
