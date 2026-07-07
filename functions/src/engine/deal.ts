// deal.ts
import { GameDocument, PlayerState } from '../models/game';
import { createDeck, shuffle } from './deck';

/**
 * Deals cards for a new round.
 * - 5 + 4 + 4 = 13 cards per player
 * - Face-up card is the last card dealt (to the dealer)
 * - Dealer index rotates each round
 */
export function dealRound(game: GameDocument): GameDocument {
  const deck = shuffle(createDeck());
  const dealPattern = [5, 4, 4];
  let deckIndex = 0;

  // Initialize empty hands
  for (const seat of ['0', '1', '2', '3']) {
    game.players[seat].hand = [];
    game.players[seat].takenCards = [];
    game.players[seat].tricksWon = 0;
    game.players[seat].bid = null;
    game.players[seat].bonuses = null;
    game.players[seat].isReady = false;
  }

  // Deal counter-clockwise in rounds of 5 + 4 + 4.
  // The player to the dealer's right is dealt first; the dealer is dealt last.
  // For each round, the last card is dealt to the dealer and becomes the face-up card.
  let faceUpCard: string | null = null;
  for (const count of dealPattern) {
    for (let offset = 1; offset <= 4; offset++) {
      const seat = String((game.dealerIndex + offset) % 4);
      const cards = deck.slice(deckIndex, deckIndex + count);
      game.players[seat].hand.push(...cards);
      deckIndex += count;
      if (offset === 4) {
        faceUpCard = cards[cards.length - 1];
      }
    }
  }

  game.faceUpCard = faceUpCard;

  // Reset trick state
  game.currentTrick = {
    trickNumber: 1,
    trickLeaderIndex: -1,
    leadingSuit: null,
    cards: { '0': null, '1': null, '2': null, '3': null },
  };

  game.roundTricksA = 0;
  game.roundTricksB = 0;
  game.status = 'bidding';

  // Turn starts with player to dealer's right
  game.turnIndex = (game.dealerIndex + 1) % 4;

  return game;
}

/**
 * Creates the initial game document from room data.
 */
export function createGameDocument(
  gameId: string,
  roomId: string,
  players: PlayerState[],
  targetScore = 152,
): GameDocument {
  const playersMap: Record<string, PlayerState> = {};
  players.forEach((p, i) => {
    playersMap[String(i)] = p;
  });

  const now = new Date();

  return {
    id: gameId,
    roomId,
    status: 'dealing',
    gameType: null,
    targetScore,
    currentRound: 1,
    dealerIndex: 0,
    turnIndex: 1,
    turnTimerStart: null,
    turnTimeLimit: 90,  // Must be >= Cloud Scheduler minimum interval (60s)
    trumpSuit: null,
    faceUpCard: null,
    hokmBidder: null,
    sunBidder: null,
    biddingTeam: null,
    teamAScore: 0,
    teamBScore: 0,
    roundTricksA: 0,
    roundTricksB: 0,
    currentTrick: {
      trickNumber: 1,
      trickLeaderIndex: -1,
      leadingSuit: null,
      cards: { '0': null, '1': null, '2': null, '3': null },
    },
    players: playersMap,
    playerUids: players.map((p) => p.uid),
    gameLog: [],
    createdAt: now as any,
    updatedAt: now as any,
    endedAt: null,
  };
}
