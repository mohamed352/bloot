import * as functions from 'firebase-functions';
import { db } from '../config/admin';
import { requireAppCheck } from '../utils/appCheck';

/**
 * Creates a new tournament document.
 * Only authenticated users can create tournaments.
 */
export const createTournament = functions.https.onCall(
  { cors: true },
  async (request) => {
    if (!request.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'Must be authenticated to create a tournament.',
      );
    }

    requireAppCheck(request);

    const {
      name,
      prize,
      maxParticipants,
      entryFee,
      date,
      isPremium,
      prizes,
    } = request.data as {
      name?: string;
      prize?: string;
      maxParticipants?: number;
      entryFee?: string;
      date?: string;
      isPremium?: boolean;
      prizes?: Array<{ place: string; amount: string }>;
    };

    if (!name || typeof name !== 'string') {
      throw new functions.https.HttpsError('invalid-argument', 'Missing or invalid name.');
    }

    const validSizes = [8, 16, 32, 64];
    const size = maxParticipants ?? 64;
    if (!validSizes.includes(size)) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `maxParticipants must be one of: ${validSizes.join(', ')}.`,
      );
    }

    const tournamentRef = db.collection('tournaments').doc();
    const now = new Date();

    await tournamentRef.set({
      id: tournamentRef.id,
      name,
      prize: prize ?? '',
      participants: `0/${size}`,
      maxParticipants: size,
      status: 'upcoming',
      date: date ?? '',
      isPremium: isPremium ?? false,
      entryFee: entryFee ?? '0',
      participantIds: [],
      currentRound: 0,
      creatorUid: request.auth.uid,
      format: 'single_elimination',
      prizes: prizes ?? [],
      matches: [],
      createdAt: now,
      updatedAt: now,
    });

    return { tournamentId: tournamentRef.id };
  },
);
