import { useQuery } from '@tanstack/react-query';
import { doc, getDoc } from 'firebase/firestore';
import { db } from '../services/firebase';
import type { SystemSettings } from '../types';

export function useSettings() {
  return useQuery<SystemSettings | null>({
    queryKey: ['settings'],
    queryFn: async () => {
      const snap = await getDoc(doc(db, 'settings', 'system'));
      if (!snap.exists()) return null;
      return { id: snap.id, ...(snap.data() as SystemSettings) };
    },
  });
}
