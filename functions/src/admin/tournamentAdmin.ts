import * as functions from 'firebase-functions';
import { db } from '../config/admin';
import { verifyPermission, logAdminAction } from './helpers';
import {
  CreateTournamentInput,
  UpdateTournamentInput,
  CancelTournamentInput,
  StartTournamentInput,
  SuccessResponse,
} from './types';

function assertAuth(request: functions.https.CallableRequest<unknown>): string {
  if (!request.auth?.uid) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }
  return request.auth.uid;
}

function toDate(value: unknown): Date {
  if (typeof value === 'string') {
    const parsed = new Date(value);
    if (isNaN(parsed.getTime())) {
      throw new functions.https.HttpsError('invalid-argument', 'Invalid date string');
    }
    return parsed;
  }
  if (value instanceof Date) {
    return value;
  }
  throw new functions.https.HttpsError('invalid-argument', 'Invalid date');
}

export const adminCreateTournament = functions.https.onCall(async (request) => {
  const actorUid = assertAuth(request);
  await verifyPermission(actorUid, 'manage');

  const data = request.data as CreateTournamentInput;
  if (!data.name || typeof data.name !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing name');
  }
  if (!data.type || typeof data.type !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing type');
  }
  if (!data.gameType || typeof data.gameType !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing gameType');
  }
  if (typeof data.maxParticipants !== 'number') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing maxParticipants');
  }
  if (typeof data.entryFee !== 'number') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing entryFee');
  }
  if (typeof data.prizePool !== 'number') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing prizePool');
  }

  const now = new Date();
  const tournamentRef = db.collection('tournaments').doc();
  await tournamentRef.set({
    id: tournamentRef.id,
    name: data.name,
    description: data.description ?? '',
    type: data.type,
    gameType: data.gameType,
    maxParticipants: data.maxParticipants,
    currentParticipants: 0,
    entryFee: data.entryFee,
    prizePool: data.prizePool,
    prizes: data.prizes ?? {},
    rules: data.rules ?? {},
    startDate: toDate(data.startDate),
    endDate: toDate(data.endDate),
    registrationDeadline: toDate(data.registrationDeadline),
    hostUid: actorUid,
    participants: [],
    brackets: {},
    imageUrl: data.imageUrl ?? '',
    isPremium: data.isPremium ?? false,
    status: 'upcoming',
    createdAt: now,
    updatedAt: now,
  });

  await logAdminAction(actorUid, 'admin-createTournament', 'tournament', tournamentRef.id, data as unknown as Record<string, unknown>);
  return { success: true, tournamentId: tournamentRef.id } as SuccessResponse & { tournamentId: string };
});

const ADMIN_UPDATABLE_TOURNAMENT_FIELDS = new Set([
  'name',
  'description',
  'type',
  'gameType',
  'maxParticipants',
  'entryFee',
  'prizePool',
  'prizes',
  'rules',
  'startDate',
  'endDate',
  'registrationDeadline',
  'imageUrl',
  'isPremium',
  'status',
]);

export const adminUpdateTournament = functions.https.onCall(async (request) => {
  const actorUid = assertAuth(request);
  await verifyPermission(actorUid, 'manage');

  const { tournamentId, updates } = request.data as UpdateTournamentInput;
  if (!tournamentId || typeof tournamentId !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing tournamentId');
  }
  if (!updates || typeof updates !== 'object') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing updates');
  }

  const tournamentRef = db.collection('tournaments').doc(tournamentId);
  await db.runTransaction(async (transaction) => {
    const tournamentDoc = await transaction.get(tournamentRef);
    if (!tournamentDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Tournament not found');
    }

    const payload: Record<string, unknown> = { updatedAt: new Date() };
    for (const [key, value] of Object.entries(updates as Record<string, unknown>)) {
      if (!ADMIN_UPDATABLE_TOURNAMENT_FIELDS.has(key)) {
        throw new functions.https.HttpsError(
          'invalid-argument',
          `Field '${key}' cannot be updated via adminUpdateTournament.`,
        );
      }
      if (['startDate', 'endDate', 'registrationDeadline'].includes(key) && value) {
        payload[key] = toDate(value);
      } else {
        payload[key] = value;
      }
    }

    transaction.update(tournamentRef, payload);
  });

  await logAdminAction(actorUid, 'admin-updateTournament', 'tournament', tournamentId, { updates });
  return { success: true } as SuccessResponse;
});

export const adminCancelTournament = functions.https.onCall(async (request) => {
  const actorUid = assertAuth(request);
  await verifyPermission(actorUid, 'manage');

  const { tournamentId } = request.data as CancelTournamentInput;
  if (!tournamentId || typeof tournamentId !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing tournamentId');
  }

  const tournamentRef = db.collection('tournaments').doc(tournamentId);
  await db.runTransaction(async (transaction) => {
    const tournamentDoc = await transaction.get(tournamentRef);
    if (!tournamentDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Tournament not found');
    }
    transaction.update(tournamentRef, {
      status: 'cancelled',
      updatedAt: new Date(),
    });
  });

  await logAdminAction(actorUid, 'admin-cancelTournament', 'tournament', tournamentId, {});
  return { success: true } as SuccessResponse;
});

export const adminStartTournament = functions.https.onCall(async (request) => {
  const actorUid = assertAuth(request);
  await verifyPermission(actorUid, 'manage');

  const { tournamentId } = request.data as StartTournamentInput;
  if (!tournamentId || typeof tournamentId !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing tournamentId');
  }

  const tournamentRef = db.collection('tournaments').doc(tournamentId);
  await db.runTransaction(async (transaction) => {
    const tournamentDoc = await transaction.get(tournamentRef);
    if (!tournamentDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Tournament not found');
    }
    const tournament = tournamentDoc.data()!;
    const allowedStatuses = ['registration', 'upcoming'];
    if (!allowedStatuses.includes(tournament.status as string)) {
      throw new functions.https.HttpsError(
        'failed-precondition',
        `Cannot start tournament from status ${tournament.status}`,
      );
    }
    transaction.update(tournamentRef, {
      status: 'active',
      updatedAt: new Date(),
    });
  });

  await logAdminAction(actorUid, 'admin-startTournament', 'tournament', tournamentId, {});
  return { success: true } as SuccessResponse;
});
