import { createGameDocument, dealRound } from '../engine/deal';
import { resolveBidding, applyBiddingResult } from '../engine/bidding';
import { isCardLegal, playCardOntoTrick, startNextTrick } from '../engine/trick';
import { calculateRoundScore, checkGameEnd } from '../engine/scoring';
import { PlayerState } from '../models/game';

function createMockPlayers(): PlayerState[] {
  return [
    { uid: 'p0', displayName: 'Player0', avatarUrl: '', team: 'A', hand: [], takenCards: [], tricksWon: 0, bid: null, isReady: false, bonuses: null, isConnected: true },
    { uid: 'p1', displayName: 'Player1', avatarUrl: '', team: 'B', hand: [], takenCards: [], tricksWon: 0, bid: null, isReady: false, bonuses: null, isConnected: true },
    { uid: 'p2', displayName: 'Player2', avatarUrl: '', team: 'A', hand: [], takenCards: [], tricksWon: 0, bid: null, isReady: false, bonuses: null, isConnected: true },
    { uid: 'p3', displayName: 'Player3', avatarUrl: '', team: 'B', hand: [], takenCards: [], tricksWon: 0, bid: null, isReady: false, bonuses: null, isConnected: true },
  ];
}

describe('Full Game Integration', () => {
  it('completes a Sun round with no fall', () => {
    const game = createGameDocument('g1', 'r1', createMockPlayers());
    dealRound(game);

    // Bidding: all pass → redeal
    for (let i = 0; i < 4; i++) {
      game.players[String(i)].bid = 'pass';
    }
    let bidResult = resolveBidding(game);
    expect(bidResult.redeal).toBe(true);

    // Re-deal
    dealRound(game);

    // Bidding: Sun wins
    game.players['0'].bid = 'sun';
    game.players['1'].bid = 'pass';
    game.players['2'].bid = 'pass';
    game.players['3'].bid = 'pass';

    bidResult = resolveBidding(game);
    expect(bidResult.gameType).toBe('sun');
    applyBiddingResult(game, bidResult);
    expect(game.status).toBe('playing');
    expect(game.gameType).toBe('sun');

    // Play 13 tricks with deterministic hands
    game.players['0'].hand = ['AH', 'KH', 'QH', 'JH', '10H', '9H', '8H', '7H', '6H', '5H', '4H', '3H', '2H'];
    game.players['1'].hand = ['AD', 'KD', 'QD', 'JD', '10D', '9D', '8D', '7D', '6D', '5D', '4D', '3D', '2D'];
    game.players['2'].hand = ['AS', 'KS', 'QS', 'JS', '10S', '9S', '8S', '7S', '6S', '5S', '4S', '3S', '2S'];
    game.players['3'].hand = ['AC', 'KC', 'QC', 'JC', '10C', '9C', '8C', '7C', '6C', '5C', '4C', '3C', '2C'];

    for (let trick = 0; trick < 13; trick++) {
      game.currentTrick = {
        trickNumber: trick + 1,
        trickLeaderIndex: game.turnIndex,
        leadingSuit: null,
        cards: { '0': null, '1': null, '2': null, '3': null },
      };

      let currentSeat = game.turnIndex;
      for (let p = 0; p < 4; p++) {
        const seat = (currentSeat + p) % 4;
        const card = game.players[String(seat)].hand[0];
        const legality = isCardLegal(game, seat, card);
        expect(legality.legal).toBe(true);
        const result = playCardOntoTrick(game, seat, card);
        if (result.trickComplete) {
          expect(result.winnerSeat).toBeDefined();
          startNextTrick(game, result.winnerSeat!);
        }
      }
    }

    expect(game.roundTricksA + game.roundTricksB).toBe(13);

    const score = calculateRoundScore(game);
    expect(score.fell).toBeNull();
    expect(score.teamAPoints + score.teamBPoints).toBeGreaterThan(0);
  });

  it('completes a Hokm round where bidder falls', () => {
    const game = createGameDocument('g1', 'r1', createMockPlayers());
    dealRound(game);

    // Hokm bid by Team A
    game.players['0'].bid = 'hokm';
    game.players['1'].bid = 'pass';
    game.players['2'].bid = 'pass';
    game.players['3'].bid = 'pass';

    const bidResult = resolveBidding(game);
    expect(bidResult.gameType).toBe('hokm');
    applyBiddingResult(game, bidResult);

    // Give B all the high trump cards
    game.trumpSuit = 'hearts';
    game.players['0'].hand = ['2H', '3H', '4H', '5H', '6H', '7H', '8H', 'AD', 'KD', 'QD', 'JD', '10D', '9D'];
    game.players['1'].hand = ['JH', '9H', 'AH', '10H', 'KH', 'QH', 'AS', 'KS', 'QS', 'JS', '10S', '9S', '8S'];
    game.players['2'].hand = ['AC', 'KC', 'QC', 'JC', '10C', '9C', '8C', '7C', '6C', '5C', '4C', '3C', '2C'];
    game.players['3'].hand = ['8D', '7D', '6D', '5D', '4D', '3D', '2D', '7S', '6S', '5S', '4S', '3S', '2S'];

    for (let trick = 0; trick < 13; trick++) {
      game.currentTrick = {
        trickNumber: trick + 1,
        trickLeaderIndex: game.turnIndex,
        leadingSuit: null,
        cards: { '0': null, '1': null, '2': null, '3': null },
      };

      let currentSeat = game.turnIndex;
      for (let p = 0; p < 4; p++) {
        const seat = (currentSeat + p) % 4;
        const card = game.players[String(seat)].hand[0];
        const result = playCardOntoTrick(game, seat, card);
        if (result.trickComplete) {
          startNextTrick(game, result.winnerSeat!);
        }
      }
    }

    const score = calculateRoundScore(game);
    expect(score.fell).toBe('A');
    expect(score.teamAPoints).toBe(0);
    expect(score.teamBPoints).toBeGreaterThanOrEqual(152);
  });

  it('game ends when target is reached', () => {
    expect(checkGameEnd(152, 100, 152)).toBe('A');
    expect(checkGameEnd(100, 152, 152)).toBe('B');
    expect(checkGameEnd(100, 100, 152)).toBeNull();
  });
});
