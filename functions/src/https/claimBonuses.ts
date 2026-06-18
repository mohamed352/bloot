import * as functions from 'firebase-functions';
import { db } from '../config/admin';
import { requireAppCheck } from '../utils/appCheck';
import { detectBnaga, detectMosal, resolveBonusClaims } from '../engine/bonuses';
import { BonusClaim } from '../models/game';
import { buildGameUpdate, deepCloneGame } from '../utils/gameUpdate';

export const claimBonuses = functions.https.onCall(async (request) => {
  if (!request.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  requireAppCheck(request);

  const { gameId, bonuses } = request.data;
  if (!gameId || !Array.isArray(bonuses)) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing gameId or bonuses');
  }

  const gameRef = db.collection('games').doc(gameId);

  return db.runTransaction(async (transaction) => {
    const gameDoc = await transaction.get(gameRef);
    if (!gameDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Game not found');
    }

    const game = gameDoc.data() as any;
    const originalGame = deepCloneGame(game);

    if (game.status !== 'bonusClaim') {
      throw new functions.https.HttpsError('failed-precondition', 'Not in bonus claim phase');
    }

    if (game.gameType !== 'hokm') {
      throw new functions.https.HttpsError('failed-precondition', 'Bonuses only in Hokm');
    }

    // Find player seat
    const playerEntry = Object.entries(game.players).find(
      ([, p]: [string, any]) => (p as any).uid === request.auth!.uid,
    );
    if (!playerEntry) {
      throw new functions.https.HttpsError('permission-denied', 'Not a player');
    }

    const seatIndex = parseInt(playerEntry[0], 10);
    const player = game.players[String(seatIndex)];

    // Validate claimed bonuses against actual hand and real detectable bonuses
    const claimed = bonuses as BonusClaim[];
    const detectedBnaga = detectBnaga(player.hand);
    const detectedMosal = detectMosal(player.hand);

    for (const claim of claimed) {
      // All claimed cards must be in the player's hand
      for (const card of claim.cards) {
        if (!player.hand.includes(card)) {
          throw new functions.https.HttpsError(
            'failed-precondition',
            `Card ${card} not in hand`,
          );
        }
      }

      if (claim.type === 'bnaga') {
        if (!detectedBnaga) {
          throw new functions.https.HttpsError(
            'failed-precondition',
            'No valid bnaga in hand',
          );
        }
        // Claimed sequence must match the detected best sequence exactly
        const claimedSet = new Set(claim.cards);
        const detectedSet = new Set(detectedBnaga.sequence);
        if (claimedSet.size !== detectedSet.size ||
            ![...claimedSet].every((c) => detectedSet.has(c))) {
          throw new functions.https.HttpsError(
            'failed-precondition',
            'Invalid bnaga claim',
          );
        }
        if (claim.points !== detectedBnaga.points) {
          throw new functions.https.HttpsError(
            'failed-precondition',
            'Incorrect bnaga points',
          );
        }
      } else if (claim.type === 'mosal') {
        if (!detectedMosal) {
          throw new functions.https.HttpsError(
            'failed-precondition',
            'No valid mosal in hand',
          );
        }
        const claimedSet = new Set(claim.cards);
        const detectedSet = new Set(detectedMosal.cards);
        if (claimedSet.size !== detectedSet.size ||
            ![...claimedSet].every((c) => detectedSet.has(c))) {
          throw new functions.https.HttpsError(
            'failed-precondition',
            'Invalid mosal claim',
          );
        }
        if (claim.points !== detectedMosal.points) {
          throw new functions.https.HttpsError(
            'failed-precondition',
            'Incorrect mosal points',
          );
        }
      } else {
        throw new functions.https.HttpsError(
          'failed-precondition',
          `Unknown bonus type: ${claim.type}`,
        );
      }
    }

    player.bonuses = claimed;
    player.isReady = true;

    // Check if all players are ready
    const allReady = Object.values(game.players).every((p: any) => p.isReady);
    if (allReady) {
      // Resolve bonuses
      const teamABonuses: BonusClaim[] = [];
      const teamBBonuses: BonusClaim[] = [];

      for (const [, p] of Object.entries(game.players) as [string, any][]) {
        if (p.bonuses) {
          if (p.team === 'A') {
            teamABonuses.push(...p.bonuses);
          } else {
            teamBBonuses.push(...p.bonuses);
          }
        }
      }

      const resolved = resolveBonusClaims(teamABonuses, teamBBonuses);

      // Store resolved bonus points on the game document for scoring.
      // Player.bonuses arrays are intentionally left intact so scoring can
      // include both teams' bonuses in a Hokm fall.
      game.resolvedBonuses = {
        teamA: resolved.teamAPoints,
        teamB: resolved.teamBPoints,
      };

      game.status = 'playing';
      game.turnIndex = game.hokmBidder ?? game.sunBidder ?? 0;
      game.currentTrick.trickLeaderIndex = game.turnIndex;
    }

    const update = buildGameUpdate(originalGame, game);
    transaction.update(gameRef, update);

    return { success: true, status: game.status, allReady };
  });
});
