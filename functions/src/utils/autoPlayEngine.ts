import { DocumentReference } from 'firebase-admin/firestore';
import { db } from '../config/admin';
import { BalootBot, BalootEngine, BotLevel } from '../engine';
import {
  autoResolveDoubling,
  GameDocument,
  loadMatch,
  saveMatch,
  setTrickEndStatus,
} from '../engine/gameAdapter';
import { buildGameUpdate, deepCloneGame } from './gameUpdate';

export function toMillis(value: unknown): number {
  return (
    (value as { toMillis?: () => number })?.toMillis?.() ||
    (value as Date)?.getTime?.() ||
    0
  );
}

/**
 * True when the trickEnd pause has fully elapsed and the game can move back
 * to 'playing'.
 */
export function isTrickEndDue(
  game: { turnTimerStart?: unknown; trickEndDelayMs?: number },
  nowMillis: number,
): boolean {
  const trickEndStart = toMillis(game.turnTimerStart);
  const trickEndDelay = game.trickEndDelayMs || 2000;
  return nowMillis - trickEndStart >= trickEndDelay;
}

/**
 * True when the current player should be auto-played: either explicitly
 * marked disconnected or past the turn time limit.
 */
export function isPlayerTimedOut(
  player: { isConnected?: boolean } | undefined,
  nowMillis: number,
  turnStartMillis: number,
  timeLimitMillis: number,
): boolean {
  if (!player) return false;
  const isDisconnected = player.isConnected === false;
  const isTimedOut = nowMillis - turnStartMillis > timeLimitMillis;
  return isDisconnected || isTimedOut;
}

/**
 * Applies one auto-play pass to a single game inside a transaction:
 * advances the trickEnd pause when due, or auto-plays for a timed-out /
 * disconnected player (bid or card, matching the cron's historical logic).
 *
 * Returns true when the game document was actually updated. All decisions
 * are based on the freshly-read document inside the transaction, so
 * concurrent callers (cron + checkTurnTimeout callable + clients) are safe:
 * losers of the race simply observe a fresh turnTimerStart and act=false.
 */
export async function applyAutoPlayToGame(
  gameRef: DocumentReference,
  nowMillis: number,
): Promise<boolean> {
  let acted = false;
  await db.runTransaction(async (transaction) => {
    const freshDoc = await transaction.get(gameRef);
    if (!freshDoc.exists) return;

    const freshGame = freshDoc.data() as GameDocument;
    const originalGame = deepCloneGame(freshGame);

    // Advance trickEnd -> playing after a short pause.
    if (freshGame.status === 'trickEnd') {
      if (!isTrickEndDue(freshGame, nowMillis)) return;

      freshGame.status = 'playing';
      freshGame.turnTimerStart = new Date();
      const update = buildGameUpdate(originalGame, freshGame);
      transaction.update(gameRef, update);
      acted = true;
      return;
    }

    if (freshGame.status !== 'bidding' && freshGame.status !== 'playing') {
      return;
    }

    const turnStart = toMillis(freshGame.turnTimerStart);
    const timeLimit = (freshGame.turnTimeLimit || 45) * 1000;

    const engine = new BalootEngine();
    const match = loadMatch(freshGame);
    const state = match.state!;
    const seatIndex = state.turn;
    const player = freshGame.players[String(seatIndex)];

    if (!isPlayerTimedOut(player, nowMillis, turnStart, timeLimit)) return;

    if (state.phase === 'bidding') {
      const bot = new BalootBot();
      const level = ((player.level as BotLevel | undefined) ?? 'amateur');
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
      const level = ((player.level as BotLevel | undefined) ?? 'amateur');
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
    const update = buildGameUpdate(originalGame, freshGame);
    transaction.update(gameRef, update);
    acted = true;
  });
  return acted;
}
