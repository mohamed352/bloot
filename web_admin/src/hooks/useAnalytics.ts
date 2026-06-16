import { useQuery } from '@tanstack/react-query';
import {
  collection,
  getCountFromServer,
  query,
  where,
  getDocs,
  orderBy,
} from 'firebase/firestore';
import { db } from '../services/firebase';
import type { DashboardStats } from '../types';

interface ModeDistribution {
  labels: string[];
  values: number[];
}

interface RevenueByDay {
  labels: string[];
  values: number[];
}

interface AnalyticsData extends DashboardStats {
  modeDistribution: ModeDistribution;
  revenueByDay: RevenueByDay;
  newUsersByDay: { labels: string[]; values: number[] };
}

function formatDayLabel(date: Date): string {
  return date.toLocaleDateString('en-US', { weekday: 'short' });
}

export function useAnalytics() {
  return useQuery<AnalyticsData>({
    queryKey: ['analytics'],
    queryFn: async () => {
      const now = new Date();
      const sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
      const thirtyDaysAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);

      const [onlineSnap, liveStreamsSnap, playingGamesSnap, waitingRoomsSnap, openReportsSnap] =
        await Promise.all([
          getCountFromServer(query(collection(db, 'users'), where('isOnline', '==', true))),
          getCountFromServer(query(collection(db, 'streams'), where('status', '==', 'live'))),
          getCountFromServer(query(collection(db, 'games'), where('status', '==', 'playing'))),
          getCountFromServer(query(collection(db, 'rooms'), where('status', '==', 'waiting'))),
          getCountFromServer(query(collection(db, 'reports'), where('status', '==', 'pending'))),
        ]);

      const liveStreamsForViewersSnap = await getDocs(
        query(collection(db, 'streams'), where('status', '==', 'live'))
      );
      const totalViewers = liveStreamsForViewersSnap.docs.reduce(
        (sum, d) => sum + ((d.data().viewerCount as number) ?? 0),
        0
      );

      // Revenue (last 7 days)
      const revenueSnap = await getDocs(
        query(
          collection(db, 'coin_transactions'),
          where('type', '==', 'purchase'),
          where('createdAt', '>=', sevenDaysAgo),
          orderBy('createdAt', 'desc')
        )
      );

      const revenueMap = new Map<string, number>();
      for (let i = 6; i >= 0; i--) {
        const d = new Date(now.getTime() - i * 24 * 60 * 60 * 1000);
        revenueMap.set(formatDayLabel(d), 0);
      }
      revenueSnap.docs.forEach((doc) => {
        const createdAt = doc.data().createdAt;
        const date = createdAt?.toDate ? createdAt.toDate() : new Date(createdAt);
        const key = formatDayLabel(date);
        revenueMap.set(key, (revenueMap.get(key) || 0) + (doc.data().amount as number));
      });

      // New users (last 7 days)
      const newUsersSnap = await getDocs(
        query(
          collection(db, 'users'),
          where('createdAt', '>=', sevenDaysAgo),
          orderBy('createdAt', 'desc')
        )
      );
      const newUsersMap = new Map<string, number>();
      for (let i = 6; i >= 0; i--) {
        const d = new Date(now.getTime() - i * 24 * 60 * 60 * 1000);
        newUsersMap.set(formatDayLabel(d), 0);
      }
      newUsersSnap.docs.forEach((doc) => {
        const createdAt = doc.data().createdAt;
        const date = createdAt?.toDate ? createdAt.toDate() : new Date(createdAt);
        const key = formatDayLabel(date);
        newUsersMap.set(key, (newUsersMap.get(key) || 0) + 1);
      });

      // Game mode distribution (last 30 days)
      const gamesSnap = await getDocs(
        query(
          collection(db, 'games'),
          where('createdAt', '>=', thirtyDaysAgo),
          orderBy('createdAt', 'desc')
        )
      );
      const modeCounts: Record<string, number> = {};
      gamesSnap.docs.forEach((doc) => {
        const gameType = (doc.data().gameType as string) || 'unknown';
        modeCounts[gameType] = (modeCounts[gameType] || 0) + 1;
      });

      return {
        activePlayersNow: onlineSnap.data().count,
        activePlayersChange: 0,
        liveStreams: liveStreamsSnap.data().count,
        totalViewers,
        gamesInProgress: playingGamesSnap.data().count,
        activeRooms: waitingRoomsSnap.data().count,
        openReports: openReportsSnap.data().count,
        reportsChange: 0,
        dailyRevenue: Array.from(revenueMap.values()).slice(-1)[0] || 0,
        weeklyRevenue: Array.from(revenueMap.values()).reduce((a, b) => a + b, 0),
        modeDistribution: {
          labels: Object.keys(modeCounts).map((k) => k.charAt(0).toUpperCase() + k.slice(1)),
          values: Object.values(modeCounts),
        },
        revenueByDay: {
          labels: Array.from(revenueMap.keys()),
          values: Array.from(revenueMap.values()),
        },
        newUsersByDay: {
          labels: Array.from(newUsersMap.keys()),
          values: Array.from(newUsersMap.values()),
        },
      };
    },
    refetchInterval: 30000,
  });
}
