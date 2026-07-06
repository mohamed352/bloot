import { onDocumentUpdated } from 'firebase-functions/v2/firestore';
import { Timestamp } from 'firebase-admin/firestore';
import { db } from '../config/admin';
import { chooseBid, chooseCard, chooseBonuses } from '../engine/botStrategy';
import { playCardOntoTrick, startNextTrick } from '../engine/trick';
import { resolveBidding, applyBiddingResult } from '../engine/bidding';
import { dealRound } from '../engine/deal';
import { calculateRoundScore, checkGameEnd } from '../engine/scoring';
import { resolveBonusClaims } from '../engine/bonuses';
import { BonusClaim, GameDocument } from '../models/game';
import { buildGameUpdate, deepCloneGame } from '../utils/gameUpdate';

/**
 * Firestore trigger that auto-acts for bot players whenever it becomes their
 * turn. This makes the "Play with Bots" single-device test flow work against
 * the real database.
 */
export const botAutoPlay = onDocumentUpdated(
  {
    document: 'games/{gameId}',
    maxInstances: 10,
  },
  async (event) => {
    const after = event.data?.after;
    if (!after?.exists) return;

    const gameId = event.params.gameId;
    const game = after.data() as GameDocument;

    const seatIndex = game.turnIndex;
    const seatStr = String(seatIndex);
    const player = game.players[seatStr];

    if (!player?.isBot) return;

    // Small delay so the human can see the turn move to the bot.
    await sleep(1000);

    try {
      await db.runTransaction(async (transaction) => {
        const freshDoc = await transaction.get(after.ref);
        if (!freshDoc.exists) return;

        const freshGame = freshDoc.data() as GameDocument;
        const originalGame = deepCloneGame(freshGame as any);

        // Guard: make sure the bot is still on turn and the game state still
        // requires an action.
        if (freshGame.turnIndex !== seatIndex) return;
        const freshPlayer = freshGame.players[seatStr];
        if (!freshPlayer?.isBot) return;

        let status = freshGame.status;

        if (status === 'bidding') {
          actOnBid(freshGame, seatIndex);
        } else if (status === 'bonusClaim') {
          actOnBonusClaim(freshGame, seatIndex);
        } else if (status === 'playing') {
          actOnPlay(freshGame, seatIndex);
        } else {
          return;
        }

        // If a bot just completed a trick, advance immediately so play keeps
        // moving without waiting for the scheduled autoPlay tick.
        status = freshGame.status;
        if (status === 'trickEnd') {
          const winnerSeat = freshGame.currentTrick?.winnerSeat;
          if (winnerSeat != null) {
            startNextTrick(freshGame, winnerSeat);
            freshGame.turnTimerStart = Timestamp.now();
          }
        }

        // If a bot just completed a round, deal the next round automatically.
        if (freshGame.status === 'roundEnd') {
          dealRound(freshGame);
          freshGame.status = 'bidding';
          freshGame.turnIndex = (freshGame.dealerIndex + 1) % 4;
          freshGame.turnTimerStart = Timestamp.now();
        }

        const update = buildGameUpdate(originalGame, freshGame as any);
        if (Object.keys(update).length === 0) return;

        transaction.update(freshDoc.ref, update);
      });
    } catch (e) {
      console.error(`[botAutoPlay] failed for game ${gameId}:`, e);
    }
  },
);

function actOnBid(game: GameDocument, seatIndex: number): void {
  const bid = chooseBid(game, seatIndex);
  game.players[String(seatIndex)].bid = bid;

  // Advance to next bidder who has not yet bid.
  let nextTurn = (seatIndex + 1) % 4;
  let loopCount = 0;
  while (game.players[String(nextTurn)]?.bid != null && loopCount < 4) {
    nextTurn = (nextTurn + 1) % 4;
    loopCount++;
  }
  game.turnIndex = nextTurn;
  game.turnTimerStart = Timestamp.now();

  // If all players have bid, resolve immediately.
  const allBids = Object.values(game.players).map((p) => p.bid);
  if (allBids.every((b) => b !== null)) {
    const result = resolveBidding(game);
    if (result.resolved) {
      applyBiddingResult(game, result as any);
      if (result.redeal) {
        dealRound(game);
      }
    }
  }
}

function actOnBonusClaim(game: GameDocument, seatIndex: number): void {
  const player = game.players[String(seatIndex)];
  player.bonuses = chooseBonuses(player.hand);
  player.isReady = true;

  const allReady = Object.values(game.players).every((p) => p.isReady);
  if (!allReady) return;

  const teamABonuses: BonusClaim[] = [];
  const teamBBonuses: BonusClaim[] = [];

  for (const p of Object.values(game.players)) {
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
  game.currentTrick.trickLeaderIndex = game.turnIndex;
  game.turnTimerStart = Timestamp.now();
}

function actOnPlay(game: GameDocument, seatIndex: number): void {
  const card = chooseCard(game, seatIndex);
  if (!card) return;

  const result = playCardOntoTrick(game, seatIndex, card);

  if (result.trickComplete) {
    const completedTrickNumber = game.currentTrick.trickNumber;

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
        game.endedAt = Timestamp.now();
      } else {
        game.status = 'roundEnd';
        game.currentRound = (game.currentRound || 1) + 1;
        game.dealerIndex = ((game.dealerIndex || 0) + 1) % 4;
      }
    } else {
      game.status = 'trickEnd';
      game.turnTimerStart = Timestamp.now();
    }
  } else {
    game.turnTimerStart = Timestamp.now();
  }
}

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}
