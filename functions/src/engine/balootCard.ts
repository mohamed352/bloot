export const BALOOT_SUITS: BalootSuit[] = ['spades', 'hearts', 'diamonds', 'clubs'];
export const BALOOT_RANKS: BalootRank[] = ['7', '8', '9', '10', 'J', 'Q', 'K', 'A'];

export type BalootSuit = 'spades' | 'hearts' | 'diamonds' | 'clubs';
export type BalootRank = '7' | '8' | '9' | '10' | 'J' | 'Q' | 'K' | 'A';

export const SUIT_SYMBOLS: Record<BalootSuit, string> = {
  spades: '♠',
  hearts: '♥',
  diamonds: '♦',
  clubs: '♣',
};

const SUIT_CODES: Record<BalootSuit, string> = {
  spades: 'S',
  hearts: 'H',
  diamonds: 'D',
  clubs: 'C',
};

export class BalootCard {
  readonly suit: BalootSuit;
  readonly rank: BalootRank;

  constructor(suit: BalootSuit, rank: BalootRank) {
    this.suit = suit;
    this.rank = rank;
  }

  static fromString(key: string): BalootCard {
    const trimmed = key.trim();
    // Try the symbolic form first: A♠, 10♦
    for (const suit of BALOOT_SUITS) {
      const sym = SUIT_SYMBOLS[suit];
      if (trimmed.endsWith(sym)) {
        const rankPart = trimmed.slice(0, -sym.length);
        const rank = parseRank(rankPart);
        return new BalootCard(suit, rank);
      }
    }
    // Fallback to code form: AS, 10D
    if (trimmed.length >= 2) {
      const rankPart = trimmed.slice(0, -1);
      const code = trimmed.slice(-1).toUpperCase();
      const suit = Object.entries(SUIT_CODES).find(([, v]) => v === code)?.[0] as BalootSuit | undefined;
      if (suit) {
        return new BalootCard(suit, parseRank(rankPart));
      }
    }
    throw new Error(`Invalid BalootCard key: ${key}`);
  }

  get key(): string {
    return `${this.rank}${SUIT_SYMBOLS[this.suit]}`;
  }

  get code(): string {
    return `${this.rank}${SUIT_CODES[this.suit]}`;
  }

  equals(other: BalootCard): boolean {
    return this.suit === other.suit && this.rank === other.rank;
  }

  toString(): string {
    return this.key;
  }
}

function parseRank(part: string): BalootRank {
  const p = part.trim();
  if (p === '10') return '10';
  if (p === 'J' || p === 'j') return 'J';
  if (p === 'Q' || p === 'q') return 'Q';
  if (p === 'K' || p === 'k') return 'K';
  if (p === 'A' || p === 'a') return 'A';
  if (p === '7') return '7';
  if (p === '8') return '8';
  if (p === '9') return '9';
  throw new Error(`Invalid Baloot rank: ${part}`);
}
