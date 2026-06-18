import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { db } from '../config/admin';
import { requireAppCheck } from '../utils/appCheck';

/**
 * Withdraws the authenticated user from a tournament.
 * Refunds the entry fee (if any) and records a coin transaction.
 */
export const leaveTournament = functions.https.onCall(
  { cors: true },
  async (request) => {
    if (!request.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
    }

    requireAppCheck(request);

    const { tournamentId } = request.data as { tournamentId?: string };
    if (!tournamentId || typeof tournamentId !== 'string') {
      throw new functions.https.HttpsError('invalid-argument', 'Missing tournamentId.');
    }

    const uid = request.auth.uid;
    const tournamentRef = db.collection('tournaments').doc(tournamentId);
    const userRef = db.collection('users').doc(uid);

    return db.runTransaction(async (transaction) => {
      const tournamentDoc = await transaction.get(tournamentRef);
      if (!tournamentDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Tournament not found.');
      }

      const tournamentData = tournamentDoc.data()!;
      if (tournamentData.status !== 'upcoming') {
        throw new functions.https.HttpsError(
          'failed-precondition',
          'Tournament has already started or ended.',
        );
      }

      const participantIds: string[] = tournamentData.participantIds ?? [];
      if (!participantIds.includes(uid)) {
        throw new functions.https.HttpsError(
          'failed-precondition',
          'You are not registered for this tournament.',
        );
      }

      const entryFee = parseInt(tournamentData.entryFee, 10) || 0;
      if (entryFee > 0) {
        const userDoc = await transaction.get(userRef);
        const userData = userDoc.data() ?? {};
        const currentCoins: number = userData.coins ?? 0;
        transaction.update(userRef, {
          coins: currentCoins + entryFee,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        const txRef = db.collection('coin_transactions').doc();
        transaction.set(txRef, {
          uid,
          type: 'tournament_refund',
          amount: entryFee,
          currency: 'coins',
          status: 'completed',
          description: `Refund for leaving tournament ${tournamentData.name || tournamentId}`,
          metadata: { tournamentId, tournamentName: tournamentData.name || '' },
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }

      const updatedParticipantIds = participantIds.filter((id) => id !== uid);
      const maxParticipants: number = tournamentData.maxParticipants ?? 64;
      transaction.update(tournamentRef, {
        participantIds: updatedParticipantIds,
        participants: `${updatedParticipantIds.length}/${maxParticipants}`,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return { success: true, participantCount: updatedParticipantIds.length };
    });
  },
);
