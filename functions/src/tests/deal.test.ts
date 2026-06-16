import { createGameDocument, dealRound } from '../engine/deal';
import { PlayerState } from '../models/game';

function createMockPlayers(): PlayerState[] {
  return [
    { uid: 'p0', displayName: 'Player0', avatarUrl: '', team: 'A', hand: [], takenCards: [], tricksWon: 0, bid: null, isReady: false, bonuses: null, isConnected: true },
    { uid: 'p1', displayName: 'Player1', avatarUrl: '', team: 'B', hand: [], takenCards: [], tricksWon: 0, bid: null, isReady: false, bonuses: null, isConnected: true },
    { uid: 'p2', displayName: 'Player2', avatarUrl: '', team: 'A', hand: [], takenCards: [], tricksWon: 0, bid: null, isReady: false, bonuses: null, isConnected: true },
    { uid: 'p3', displayName: 'Player3', avatarUrl: '', team: 'B', hand: [], takenCards: [], tricksWon: 0, bid: null, isReady: false, bonuses: null, isConnected: true },
  ];
}

describe('dealRound', () => {
  it('deals exactly 13 cards to each player', () => {
    const game = createGameDocument('g1', 'r1', createMockPlayers());
    dealRound(game);

    for (let i = 0; i < 4; i++) {
      expect(game.players[String(i)].hand).toHaveLength(13);
    }
  });

  it('deals no duplicate cards across players', () => {
    const game = createGameDocument('g1', 'r1', createMockPlayers());
    dealRound(game);

    const allCards: string[] = [];
    for (let i = 0; i < 4; i++) {
      allCards.push(...game.players[String(i)].hand);
    }
    expect(allCards).toHaveLength(52);
    expect(new Set(allCards).size).toBe(52);
  });

  it('sets faceUpCard to the last dealt card', () => {
    const game = createGameDocument('g1', 'r1', createMockPlayers());
    dealRound(game);

    expect(game.faceUpCard).toBeDefined();
    expect(game.faceUpCard).toMatch(/^(2|3|4|5|6|7|8|9|10|J|Q|K|A)[HDCS]$/);
  });

  it('resets player state for new round', () => {
    const game = createGameDocument('g1', 'r1', createMockPlayers());
    game.players['0'].tricksWon = 5;
    game.players['0'].bid = 'sun';
    game.players['0'].takenCards = ['AH'];

    dealRound(game);

    expect(game.players['0'].tricksWon).toBe(0);
    expect(game.players['0'].bid).toBeNull();
    expect(game.players['0'].takenCards).toEqual([]);
  });

  it('sets status to bidding', () => {
    const game = createGameDocument('g1', 'r1', createMockPlayers());
    dealRound(game);
    expect(game.status).toBe('bidding');
  });

  it('sets turn to player right of dealer', () => {
    const game = createGameDocument('g1', 'r1', createMockPlayers());
    game.dealerIndex = 0;
    dealRound(game);
    expect(game.turnIndex).toBe(1);

    game.dealerIndex = 3;
    dealRound(game);
    expect(game.turnIndex).toBe(0);
  });
});
