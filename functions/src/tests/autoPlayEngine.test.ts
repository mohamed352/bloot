import { isPlayerTimedOut, isTrickEndDue } from '../utils/autoPlayEngine';

describe('isPlayerTimedOut', () => {
  it('acts when the player is marked disconnected even before the limit', () => {
    expect(isPlayerTimedOut({ isConnected: false }, 10_000, 9_000, 45_000)).toBe(true);
  });

  it('acts when the turn time limit has elapsed', () => {
    expect(isPlayerTimedOut({ isConnected: true }, 100_000, 50_000, 45_000)).toBe(true);
  });

  it('does not act for a connected player inside the limit', () => {
    expect(isPlayerTimedOut({ isConnected: true }, 50_000, 10_000, 45_000)).toBe(false);
  });

  it('does not act without a player record', () => {
    expect(isPlayerTimedOut(undefined, 100_000, 0, 45_000)).toBe(false);
  });
});

describe('isTrickEndDue', () => {
  const startedAt = { toMillis: () => 1_000 };

  it('is due once the default 2s trick-end delay has elapsed', () => {
    expect(isTrickEndDue({ turnTimerStart: startedAt }, 3_000)).toBe(true);
    expect(isTrickEndDue({ turnTimerStart: startedAt }, 2_999)).toBe(false);
  });

  it('honours a custom trickEndDelayMs', () => {
    const game = { turnTimerStart: startedAt, trickEndDelayMs: 5_000 };
    expect(isTrickEndDue(game, 5_999)).toBe(false);
    expect(isTrickEndDue(game, 6_000)).toBe(true);
  });
});
