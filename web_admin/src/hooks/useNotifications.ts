import { useQuery } from '@tanstack/react-query';
import { collection, query, orderBy, limit, where, getDocs, type QueryConstraint } from 'firebase/firestore';
import { db } from '../services/firebase';
import type { Notification } from '../types';

export function useNotifications(type?: string, priority?: Notification['priority']) {
  return useQuery<Notification[]>({
    queryKey: ['notifications', type, priority],
    queryFn: async () => {
      const constraints: QueryConstraint[] = [orderBy('createdAt', 'desc'), limit(100)];
      if (type) {
        constraints.unshift(where('type', '==', type));
      }
      if (priority) {
        constraints.unshift(where('priority', '==', priority));
      }
      const q = query(collection(db, 'notifications'), ...constraints);
      const snap = await getDocs(q);
      return snap.docs.map((d) => ({ id: d.id, ...(d.data() as Notification) }));
    },
  });
}
