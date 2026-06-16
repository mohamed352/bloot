import { GameDocument } from '../models/game';
import { isCardLegal } from './trick';

/**
 * Finds the lowest legal card for the current player to auto-play.
 * Returns null if no legal card found (shouldn't happen in a valid game).
 */
export function findLowestLegalCard(
  game: GameDocument,
  seatIndex: number,
): string | null {
  const hand = game.players[String(seatIndex)]?.hand ?? [];
  if (hand.length === 0) return null;

  // Sort cards by point value (ascending) to find "lowest"
  const sorted = [...hand].sort((a, b) => {
    const rankOrder: Record<string, number> = {
      '2': 0, '3': 1, '4': 2, '5': 3, '6': 4, '7': 5, '8': 6,
      '9': 7, J: 8, Q: 9, K: 10, '10': 11, A: 12,
    };
    const rankA = a.slice(0, -1);
    const rankB = b.slice(0, -1);
    return (rankOrder[rankA] ?? 0) - (rankOrder[rankB] ?? 0);
  });

  for (const card of sorted) {
    const legality = isCardLegal(game, seatIndex, card);
    if (legality.legal) {
      return card;
    }
  }

  return null;
}

/**
 * Determines what auto-action to take for the current player.
 */
export function determineAutoAction(
  game: GameDocument,
): { action: 'bid' | 'play' | 'claim' | null; payload?: string } {
  const seatIndex = game.turnIndex;

  if (game.status === 'bidding') {
    return { action: 'bid', payload: 'pass' };
  }

  if (game.status === 'playing') {
    const card = findLowestLegalCard(game, seatIndex);
    if (card) {
      return { action: 'play', payload: card };
    }
  }

  if (game.status === 'bonusClaim') {
    // Auto-claim no bonuses
    return { action: 'claim', payload: '[]' };
  }

  return { action: null };
}
