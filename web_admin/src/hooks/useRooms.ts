import { useQuery } from '@tanstack/react-query';
import { collection, query, orderBy, limit, where, getDocs, type QueryConstraint } from 'firebase/firestore';
import { db } from '../services/firebase';
import type { Room } from '../types';

export function useRooms(status?: Room['status']) {
  return useQuery<Room[]>({
    queryKey: ['rooms', status],
    queryFn: async () => {
      const constraints: QueryConstraint[] = [orderBy('createdAt', 'desc'), limit(100)];
      if (status) {
        constraints.unshift(where('status', '==', status));
      }
      const q = query(collection(db, 'rooms'), ...constraints);
      const snap = await getDocs(q);
      return snap.docs.map((d) => ({ id: d.id, ...(d.data() as Room) }));
    },
  });
}
