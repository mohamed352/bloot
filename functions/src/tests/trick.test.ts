import { isCardLegal, determineTrickWinner, playCardOntoTrick, startNextTrick } from '../engine/trick';
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

function createPlayingGame(type: 'sun' | 'hokm' = 'sun') {
  const game = createGameDocument('g1', 'r1', createMockPlayers());
  dealRound(game);
  game.status = 'playing';
  game.gameType = type;
  game.turnIndex = 0;
  if (type === 'hokm') {
    game.trumpSuit = 'hearts';
  }
  return game;
}

describe('isCardLegal', () => {
  it('allows lead player to play any card', () => {
    const game = createPlayingGame();
    game.players['0'].hand = ['AH', 'KS', 'QD'];

    expect(isCardLegal(game, 0, 'AH').legal).toBe(true);
    expect(isCardLegal(game, 0, 'KS').legal).toBe(true);
  });

  it('requires following suit if possible', () => {
    const game = createPlayingGame();
    game.players['0'].hand = ['AH'];
    game.currentTrick.leadingSuit = 'hearts';
    game.currentTrick.trickLeaderIndex = 0;
    game.currentTrick.cards['0'] = 'AH';
    game.turnIndex = 1;

    // Player 1 has hearts — must follow
    game.players['1'].hand = ['KH', 'QS', 'JD'];
    expect(isCardLegal(game, 1, 'QS').legal).toBe(false);
    expect(isCardLegal(game, 1, 'KH').legal).toBe(true);
  });

  it('allows any card when void in led suit', () => {
    const game = createPlayingGame();
    game.players['0'].hand = ['AH'];
    game.currentTrick.leadingSuit = 'hearts';
    game.currentTrick.trickLeaderIndex = 0;
    game.currentTrick.cards['0'] = 'AH';
    game.turnIndex = 1;

    // Player 1 has no hearts
    game.players['1'].hand = ['KS', 'QS', 'JD'];
    expect(isCardLegal(game, 1, 'KS').legal).toBe(true);
    expect(isCardLegal(game, 1, 'JD').legal).toBe(true);
  });

  it('rejects card not in hand', () => {
    const game = createPlayingGame();
    game.players['0'].hand = ['AH'];
    expect(isCardLegal(game, 0, 'KS').legal).toBe(false);
  });

  it('rejects play out of turn', () => {
    const game = createPlayingGame();
    game.players['0'].hand = ['AH'];
    game.turnIndex = 1;
    expect(isCardLegal(game, 0, 'AH').legal).toBe(false);
  });
});

describe('determineTrickWinner', () => {
  it('Sun: highest of led suit wins', () => {
    const result = determineTrickWinner(
      [
        { seat: 0, card: '7H' },
        { seat: 1, card: 'KH' },
        { seat: 2, card: '10H' },
        { seat: 3, card: 'JH' },
      ],
      null,
      true,
    );
    expect(result).toBe(2); // 10H is highest (A > 10 > K > Q > J)
  });

  it('Hokm: highest trump wins even if not led', () => {
    const result = determineTrickWinner(
      [
        { seat: 0, card: 'AH' },
        { seat: 1, card: 'JS' }, // trump
        { seat: 2, card: 'KH' },
        { seat: 3, card: 'QH' },
      ],
      'spades',
      false,
    );
    expect(result).toBe(1); // JS is trump
  });

  it('Hokm: if no trump, highest of led suit wins', () => {
    const result = determineTrickWinner(
      [
        { seat: 0, card: 'AH' },
        { seat: 1, card: 'KH' },
        { seat: 2, card: '10H' },
        { seat: 3, card: 'QH' },
      ],
      'spades',
      false,
    );
    expect(result).toBe(0); // AH is highest of hearts
  });

  it('Hokm: J of trump beats A of trump', () => {
    const result = determineTrickWinner(
      [
        { seat: 0, card: 'AS' },
        { seat: 1, card: 'JS' },
        { seat: 2, card: 'KS' },
        { seat: 3, card: '9S' },
      ],
      'spades',
      false,
    );
    expect(result).toBe(1); // JS beats AS
  });

  it('Hokm: 9 of trump beats 10 of trump', () => {
    const result = determineTrickWinner(
      [
        { seat: 0, card: '10S' },
        { seat: 1, card: '9S' },
        { seat: 2, card: 'KS' },
        { seat: 3, card: 'QS' },
      ],
      'spades',
      false,
    );
    expect(result).toBe(1); // 9S beats 10S
  });
});

describe('playCardOntoTrick', () => {
  it('places card on trick and advances turn', () => {
    const game = createPlayingGame();
    game.players['0'].hand = ['AH', 'KS'];

    const result = playCardOntoTrick(game, 0, 'AH');
    expect(result.trickComplete).toBe(false);
    expect(game.currentTrick.cards['0']).toBe('AH');
    expect(game.currentTrick.leadingSuit).toBe('hearts');
    expect(game.turnIndex).toBe(1);
  });

  it('completes trick and determines winner', () => {
    const game = createPlayingGame('hokm');
    game.trumpSuit = 'spades';
    game.players['0'].hand = ['AH'];
    game.players['1'].hand = ['JS'];
    game.players['2'].hand = ['KH'];
    game.players['3'].hand = ['QH'];

    playCardOntoTrick(game, 0, 'AH');
    playCardOntoTrick(game, 1, 'JS');
    playCardOntoTrick(game, 2, 'KH');
    const result = playCardOntoTrick(game, 3, 'QH');

    expect(result.trickComplete).toBe(true);
    expect(result.winnerSeat).toBe(1); // JS (trump) wins
    expect(game.players['1'].tricksWon).toBe(1);
    expect(game.players['1'].takenCards).toContain('AH');
    expect(game.players['1'].takenCards).toContain('JS');
  });
});

describe('startNextTrick', () => {
  it('clears trick and sets winner as leader', () => {
    const game = createPlayingGame();
    game.currentTrick.cards = { '0': 'AH', '1': 'KH', '2': 'QH', '3': 'JH' };

    startNextTrick(game, 2);
    expect(game.currentTrick.trickNumber).toBe(2);
    expect(game.currentTrick.trickLeaderIndex).toBe(2);
    expect(game.currentTrick.leadingSuit).toBeNull();
    expect(game.currentTrick.cards['0']).toBeNull();
    expect(game.turnIndex).toBe(2);
    expect(game.status).toBe('playing');
  });
});
