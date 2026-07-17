import * as admin from 'firebase-admin';

/**
 * One-off backfill: populates `searchKeywords` on every user document using
 * the same tokenization as the syncUserSearchKeywords trigger. Safe to re-run;
 * documents whose keywords are already correct are skipped.
 *
 * Usage: npx ts-node scripts/backfillSearchKeywords.ts
 */
admin.initializeApp();

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
  add(data.displayName);
  add(data.username);
  add(data.email);
  return Array.from(new Set(tokens));
}

async function backfill() {
  const db = admin.firestore();
  const users = await db.collection('users').get();
  let updated = 0;
  let skipped = 0;

  const batch = db.batch();
  for (const doc of users.docs) {
    const data = doc.data();
    const keywords = buildKeywords(data);
    const current = (data.searchKeywords as string[] | undefined) || [];
    const same =
      keywords.length === current.length &&
      keywords.every((k, i) => k === current[i]);
    if (same) {
      skipped++;
      continue;
    }
    batch.update(doc.ref, { searchKeywords: keywords });
    updated++;
  }

  await batch.commit();
  console.log(`Backfill complete: ${updated} updated, ${skipped} already up to date.`);
}

backfill()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
