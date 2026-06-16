import { GameDocument, Bid } from '../models/game';
import { getSuit, parseCard } from '../models/card';

/**
 * Validates whether a player can place a specific bid.
 */
export function validateBid(
  game: GameDocument,
  seatIndex: number,
  bid: Bid,
): { valid: boolean; reason?: string } {
  if (game.status !== 'bidding') {
    return { valid: false, reason: 'Not in bidding phase' };
  }

  if (game.turnIndex !== seatIndex) {
    return { valid: false, reason: 'Not your turn' };
  }

  if (bid === 'pass') {
    return { valid: true };
  }

  const seatStr = String(seatIndex);
  const player = game.players[seatStr];
  if (!player) {
    return { valid: false, reason: 'Player not found' };
  }

  // Check if a higher or equal bid already exists
  const existingBids = Object.values(game.players)
    .map((p) => p.bid)
    .filter((b): b is Bid => b !== null);

  const hasHokm = existingBids.includes('hokm');
  const hasSun = existingBids.includes('sun');

  if (bid === 'sun') {
    if (hasHokm) {
      return { valid: false, reason: 'Cannot bid Sun after Hokm' };
    }
    if (hasSun) {
      return { valid: false, reason: 'Cannot bid Sun after Sun' };
    }
    return { valid: true };
  }

  if (bid === 'hokm') {
    if (hasHokm) {
      return { valid: false, reason: 'Hokm already bid' };
    }

    // Must hold at least one card of the face-up suit
    if (!game.faceUpCard) {
      return { valid: false, reason: 'No face-up card' };
    }

    const faceUpSuit = getSuit(game.faceUpCard);
    const hasSuit = player.hand.some((card) => getSuit(card) === faceUpSuit);

    if (!hasSuit) {
      return {
        valid: false,
        reason: `Must hold at least one ${faceUpSuit} card to bid Hokm`,
      };
    }

    return { valid: true };
  }

  return { valid: false, reason: 'Invalid bid' };
}

/**
 * Checks if all players have bid, and resolves the bidding.
 * Returns the game type and bidder, or indicates a re-deal is needed.
 */
export function resolveBidding(game: GameDocument): {
  resolved: boolean;
  gameType?: 'sun' | 'hokm';
  bidderIndex?: number;
  redeal?: boolean;
} {
  const allBids = Object.entries(game.players).map(([seat, p]) => ({
    seatIndex: parseInt(seat, 10),
    bid: p.bid,
  }));

  // Check if everyone has bid
  if (allBids.some((b) => b.bid === null)) {
    return { resolved: false };
  }

  const allPass = allBids.every((b) => b.bid === 'pass');
  if (allPass) {
    return { resolved: true, redeal: true };
  }

  // Find Hokm bidders (first one wins if multiple)
  const hokmBidders = allBids
    .filter((b) => b.bid === 'hokm')
    .sort((a, b) => a.seatIndex - b.seatIndex);

  if (hokmBidders.length > 0) {
    const winner = hokmBidders[0];
    return {
      resolved: true,
      gameType: 'hokm',
      bidderIndex: winner.seatIndex,
    };
  }

  // Find Sun bidders (last one wins)
  const sunBidders = allBids
    .filter((b) => b.bid === 'sun')
    .sort((a, b) => a.seatIndex - b.seatIndex);

  if (sunBidders.length > 0) {
    const winner = sunBidders[sunBidders.length - 1];
    return {
      resolved: true,
      gameType: 'sun',
      bidderIndex: winner.seatIndex,
    };
  }

  return { resolved: false };
}

/**
 * Applies the resolved bidding to the game document.
 */
export function applyBiddingResult(
  game: GameDocument,
  result: Exclude<ReturnType<typeof resolveBidding>, { resolved: false }>,
): GameDocument {
  if (result.redeal) {
    // Rotate dealer and re-deal
    game.dealerIndex = (game.dealerIndex + 1) % 4;
    game.status = 'dealing';
    return game;
  }

  if (result.gameType === 'hokm') {
    game.gameType = 'hokm';
    game.hokmBidder = result.bidderIndex ?? null;
    game.sunBidder = null;
    if (game.faceUpCard) {
      game.trumpSuit = parseCard(game.faceUpCard).suit;
    }
    game.biddingTeam = game.players[String(result.bidderIndex)]?.team ?? null;
    game.turnIndex = result.bidderIndex ?? 0;
    game.status = 'bonusClaim';
  } else if (result.gameType === 'sun') {
    game.gameType = 'sun';
    game.sunBidder = result.bidderIndex ?? null;
    game.hokmBidder = null;
    game.trumpSuit = null;
    game.biddingTeam = game.players[String(result.bidderIndex)]?.team ?? null;
    game.turnIndex = result.bidderIndex ?? 0;
    game.status = 'playing';
  }

  game.currentTrick.trickLeaderIndex = game.turnIndex;

  return game;
}
