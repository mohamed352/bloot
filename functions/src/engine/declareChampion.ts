import { db } from '../config/admin';
import * as admin from 'firebase-admin';

interface Prize {
  place: string;
  amount: string | number;
}

function parsePrizeAmount(amount: string | number | undefined): number {
  if (amount === undefined || amount === null) return 0;
  if (typeof amount === 'number') return Math.max(0, Math.floor(amount));
  const parsed = parseInt(String(amount).replace(/[^0-9]/g, ''), 10);
  return isNaN(parsed) ? 0 : parsed;
}

/**
 * Declares a tournament champion, distributes prizes, and marks tournament complete.
 * Currently awards the 1st-place prize; full 1st-4th place distribution requires
 * bracket state to include runner-up placements.
 */
export async function declareChampion({
  tournamentId,
  championUid,
  championName,
}: {
  tournamentId: string;
  championUid: string;
  championName: string;
}): Promise<void> {
  const tournamentRef = db.collection('tournaments').doc(tournamentId);
  const tournamentDoc = await tournamentRef.get();

  if (!tournamentDoc.exists) {
    throw new Error('Tournament not found');
  }

  const tournamentData = tournamentDoc.data()!;
  const prizes: Prize[] = tournamentData.prizes ?? [];
  const prizePool: number = tournamentData.prizePool ?? parsePrizeAmount(tournamentData.prize);
  const now = new Date();

  const batch = db.batch();

  // Distribute 1st-place prize to the champion.
  const firstPlace = prizes.find((p) => p.place === '1st');
  const firstPlaceAmount = firstPlace
    ? parsePrizeAmount(firstPlace.amount)
    : prizePool;

  if (firstPlaceAmount > 0) {
    const userRef = db.collection('users').doc(championUid);
    const userDoc = await userRef.get();
    const userData = userDoc.data() ?? {};
    const currentCoins: number = userData.coins ?? 0;

    batch.update(userRef, {
      coins: currentCoins + firstPlaceAmount,
      updatedAt: now,
    });

    // Record transaction in the shared coin_transactions collection.
    const txRef = db.collection('coin_transactions').doc();
    batch.set(txRef, {
      uid: championUid,
      type: 'tournament_prize',
      amount: firstPlaceAmount,
      currency: 'coins',
      status: 'completed',
      description: `Won 1st place in ${tournamentData.name}`,
      metadata: { tournamentId, tournamentName: tournamentData.name, place: '1st' },
      createdAt: now,
      updatedAt: now,
    });
  }

  // Mark tournament as completed
  batch.update(tournamentRef, {
    status: 'completed',
    endedAt: now,
    championUid,
    championName,
    updatedAt: now,
  });

  await batch.commit();

  // Send champion notification
  const championDoc = await db.collection('users').doc(championUid).get();
  const championData = championDoc.data();
  const fcmToken = championData?.fcmToken as string | undefined;

  if (fcmToken) {
    const payload: admin.messaging.Message = {
      token: fcmToken,
      notification: {
        title: '🏆 Tournament Champion!',
        body: `Congratulations! You won ${tournamentData.name}!`,
      },
      data: {
        type: 'tournamentChampion',
        tournamentId,
        tournamentName: tournamentData.name ?? '',
      },
      android: {
        notification: {
          channelId: 'tournament_matches',
          priority: 'high',
        },
      },
      apns: {
        payload: {
          aps: {
            alert: {
              title: '🏆 Tournament Champion!',
              body: `Congratulations! You won ${tournamentData.name}!`,
            },
            badge: 1,
            sound: 'default',
          },
        },
      },
    };

    try {
      await admin.messaging().send(payload);
    } catch (error) {
      console.error('Failed to send champion notification', error);
    }
  }
}
