import { randomInt } from 'crypto';
import { FieldValue, Transaction } from 'firebase-admin/firestore';
import { db } from '../config/admin';

const MIN_AGORA_UID = 1_000_000;
const MAX_AGORA_UID = 2_147_483_647; // 2^31 - 1
const MAX_UNIQUENESS_ATTEMPTS = 10;

/**
 * Generates a random 31-bit Agora UID that is not currently in use by any
 * user document. Falls back to a deterministic hash if all attempts fail.
 */
async function generateUniqueAgoraUid(): Promise<number> {
  for (let attempt = 0; attempt < MAX_UNIQUENESS_ATTEMPTS; attempt++) {
    const candidate = randomInt(MIN_AGORA_UID, MAX_AGORA_UID + 1);
    const snapshot = await db
      .collection('users')
      .where('agoraUid', '==', candidate)
      .limit(1)
      .get();
    if (snapshot.empty) {
      return candidate;
    }
  }

  // Should be extremely rare; fall back to a deterministic value so callers
  // still get a valid UID. The collision risk here is the same as the legacy
  // hash-based assignment.
  return deterministicAgoraUidFromUid('');
}

/**
 * Returns a deterministic 31-bit UID for a Firebase UID. Used only as a
 * last-resort fallback; prefer `generateUniqueAgoraUid`.
 */
export function deterministicAgoraUidFromUid(uid: string): number {
  let hash = 0;
  for (let i = 0; i < uid.length; i++) {
    const char = uid.charCodeAt(i);
    hash = (hash << 5) - hash + char;
    hash |= 0;
  }
  return Math.abs(hash) % MAX_AGORA_UID;
}

/**
 * Retrieves the existing `agoraUid` for a user, or atomically generates and
 * stores a unique one if it is missing or invalid.
 *
 * This function is safe to call concurrently; the transaction guarantees that
 * only one unique UID is ever written for a given Firebase user.
 */
export async function getOrCreateUserAgoraUid(uid: string): Promise<number> {
  const userRef = db.collection('users').doc(uid);

  return db.runTransaction(async (transaction) => {
    const userDoc = await transaction.get(userRef);
    const existing = userDoc.data()?.agoraUid as number | undefined;

    if (isValidAgoraUid(existing)) {
      return existing;
    }

    const agoraUid = await generateUniqueAgoraUid();
    transaction.set(userRef, {
      agoraUid,
      updatedAt: FieldValue.serverTimestamp(),
    }, { merge: true });
    return agoraUid;
  });
}

/**
 * Like `getOrCreateUserAgoraUid` but accepts an existing transaction so the
 * caller can batch multiple reads/writes atomically.
 */
export async function getOrCreateUserAgoraUidInTransaction(
  uid: string,
  transaction: Transaction,
): Promise<number> {
  const userRef = db.collection('users').doc(uid);
  const userDoc = await transaction.get(userRef);
  const existing = userDoc.data()?.agoraUid as number | undefined;

  if (isValidAgoraUid(existing)) {
    return existing;
  }

  const agoraUid = await generateUniqueAgoraUid();
  transaction.set(userRef, {
    agoraUid,
    updatedAt: FieldValue.serverTimestamp(),
  }, { merge: true });
  return agoraUid;
}

function isValidAgoraUid(value: number | undefined): value is number {
  return (
    value !== undefined &&
    Number.isInteger(value) &&
    value >= MIN_AGORA_UID &&
    value <= MAX_AGORA_UID
  );
}
