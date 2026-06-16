import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { db } from '../config/admin';
import { requireAppCheck } from '../utils/appCheck';
import { createTournamentMatchRoom } from '../engine/createTournamentMatchRoom';

/**
 * Starts a tournament: generates bracket, creates match rooms for round 1.
 * Only the creator or an admin can start.
 */
export const startTournament = functions.https.onCall(
  { cors: true },
  async (request) => {
    if (!request.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'Must be authenticated to start a tournament.',
      );
    }

    requireAppCheck(request);

    const { tournamentId } = request.data as { tournamentId?: string };
    if (!tournamentId || typeof tournamentId !== 'string') {
      throw new functions.https.HttpsError('invalid-argument', 'Missing tournamentId.');
    }

    const tournamentRef = db.collection('tournaments').doc(tournamentId);
    const tournamentDoc = await tournamentRef.get();

    if (!tournamentDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Tournament not found.');
    }

    const data = tournamentDoc.data()!;

    // Authorization: only creator or admin can start
    if (data.creatorUid !== request.auth.uid) {
      throw new functions.https.HttpsError(
        'permission-denied',
        'Only the tournament creator can start it.',
      );
    }

    if (data.status !== 'upcoming') {
      throw new functions.https.HttpsError(
        'failed-precondition',
        `Tournament cannot be started (status: ${data.status}).`,
      );
    }

    let participantIds: string[] = data.participantIds ?? [];
    if (participantIds.length < 2) {
      throw new functions.https.HttpsError(
        'failed-precondition',
        'Need at least 2 participants to start.',
      );
    }

    const maxParticipants: number = data.maxParticipants ?? 64;

    // Shuffle participants for random seeding
    participantIds = [...participantIds];
    for (let i = participantIds.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [participantIds[i], participantIds[j]] = [participantIds[j], participantIds[i]];
    }

    // Pad with nulls to reach power of 2
    while (participantIds.length < maxParticipants) {
      participantIds.push('');
    }

    // Generate bracket
    const matches = generateBracket(participantIds, maxParticipants);

    // Create rooms for round 0 matches that have two real players
    const round0Matches = matches.filter((m) => m.roundIndex === 0);
    for (const match of round0Matches) {
      if (match.playerAUid && match.playerBUid) {
        try {
          const roomId = await createTournamentMatchRoom({
            tournamentId,
            matchId: match.matchId,
            playerAUid: match.playerAUid,
            playerBUid: match.playerBUid,
            participantPool: data.participantIds,
          });
          match.roomId = roomId;
          match.status = 'live';

          // Send match ready notifications to all players
          await _sendMatchReadyNotifications({
            tournamentName: data.name,
            tournamentId,
            matchId: match.matchId,
            roomId,
            playerUids: [...match.teamAPlayerIds, ...match.teamBPlayerIds],
          });
        } catch (e) {
          functions.logger.error(`Failed to create room for match ${match.matchId}`, e);
        }
      }
    }

    const now = new Date();
    await tournamentRef.update({
      status: 'live',
      currentRound: 0,
      startedAt: now,
      matches,
      updatedAt: now,
    });

    return { success: true, matchCount: matches.length };
  },
);

interface MatchSlot {
  matchId: string;
  playerAUid: string | null;
  playerBUid: string | null;
  playerAName: string;
  playerBName: string;
  winnerUid: string | null;
  roomId: string | null;
  gameId: string | null;
  nextMatchId: string | null;
  roundIndex: number;
  matchIndex: number;
  status: string;
  isUserMatch: boolean;
  playerAAvatarUrl: string | null;
  playerBAvatarUrl: string | null;
  teamAPlayerIds: string[];
  teamBPlayerIds: string[];
}

function generateBracket(participantIds: string[], maxParticipants: number): MatchSlot[] {
  const matches: MatchSlot[] = [];
  let currentRoundSize = maxParticipants / 2;
  let matchIndex = 0;

  // Calculate total rounds
  let totalRounds = 0;
  let temp = maxParticipants;
  while (temp > 1) {
    temp /= 2;
    totalRounds++;
  }

  // Generate all rounds
  for (let round = 0; round < totalRounds; round++) {
    for (let i = 0; i < currentRoundSize; i++) {
      const matchId = `match_${round}_${i}`;
      const nextMatchId =
        round < totalRounds - 1 ? `match_${round + 1}_${Math.floor(i / 2)}` : null;

      let playerAUid: string | null = null;
      let playerBUid: string | null = null;

      // Only round 0 gets actual player assignments
      if (round === 0) {
        const idxA = i * 2;
        const idxB = i * 2 + 1;
        playerAUid = participantIds[idxA] || null;
        playerBUid = participantIds[idxB] || null;
      }

      matches.push({
        matchId,
        playerAUid: playerAUid && playerAUid !== '' ? playerAUid : null,
        playerBUid: playerBUid && playerBUid !== '' ? playerBUid : null,
        playerAName: playerAUid && playerAUid !== '' ? 'TBD' : 'TBD',
        playerBName: playerBUid && playerBUid !== '' ? 'TBD' : 'TBD',
        winnerUid: null,
        roomId: null,
        gameId: null,
        nextMatchId,
        roundIndex: round,
        matchIndex: i,
        status: round === 0 && playerAUid && playerBUid ? 'live' : 'upcoming',
        isUserMatch: false,
        playerAAvatarUrl: null,
        playerBAvatarUrl: null,
        teamAPlayerIds: playerAUid ? [playerAUid] : [],
        teamBPlayerIds: playerBUid ? [playerBUid] : [],
      });

      matchIndex++;
    }
    currentRoundSize /= 2;
  }

  return matches;
}

async function _sendMatchReadyNotifications({
  tournamentName,
  tournamentId,
  matchId,
  roomId,
  playerUids,
}: {
  tournamentName: string;
  tournamentId: string;
  matchId: string;
  roomId: string;
  playerUids: string[];
}) {
  for (const playerUid of playerUids) {
    if (!playerUid) continue;

    const userDoc = await admin.firestore().collection('users').doc(playerUid).get();
    const userData = userDoc.data();
    if (!userData) continue;

    const settings = userData.settings as Record<string, any> | undefined;
    if (settings?.notifications?.tournaments === false) continue;

    const fcmToken = userData.fcmToken as string | undefined;
    if (!fcmToken) {
      functions.logger.info(`No FCM token for user ${playerUid}`);
      continue;
    }

    const payload: admin.messaging.Message = {
      token: fcmToken,
      notification: {
        title: 'Tournament Match Ready!',
        body: `Your match in ${tournamentName} is starting now.`,
      },
      data: {
        type: 'tournamentMatchReady',
        tournamentId,
        matchId,
        roomId,
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
              title: 'Tournament Match Ready!',
              body: `Your match in ${tournamentName} is starting now.`,
            },
            badge: 1,
            sound: 'default',
          },
        },
      },
    };

    try {
      await admin.messaging().send(payload);
      functions.logger.info(`Sent tournament match ready notification to ${playerUid}`);
    } catch (error) {
      functions.logger.error(`Failed to send FCM to ${playerUid}`, error);
    }
  }
}
