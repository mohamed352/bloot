import { findLowestLegalCard, determineAutoAction } from '../engine/autoPlay';
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

describe('findLowestLegalCard', () => {
  it('returns lowest legal card when leading', () => {
    const game = createGameDocument('g1', 'r1', createMockPlayers());
    dealRound(game);
    game.status = 'playing';
    game.turnIndex = 0;
    game.players['0'].hand = ['AH', '2H', '3D'];

    const card = findLowestLegalCard(game, 0);
    expect(card).toBe('2H'); // 2 is lower than A
  });

  it('must follow suit when not leading', () => {
    const game = createGameDocument('g1', 'r1', createMockPlayers());
    dealRound(game);
    game.status = 'playing';
    game.turnIndex = 0;
    game.currentTrick.leadingSuit = 'hearts';
    game.currentTrick.trickLeaderIndex = 1;
    game.players['0'].hand = ['AH', '2H', '3D'];

    const card = findLowestLegalCard(game, 0);
    expect(card).toBe('2H'); // must follow hearts, 2 < A
  });

  it('can play any card when void', () => {
    const game = createGameDocument('g1', 'r1', createMockPlayers());
    dealRound(game);
    game.status = 'playing';
    game.turnIndex = 0;
    game.currentTrick.leadingSuit = 'hearts';
    game.currentTrick.trickLeaderIndex = 1;
    game.players['0'].hand = ['3D', '4C', '5S'];

    const card = findLowestLegalCard(game, 0);
    expect(card).toBe('3D'); // void in hearts, lowest overall
  });

  it('returns null for empty hand', () => {
    const game = createGameDocument('g1', 'r1', createMockPlayers());
    dealRound(game);
    game.players['0'].hand = [];
    expect(findLowestLegalCard(game, 0)).toBeNull();
  });
});

describe('determineAutoAction', () => {
  it('auto-passes during bidding', () => {
    const game = createGameDocument('g1', 'r1', createMockPlayers());
    dealRound(game);
    const action = determineAutoAction(game);
    expect(action.action).toBe('bid');
    expect(action.payload).toBe('pass');
  });

  it('auto-plays lowest card during playing', () => {
    const game = createGameDocument('g1', 'r1', createMockPlayers());
    dealRound(game);
    game.status = 'playing';
    game.turnIndex = 0;
    game.players['0'].hand = ['AH', '2H', '3D'];
    const action = determineAutoAction(game);
    expect(action.action).toBe('play');
    expect(action.payload).toBe('2H');
  });

  it('auto-claims no bonuses during bonusClaim', () => {
    const game = createGameDocument('g1', 'r1', createMockPlayers());
    dealRound(game);
    game.status = 'bonusClaim';
    const action = determineAutoAction(game);
    expect(action.action).toBe('claim');
  });
});
