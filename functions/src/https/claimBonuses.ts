import * as functions from 'firebase-functions';
import { db } from '../config/admin';
import { requireAppCheck } from '../utils/appCheck';
import { resolveBonusClaims } from '../engine/bonuses';
import { BonusClaim } from '../models/game';

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

    // Validate claimed bonuses against actual hand
    const claimed = bonuses as BonusClaim[];
    for (const claim of claimed) {
      for (const card of claim.cards) {
        if (!player.hand.includes(card)) {
          throw new functions.https.HttpsError(
            'failed-precondition',
            `Card ${card} not in hand`,
          );
        }
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

      // Store resolved bonus points on the game document for scoring
      game.resolvedBonuses = {
        teamA: resolved.teamAPoints,
        teamB: resolved.teamBPoints,
      };

      // Mark only winning team's bonuses as valid
      for (const [, p] of Object.entries(game.players) as [string, any][]) {
        if (p.team === 'A' && resolved.teamAPoints === 0) {
          p.bonuses = [];
        } else if (p.team === 'B' && resolved.teamBPoints === 0) {
          p.bonuses = [];
        }
      }

      game.status = 'playing';
      game.turnIndex = game.hokmBidder ?? game.sunBidder ?? 0;
      game.currentTrick.trickLeaderIndex = game.turnIndex;
    }

    game.updatedAt = new Date();
    transaction.update(gameRef, game);

    return { success: true, status: game.status, allReady };
  });
});
