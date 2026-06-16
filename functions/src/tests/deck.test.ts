import { createDeck, shuffle } from '../engine/deck';

describe('createDeck', () => {
  it('returns exactly 52 cards', () => {
    const deck = createDeck();
    expect(deck).toHaveLength(52);
  });

  it('returns unique cards', () => {
    const deck = createDeck();
    const unique = new Set(deck);
    expect(unique.size).toBe(52);
  });

  it('contains all expected cards', () => {
    const deck = createDeck();
    expect(deck).toContain('AH');
    expect(deck).toContain('KS');
    expect(deck).toContain('10D');
    expect(deck).toContain('2C');
    expect(deck).toContain('JC');
    expect(deck).toContain('QD');
  });
});

describe('shuffle', () => {
  it('returns a permutation of the input deck', () => {
    const deck = createDeck();
    const shuffled = shuffle([...deck]);
    expect(shuffled).toHaveLength(52);
    expect(new Set(shuffled).size).toBe(52);
    expect(shuffled.sort()).toEqual(deck.sort());
  });

  it('produces different orderings most of the time', () => {
    const deck = createDeck();
    const shuffled = shuffle([...deck]);
    // It's extremely unlikely shuffle returns identical order
    expect(shuffled).not.toEqual(deck);
  });
});
