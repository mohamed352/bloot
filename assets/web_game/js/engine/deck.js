import { SUITS, RANKS } from "./constants.js";

export function makeDeck() {
  const deck = [];
  for (const s of SUITS) for (const r of RANKS) deck.push({ suit: s, rank: r });
  return deck;
}

export function cardKey(c) { return c.rank + c.suit; }
export function sameCard(a, b) { return a.suit === b.suit && a.rank === b.rank; }
