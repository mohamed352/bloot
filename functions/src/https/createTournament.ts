import * as functions from 'firebase-functions';
import { db } from '../config/admin';
import { requireAppCheck } from '../utils/appCheck';

function sanitizeNumericString(value: unknown): string {
  if (value === undefined || value === null) return '0';
  if (typeof value === 'number') return Math.max(0, Math.floor(value)).toString();
  if (typeof value === 'string') {
    const parsed = parseInt(value.replace(/[^0-9]/g, ''), 10);
    return isNaN(parsed) ? '0' : parsed.toString();
  }
  return '0';
}

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
      prize?: string | number;
      maxParticipants?: number;
      entryFee?: string | number;
      date?: string;
      isPremium?: boolean;
      prizes?: Array<{ place: string; amount: string | number }>;
    };

    if (!name || typeof name !== 'string' || name.trim().length === 0) {
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

    const sanitizedPrize = sanitizeNumericString(prize);
    const sanitizedEntryFee = sanitizeNumericString(entryFee);

    const sanitizedPrizes = (prizes ?? []).map((p) => ({
      place: String(p.place ?? ''),
      amount: sanitizeNumericString(p.amount),
    }));

    const tournamentRef = db.collection('tournaments').doc();
    const now = new Date();

    await tournamentRef.set({
      id: tournamentRef.id,
      name: name.trim(),
      prize: sanitizedPrize,
      prizePool: parseInt(sanitizedPrize, 10),
      participants: `0/${size}`,
      currentParticipants: 0,
      maxParticipants: size,
      status: 'upcoming',
      date: date ?? '',
      isPremium: isPremium ?? false,
      entryFee: sanitizedEntryFee,
      participantIds: [],
      currentRound: 0,
      creatorUid: request.auth.uid,
      hostUid: request.auth.uid,
      format: 'single_elimination',
      type: 'single_elimination',
      prizes: sanitizedPrizes,
      matches: [],
      brackets: [],
      createdAt: now,
      updatedAt: now,
    });

    return { tournamentId: tournamentRef.id };
  },
);
