import { buildGameUpdate, deepCloneGame } from './gameUpdate';

jest.mock('firebase-admin', () => ({
  firestore: {
    FieldValue: {
      serverTimestamp: jest.fn(() => 'server-timestamp'),
    },
  },
}));

describe('deepCloneGame', () => {
  it('preserves Date and Timestamp-like objects', () => {
    const date = new Date();
    const timestamp = { seconds: 1, nanoseconds: 0, toMillis: () => 1000 };
    const original = { date, timestamp, nested: { value: 1 } };
    const cloned = deepCloneGame(original);

    expect(cloned.date).toBe(date);
    expect(cloned.timestamp).toBe(timestamp);
    expect(cloned.nested).not.toBe(original.nested);
    expect(cloned.nested).toEqual(original.nested);
  });

  it('deep clones arrays and objects', () => {
    const original = { arr: [1, { a: 2 }], obj: { b: 3 } };
    const cloned = deepCloneGame(original);

    expect(cloned).toEqual(original);
    expect(cloned.arr).not.toBe(original.arr);
    expect(cloned.arr[1]).not.toBe(original.arr[1]);
  });
});

describe('buildGameUpdate', () => {
  it('returns empty object when nothing changed', () => {
    const game = {
      status: 'bidding',
      players: { 0: { bid: null } },
      currentTrick: {},
    };
    const update = buildGameUpdate(game, game);
    expect(Object.keys(update)).toHaveLength(0);
  });

  it('includes top-level changed scalar fields', () => {
    const original = { status: 'bidding', turnIndex: 0 };
    const mutated = { status: 'playing', turnIndex: 0 };
    const update = buildGameUpdate(original, mutated);

    expect(update.status).toBe('playing');
    expect(update.turnIndex).toBeUndefined();
    expect(update.updatedAt).toBe('server-timestamp');
  });

  it('uses dot-notation for player changes', () => {
    const original = {
      players: {
        0: { bid: null, hand: ['AH'] },
        1: { bid: null, hand: ['KH'] },
      },
    };
    const mutated = {
      players: {
        0: { bid: 'sun', hand: ['AH'] },
        1: { bid: null, hand: ['KH'] },
      },
    };
    const update = buildGameUpdate(original, mutated);

    expect(update['players.0.bid']).toBe('sun');
    expect(update['players.0.hand']).toBeUndefined();
    expect(update['players.1.bid']).toBeUndefined();
  });

  it('uses dot-notation for currentTrick changes', () => {
    const original = { currentTrick: { leaderSeat: 0, cards: [] } };
    const mutated = { currentTrick: { leaderSeat: 1, cards: ['AH'] } };
    const update = buildGameUpdate(original, mutated);

    expect(update['currentTrick.leaderSeat']).toBe(1);
    expect(update['currentTrick.cards']).toEqual(['AH']);
  });

  it('uses dot-notation for resolvedBonuses changes', () => {
    const original = { resolvedBonuses: { teamA: 0, teamB: 0 } };
    const mutated = { resolvedBonuses: { teamA: 20, teamB: 0 } };
    const update = buildGameUpdate(original, mutated);

    expect(update['resolvedBonuses.teamA']).toBe(20);
    expect(update['resolvedBonuses.teamB']).toBeUndefined();
  });

  it('treats equal Timestamps as unchanged', () => {
    const ts = { seconds: 1, nanoseconds: 0, toMillis: () => 1000 };
    const original = { startedAt: ts };
    const mutated = { startedAt: ts };
    const update = buildGameUpdate(original, mutated);

    expect(update.startedAt).toBeUndefined();
  });
});
