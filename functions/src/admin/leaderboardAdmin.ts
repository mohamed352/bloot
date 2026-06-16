import * as functions from 'firebase-functions';
import { db } from '../config/admin';
import { verifyPermission, logAdminAction } from './helpers';
import {
  RecalculateLeaderboardInput,
  ResetLeaderboardInput,
  SuccessResponse,
} from './types';

function assertAuth(request: functions.https.CallableRequest<unknown>): string {
  if (!request.auth?.uid) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }
  return request.auth.uid;
}

function getMetricField(metric: string, gameType?: string): string {
  if (metric === 'wins' && gameType && gameType !== 'overall') {
    return `${gameType}GamesWon`;
  }
  if (metric === 'gamesPlayed' && gameType && gameType !== 'overall') {
    return `${gameType}GamesPlayed`;
  }
  if (metric === 'winRate') {
    return 'gamesWon';
  }
  const validFields = [
    'gamesPlayed',
    'gamesWon',
    'sunGamesPlayed',
    'sunGamesWon',
    'hokmGamesPlayed',
    'hokmGamesWon',
    'xp',
    'coins',
    'followersCount',
  ];
  if (validFields.includes(metric)) {
    return metric;
  }
  return 'xp';
}

function calculateValue(userData: FirebaseFirestore.DocumentData, metricField: string): number {
  if (metricField === 'winRate') {
    const played = (userData.gamesPlayed as number) || 0;
    const won = (userData.gamesWon as number) || 0;
    return played > 0 ? Math.round((won / played) * 1000) : 0;
  }
  return (userData[metricField] as number) || 0;
}

export const recalculateLeaderboard = functions.https.onCall(async (request) => {
  const actorUid = assertAuth(request);
  await verifyPermission(actorUid, 'manage');

  const { leaderboardId } = request.data as RecalculateLeaderboardInput;
  if (!leaderboardId || typeof leaderboardId !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing leaderboardId');
  }

  const leaderboardRef = db.collection('leaderboards').doc(leaderboardId);
  const leaderboardDoc = await leaderboardRef.get();
  if (!leaderboardDoc.exists) {
    throw new functions.https.HttpsError('not-found', 'Leaderboard not found');
  }

  const leaderboard = leaderboardDoc.data()!;
  const metric = (leaderboard.metric as string) || 'xp';
  const gameType = (leaderboard.gameType as string) || 'overall';
  const startDate = leaderboard.startDate?.toDate?.()
    ? leaderboard.startDate.toDate()
    : new Date(0);
  const endDate = leaderboard.endDate?.toDate?.()
    ? leaderboard.endDate.toDate()
    : new Date('2099-12-31');

  const metricField = getMetricField(metric, gameType);

  // Query users created within the leaderboard window.
  // For metrics based on cumulative stats this is an approximation; gameHistory
  // would be more accurate for historical leaderboards.
  const usersSnap = await db
    .collection('users')
    .where('createdAt', '>=', startDate)
    .where('createdAt', '<=', endDate)
    .get();

  let entries = usersSnap.docs
    .map((doc) => {
      const data = doc.data();
      return {
        uid: doc.id,
        displayName: (data.displayName as string) || '',
        avatarUrl: (data.avatarUrl as string) || '',
        level: (data.level as number) || 1,
        value: calculateValue(data, metricField),
        previousRank: undefined as number | undefined,
      };
    })
    .filter((entry) => entry.displayName && entry.value > 0)
    .sort((a, b) => b.value - a.value)
    .slice(0, 100)
    .map((entry, index) => ({
      rank: index + 1,
      uid: entry.uid,
      displayName: entry.displayName,
      avatarUrl: entry.avatarUrl,
      level: entry.level,
      value: entry.value,
      previousRank: entry.previousRank,
    }));

  await leaderboardRef.update({
    entries,
    totalParticipants: entries.length,
    status: 'active',
    updatedAt: new Date(),
  });

  await logAdminAction(actorUid, 'recalculateLeaderboard', 'leaderboard', leaderboardId, {
    totalParticipants: entries.length,
  });
  return { success: true } as SuccessResponse;
});

export const resetLeaderboard = functions.https.onCall(async (request) => {
  const actorUid = assertAuth(request);
  await verifyPermission(actorUid, 'manage');

  const { leaderboardId } = request.data as ResetLeaderboardInput;
  if (!leaderboardId || typeof leaderboardId !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing leaderboardId');
  }

  const leaderboardRef = db.collection('leaderboards').doc(leaderboardId);
  await db.runTransaction(async (transaction) => {
    const leaderboardDoc = await transaction.get(leaderboardRef);
    if (!leaderboardDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Leaderboard not found');
    }
    transaction.update(leaderboardRef, {
      entries: [],
      totalParticipants: 0,
      updatedAt: new Date(),
      status: 'active',
    });
  });

  await logAdminAction(actorUid, 'resetLeaderboard', 'leaderboard', leaderboardId, {});
  return { success: true } as SuccessResponse;
});
