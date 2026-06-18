import { onSchedule } from 'firebase-functions/v2/scheduler';
import { db } from '../config/admin';
import { findLowestLegalCard } from '../engine/autoPlay';
import { playCardOntoTrick, startNextTrick } from '../engine/trick';
import { calculateRoundScore, checkGameEnd } from '../engine/scoring';
import { resolveBidding, applyBiddingResult } from '../engine/bidding';
import { dealRound } from '../engine/deal';
import { detectAllBonuses, resolveBonusClaims } from '../engine/bonuses';
import { BonusClaim } from '../models/game';
import { buildGameUpdate, deepCloneGame } from '../utils/gameUpdate';

/**
 * Scheduled function that runs every minute to auto-play
 * for players who have timed out or disconnected, and to advance
 * the brief trickEnd pause to the next trick.
 *
 * Note: Cloud Scheduler minimum interval is 1 minute. Client-side
 * timeout UX should account for this coarse granularity.
 */
export const autoPlay = onSchedule(
  {
    schedule: 'every 1 minutes',
    timeZone: 'Asia/Riyadh',
  },
  async () => {
    const now = Date.now();
    const gamesSnap = await db
      .collection('games')
      .where('status', 'in', ['bidding', 'playing', 'bonusClaim', 'trickEnd'])
      .get();

    for (const doc of gamesSnap.docs) {
      const game = doc.data() as any;
      const gameTurnIndex = game.turnIndex;
      const gameTurnTimerStart = game.turnTimerStart?.toMillis?.() || 0;

      try {
        await db.runTransaction(async (transaction) => {
          const freshDoc = await transaction.get(doc.ref);
          if (!freshDoc.exists) return;

          const freshGame = freshDoc.data() as any;
          const originalGame = deepCloneGame(freshGame);
          const freshTurnTimerStart = freshGame.turnTimerStart?.toMillis?.() || 0;
          if (
            freshGame.status !== game.status ||
            freshGame.turnIndex !== gameTurnIndex ||
            freshTurnTimerStart !== gameTurnTimerStart
          ) {
            return;
          }

          // Advance trickEnd → playing after a short pause so clients can
          // display the completed trick.
          if (freshGame.status === 'trickEnd') {
            const trickEndStart = freshGame.turnTimerStart?.toMillis?.() || 0;
            const trickEndDelay = freshGame.trickEndDelayMs || 2000;
            if (now - trickEndStart < trickEndDelay) return;

            const winnerSeat = freshGame.currentTrick?.winnerSeat;
            if (winnerSeat == null) return;

            startNextTrick(freshGame, winnerSeat);
            freshGame.turnTimerStart = new Date();
            const update = buildGameUpdate(originalGame, freshGame);
            transaction.update(doc.ref, update);
            return;
          }

          const turnStart = freshGame.turnTimerStart?.toMillis?.() || 0;
          const timeLimit = (freshGame.turnTimeLimit || 90) * 1000;

          if (freshGame.status === 'bidding') {
            await handleAutoBid(freshGame, now, turnStart, timeLimit);
          } else if (freshGame.status === 'playing') {
            await handleAutoPlay(freshGame, now, turnStart, timeLimit);
          } else if (freshGame.status === 'bonusClaim') {
            await handleAutoBonusClaim(freshGame, now, turnStart, timeLimit);
          }

          const update = buildGameUpdate(originalGame, freshGame);
          transaction.update(doc.ref, update);
        });
      } catch (e) {
        console.error(`Auto-play failed for game ${doc.id}:`, e);
      }
    }
  },
);

function isPlayerTimedOut(
  player: any,
  now: number,
  turnStart: number,
  timeLimit: number,
): boolean {
  if (!player) return false;
  const isDisconnected = player.isConnected === false;
  const isTimedOut = now - turnStart > timeLimit;
  return isDisconnected || isTimedOut;
}

function advanceBidTurn(game: any, seatIndex: number): void {
  let nextTurn = (seatIndex + 1) % 4;
  let loopCount = 0;
  while (game.players[String(nextTurn)]?.bid != null && loopCount < 4) {
    nextTurn = (nextTurn + 1) % 4;
    loopCount++;
  }
  game.turnIndex = nextTurn;
  game.turnTimerStart = new Date();
}

async function handleAutoBid(
  game: any,
  now: number,
  turnStart: number,
  timeLimit: number,
): Promise<void> {
  const seatIndex = game.turnIndex;
  const player = game.players[String(seatIndex)];

  if (!isPlayerTimedOut(player, now, turnStart, timeLimit)) return;

  // Auto-pass
  game.players[String(seatIndex)].bid = 'pass';
  advanceBidTurn(game, seatIndex);

  // If all players have bid, resolve the bidding immediately.
  const allBids = Object.values(game.players).map((p: any) => p.bid);
  const biddingComplete = allBids.every((b) => b !== null);
  if (!biddingComplete) return;

  const bidResult = resolveBidding(game);
  if (!bidResult.resolved) return;

  applyBiddingResult(game, bidResult as any);

  if (bidResult.redeal) {
    dealRound(game);
  }

  game.turnTimerStart = new Date();
}

async function handleAutoPlay(
  game: any,
  now: number,
  turnStart: number,
  timeLimit: number,
): Promise<void> {
  const seatIndex = game.turnIndex;
  const player = game.players[String(seatIndex)];

  if (!isPlayerTimedOut(player, now, turnStart, timeLimit)) return;

  const card = findLowestLegalCard(game, seatIndex);
  if (!card) return;

  const result = playCardOntoTrick(game, seatIndex, card);

  if (result.trickComplete) {
    const completedTrickNumber = game.currentTrick?.trickNumber;

    if (completedTrickNumber === 13) {
      const score = calculateRoundScore(game);
      game.teamAScore = (game.teamAScore || 0) + score.teamAPoints;
      game.teamBScore = (game.teamBScore || 0) + score.teamBPoints;
      game.fellTeam = score.fell;

      const winner = checkGameEnd(
        game.teamAScore,
        game.teamBScore,
        game.targetScore || 152,
      );
      if (winner) {
        game.status = 'gameEnd';
        game.endedAt = new Date();
      } else {
        game.status = 'roundEnd';
        game.currentRound = (game.currentRound || 1) + 1;
        game.dealerIndex = ((game.dealerIndex || 0) + 1) % 4;
      }
    } else {
      // Pause at trickEnd; next autoPlay tick will advance.
      game.status = 'trickEnd';
      game.turnTimerStart = new Date();
    }
  } else {
    game.turnTimerStart = new Date();
  }
}

async function handleAutoBonusClaim(
  game: any,
  now: number,
  turnStart: number,
  timeLimit: number,
): Promise<void> {
  // Auto-claim bonuses for every disconnected/timed-out player who hasn't declared yet.
  for (let seatIndex = 0; seatIndex < 4; seatIndex++) {
    const player = game.players[String(seatIndex)];
    if (player.isReady) continue;

    if (isPlayerTimedOut(player, now, turnStart, timeLimit)) {
      // Auto-detect actual bonuses instead of blindly trusting an empty claim.
      const autoBonuses = detectAllBonuses(player.hand || []);
      player.bonuses = autoBonuses;
      player.isReady = true;
    }
  }

  const allReady = Object.values(game.players).every((p: any) => p.isReady);
  if (!allReady) return;

  // Resolve bonuses across all claims.
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
  game.resolvedBonuses = {
    teamA: resolved.teamAPoints,
    teamB: resolved.teamBPoints,
  };

  game.status = 'playing';
  game.turnIndex = game.hokmBidder ?? game.sunBidder ?? 0;
  if (game.currentTrick) {
    game.currentTrick.trickLeaderIndex = game.turnIndex;
  }
  game.turnTimerStart = new Date();
}
