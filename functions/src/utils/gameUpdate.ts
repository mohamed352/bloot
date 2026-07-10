import * as admin from 'firebase-admin';

/**
 * Deep-clones a plain object while preserving Firestore Timestamp and Date
 * instances by reference (they are immutable).
 */
export function deepCloneGame(value: unknown): any {
  if (value == null || typeof value !== 'object') return value;

  // Preserve Timestamp / Date instances.
  if (
    value instanceof Date ||
    (typeof (value as any).toMillis === 'function' &&
      typeof (value as any).seconds === 'number')
  ) {
    return value;
  }

  if (Array.isArray(value)) {
    return value.map(deepCloneGame);
  }

  const cloned: Record<string, unknown> = {};
  for (const [key, val] of Object.entries(value)) {
    cloned[key] = deepCloneGame(val);
  }
  return cloned;
}

/**
 * Builds a Firestore update payload containing only the fields that changed
 * between the original game document and the mutated game object.
 *
 * Uses dot-notation for nested fields (especially players and currentTrick) so
 * concurrent updates to different players do not overwrite each other.
 */
export function buildGameUpdate(
  original: unknown,
  mutated: unknown,
): Record<string, unknown> {
  const update: Record<string, unknown> = {};
  const originalObj = original as Record<string, unknown>;
  const mutatedObj = mutated as Record<string, unknown>;

  // Top-level scalar/object fields (except players/currentTrick, handled below).
  const nestedKeys = new Set(['players', 'currentTrick', 'resolvedBonuses']);
  for (const key of Object.keys(mutatedObj)) {
    if (nestedKeys.has(key)) continue;
    if (!isEqual(originalObj[key], mutatedObj[key])) {
      update[key] = mutatedObj[key];
    }
  }

  // players.{seat}.{field}
  const originalPlayers = (originalObj.players ?? {}) as Record<string, Record<string, unknown>>;
  const mutatedPlayers = (mutatedObj.players ?? {}) as Record<string, Record<string, unknown>>;
  for (const seat of Object.keys(mutatedPlayers)) {
    const originalPlayer = originalPlayers[seat] ?? {};
    const mutatedPlayer = mutatedPlayers[seat];
    for (const field of Object.keys(mutatedPlayer)) {
      if (!isEqual(originalPlayer[field], mutatedPlayer[field])) {
        update[`players.${seat}.${field}`] = mutatedPlayer[field];
      }
    }
  }

  // currentTrick.{field}
  const originalTrick = (originalObj.currentTrick ?? {}) as Record<string, unknown>;
  const mutatedTrick = (mutatedObj.currentTrick ?? {}) as Record<string, unknown>;
  for (const field of Object.keys(mutatedTrick)) {
    if (!isEqual(originalTrick[field], mutatedTrick[field])) {
      update[`currentTrick.${field}`] = mutatedTrick[field];
    }
  }

  // resolvedBonuses.{team}
  const originalResolved = (originalObj.resolvedBonuses ?? {}) as Record<string, unknown>;
  const mutatedResolved = (mutatedObj.resolvedBonuses ?? {}) as Record<string, unknown>;
  for (const field of Object.keys(mutatedResolved)) {
    if (!isEqual(originalResolved[field], mutatedResolved[field])) {
      update[`resolvedBonuses.${field}`] = mutatedResolved[field];
    }
  }

  // Always include updatedAt if anything changed.
  if (Object.keys(update).length > 0 && !update.updatedAt) {
    update.updatedAt = admin.firestore.FieldValue.serverTimestamp();
  }

  return update;
}

function isEqual(a: unknown, b: unknown): boolean {
  if (a === b) return true;
  if (a == null || b == null) return a === b;
  if (typeof a !== typeof b) return false;

  if (typeof a === 'object') {
    // Treat Firestore Timestamps/Dates loosely by value if possible.
    if (isTimestampLike(a) && isTimestampLike(b)) {
      return getMillis(a) === getMillis(b);
    }

    const aKeys = Object.keys(a as object);
    const bKeys = Object.keys(b as object);
    if (aKeys.length !== bKeys.length) return false;
    for (const key of aKeys) {
      if (!bKeys.includes(key)) return false;
      if (!isEqual((a as Record<string, unknown>)[key], (b as Record<string, unknown>)[key])) {
        return false;
      }
    }
    return true;
  }

  return false;
}

function getMillis(value: unknown): number {
  if (value instanceof Date) return value.getTime();
  return (value as any).toMillis();
}

function isTimestampLike(value: unknown): boolean {
  return (
    value instanceof Date ||
    (value != null &&
      typeof (value as any).toMillis === 'function' &&
      typeof (value as any).seconds === 'number')
  );
}
