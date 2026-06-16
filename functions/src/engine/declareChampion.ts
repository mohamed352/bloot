import { db } from '../config/admin';
import * as admin from 'firebase-admin';

interface Prize {
  place: string;
  amount: string;
}

/**
 * Declares a tournament champion, distributes prizes, and marks tournament complete.
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
  const now = new Date();

  const batch = db.batch();

  // Distribute prizes
  for (const prize of prizes) {
    const amount = parseInt(prize.amount.replace(/[^0-9]/g, ''), 10);
    if (isNaN(amount) || amount <= 0) continue;

    // For MVP, only the champion gets 1st place prize
    if (prize.place === '1st') {
      const userRef = db.collection('users').doc(championUid);
      batch.update(userRef, {
        coins: (tournamentData.coins || 0) + amount,
        updatedAt: now,
      });

      // Record transaction
      const txRef = userRef.collection('transactions').doc();
      batch.set(txRef, {
        type: 'tournament_prize',
        amount,
        tournamentId,
        tournamentName: tournamentData.name,
        description: `Won ${prize.place} place in ${tournamentData.name}`,
        createdAt: now,
      });
    }
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
