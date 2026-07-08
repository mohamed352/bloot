import { BalootCard, BalootRank, BalootSuit, BALOOT_RANKS, BALOOT_SUITS } from './balootCard';

export type BalootMode = 'sun' | 'hokum';

export type BidActionType = 'pass' | 'hokum' | 'sun' | 'ashkal';

export type DoubleAction = 'pass' | 'double';

export type ProjectType = 'sira' | 'fifty' | 'hundred' | 'fourAces';

export type ViolationType = 'qatee' | 'makabr' | 'madaq' | 'sawa' | 'rubu';

export const NATURAL_ORDER: BalootRank[] = ['7', '8', '9', '10', 'J', 'Q', 'K', 'A'];

/** Card strength order in Sun mode and non-trump Hokm suits. */
export const SUN_ORDER: BalootRank[] = ['7', '8', '9', 'J', 'Q', 'K', '10', 'A'];

/** Card strength order in the Hokm trump suit. */
export const HOKUM_TRUMP_ORDER: BalootRank[] = ['7', '8', 'Q', 'K', '10', 'A', '9', 'J'];

/** Point values in Sun mode / non-trump suits. */
export const SUN_POINTS: Record<BalootRank, number> = {
  A: 11,
  '10': 10,
  K: 4,
  Q: 3,
  J: 2,
  '9': 0,
  '8': 0,
  '7': 0,
};

/** Point values in the Hokm trump suit. */
export const HOKUM_TRUMP_POINTS: Record<BalootRank, number> = {
  J: 20,
  '9': 14,
  A: 11,
  '10': 10,
  K: 4,
  Q: 3,
  '8': 0,
  '7': 0,
};

/** Point values for non-trump suits in Hokm mode. */
export const HOKUM_PLAIN_POINTS = SUN_POINTS;

/** Project points in Sun mode (qaid). */
export const SUN_PROJECT_QAID: Record<ProjectType, number> = {
  sira: 4,
  fifty: 10,
  hundred: 20,
  fourAces: 40,
};

/** Hokm mode has no projects except Baloot (handled separately). */
export const HOKUM_PROJECT_QAID: Record<ProjectType, number> = {
  sira: 0,
  fifty: 0,
  hundred: 0,
  fourAces: 0,
};

/** Human-readable Arabic names for projects. */
export const PROJECT_NAMES: Record<ProjectType, string> = {
  sira: 'سرا',
  fifty: 'خمسين',
  hundred: 'مية',
  fourAces: 'أربعمئة',
};

/** Qaid value of a Baloot (K+Q of trump in Hokm mode). */
export const BALOOT_QAID = 2;

/** Target score to win the match. */
export const TARGET_QAID = 152;

/** Base round totals used for complementary scoring. */
export const HOKUM_ROUND_TOTAL = 16;
export const SUN_ROUND_TOTAL = 26;

/** Kabout (capot) fixed qaid awards. */
export const HOKUM_CAPOT_QAID = 25;
export const SUN_CAPOT_QAID = 44;

export function indexInNaturalOrder(rank: BalootRank): number {
  return NATURAL_ORDER.indexOf(rank);
}

export function indexInSunOrder(rank: BalootRank): number {
  return SUN_ORDER.indexOf(rank);
}

export function indexInHokumTrumpOrder(rank: BalootRank): number {
  return HOKUM_TRUMP_ORDER.indexOf(rank);
}

/** Returns the point value of a card given the current mode and trump suit. */
export function cardPoints(card: BalootCard, mode: BalootMode, trump: BalootSuit | null): number {
  if (mode === 'hokum' && card.suit === trump) {
    return HOKUM_TRUMP_POINTS[card.rank] ?? 0;
  }
  return SUN_POINTS[card.rank] ?? 0;
}

/**
 * Returns the strength index of a card inside a trick.
 * Higher value = stronger. Non-followers of the led suit get -1.
 */
export function cardStrength(
  card: BalootCard,
  ledSuit: BalootSuit,
  mode: BalootMode,
  trump: BalootSuit | null,
): number {
  if (mode === 'hokum' && card.suit === trump) {
    return 100 + indexInHokumTrumpOrder(card.rank);
  }
  if (card.suit !== ledSuit) return -1;
  return indexInSunOrder(card.rank);
}

export function projectQaidFor(mode: BalootMode): Record<ProjectType, number> {
  return mode === 'sun' ? SUN_PROJECT_QAID : HOKUM_PROJECT_QAID;
}

export { BALOOT_RANKS, BALOOT_SUITS };
