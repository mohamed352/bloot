import * as functions from 'firebase-functions';
import { db } from '../config/admin';

function buildKeywords(data: Record<string, unknown>): string[] {
  const tokens: string[] = [];
  const add = (value: unknown) => {
    if (typeof value === 'string' && value.trim()) {
      const normalized = value.trim().toLowerCase();
      tokens.push(normalized);
      // Also add each word for partial matching.
      normalized.split(/\s+/).forEach((word) => {
        if (word.length > 1) tokens.push(word);
      });
    }
  };

  add(data.displayName);
  add(data.username);
  add(data.phoneNumber);
  add(data.email);

  return Array.from(new Set(tokens));
}

/**
 * Keeps users.searchKeywords in sync with searchable fields.
 */
export const syncUserSearchKeywords = functions.firestore
  .onDocumentWritten('users/{uid}', async (event) => {
    const after = event.data?.after?.data();
    if (!after) return; // document deleted

    const uid = event.params.uid;
    const keywords = buildKeywords(after);
    const current = (after.searchKeywords as string[] | undefined) || [];

    const same =
      keywords.length === current.length &&
      keywords.every((k, i) => k === current[i]);
    if (same) return;

    await db.collection('users').doc(uid).update({ searchKeywords: keywords });
  });
