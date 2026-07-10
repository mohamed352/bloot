import { rtdb } from '../config/admin';
import { GameDocument } from '../engine/gameAdapter';

const GAMES_REF = 'games';

export interface RtdbGameValue {
  engineState: Record<string, unknown> | null;
  playerUids: Record<string, boolean>;
  status: string;
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

  return {
    engineState: (game.engineState as Record<string, unknown>) ?? null,
    playerUids,
    status: game.status ?? 'dealing',
    updatedAt: Date.now(),
  };
}

/**
 * Writes a game's current state to the RTDB mirror.
 * Admin SDK writes bypass RTDB security rules.
 */
export async function mirrorGameToRtdb(game: GameDocument): Promise<void> {
  if (!game?.id) return;
  try {
    await rtdb.ref(`${GAMES_REF}/${game.id}`).set(buildRtdbGameValue(game));
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
