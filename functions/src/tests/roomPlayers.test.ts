import {
  allocateParitySeat,
  canAutoStartGame,
  computeReadyPlayers,
  freeParitySeat,
  normalizeParitySeats,
} from '../utils/roomPlayers';

describe('normalizeParitySeats', () => {
  it('orders 2A+2B players as [A1,B1,A2,B2] with seatIndex 0..3', () => {
    const players = [
      { uid: 'b2', team: 'B' as const, seatIndex: 3 },
      { uid: 'a1', team: 'A' as const, seatIndex: 0 },
      { uid: 'b1', team: 'B' as const, seatIndex: 1 },
      { uid: 'a2', team: 'A' as const, seatIndex: 2 },
    ];
    const normalized = normalizeParitySeats(players);
    expect(normalized.map((p) => p.uid)).toEqual(['a1', 'b1', 'a2', 'b2']);
    expect(normalized.map((p) => p.seatIndex)).toEqual([0, 1, 2, 3]);
    expect(normalized.map((p) => p.team)).toEqual(['A', 'B', 'A', 'B']);
  });

  it('reassigns parity seats when stored seatIndex violates parity', () => {
    // Legacy room: both Team A players ended up on seats 0 and 1.
    const players = [
      { uid: 'a1', team: 'A' as const, seatIndex: 0 },
      { uid: 'a2', team: 'A' as const, seatIndex: 1 },
      { uid: 'b1', team: 'B' as const, seatIndex: 2 },
      { uid: 'b2', team: 'B' as const, seatIndex: 3 },
    ];
    const normalized = normalizeParitySeats(players);
    expect(normalized.map((p) => p.uid)).toEqual(['a1', 'b1', 'a2', 'b2']);
    expect(normalized.every((p, i) => p.seatIndex === i)).toBe(true);
  });

  it('falls back to seat sort for non-2v2 input', () => {
    const players = [
      { uid: 'x', team: 'A' as const, seatIndex: 2 },
      { uid: 'y', team: 'A' as const, seatIndex: 0 },
    ];
    const normalized = normalizeParitySeats(players);
    expect(normalized.map((p) => p.uid)).toEqual(['y', 'x']);
    expect(normalized.map((p) => p.seatIndex)).toEqual([0, 2]);
  });

  it('does not mutate the original player objects', () => {
    const players = [
      { uid: 'a1', team: 'A' as const, seatIndex: 0 },
      { uid: 'b1', team: 'B' as const, seatIndex: 1 },
      { uid: 'a2', team: 'A' as const, seatIndex: 2 },
      { uid: 'b2', team: 'B' as const, seatIndex: 3 },
    ];
    normalizeParitySeats(players);
    expect(players.map((p) => p.seatIndex)).toEqual([0, 1, 2, 3]);
  });
});

describe('freeParitySeat', () => {
  it('gives Team A seats 0 then 2', () => {
    expect(freeParitySeat([], 'A')).toBe(0);
    expect(freeParitySeat([{ seatIndex: 0 }], 'A')).toBe(2);
    expect(freeParitySeat([{ seatIndex: 0 }, { seatIndex: 2 }], 'A')).toBeNull();
  });

  it('gives Team B seats 1 then 3', () => {
    expect(freeParitySeat([], 'B')).toBe(1);
    expect(freeParitySeat([{ seatIndex: 1 }], 'B')).toBe(3);
    expect(freeParitySeat([{ seatIndex: 1 }, { seatIndex: 3 }], 'B')).toBeNull();
  });
});

describe('allocateParitySeat', () => {
  it('prefers Team A on ties', () => {
    expect(allocateParitySeat([])).toEqual({ team: 'A', seatIndex: 0 });
  });

  it('balances teams across a full join sequence', () => {
    const players: Array<{ team: 'A' | 'B'; seatIndex: number }> = [];
    const seats: Array<{ team: 'A' | 'B'; seatIndex: number } | null> = [];
    for (let i = 0; i < 4; i++) {
      const alloc = allocateParitySeat(players);
      seats.push(alloc);
      if (alloc) players.push(alloc);
    }
    expect(seats).toEqual([
      { team: 'A', seatIndex: 0 },
      { team: 'B', seatIndex: 1 },
      { team: 'A', seatIndex: 2 },
      { team: 'B', seatIndex: 3 },
    ]);
    expect(allocateParitySeat(players)).toBeNull();
  });

  it('fills a freed parity seat for the correct team', () => {
    // Seat 2 (Team A) left the room.
    const players = [
      { team: 'A' as const, seatIndex: 0 },
      { team: 'B' as const, seatIndex: 1 },
      { team: 'B' as const, seatIndex: 3 },
    ];
    expect(allocateParitySeat(players)).toEqual({ team: 'A', seatIndex: 2 });
  });
});

describe('computeReadyPlayers', () => {
  it('returns only ready player uids', () => {
    expect(
      computeReadyPlayers([
        { uid: 'a', isReady: true },
        { uid: 'b', isReady: false },
        { uid: 'c', isReady: true },
      ]),
    ).toEqual(['a', 'c']);
  });

  it('treats missing isReady as not ready', () => {
    expect(computeReadyPlayers([{ uid: 'a' }, { uid: 'b', isReady: true }])).toEqual(['b']);
  });
});

describe('canAutoStartGame', () => {
  it('requires exactly 4 players', () => {
    expect(
      canAutoStartGame([
        { isReady: true },
        { isReady: true },
        { isReady: true },
      ]),
    ).toBe(false);
  });

  it('auto-starts when all humans are ready and bots fill the rest', () => {
    expect(
      canAutoStartGame([
        { isReady: true },
        { isReady: true, isBot: true },
        { isReady: true },
        { isReady: true, isBot: true },
      ]),
    ).toBe(true);
  });

  it('does not auto-start when a human is not ready', () => {
    expect(
      canAutoStartGame([
        { isReady: true },
        { isReady: false },
        { isReady: true, isBot: true },
        { isReady: true, isBot: true },
      ]),
    ).toBe(false);
  });

  it('bots count as ready even without isReady', () => {
    expect(
      canAutoStartGame([
        { isReady: true },
        { isBot: true },
        { isBot: true },
        { isBot: true },
      ]),
    ).toBe(true);
  });
});
