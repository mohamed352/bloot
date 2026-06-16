import { GameDocument } from '../models/game';
import { CardString, getSuit, getRank, isHigherRank } from '../models/card';

/**
 * Checks if a card play is legal according to Baloot rules.
 */
export function isCardLegal(
  game: GameDocument,
  seatIndex: number,
  card: CardString,
): { legal: boolean; reason?: string } {
  if (game.status !== 'playing') {
    return { legal: false, reason: 'Not in playing phase' };
  }

  if (game.turnIndex !== seatIndex) {
    return { legal: false, reason: 'Not your turn' };
  }

  const seatStr = String(seatIndex);
  const player = game.players[seatStr];
  if (!player) {
    return { legal: false, reason: 'Player not found' };
  }

  if (!player.hand.includes(card)) {
    return { legal: false, reason: 'Card not in hand' };
  }

  const trick = game.currentTrick;
  const isLead = trick.leadingSuit === null;

  if (isLead) {
    return { legal: true };
  }

  const ledSuit = trick.leadingSuit;
  const cardSuit = getSuit(card);

  // Must follow suit if possible
  const hasLedSuit = player.hand.some((c) => getSuit(c) === ledSuit);
  if (hasLedSuit && cardSuit !== ledSuit) {
    return { legal: false, reason: `Must follow suit: ${ledSuit}` };
  }

  return { legal: true };
}

/**
 * Determines the winner of a completed trick.
 * Returns the seat index of the winner.
 */
export function determineTrickWinner(
  trickCards: { seat: number; card: CardString }[],
  trumpSuit: string | null,
  isSunMode: boolean,
): number {
  if (trickCards.length !== 4) {
    throw new Error('Trick must have exactly 4 cards');
  }

  const leadSuit = getSuit(trickCards[0].card);

  // Sun mode: no trump, highest of led suit wins
  if (isSunMode || trumpSuit === null) {
    const validCards = trickCards.filter((c) => getSuit(c.card) === leadSuit);
    return validCards.reduce((winner, current) =>
      isHigherRank(getRank(current.card), getRank(winner.card), false)
        ? current
        : winner,
    ).seat;
  }

  // Hokm mode: check for trumps
  const trumps = trickCards.filter((c) => getSuit(c.card) === trumpSuit);
  if (trumps.length > 0) {
    return trumps.reduce((winner, current) =>
      isHigherRank(getRank(current.card), getRank(winner.card), true)
        ? current
        : winner,
    ).seat;
  }

  // No trumps: highest of led suit wins
  const validCards = trickCards.filter((c) => getSuit(c.card) === leadSuit);
  return validCards.reduce((winner, current) =>
    isHigherRank(getRank(current.card), getRank(winner.card), false)
      ? current
      : winner,
  ).seat;
}

/**
 * Plays a card onto the current trick.
 * Returns true if the trick is now complete (4 cards played).
 */
export function playCardOntoTrick(
  game: GameDocument,
  seatIndex: number,
  card: CardString,
): { trickComplete: boolean; winnerSeat?: number } {
  const seatStr = String(seatIndex);
  const trick = game.currentTrick;

  // Remove card from hand
  const hand = game.players[seatStr].hand;
  const cardIndex = hand.indexOf(card);
  if (cardIndex >= 0) {
    hand.splice(cardIndex, 1);
  }

  // Place on trick
  trick.cards[seatStr] = card;

  // Set leading suit if leading
  if (trick.leadingSuit === null) {
    trick.leadingSuit = getSuit(card);
    trick.trickLeaderIndex = seatIndex;
  }

  // Check if trick is complete
  const playedCards = Object.values(trick.cards).filter((c): c is CardString => c !== null);
  if (playedCards.length === 4) {
    const trickEntries = Object.entries(trick.cards)
      .filter(([, c]) => c !== null)
      .map(([seat, c]) => ({ seat: parseInt(seat, 10), card: c as CardString }));

    const winner = determineTrickWinner(
      trickEntries,
      game.trumpSuit,
      game.gameType === 'sun',
    );

    // Update winner's trick count and taken cards
    const winnerStr = String(winner);
    const winnerTeam = game.players[winnerStr].team;
    game.players[winnerStr].tricksWon += 1;

    // Record winner on the trick so clients can show the trick-end state.
    trick.winnerSeat = winner;

    // Winner takes all 4 cards from the trick
    const trickCards = Object.values(trick.cards).filter((c): c is CardString => c !== null);
    game.players[winnerStr].takenCards.push(...trickCards);

    if (winnerTeam === 'A') {
      game.roundTricksA += 1;
    } else {
      game.roundTricksB += 1;
    }

    return { trickComplete: true, winnerSeat: winner };
  }

  // Advance turn
  game.turnIndex = (seatIndex + 1) % 4;

  return { trickComplete: false };
}

/**
 * Clears the current trick and prepares for the next one.
 */
export function startNextTrick(game: GameDocument, winnerSeat: number): GameDocument {
  game.currentTrick = {
    trickNumber: game.currentTrick.trickNumber + 1,
    trickLeaderIndex: winnerSeat,
    leadingSuit: null,
    cards: { '0': null, '1': null, '2': null, '3': null },
  };
  game.turnIndex = winnerSeat;
  game.status = 'playing';
  return game;
}
