import * as functions from 'firebase-functions';
import { db } from '../config/admin';

function buildKeywords(data: Record<string, unknown>): string[] {
  const tokens: string[] = [];
  const add = (value: unknown) => {
    if (typeof value === 'string' && value.trim()) {
      const normalized = value.trim().toLowerCase();
      tokens.push(normalized);
      normalized.split(/\s+/).forEach((word) => {
        if (word.length > 1) tokens.push(word);
      });
    }
  };

  add(data.reason);
  add(data.description);
  add(data.reportedUid);
  add(data.reporterUid);
  add(data.referenceId);

  return Array.from(new Set(tokens));
}

/**
 * Keeps reports.searchKeywords in sync with searchable fields.
 */
export const syncReportSearchKeywords = functions.firestore
  .onDocumentWritten('reports/{reportId}', async (event) => {
    const after = event.data?.after?.data();
    if (!after) return;

    const reportId = event.params.reportId;
    const keywords = buildKeywords(after);
    const current = (after.searchKeywords as string[] | undefined) || [];

    const same =
      keywords.length === current.length &&
      keywords.every((k, i) => k === current[i]);
    if (same) return;

    await db.collection('reports').doc(reportId).update({ searchKeywords: keywords });
  });
