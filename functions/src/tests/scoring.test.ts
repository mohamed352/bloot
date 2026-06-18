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

    // A: hearts (30) + diamonds (30) + KC (4) - 2H (0) = 64
    // B: clubs (30) + spades (30) + 2H (0) - KC (4) = 56
    game.players['0'].takenCards = ['AH', 'KH', 'QH', 'JH', '10H', '9H', '8H', '7H', '6H', '5H', '4H', '3H', 'AD'];
    game.players['2'].takenCards = ['KD', 'QD', 'JD', '10D', '9D', '8D', '7D', '6D', '5D', '4D', '3D', '2D', 'KC'];
    game.players['1'].takenCards = ['2H', 'QC', 'JC', '10C', '9C', '8C', '7C', '6C', '5C', '4C', '3C', '2C', 'KS'];
    game.players['3'].takenCards = ['AS', 'QS', 'JS', '10S', '9S', '8S', '7S', '6S', '5S', '4S', '3S', '2S', 'AC'];

    const result = calculateRoundScore(game);
    expect(result.fell).toBeNull();
    expect(result.teamAPoints).toBe(64);
    expect(result.teamBPoints).toBe(56);
  });

  it('Sun: bidding team <= 60, they fall', () => {
    const game = createGameDocument('g1', 'r1', createMockPlayers());
    dealRound(game);
    game.gameType = 'sun';
    game.biddingTeam = 'A';

    // A: hearts + diamonds (60) - 10H (10) + 2C (0) = 50
    // B: clubs + spades (60) + 10H (10) - 2C (0) = 70
    game.players['0'].takenCards = ['AH', 'KH', 'QH', 'JH', '9H', '8H', '7H', '6H', '5H', '4H', '3H', '2H', 'AD'];
    game.players['2'].takenCards = ['KD', 'QD', 'JD', '10D', '9D', '8D', '7D', '6D', '5D', '4D', '3D', '2D', '2C'];
    game.players['1'].takenCards = ['KC', 'QC', 'JC', '10C', '9C', '8C', '7C', '6C', '5C', '4C', '3C', '10H', 'KS'];
    game.players['3'].takenCards = ['AS', 'QS', 'JS', '10S', '9S', '8S', '7S', '6S', '5S', '4S', '3S', '2S', 'AC'];

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

    // A: hearts (62) + diamonds (30) = 92
    // B: clubs (30) + spades (30) = 60
    game.players['0'].takenCards = ['AH', 'KH', 'QH', 'JH', '10H', '9H', '8H', '7H', '6H', '5H', '4H', '3H', '2H'];
    game.players['2'].takenCards = ['AD', 'KD', 'QD', 'JD', '10D', '9D', '8D', '7D', '6D', '5D', '4D', '3D', '2D'];
    game.players['1'].takenCards = ['AC', 'KC', 'QC', 'JC', '10C', '9C', '8C', '7C', '6C', '5C', '4C', '3C', '2C'];
    game.players['3'].takenCards = ['AS', 'KS', 'QS', 'JS', '10S', '9S', '8S', '7S', '6S', '5S', '4S', '3S', '2S'];

    const result = calculateRoundScore(game);
    expect(result.fell).toBeNull();
    expect(result.teamAPoints).toBe(92);
    expect(result.teamBPoints).toBe(60);
  });

  it('Hokm: bidder falls, opponents get 152 + bonuses', () => {
    const game = createGameDocument('g1', 'r1', createMockPlayers());
    dealRound(game);
    game.gameType = 'hokm';
    game.trumpSuit = 'hearts';
    game.biddingTeam = 'A';

    // A: hearts only = 62
    // B: diamonds + clubs + spades = 90
    game.players['0'].takenCards = ['AH', 'KH', 'QH', 'JH', '10H', '9H', '8H', '7H', '6H', '5H', '4H', '3H', '2H'];
    game.players['2'].takenCards = [];
    game.players['1'].takenCards = ['AD', 'KD', 'QD', 'JD', '10D', '9D', '8D', '7D', '6D', '5D', '4D', '3D', '2D'];
    game.players['3'].takenCards = ['AC', 'KC', 'QC', 'JC', '10C', '9C', '8C', '7C', '6C', '5C', '4C', '3C', '2C', 'AS', 'KS', 'QS', 'JS', '10S', '9S', '8S', '7S', '6S', '5S', '4S', '3S', '2S'];

    const result = calculateRoundScore(game);
    expect(result.fell).toBe('A');
    expect(result.teamAPoints).toBe(0);
    expect(result.teamBPoints).toBe(152);
  });

  it('Hokm fall includes raw bonuses from both teams', () => {
    const game = createGameDocument('g1', 'r1', createMockPlayers());
    dealRound(game);
    game.gameType = 'hokm';
    game.trumpSuit = 'hearts';
    game.biddingTeam = 'A';

    game.players['0'].takenCards = ['AH', 'KH', 'QH', 'JH', '10H', '9H', '8H', '7H', '6H', '5H', '4H', '3H', '2H'];
    game.players['2'].takenCards = [];
    game.players['1'].takenCards = ['AD', 'KD', 'QD', 'JD', '10D', '9D', '8D', '7D', '6D', '5D', '4D', '3D', '2D'];
    game.players['3'].takenCards = ['AC', 'KC', 'QC', 'JC', '10C', '9C', '8C', '7C', '6C', '5C', '4C', '3C', '2C', 'AS', 'KS', 'QS', 'JS', '10S', '9S', '8S', '7S', '6S', '5S', '4S', '3S', '2S'];

    // Award raw bonus claims to both teams; when A falls, B receives all bonuses.
    game.players['0'].bonuses = [{ type: 'bnaga', points: 20, cards: ['AH', 'KH', 'QH'], description: 'Bnaga' }];
    game.players['1'].bonuses = [{ type: 'mosal', points: 50, cards: ['AD', 'KD', 'QD'], description: 'Mosal' }];

    const result = calculateRoundScore(game);
    expect(result.fell).toBe('A');
    expect(result.teamAPoints).toBe(0);
    expect(result.teamBPoints).toBe(152 + 20 + 50);
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
