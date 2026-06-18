import { detectBnaga, detectMosal, detectAllBonuses, resolveBonusClaims } from '../engine/bonuses';
import { BonusClaim } from '../models/game';

describe('detectBnaga', () => {
  it('detects 3-card sequence', () => {
    const result = detectBnaga(['7H', '8H', '9H']);
    expect(result).not.toBeNull();
    expect(result!.points).toBe(20);
    expect(result!.sequence).toHaveLength(3);
  });

  it('detects 4-card sequence', () => {
    const result = detectBnaga(['7H', '8H', '9H', '10H']);
    expect(result).not.toBeNull();
    expect(result!.points).toBe(50);
  });

  it('detects 5-card sequence', () => {
    const result = detectBnaga(['7H', '8H', '9H', '10H', 'JH']);
    expect(result).not.toBeNull();
    expect(result!.points).toBe(100);
  });

  it('returns null for non-consecutive cards', () => {
    const result = detectBnaga(['7H', '9H', 'JH']);
    expect(result).toBeNull();
  });

  it('returns null for less than 3 cards', () => {
    const result = detectBnaga(['7H', '8H']);
    expect(result).toBeNull();
  });

  it('finds best sequence across suits', () => {
    const result = detectBnaga(['7H', '8H', '9H', '10H', '7D', '8D', '9D']);
    expect(result).not.toBeNull();
    expect(result!.sequence).toHaveLength(4); // hearts sequence is longer
  });
});

describe('detectMosal', () => {
  it('detects four Jacks', () => {
    const result = detectMosal(['JC', 'JD', 'JH', 'JS']);
    expect(result).not.toBeNull();
    expect(result!.points).toBe(200);
    expect(result!.rank).toBe('J');
  });

  it('detects four Nines', () => {
    const result = detectMosal(['9C', '9D', '9H', '9S']);
    expect(result).not.toBeNull();
    expect(result!.points).toBe(150);
  });

  it('detects four Aces', () => {
    const result = detectMosal(['AC', 'AD', 'AH', 'AS']);
    expect(result).not.toBeNull();
    expect(result!.points).toBe(100);
  });

  it('returns null for no four of a kind', () => {
    const result = detectMosal(['AC', 'AD', 'AH', 'KS']);
    expect(result).toBeNull();
  });

  it('returns highest mosal if multiple', () => {
    const result = detectMosal(['JC', 'JD', 'JH', 'JS', '9C', '9D', '9H', '9S']);
    expect(result).not.toBeNull();
    expect(result!.points).toBe(200); // Jacks beat Nines
  });
});

describe('detectAllBonuses', () => {
  it('detects both bnaga and mosal', () => {
    const bonuses = detectAllBonuses(['7H', '8H', '9H', 'JC', 'JD', 'JH', 'JS']);
    expect(bonuses).toHaveLength(2);
    expect(bonuses.some((b) => b.type === 'bnaga')).toBe(true);
    expect(bonuses.some((b) => b.type === 'mosal')).toBe(true);
  });
});

describe('resolveBonusClaims', () => {
  it('mosal beats bnaga', () => {
    const teamA: BonusClaim[] = [
      { type: 'bnaga', points: 50, cards: ['7H', '8H', '9H', '10H'], description: '' },
    ];
    const teamB: BonusClaim[] = [
      { type: 'mosal', points: 200, cards: ['JC', 'JD', 'JH', 'JS'], description: '' },
    ];

    const result = resolveBonusClaims(teamA, teamB);
    expect(result.teamAPoints).toBe(0);
    expect(result.teamBPoints).toBe(200);
  });

  it('higher mosal wins', () => {
    const teamA: BonusClaim[] = [
      { type: 'mosal', points: 200, cards: ['JC', 'JD', 'JH', 'JS'], description: '' },
    ];
    const teamB: BonusClaim[] = [
      { type: 'mosal', points: 150, cards: ['9C', '9D', '9H', '9S'], description: '' },
    ];

    const result = resolveBonusClaims(teamA, teamB);
    expect(result.teamAPoints).toBe(200);
    expect(result.teamBPoints).toBe(0);
  });

  it('longer sequence wins when no mosal', () => {
    const teamA: BonusClaim[] = [
      { type: 'bnaga', points: 50, cards: ['7H', '8H', '9H', '10H'], description: '' },
    ];
    const teamB: BonusClaim[] = [
      { type: 'bnaga', points: 20, cards: ['7D', '8D', '9D'], description: '' },
    ];

    const result = resolveBonusClaims(teamA, teamB);
    expect(result.teamAPoints).toBe(50);
    expect(result.teamBPoints).toBe(0);
  });

  it('equal length sequences: higher card wins', () => {
    const teamA: BonusClaim[] = [
      { type: 'bnaga', points: 50, cards: ['AH', 'KH', 'QH', 'JH'], description: '' },
    ];
    const teamB: BonusClaim[] = [
      { type: 'bnaga', points: 50, cards: ['10D', '9D', '8D', '7D'], description: '' },
    ];

    const result = resolveBonusClaims(teamA, teamB);
    expect(result.teamAPoints).toBe(50);
    expect(result.teamBPoints).toBe(0);
  });

  it('sequence with Jack-high beats sequence with 10-high', () => {
    const teamA: BonusClaim[] = [
      { type: 'bnaga', points: 50, cards: ['JH', '10H', '9H', '8H'], description: '' },
    ];
    const teamB: BonusClaim[] = [
      { type: 'bnaga', points: 50, cards: ['10D', '9D', '8D', '7D'], description: '' },
    ];

    const result = resolveBonusClaims(teamA, teamB);
    expect(result.teamAPoints).toBe(50);
    expect(result.teamBPoints).toBe(0);
  });

  it('no bonuses returns zero for both', () => {
    const result = resolveBonusClaims([], []);
    expect(result.teamAPoints).toBe(0);
    expect(result.teamBPoints).toBe(0);
  });

  it('only one team has bonuses', () => {
    const teamA: BonusClaim[] = [
      { type: 'bnaga', points: 20, cards: ['7H', '8H', '9H'], description: '' },
    ];
    const result = resolveBonusClaims(teamA, []);
    expect(result.teamAPoints).toBe(20);
    expect(result.teamBPoints).toBe(0);
  });

  it('equal highest sequence card is a true tie: both keep bonuses', () => {
    const teamA: BonusClaim[] = [
      { type: 'bnaga', points: 50, cards: ['AH', 'KH', 'QH', 'JH'], description: '' },
    ];
    const teamB: BonusClaim[] = [
      { type: 'bnaga', points: 50, cards: ['AD', 'KD', 'QD', 'JD'], description: '' },
    ];

    const result = resolveBonusClaims(teamA, teamB);
    expect(result.teamAPoints).toBe(50);
    expect(result.teamBPoints).toBe(50);
  });
});
