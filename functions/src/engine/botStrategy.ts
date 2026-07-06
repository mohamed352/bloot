import { GameDocument, Bid, BonusClaim } from '../models/game';
import { CardString, getSuit, getRank, getCardPoints } from '../models/card';
import { isCardLegal } from './trick';
import { detectAllBonuses } from './bonuses';

const RANK_ORDER: Record<string, number> = {
  '2': 0, '3': 1, '4': 2, '5': 3, '6': 4, '7': 5, '8': 6,
  '9': 7, J: 8, Q: 9, K: 10, '10': 11, A: 12,
};

/**
 * Chooses a bot bid based on hand strength.
 * - Hokm: bid when holding several trump cards.
 * - Sun: bid when holding a high overall point count and no one bid Hokm yet.
 * - Otherwise pass.
 */
export function chooseBid(game: GameDocument, seatIndex: number): Bid {
  const player = game.players[String(seatIndex)];
  const hand = player.hand;
  if (hand.length === 0) return 'pass';

  const existingBids = Object.values(game.players)
    .map((p) => p.bid)
    .filter((b): b is Bid => b !== null);
  const hasHokm = existingBids.includes('hokm');
  const hasSun = existingBids.includes('sun');

  const faceUpSuit = game.faceUpCard ? getSuit(game.faceUpCard) : null;
  const trumpCards = faceUpSuit
    ? hand.filter((c) => getSuit(c) === faceUpSuit)
    : [];
  const trumpPoints = trumpCards.reduce(
    (sum, c) => sum + getCardPoints(c, true),
    0,
  );
  const totalPoints = hand.reduce(
    (sum, c) => sum + getCardPoints(c, faceUpSuit ? getSuit(c) === faceUpSuit : false),
    0,
  );

  // Bid Hokm with a decent trump holding and no existing Hokm bid.
  if (!hasHokm && faceUpSuit && trumpCards.length >= 3 && trumpPoints >= 20) {
    return 'hokm';
  }

  // Bid Sun with a strong overall hand and no existing Sun/Hokm bid.
  if (!hasHokm && !hasSun && totalPoints >= 40) {
    return 'sun';
  }

  return 'pass';
}

/**
 * Chooses a legal card for a bot to play.
 * Simple strategy:
 * - If leading, play the lowest card.
 * - If partner is winning the trick, play the lowest legal card.
 * - Otherwise, play the lowest card that can win; if none, play the lowest.
 */
export function chooseCard(game: GameDocument, seatIndex: number): CardString | null {
  const hand = game.players[String(seatIndex)].hand;
  if (hand.length === 0) return null;

  const legalCards = hand.filter((c) => isCardLegal(game, seatIndex, c).legal);
  if (legalCards.length === 0) return null;

  const trick = game.currentTrick;
  const isLead = trick.leadingSuit === null;

  if (isLead) {
    return sortByPower(legalCards)[0];
  }

  const playedCards = Object.entries(trick.cards)
    .filter(([, c]) => c !== null)
    .map(([seat, c]) => ({ seat: parseInt(seat, 10), card: c as CardString }));

  const partnerSeat = (seatIndex + 2) % 4;
  const partnerIsWinning =
    playedCards.length > 0 &&
    trick.winnerSeat === undefined &&
    determineCurrentWinner(playedCards, game.trumpSuit, game.gameType === 'sun') === partnerSeat;

  const sorted = sortByPower(legalCards);

  if (partnerIsWinning) {
    return sorted[0];
  }

  // Try to win with the lowest winning card.
  const currentWinnerCard = winningCardSoFar(playedCards, game.trumpSuit, game.gameType === 'sun');
  if (currentWinnerCard) {
    const winningCards = sorted.filter((c) =>
      cardBeats(c, currentWinnerCard, trick.leadingSuit!, game.trumpSuit ?? undefined),
    );
    if (winningCards.length > 0) {
      return winningCards[0];
    }
  }

  return sorted[0];
}

/**
 * Auto-detects and claims all valid bonuses for a bot hand.
 */
export function chooseBonuses(hand: CardString[]): BonusClaim[] {
  return detectAllBonuses(hand);
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

function sortByPower(cards: CardString[]): CardString[] {
  return [...cards].sort((a, b) => {
    const powerA = rankPower(a);
    const powerB = rankPower(b);
    return powerA - powerB;
  });
}

function rankPower(card: CardString): number {
  return RANK_ORDER[getRank(card)] ?? 0;
}

function cardBeats(
  candidate: CardString,
  current: CardString,
  leadingSuit: string,
  trumpSuit?: string,
): boolean {
  const candSuit = getSuit(candidate);
  const currSuit = getSuit(current);

  if (trumpSuit) {
    if (candSuit === trumpSuit && currSuit !== trumpSuit) return true;
    if (candSuit !== trumpSuit && currSuit === trumpSuit) return false;
  }

  if (candSuit === leadingSuit && currSuit !== leadingSuit) return true;
  if (candSuit !== leadingSuit && currSuit === leadingSuit) return false;

  return rankPower(candidate) > rankPower(current);
}

function winningCardSoFar(
  played: { seat: number; card: CardString }[],
  trumpSuit: string | null,
  isSun: boolean,
): CardString | null {
  if (played.length === 0) return null;
  const leadSuit = getSuit(played[0].card);
  let winner = played[0];
  for (let i = 1; i < played.length; i++) {
    const current = played[i];
    if (cardBeats(current.card, winner.card, leadSuit, trumpSuit ?? undefined)) {
      winner = current;
    }
  }
  return winner.card;
}

function determineCurrentWinner(
  played: { seat: number; card: CardString }[],
  trumpSuit: string | null,
  isSun: boolean,
): number {
  if (played.length === 0) return -1;
  const leadSuit = getSuit(played[0].card);
  let winner = played[0];
  for (let i = 1; i < played.length; i++) {
    const current = played[i];
    if (cardBeats(current.card, winner.card, leadSuit, trumpSuit ?? undefined)) {
      winner = current;
    }
  }
  return winner.seat;
}
