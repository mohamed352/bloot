import { onSchedule } from 'firebase-functions/v2/scheduler';
import { db } from '../config/admin';
import { BalootBot, BalootEngine } from '../engine';
import {
  autoResolveDoubling,
  GameDocument,
  loadMatch,
  saveMatch,
  setTrickEndStatus,
} from '../engine/gameAdapter';
import { buildGameUpdate, deepCloneGame } from '../utils/gameUpdate';

/**
 * Scheduled function that runs every minute to auto-play for players who have
 * timed out or disconnected, and to advance the brief trickEnd pause.
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
      .where('status', 'in', ['bidding', 'playing', 'trickEnd'])
      .get();

    for (const doc of gamesSnap.docs) {
      const game = doc.data() as GameDocument;
      const gameTurnIndex = game.turnIndex;
      const gameTurnTimerStart =
        (game.turnTimerStart as any)?.toMillis?.() ||
        (game.turnTimerStart as Date)?.getTime?.() ||
        0;

      try {
        await db.runTransaction(async (transaction) => {
          const freshDoc = await transaction.get(doc.ref);
          if (!freshDoc.exists) return;

          const freshGame = freshDoc.data() as GameDocument;
          const originalGame = deepCloneGame(freshGame);
          const freshTurnTimerStart =
            (freshGame.turnTimerStart as any)?.toMillis?.() ||
            (freshGame.turnTimerStart as Date)?.getTime?.() ||
            0;
          if (
            freshGame.status !== game.status ||
            freshGame.turnIndex !== gameTurnIndex ||
            freshTurnTimerStart !== gameTurnTimerStart
          ) {
            return;
          }

          // Advance trickEnd -> playing after a short pause.
          if (freshGame.status === 'trickEnd') {
            const trickEndStart =
              (freshGame.turnTimerStart as any)?.toMillis?.() ||
              (freshGame.turnTimerStart as Date)?.getTime?.() ||
              0;
            const trickEndDelay = freshGame.trickEndDelayMs || 2000;
            if (now - trickEndStart < trickEndDelay) return;

            freshGame.status = 'playing';
            freshGame.turnTimerStart = new Date();
            const update = buildGameUpdate(originalGame, freshGame );
            transaction.update(doc.ref, update);
            return;
          }

          const turnStart =
            (freshGame.turnTimerStart as any)?.toMillis?.() ||
            (freshGame.turnTimerStart as Date)?.getTime?.() ||
            0;
          const timeLimit = (freshGame.turnTimeLimit || 90) * 1000;

          const engine = new BalootEngine();
          const match = loadMatch(freshGame);
          const state = match.state!;
          const seatIndex = state.turn;
          const player = freshGame.players[String(seatIndex)];

          if (!isPlayerTimedOut(player, now, turnStart, timeLimit)) return;

          if (state.phase === 'bidding') {
            const bot = new BalootBot();
            const level = (player.level as any) ?? 'amateur';
            const action = bot.decideBid(match, seatIndex, level);
            const events = engine.applyBid(match, seatIndex, action);
            freshGame.playerBids = freshGame.playerBids ?? {};
            freshGame.playerBids[String(seatIndex)] = action.type;

            if (match.state?.awaitingDouble) {
              autoResolveDoubling(match, engine);
            }
            saveMatch(freshGame, match);

            if (events.some((e) => e.type === 'redeal')) {
              freshGame.playerBids = {};
            }
          } else if (state.phase === 'playing') {
            const bot = new BalootBot();
            const level = (player.level as any) ?? 'amateur';
            const card = bot.decidePlay(match, seatIndex, level);
            const events = engine.playCard(match, seatIndex, card);

            const trickEnded = events.some((e) => e.type === 'trickEnd');
            const handEnded = events.some((e) => e.type === 'handEnd');
            const matchEnded = events.some((e) => e.type === 'matchEnd');

            saveMatch(freshGame, match);

            if (trickEnded && !handEnded && !matchEnded) {
              setTrickEndStatus(freshGame, match);
            }
          }

          freshGame.turnTimerStart = new Date();
          const update = buildGameUpdate(originalGame, freshGame );
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
