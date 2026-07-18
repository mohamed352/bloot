import { onDocumentWritten } from 'firebase-functions/v2/firestore';
import { Timestamp } from 'firebase-admin/firestore';
import { db } from '../config/admin';
import { BalootBot, BalootEngine } from '../engine';
import { autoResolveDoubling, loadMatch, saveMatch, setTrickEndStatus } from '../engine/gameAdapter';
import { buildGameUpdate, deepCloneGame } from '../utils/gameUpdate';

/**
 * Firestore trigger that auto-acts for bot players whenever it becomes their
 * turn. This makes the "Play with Bots" single-device test flow work against
 * the real database.
 */
export function isTerminalGameForBotAutoPlay(game: {
  status?: string;
  endedAt?: unknown;
}): boolean {
  return game.status === 'gameEnd' || game.endedAt != null;
}

export const botAutoPlay = onDocumentWritten(
  {
    document: 'games/{gameId}',
    maxInstances: 10,
  },
  async (event) => {
    const after = event.data?.after;
    if (!after?.exists) return;

    const gameId = event.params.gameId;
    const game = after.data() as any;

    // Never act on a completed game. Without this guard, the unconditional
    // turnTimerStart update below writes the game again, re-triggers this
    // function, and creates an expensive infinite bot/mirror/update loop.
    if (isTerminalGameForBotAutoPlay(game)) return;

    const seatIndex = game.turnIndex;
    const seatStr = String(seatIndex);
    const player = game.players?.[seatStr];

    if (!player?.isBot) return;

    await sleep(1000);

    try {
      await db.runTransaction(async (transaction) => {
        const freshDoc = await transaction.get(after.ref);
        if (!freshDoc.exists) return;

        const freshGame = freshDoc.data() as any;
        const originalGame = deepCloneGame(freshGame);

        if (isTerminalGameForBotAutoPlay(freshGame)) return;
        if (freshGame.turnIndex !== seatIndex) return;
        if (!freshGame.players?.[seatStr]?.isBot) return;

        const engine = new BalootEngine();
        const match = loadMatch(freshGame);
        let state = match.state!;
        if (match.matchOver) return;
        const bot = new BalootBot();
        const level = player.level ?? 'amateur';
        let acted = false;

        if (state.phase === 'bidding') {
          const action = bot.decideBid(match, seatIndex, level);
          const events = engine.applyBid(match, seatIndex, action);
          freshGame.playerBids = freshGame.playerBids ?? {};
          freshGame.playerBids[seatStr] = action.type;

          if (match.state?.awaitingDouble) {
            autoResolveDoubling(match, engine);
          }
          saveMatch(freshGame, match);

          acted = true;
          if (events.some((e) => e.type === 'redeal')) {
            freshGame.playerBids = {};
          }
        } else if (state.awaitingDeclare && state.declareSeats.includes(seatIndex)) {
          const botProjects = state.projects.filter((p) => p.seat === seatIndex);
          const types = botProjects.map((p) => p.type);
          engine.declareProject(match, seatIndex, types);
          saveMatch(freshGame, match);
          acted = true;
        } else if (state.awaitingDouble && state.doubling?.turn === seatIndex) {
          const wantsDouble = bot.decideDouble(match, seatIndex, level);
          engine.applyDouble(match, seatIndex, wantsDouble ? 'double' : 'pass');
          saveMatch(freshGame, match);
          acted = true;
        } else if (state.phase === 'playing') {
          const card = bot.decidePlay(match, seatIndex, level);
          const events = engine.playCard(match, seatIndex, card);

          const trickEnded = events.some((e) => e.type === 'trickEnd');
          const handEnded = events.some((e) => e.type === 'handEnd');
          const matchEnded = events.some((e) => e.type === 'matchEnd');

          saveMatch(freshGame, match);

          acted = true;
          if (trickEnded && !handEnded && !matchEnded) {
            setTrickEndStatus(freshGame, match);
          }
        }

        // Bots don't need the trick-end pause; advance immediately.
        if (freshGame.status === 'trickEnd') {
          freshGame.status = 'playing';
        }

        // In all-bot games, deal the next round automatically.
        if (match.state?.phase === 'handEnd' && !match.matchOver) {
          match.dealer = (match.dealer + 1) % 4;
          engine.startHand(match);
          freshGame.playerBids = {};
          freshGame.fellTeam = null;
          freshGame.resolvedBonuses = null;
          saveMatch(freshGame, match);
          acted = true;
        }

        // Do not write when no bot action was applicable. A timer-only write
        // would retrigger this function forever on terminal/stale states.
        if (!acted) return;

        freshGame.turnTimerStart = Timestamp.now();

        const update = buildGameUpdate(originalGame, freshGame);
        if (Object.keys(update).length === 0) return;

        transaction.update(freshDoc.ref, update);
      });
    } catch (e) {
      console.error(`[botAutoPlay] failed for game ${gameId}:`, e);
    }
  },
);

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}
