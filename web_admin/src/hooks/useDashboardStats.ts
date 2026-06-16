import { useQuery } from '@tanstack/react-query';
import { collection, getCountFromServer, query, where, getDocs } from 'firebase/firestore';
import { db } from '../services/firebase';
import type { DashboardStats } from '../types';

export function useDashboardStats() {
  return useQuery<DashboardStats>({
    queryKey: ['dashboardStats'],
    queryFn: async () => {
      const [onlineSnap, playingGamesSnap, waitingRoomsSnap, openReportsSnap] = await Promise.all([
        getCountFromServer(query(collection(db, 'users'), where('isOnline', '==', true))),
        getCountFromServer(query(collection(db, 'games'), where('status', '==', 'playing'))),
        getCountFromServer(query(collection(db, 'rooms'), where('status', '==', 'waiting'))),
        getCountFromServer(query(collection(db, 'reports'), where('status', '==', 'pending'))),
      ]);

      const liveStreamsQuery = query(collection(db, 'streams'), where('status', '==', 'live'));
      const liveStreamsSnap = await getDocs(liveStreamsQuery);
      const totalViewers = liveStreamsSnap.docs.reduce(
        (sum, doc) => sum + ((doc.data().viewerCount as number) || 0),
        0
      );

      return {
        activePlayersNow: onlineSnap.data().count,
        activePlayersChange: 0,
        liveStreams: liveStreamsSnap.size,
        totalViewers,
        gamesInProgress: playingGamesSnap.data().count,
        activeRooms: waitingRoomsSnap.data().count,
        openReports: openReportsSnap.data().count,
        reportsChange: 0,
        dailyRevenue: 0,
        weeklyRevenue: 0,
      };
    },
    refetchInterval: 30000,
  });
}
