import { rtdb } from '../config/admin';
import { GameDocument } from '../engine/gameAdapter';

const GAMES_REF = 'games';

export interface RtdbGameValue {
  engineState: Record<string, unknown> | null;
  playerUids: Record<string, boolean>;
  status: string;
  turnTimerStart: number | null;
  turnTimeLimit: number;
  updatedAt: number;
}

/**
 * Builds the value mirrored to Realtime Database for a game.
 * Only the serialized engine state and lightweight metadata are kept in RTDB;
 * Firestore remains the source of truth for rooms, users, and history.
 */
export function buildRtdbGameValue(game: GameDocument): RtdbGameValue {
  const playerUids: Record<string, boolean> = {};
  for (const uid of game.playerUids || []) {
    if (uid) playerUids[uid] = true;
  }

  const timerStart = game.turnTimerStart as unknown as {
    toMillis?: () => number;
    getTime?: () => number;
  } | null;
  const turnTimerStart = timerStart
    ? (typeof timerStart.toMillis === 'function'
        ? timerStart.toMillis()
        : typeof timerStart.getTime === 'function'
          ? timerStart.getTime()
          : null)
    : null;

  return {
    engineState: (game.engineState as Record<string, unknown>) ?? null,
    playerUids,
    status: game.status ?? 'dealing',
    turnTimerStart,
    turnTimeLimit: game.turnTimeLimit ?? 45,
    updatedAt: Date.now(),
  };
}

/**
 * Writes a game's current state to the RTDB mirror.
 * Admin SDK writes bypass RTDB security rules.
 *
 * When [previous] is provided (the Firestore before-image), only top-level
 * keys that actually changed are written via update(), and the write is
 * skipped entirely when nothing meaningful changed (e.g. media-flag-only
 * updates that used to re-ship the full engineState to every client).
 */
export async function mirrorGameToRtdb(
  game: GameDocument,
  previous?: GameDocument | null,
): Promise<void> {
  if (!game?.id) return;
  try {
    const next = buildRtdbGameValue(game);
    if (previous) {
      const prev = buildRtdbGameValue(previous);
      const diff: Record<string, unknown> = {};
      for (const key of Object.keys(next) as (keyof RtdbGameValue)[]) {
        if (key === 'updatedAt') continue;
        if (JSON.stringify(next[key]) !== JSON.stringify(prev[key])) {
          diff[key] = next[key];
        }
      }
      // Nothing the WebView cares about changed; avoid a fan-out write.
      if (Object.keys(diff).length === 0) return;
      diff.updatedAt = next.updatedAt;
      await rtdb.ref(`${GAMES_REF}/${game.id}`).update(diff);
      return;
    }
    await rtdb.ref(`${GAMES_REF}/${game.id}`).set(next);
  } catch (e) {
    console.error(`[rtdbMirror] failed to mirror game ${game.id}:`, e);
  }
}

/**
 * Removes a game's RTDB mirror, typically after the match ends or the room
 * is rematched. Keeps RTDB storage bounded.
 */
export async function removeGameFromRtdb(gameId: string): Promise<void> {
  if (!gameId) return;
  try {
    await rtdb.ref(`${GAMES_REF}/${gameId}`).remove();
  } catch (e) {
    console.error(`[rtdbMirror] failed to remove game ${gameId} from RTDB:`, e);
  }
}
