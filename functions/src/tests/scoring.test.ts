import { calculateRoundScore, checkGameEnd, countCardPoints } from '../engine/scoring';
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

describe('countCardPoints', () => {
  it('counts non-trump points correctly', () => {
    expect(countCardPoints(['AH', '10D', 'KC'], null)).toBe(25); // 11 + 10 + 4
  });

  it('counts trump points correctly', () => {
    expect(countCardPoints(['JS', '9S', 'AS'], 'spades')).toBe(45); // 20 + 14 + 11
  });

  it('counts mixed trump and non-trump', () => {
    expect(countCardPoints(['JS', 'AH', '10D'], 'spades')).toBe(41); // 20 + 11 + 10
  });
});

describe('calculateRoundScore', () => {
  it('Sun: bidding team > 60, both keep points', () => {
    const game = createGameDocument('g1', 'r1', createMockPlayers());
    dealRound(game);
    game.gameType = 'sun';
    game.biddingTeam = 'A';
    game.players['0'].takenCards = ['AH', '10H', 'KH', 'QH', 'JH', '9H', '8H'];
    game.players['2'].takenCards = ['AD', '10D', 'KD', 'AC', '10C'];
    game.players['1'].takenCards = [];
    game.players['3'].takenCards = ['AS', '10S', 'KS', 'QS'];

    const result = calculateRoundScore(game);
    expect(result.fell).toBeNull();
    expect(result.teamAPoints).toBeGreaterThan(60);
    expect(result.teamBPoints).toBeGreaterThan(0);
  });

  it('Sun: bidding team <= 60, they fall', () => {
    const game = createGameDocument('g1', 'r1', createMockPlayers());
    dealRound(game);
    game.gameType = 'sun';
    game.biddingTeam = 'A';
    // Distribute all 52 cards. Team A gets ~25% of points (30 pts), Team B gets ~75% (90 pts)
    // After normalization: A = 30, B = 90. A falls.
    game.players['0'].takenCards = ['AH', '10H', 'KH', 'QH', 'JH', '9H', '8H'];
    game.players['2'].takenCards = ['7H', '6H', '5H', '4H', '3H', '2H'];
    game.players['1'].takenCards = ['AD', 'KD', 'QD', 'JD', '10D', '9D', '8D', '7D', '6D', '5D', '4D', '3D', '2D'];
    game.players['3'].takenCards = ['AS', 'KS', 'QS', 'JS', '10S', '9S', '8S', '7S', '6S', '5S', '4S', '3S', '2S', 'AC', 'KC', 'QC', 'JC', '10C', '9C', '8C', '7C', '6C', '5C', '4C', '3C', '2C'];

    const result = calculateRoundScore(game);
    expect(result.fell).toBe('A');
    expect(result.teamAPoints).toBe(0);
    expect(result.teamBPoints).toBe(120);
  });

  it('Hokm: bidder wins, both keep points', () => {
    const game = createGameDocument('g1', 'r1', createMockPlayers());
    dealRound(game);
    game.gameType = 'hokm';
    game.trumpSuit = 'hearts';
    game.biddingTeam = 'A';
    game.players['0'].takenCards = ['AH', 'JH', '9H', '10H', 'KH'];
    game.players['2'].takenCards = ['AD', 'KD', 'QD', 'JD'];
    game.players['1'].takenCards = ['AC', '10C'];
    game.players['3'].takenCards = ['AS', 'KS'];

    const result = calculateRoundScore(game);
    expect(result.fell).toBeNull();
    expect(result.teamAPoints).toBeGreaterThan(result.teamBPoints);
  });

  it('Hokm: bidder falls, opponents get 152 + bonuses', () => {
    const game = createGameDocument('g1', 'r1', createMockPlayers());
    dealRound(game);
    game.gameType = 'hokm';
    game.trumpSuit = 'hearts';
    game.biddingTeam = 'A';
    // A takes very little, B takes most
    game.players['0'].takenCards = ['AH'];
    game.players['2'].takenCards = ['10H'];
    game.players['1'].takenCards = ['JH', '9H', 'KH', 'QH'];
    game.players['3'].takenCards = ['AD', 'KD', 'QD', 'JD', '10D', '9D', '8D'];

    const result = calculateRoundScore(game);
    expect(result.fell).toBe('A');
    expect(result.teamAPoints).toBe(0);
    expect(result.teamBPoints).toBeGreaterThanOrEqual(152);
  });
});

describe('checkGameEnd', () => {
  it('returns A when Team A reaches target', () => {
    expect(checkGameEnd(152, 100, 152)).toBe('A');
    expect(checkGameEnd(160, 100, 152)).toBe('A');
  });

  it('returns B when Team B reaches target', () => {
    expect(checkGameEnd(100, 152, 152)).toBe('B');
    expect(checkGameEnd(100, 200, 152)).toBe('B');
  });

  it('returns null when neither reached target', () => {
    expect(checkGameEnd(100, 100, 152)).toBeNull();
    expect(checkGameEnd(0, 0, 152)).toBeNull();
  });
});
