import { useQuery } from '@tanstack/react-query';
import { collection, query, orderBy, limit, where, getDocs, type QueryConstraint } from 'firebase/firestore';
import { db } from '../services/firebase';
import type { CoinTransaction } from '../types';

export function useCoinTransactions(type?: string, uid?: string) {
  return useQuery<CoinTransaction[]>({
    queryKey: ['coin_transactions', type, uid],
    queryFn: async () => {
      const constraints: QueryConstraint[] = [orderBy('createdAt', 'desc'), limit(200)];
      if (type) {
        constraints.unshift(where('type', '==', type));
      }
      if (uid) {
        constraints.unshift(where('uid', '==', uid));
      }
      const q = query(collection(db, 'coin_transactions'), ...constraints);
      const snap = await getDocs(q);
      return snap.docs.map((d) => ({ id: d.id, ...(d.data() as CoinTransaction) }));
    },
  });
}
