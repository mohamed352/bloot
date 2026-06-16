import { CardString, RANKS, SUITS, SUIT_CODES } from '../models/card';

/**
 * Creates a standard 52-card deck.
 * Card format: "AH" (Ace of Hearts), "10S" (10 of Spades)
 */
export function createDeck(): CardString[] {
  const deck: CardString[] = [];
  for (const suit of SUITS) {
    for (const rank of RANKS) {
      deck.push(`${rank}${SUIT_CODES[suit]}`);
    }
  }
  return deck;
}

/**
 * Fisher-Yates shuffle. Mutates and returns the deck.
 */
export function shuffle(deck: CardString[]): CardString[] {
  for (let i = deck.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [deck[i], deck[j]] = [deck[j], deck[i]];
  }
  return deck;
}
