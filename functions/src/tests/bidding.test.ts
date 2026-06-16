import { validateBid, resolveBidding, applyBiddingResult } from '../engine/bidding';
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

describe('validateBid', () => {
  it('allows Pass at any time', () => {
    const game = createGameDocument('g1', 'r1', createMockPlayers());
    dealRound(game);
    const result = validateBid(game, game.turnIndex, 'pass');
    expect(result.valid).toBe(true);
  });

  it('allows Sun if no higher bid exists', () => {
    const game = createGameDocument('g1', 'r1', createMockPlayers());
    dealRound(game);
    const result = validateBid(game, game.turnIndex, 'sun');
    expect(result.valid).toBe(true);
  });

  it('rejects Sun after Sun is already bid', () => {
    const game = createGameDocument('g1', 'r1', createMockPlayers());
    dealRound(game);
    game.players[String(game.turnIndex)].bid = 'sun';
    game.turnIndex = (game.turnIndex + 1) % 4;

    const result = validateBid(game, game.turnIndex, 'sun');
    expect(result.valid).toBe(false);
  });

  it('rejects Sun after Hokm is bid', () => {
    const game = createGameDocument('g1', 'r1', createMockPlayers());
    dealRound(game);
    game.players['0'].bid = 'hokm';
    game.turnIndex = 1;

    const result = validateBid(game, 1, 'sun');
    expect(result.valid).toBe(false);
  });

  it('allows Hokm if player holds face-up suit', () => {
    const game = createGameDocument('g1', 'r1', createMockPlayers());
    dealRound(game);
    const turn = game.turnIndex;

    // Force player to have the face-up suit
    const faceUpSuit = game.faceUpCard!.slice(-1);
    game.players[String(turn)].hand = [`A${faceUpSuit}`, '2H', '3H'];

    const result = validateBid(game, turn, 'hokm');
    expect(result.valid).toBe(true);
  });

  it('rejects Hokm if player does not hold face-up suit', () => {
    const game = createGameDocument('g1', 'r1', createMockPlayers());
    dealRound(game);
    const turn = game.turnIndex;

    // Force player to NOT have the face-up suit
    const faceUpSuit = game.faceUpCard!.slice(-1);
    const otherSuits = ['H', 'D', 'C', 'S'].filter((s) => s !== faceUpSuit);
    game.players[String(turn)].hand = [`A${otherSuits[0]}`, `2${otherSuits[1]}`, `3${otherSuits[2]}`];

    const result = validateBid(game, turn, 'hokm');
    expect(result.valid).toBe(false);
  });

  it('rejects bid when not players turn', () => {
    const game = createGameDocument('g1', 'r1', createMockPlayers());
    dealRound(game);
    const wrongSeat = (game.turnIndex + 1) % 4;

    const result = validateBid(game, wrongSeat, 'pass');
    expect(result.valid).toBe(false);
    expect(result.reason).toContain('turn');
  });
});

describe('resolveBidding', () => {
  it('returns resolved=false if not all players have bid', () => {
    const game = createGameDocument('g1', 'r1', createMockPlayers());
    dealRound(game);
    const result = resolveBidding(game);
    expect(result.resolved).toBe(false);
  });

  it('returns redeal=true if all pass', () => {
    const game = createGameDocument('g1', 'r1', createMockPlayers());
    dealRound(game);
    for (let i = 0; i < 4; i++) {
      game.players[String(i)].bid = 'pass';
    }

    const result = resolveBidding(game);
    expect(result.resolved).toBe(true);
    expect(result.redeal).toBe(true);
  });

  it('resolves to Hokm with first Hokm bidder', () => {
    const game = createGameDocument('g1', 'r1', createMockPlayers());
    dealRound(game);
    game.players['0'].bid = 'pass';
    game.players['1'].bid = 'hokm';
    game.players['2'].bid = 'pass';
    game.players['3'].bid = 'pass';

    const result = resolveBidding(game);
    expect(result.resolved).toBe(true);
    expect(result.gameType).toBe('hokm');
    expect(result.bidderIndex).toBe(1);
  });

  it('resolves to Sun with last Sun bidder', () => {
    const game = createGameDocument('g1', 'r1', createMockPlayers());
    dealRound(game);
    game.players['0'].bid = 'pass';
    game.players['1'].bid = 'sun';
    game.players['2'].bid = 'pass';
    game.players['3'].bid = 'sun';

    const result = resolveBidding(game);
    expect(result.resolved).toBe(true);
    expect(result.gameType).toBe('sun');
    expect(result.bidderIndex).toBe(3);
  });

  it('Hokm beats Sun', () => {
    const game = createGameDocument('g1', 'r1', createMockPlayers());
    dealRound(game);
    game.players['0'].bid = 'sun';
    game.players['1'].bid = 'hokm';
    game.players['2'].bid = 'pass';
    game.players['3'].bid = 'pass';

    const result = resolveBidding(game);
    expect(result.gameType).toBe('hokm');
    expect(result.bidderIndex).toBe(1);
  });
});

describe('applyBiddingResult', () => {
  it('rotates dealer and sets dealing on redeal', () => {
    const game = createGameDocument('g1', 'r1', createMockPlayers());
    dealRound(game);
    const oldDealer = game.dealerIndex;

    applyBiddingResult(game, { resolved: true, redeal: true });
    expect(game.dealerIndex).toBe((oldDealer + 1) % 4);
    expect(game.status).toBe('dealing');
  });

  it('sets Hokm mode correctly', () => {
    const game = createGameDocument('g1', 'r1', createMockPlayers());
    dealRound(game);
    const faceUpSuit = game.faceUpCard!.slice(-1);
    const suitMap: Record<string, string> = { H: 'hearts', D: 'diamonds', C: 'clubs', S: 'spades' };

    applyBiddingResult(game, { resolved: true, gameType: 'hokm', bidderIndex: 1 });

    expect(game.gameType).toBe('hokm');
    expect(game.hokmBidder).toBe(1);
    expect(game.trumpSuit).toBe(suitMap[faceUpSuit]);
    expect(game.biddingTeam).toBe('B');
    expect(game.status).toBe('bonusClaim');
    expect(game.turnIndex).toBe(1);
  });

  it('sets Sun mode correctly', () => {
    const game = createGameDocument('g1', 'r1', createMockPlayers());
    dealRound(game);

    applyBiddingResult(game, { resolved: true, gameType: 'sun', bidderIndex: 2 });

    expect(game.gameType).toBe('sun');
    expect(game.sunBidder).toBe(2);
    expect(game.trumpSuit).toBeNull();
    expect(game.biddingTeam).toBe('A');
    expect(game.status).toBe('playing');
    expect(game.turnIndex).toBe(2);
  });
});
