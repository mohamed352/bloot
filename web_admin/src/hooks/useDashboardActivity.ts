import { useQuery } from '@tanstack/react-query';
import { collection, query, where, getDocs, orderBy, limit } from 'firebase/firestore';
import { db } from '../services/firebase';

interface HourlyActivity {
  labels: string[];
  values: number[];
}

export function useDashboardActivity() {
  return useQuery<HourlyActivity>({
    queryKey: ['dashboardActivity'],
    queryFn: async () => {
      const now = new Date();
      const oneDayAgo = new Date(now.getTime() - 24 * 60 * 60 * 1000);
      const snap = await getDocs(
        query(
          collection(db, 'users'),
          where('lastSeen', '>=', oneDayAgo),
          orderBy('lastSeen', 'desc'),
          limit(1000)
        )
      );

      const buckets = new Array(24).fill(0);
      const labels: string[] = [];

      for (let i = 23; i >= 0; i--) {
        const d = new Date(now.getTime() - i * 60 * 60 * 1000);
        labels.push(`${d.getHours()}:00`);
      }

      snap.docs.forEach((doc) => {
        const lastSeen = doc.data().lastSeen;
        if (!lastSeen) return;
        const date = lastSeen.toDate ? lastSeen.toDate() : new Date(lastSeen);
        const diffMs = now.getTime() - date.getTime();
        const hourIndex = Math.min(23, Math.floor(diffMs / (60 * 60 * 1000)));
        if (hourIndex >= 0 && hourIndex < 24) {
          buckets[23 - hourIndex]++;
        }
      });

      return { labels, values: buckets };
    },
    refetchInterval: 60000,
  });
}
