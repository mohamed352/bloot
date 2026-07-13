import { BalootCard, BALOOT_RANKS, BALOOT_SUITS } from './balootCard';

export interface BalootDealResult {
  hands: BalootCard[][];
  topCard: BalootCard;
  rest: BalootCard[];
  firstPlayer: number;
}

export class BalootDeck {
  private rng: () => number;

  constructor(rng: () => number = Math.random) {
    this.rng = rng;
  }

  static makeDeck(): BalootCard[] {
    const deck: BalootCard[] = [];
    for (const suit of BALOOT_SUITS) {
      for (const rank of BALOOT_RANKS) {
        deck.push(new BalootCard(suit, rank));
      }
    }
    return deck;
  }

  shuffle<T>(cards: T[]): T[] {
    const result = [...cards];
    for (let i = result.length - 1; i > 0; i--) {
      const j = Math.floor(this.rng() * (i + 1));
      [result[i], result[j]] = [result[j], result[i]];
    }
    return result;
  }

  shuffledDeck(): BalootCard[] {
    return this.shuffle(BalootDeck.makeDeck());
  }
}

/**
 * Performs the Saudi Baloot 2-phase deal:
 * - Phase 1: 5 cards to each player.
 * - Face-up card is revealed.
 * - Phase 2: remaining 11 cards distributed so each player ends with 8.
 */
export function dealBalootHands(deck: BalootDeck, dealer: number): BalootDealResult {
  const d = deck.shuffledDeck();
  const hands: BalootCard[][] = [[], [], [], []];
  // Bidding starts with the dealer (not the player to the dealer's right), per
  // the house rule set: the dealer is the first to choose Sun/Hokm/Pass.
  const firstPlayer = dealer;

  let di = 0;
  for (let round = 0; round < 5; round++) {
    for (let p = 0; p < 4; p++) {
      hands[(firstPlayer + p) % 4].push(d[di++]);
    }
  }

  const topCard = d[di++];
  const rest = d.slice(di); // 11 cards

  return { hands, topCard, rest, firstPlayer };
}
