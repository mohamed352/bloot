import { useQuery } from '@tanstack/react-query';
import { collection, query, orderBy, getDocs } from 'firebase/firestore';
import { db } from '../services/firebase';
import type { AdminDoc } from '../types';

export function useAdmins() {
  return useQuery<AdminDoc[]>({
    queryKey: ['admins'],
    queryFn: async () => {
      const q = query(collection(db, 'admins'), orderBy('createdAt', 'desc'));
      const snap = await getDocs(q);
      return snap.docs.map((d) => ({ uid: d.id, ...(d.data() as Omit<AdminDoc, 'uid'>) }));
    },
  });
}
