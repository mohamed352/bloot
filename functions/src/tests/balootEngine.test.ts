import { BalootCard, BALOOT_SUITS } from '../engine/balootCard';
import { BalootDeck } from '../engine/balootDeck';
import { BalootEngine } from '../engine/balootEngine';
import { BalootSerializer } from '../engine/balootSerializer';
import { BalootMatch } from '../engine/balootState';
import { TARGET_QAID } from '../engine/balootRules';

function seededRng(seed: number): () => number {
  let s = seed;
  return () => {
    s = (s * 9301 + 49297) % 233280;
    return s / 233280;
  };
}

function createTestMatch(autoDeclare = true): BalootMatch {
  const engine = new BalootEngine(seededRng(12345));
  const match = engine.createMatch(
    [
      { name: 'A', uid: 'a', team: 'A' },
      { name: 'B', uid: 'b', team: 'B' },
      { name: 'C', uid: 'c', team: 'A' },
      { name: 'D', uid: 'd', team: 'B' },
    ],
    { autoDeclare },
  );
  // Fix dealer so the first player is seat 0, making tests deterministic.
  match.dealer = 3;
  engine.startHand(match);
  return match;
}

function finishBidding(match: BalootMatch, engine: BalootEngine, winningBid: 'sun' | 'hokum' | 'ashkal', winner = 0): void {
  while (match.state!.phase === 'bidding') {
    if (match.state!.bidding.turn === winner) {
      engine.applyBid(match, winner, { type: winningBid });
    } else {
      engine.applyBid(match, match.state!.bidding.turn, { type: 'pass' });
    }
  }
}

describe('BalootEngine', () => {
  it('deals 5 cards initially and distributes to 8 after bidding', () => {
    const match = createTestMatch();
    const state = match.state!;
    expect(state.hands).toHaveLength(4);
    for (const hand of state.hands) {
      expect(hand).toHaveLength(5);
    }
    expect(state.rest).toHaveLength(11);
    expect(state.topCard).toBeDefined();

    const engine = new BalootEngine(seededRng(12345));
    finishBidding(match, engine, 'sun', 0);
    for (const hand of state.hands) {
      expect(hand).toHaveLength(8);
    }
  });

  it('supports a full Sun hand', () => {
    const match = createTestMatch();
    const engine = new BalootEngine(seededRng(12345));
    const state = match.state!;

    finishBidding(match, engine, 'sun', 0);

    expect(state.mode).toBe('sun');
    expect(state.buyer).toBe(0);
    expect(state.phase).toBe('playing');
    expect(state.trump).toBeUndefined();

    let plays = 0;
    while (state.phase === 'playing' && plays < 100) {
      const legal = engine.legalMoves(state, state.turn);
      engine.playCard(match, state.turn, legal[0]);
      plays++;
    }

    expect(state.phase).toBe('handEnd');
    expect(state.result).toBeDefined();
    expect(state.trickHistory).toHaveLength(8);
  });

  it('supports a full Hokm hand', () => {
    const match = createTestMatch();
    const engine = new BalootEngine(seededRng(12345));
    const state = match.state!;

    finishBidding(match, engine, 'hokum', 0);

    expect(state.mode).toBe('hokum');
    expect(state.trump).toBe(state.topCard.suit);

    let plays = 0;
    while (state.phase === 'playing' && plays < 100) {
      const legal = engine.legalMoves(state, state.turn);
      engine.playCard(match, state.turn, legal[0]);
      plays++;
    }

    expect(state.phase).toBe('handEnd');
    expect(state.trickHistory).toHaveLength(8);
  });

  it('redeals when everyone passes twice', () => {
    const match = createTestMatch();
    const engine = new BalootEngine(seededRng(12345));
    const state = match.state!;
    const originalDealer = match.dealer;

    for (let i = 0; i < 4; i++) {
      engine.applyBid(match, state.bidding.turn, { type: 'pass' });
    }
    expect(state.bidding.round).toBe(2);

    for (let i = 0; i < 4; i++) {
      engine.applyBid(match, state.bidding.turn, { type: 'pass' });
    }

    expect(match.dealer).toBe((originalDealer + 1) % 4);
    // A redeal only runs the first dealing phase.
    expect(state.hands[0]).toHaveLength(5);
  });

  it('detects a Sira project in Sun', () => {
    const engine = new BalootEngine();
    const hand = [
      new BalootCard('spades', '7'),
      new BalootCard('spades', '8'),
      new BalootCard('spades', '9'),
    ];
    const projects = engine.findProjects(hand, 'sun', null);
    expect(projects.some((p) => p.type === 'sira')).toBe(true);
  });

  it('detects four aces', () => {
    const engine = new BalootEngine();
    const hand = BALOOT_SUITS.map((suit) => new BalootCard(suit, 'A'));
    const projects = engine.findProjects(hand, 'sun', null);
    expect(projects.some((p) => p.type === 'fourAces')).toBe(true);
  });

  it('detects a Baloot in Hokm when K and Q of trump are played in adjacent tricks', () => {
    const engine = new BalootEngine();
    const match = createTestMatch();
    const state = match.state!;

    finishBidding(match, engine, 'hokum', 0);
    const trump = state.trump!;

    state.hands[0] = [
      new BalootCard(trump, 'K'),
      new BalootCard(trump, 'Q'),
      ...state.hands[0].slice(2),
    ];
    for (let s = 1; s < 4; s++) {
      state.hands[s] = [
        new BalootCard(trump, '7'),
        new BalootCard(trump, '8'),
        ...state.hands[s].slice(2),
      ];
    }

    engine.playCard(match, 0, new BalootCard(trump, 'K'));
    engine.playCard(match, 1, new BalootCard(trump, '7'));
    engine.playCard(match, 2, new BalootCard(trump, '7'));
    engine.playCard(match, 3, new BalootCard(trump, '8'));

    engine.playCard(match, 0, new BalootCard(trump, 'Q'));

    expect(state.balootTeam).toBe(0);
  });

  it('scores a completed hand', () => {
    const engine = new BalootEngine();
    const match = createTestMatch();
    const state = match.state!;

    finishBidding(match, engine, 'sun', 0);

    let plays = 0;
    while (state.phase === 'playing' && plays < 100) {
      const legal = engine.legalMoves(state, state.turn);
      engine.playCard(match, state.turn, legal[0]);
      plays++;
    }

    expect(state.result).toBeDefined();
    expect(state.result!.qaid[0] + state.result!.qaid[1]).toBeGreaterThan(0);
    expect(match.totals[0] + match.totals[1]).toBeGreaterThan(0);
  });

  it('serializes and deserializes a match', () => {
    const match = createTestMatch();
    const engine = new BalootEngine(seededRng(12345));
    finishBidding(match, engine, 'sun', 0);

    const serializer = new BalootSerializer();
    const json = serializer.serializeMatch(match);
    const restored = serializer.deserializeMatch(json);

    expect(restored.dealer).toBe(match.dealer);
    expect(restored.totals).toEqual(match.totals);
    expect(restored.state!.hands[0].length).toBe(8);
    expect(restored.state!.topCard.key).toBe(match.state!.topCard.key);
  });

  it('ends the match when a team reaches the target qaid', () => {
    const engine = new BalootEngine();
    const match = createTestMatch();
    const state = match.state!;

    finishBidding(match, engine, 'sun', 0);

    match.totals[0] = TARGET_QAID;
    let plays = 0;
    while (state.phase !== 'matchEnd' && plays < 100) {
      const legal = engine.legalMoves(state, state.turn);
      engine.playCard(match, state.turn, legal[0]);
      plays++;
    }

    expect(state.phase).toBe('matchEnd');
    expect(match.matchOver).toBe(true);
    expect(match.winnerTeam).toBe(0);
  });
});

describe('BalootDeck', () => {
  it('shuffles a full 32-card deck', () => {
    const deck = new BalootDeck(seededRng(42));
    const cards = deck.shuffledDeck();
    expect(cards).toHaveLength(32);
    const unique = new Set(cards.map((c) => c.key));
    expect(unique.size).toBe(32);
  });
});
