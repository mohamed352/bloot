import { isTerminalGameForBotAutoPlay } from '../triggers/botAutoPlay';

describe('isTerminalGameForBotAutoPlay', () => {
  it('skips completed games so the trigger cannot self-loop', () => {
    expect(isTerminalGameForBotAutoPlay({ status: 'gameEnd' })).toBe(true);
    expect(isTerminalGameForBotAutoPlay({ endedAt: new Date() })).toBe(true);
  });

  it('allows active game states', () => {
    expect(isTerminalGameForBotAutoPlay({ status: 'bidding' })).toBe(false);
    expect(isTerminalGameForBotAutoPlay({ status: 'playing' })).toBe(false);
    expect(isTerminalGameForBotAutoPlay({ status: 'trickEnd' })).toBe(false);
    expect(isTerminalGameForBotAutoPlay({ status: 'roundEnd' })).toBe(false);
  });
});
