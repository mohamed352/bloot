import { onSchedule } from 'firebase-functions/v2/scheduler';
import { db } from '../config/admin';
import { findLowestLegalCard } from '../engine/autoPlay';
import { playCardOntoTrick, startNextTrick } from '../engine/trick';
import { calculateRoundScore, checkGameEnd } from '../engine/scoring';

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

    try {
      await db.runTransaction(async (transaction) => {
        const freshDoc = await transaction.get(doc.ref);
        if (!freshDoc.exists) return;

        const freshGame = freshDoc.data() as any;
        if (freshGame.status !== game.status) return;

        // Advance trickEnd → playing after a short pause so clients can
        // display the completed trick.
        if (freshGame.status === 'trickEnd') {
          const trickEndStart = freshGame.turnTimerStart?.toMillis?.() || 0;
          const trickEndDelay = (freshGame.trickEndDelayMs || 2000);
          if (now - trickEndStart < trickEndDelay) return;

          const winnerSeat = freshGame.currentTrick?.winnerSeat;
          if (winnerSeat == null) return;

          startNextTrick(freshGame, winnerSeat);
          freshGame.turnTimerStart = new Date();
          freshGame.updatedAt = new Date();
          transaction.update(doc.ref, freshGame);
          return;
        }

        const turnStart = freshGame.turnTimerStart?.toMillis?.() || 0;
        const timeLimit = (freshGame.turnTimeLimit || 90) * 1000;
        const seatIndex = freshGame.turnIndex;
        const player = freshGame.players?.[String(seatIndex)];

        if (!player) return;

        // Auto-play if disconnected OR turn timed out
        const isDisconnected = player.isConnected === false;
        const isTimedOut = now - turnStart > timeLimit;

        if (!isDisconnected && !isTimedOut) return;

        if (freshGame.status === 'bidding') {
          // Auto-pass
          freshGame.players[String(seatIndex)].bid = 'pass';
          // Advance turn
          let nextTurn = (seatIndex + 1) % 4;
          let loopCount = 0;
          while (freshGame.players[String(nextTurn)]?.bid != null && loopCount < 4) {
            nextTurn = (nextTurn + 1) % 4;
            loopCount++;
          }
          freshGame.turnIndex = nextTurn;
          freshGame.turnTimerStart = new Date();
        } else if (freshGame.status === 'playing') {
          const card = findLowestLegalCard(freshGame, seatIndex);
          if (!card) return;

          const result = playCardOntoTrick(freshGame, seatIndex, card);

          if (result.trickComplete) {
            const completedTrickNumber = freshGame.currentTrick?.trickNumber;

            if (completedTrickNumber === 13) {
              const score = calculateRoundScore(freshGame);
              freshGame.teamAScore = (freshGame.teamAScore || 0) + score.teamAPoints;
              freshGame.teamBScore = (freshGame.teamBScore || 0) + score.teamBPoints;
              freshGame.fellTeam = score.fell;

              const winner = checkGameEnd(
                freshGame.teamAScore,
                freshGame.teamBScore,
                freshGame.targetScore || 152,
              );
              if (winner) {
                freshGame.status = 'gameEnd';
                freshGame.endedAt = new Date();
              } else {
                freshGame.status = 'roundEnd';
                freshGame.currentRound = (freshGame.currentRound || 1) + 1;
                freshGame.dealerIndex = ((freshGame.dealerIndex || 0) + 1) % 4;
              }
            } else {
              // Pause at trickEnd; next autoPlay tick will advance.
              freshGame.status = 'trickEnd';
              freshGame.turnTimerStart = new Date();
            }
          } else {
            freshGame.turnTimerStart = new Date();
          }
        } else if (freshGame.status === 'bonusClaim') {
          // Auto-claim no bonuses
          freshGame.players[String(seatIndex)].bonuses = [];
          freshGame.players[String(seatIndex)].isReady = true;

          const allReady = Object.values(freshGame.players).every(
            (p: any) => p.isReady,
          );
          if (allReady) {
            freshGame.status = 'playing';
            freshGame.turnIndex = freshGame.hokmBidder ?? freshGame.sunBidder ?? 0;
            if (freshGame.currentTrick) {
              freshGame.currentTrick.trickLeaderIndex = freshGame.turnIndex;
            }
            freshGame.turnTimerStart = new Date();
          }
        }

        freshGame.updatedAt = new Date();
        transaction.update(doc.ref, freshGame);
      });
    } catch (e) {
      console.error(`Auto-play failed for game ${doc.id}:`, e);
    }
  }
});
