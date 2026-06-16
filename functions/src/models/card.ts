export const SUITS = ['hearts', 'diamonds', 'clubs', 'spades'] as const;
export type Suit = (typeof SUITS)[number];

export const SUIT_CODES: Record<Suit, string> = {
  hearts: 'H',
  diamonds: 'D',
  clubs: 'C',
  spades: 'S',
};

export const CODE_TO_SUIT: Record<string, Suit> = {
  H: 'hearts',
  D: 'diamonds',
  C: 'clubs',
  S: 'spades',
};

export const RANKS = [
  '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A',
] as const;
export type Rank = (typeof RANKS)[number];

/** Card string format: "AH" = Ace of Hearts, "10S" = 10 of Spades */
export type CardString = string;

export function parseCard(card: CardString): { suit: Suit; rank: Rank } {
  const suitCode = card.slice(-1);
  const rankStr = card.slice(0, -1);
  const suit = CODE_TO_SUIT[suitCode];
  if (!suit) throw new Error(`Invalid card suit code: ${suitCode}`);
  if (!RANKS.includes(rankStr as Rank)) throw new Error(`Invalid card rank: ${rankStr}`);
  return { suit, rank: rankStr as Rank };
}

export function cardToString(suit: Suit, rank: Rank): CardString {
  return `${rank}${SUIT_CODES[suit]}`;
}

export function getSuit(card: CardString): Suit {
  return parseCard(card).suit;
}

export function getRank(card: CardString): Rank {
  return parseCard(card).rank;
}

/** Non-trump / Sun point values */
const NON_TRUMP_POINTS: Record<Rank, number> = {
  A: 11,
  '10': 10,
  K: 4,
  Q: 3,
  J: 2,
  '9': 0,
  '8': 0,
  '7': 0,
  '6': 0,
  '5': 0,
  '4': 0,
  '3': 0,
  '2': 0,
};

/** Trump point values (Hokm only) */
const TRUMP_POINTS: Record<Rank, number> = {
  J: 20,
  '9': 14,
  A: 11,
  '10': 10,
  K: 4,
  Q: 3,
  '8': 0,
  '7': 0,
  '6': 0,
  '5': 0,
  '4': 0,
  '3': 0,
  '2': 0,
};

export function getCardPoints(card: CardString, isTrump: boolean): number {
  const { rank } = parseCard(card);
  return isTrump ? TRUMP_POINTS[rank] : NON_TRUMP_POINTS[rank];
}

/** Rank order for comparison (higher index = higher rank) */
const RANK_ORDER_NON_TRUMP: Record<Rank, number> = {
  '2': 0,
  '3': 1,
  '4': 2,
  '5': 3,
  '6': 4,
  '7': 5,
  '8': 6,
  '9': 7,
  J: 8,
  Q: 9,
  K: 10,
  '10': 11,
  A: 12,
};

const RANK_ORDER_TRUMP: Record<Rank, number> = {
  '2': 0,
  '3': 1,
  '4': 2,
  '5': 3,
  '6': 4,
  '7': 5,
  '8': 6,
  Q: 7,
  K: 8,
  '10': 9,
  A: 10,
  '9': 11,
  J: 12,
};

export function compareRanks(a: Rank, b: Rank, isTrump: boolean): number {
  const order = isTrump ? RANK_ORDER_TRUMP : RANK_ORDER_NON_TRUMP;
  return order[a] - order[b];
}

export function isHigherRank(winner: Rank, loser: Rank, isTrump: boolean): boolean {
  return compareRanks(winner, loser, isTrump) > 0;
}
