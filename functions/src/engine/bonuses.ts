import { CardString, RANKS, SUITS, getRank, getSuit } from '../models/card';
import { BonusClaim } from '../models/game';

/**
 * Detects the highest Bnaga (sequence) in a hand.
 * Returns the best sequence found, or null if none.
 */
export function detectBnaga(hand: CardString[]): { points: number; sequence: CardString[] } | null {
  const rankIndex: Record<string, number> = {};
  RANKS.forEach((r, i) => { rankIndex[r] = i; });

  let bestSequence: CardString[] = [];

  for (const suit of SUITS) {
    const suitCards = hand.filter((c) => getSuit(c) === suit);
    if (suitCards.length < 3) continue;

    const sorted = suitCards.sort((a, b) => rankIndex[getRank(a)] - rankIndex[getRank(b)]);

    // Find longest consecutive sequence
    let currentSeq: CardString[] = [sorted[0]];
    for (let i = 1; i < sorted.length; i++) {
      const prevRankIdx = rankIndex[getRank(currentSeq[currentSeq.length - 1])];
      const currRankIdx = rankIndex[getRank(sorted[i])];
      if (currRankIdx === prevRankIdx + 1) {
        currentSeq.push(sorted[i]);
      } else {
        if (currentSeq.length > bestSequence.length) {
          bestSequence = currentSeq;
        }
        currentSeq = [sorted[i]];
      }
    }
    if (currentSeq.length > bestSequence.length) {
      bestSequence = currentSeq;
    }
  }

  if (bestSequence.length < 3) return null;

  const points = bestSequence.length === 3 ? 20 : bestSequence.length === 4 ? 50 : 100;
  return { points, sequence: bestSequence };
}

/**
 * Detects the highest Mosal (four of a kind) in a hand.
 */
export function detectMosal(hand: CardString[]): { points: number; rank: string; cards: CardString[] } | null {
  const rankCounts: Record<string, CardString[]> = {};
  for (const card of hand) {
    const rank = getRank(card);
    if (!rankCounts[rank]) rankCounts[rank] = [];
    rankCounts[rank].push(card);
  }

  const mosalRankPoints: Record<string, number> = {
    J: 200,
    '9': 150,
    A: 100,
    '10': 100,
    K: 100,
    Q: 100,
  };

  let bestMosal: { points: number; rank: string; cards: CardString[] } | null = null;

  for (const [rank, cards] of Object.entries(rankCounts)) {
    if (cards.length === 4 && mosalRankPoints[rank]) {
      if (!bestMosal || mosalRankPoints[rank] > bestMosal.points) {
        bestMosal = { points: mosalRankPoints[rank], rank, cards };
      }
    }
  }

  return bestMosal;
}

/**
 * Converts detected bonuses into BonusClaim objects.
 */
export function detectAllBonuses(hand: CardString[]): BonusClaim[] {
  const bonuses: BonusClaim[] = [];

  const bnaga = detectBnaga(hand);
  if (bnaga) {
    bonuses.push({
      type: 'bnaga',
      points: bnaga.points,
      cards: bnaga.sequence,
      description: `Bnaga ${bnaga.sequence.length} (${bnaga.points} pts)`,
    });
  }

  const mosal = detectMosal(hand);
  if (mosal) {
    bonuses.push({
      type: 'mosal',
      points: mosal.points,
      cards: mosal.cards,
      description: `Mosal ${mosal.rank} (${mosal.points} pts)`,
    });
  }

  return bonuses;
}

/**
 * Resolves bonus claims between two teams.
 * Returns the effective bonus points for each team.
 */
export function resolveBonusClaims(
  teamABonuses: BonusClaim[],
  teamBBonuses: BonusClaim[],
): { teamAPoints: number; teamBPoints: number } {
  // Find highest mosal for each team
  const teamAMosal = teamABonuses
    .filter((b) => b.type === 'mosal')
    .sort((a, b) => b.points - a.points)[0];
  const teamBMosal = teamBBonuses
    .filter((b) => b.type === 'mosal')
    .sort((a, b) => b.points - a.points)[0];

  // Compare mosals
  if (teamAMosal && teamBMosal) {
    if (teamAMosal.points > teamBMosal.points) {
      return {
        teamAPoints: sumBonuses(teamABonuses),
        teamBPoints: 0,
      };
    } else if (teamBMosal.points > teamAMosal.points) {
      return {
        teamAPoints: 0,
        teamBPoints: sumBonuses(teamBBonuses),
      };
    }
    // Equal mosal → fall through to sequence comparison
  } else if (teamAMosal) {
    return {
      teamAPoints: sumBonuses(teamABonuses),
      teamBPoints: 0,
    };
  } else if (teamBMosal) {
    return {
      teamAPoints: 0,
      teamBPoints: sumBonuses(teamBBonuses),
    };
  }

  // Compare longest sequence
  const teamASeq = getBestSequence(teamABonuses);
  const teamBSeq = getBestSequence(teamBBonuses);

  if (teamASeq && teamBSeq) {
    if (teamASeq.cards.length > teamBSeq.cards.length) {
      return { teamAPoints: sumBonuses(teamABonuses), teamBPoints: 0 };
    } else if (teamBSeq.cards.length > teamASeq.cards.length) {
      return { teamAPoints: 0, teamBPoints: sumBonuses(teamBBonuses) };
    }
    // Equal length → compare highest card in sequence
    const aHigh = getHighestSequenceCard(teamASeq.cards);
    const bHigh = getHighestSequenceCard(teamBSeq.cards);
    if (aHigh > bHigh) {
      return { teamAPoints: sumBonuses(teamABonuses), teamBPoints: 0 };
    } else {
      return { teamAPoints: 0, teamBPoints: sumBonuses(teamBBonuses) };
    }
  } else if (teamASeq) {
    return { teamAPoints: sumBonuses(teamABonuses), teamBPoints: 0 };
  } else if (teamBSeq) {
    return { teamAPoints: 0, teamBPoints: sumBonuses(teamBBonuses) };
  }

  return { teamAPoints: 0, teamBPoints: 0 };
}

function sumBonuses(bonuses: BonusClaim[]): number {
  return bonuses.reduce((sum, b) => sum + b.points, 0);
}

function getBestSequence(bonuses: BonusClaim[]): BonusClaim | undefined {
  return bonuses
    .filter((b) => b.type === 'bnaga')
    .sort((a, b) => b.cards.length - a.cards.length)[0];
}

function getHighestSequenceCard(cards: CardString[]): number {
  // Sequence high-card tiebreak: A > K > Q > J > 10 > 9 > ... > 2
  const rankOrder: Record<string, number> = {
    '2': 0, '3': 1, '4': 2, '5': 3, '6': 4, '7': 5, '8': 6,
    '9': 7, '10': 8, J: 9, Q: 10, K: 11, A: 12,
  };
  return Math.max(...cards.map((c) => rankOrder[getRank(c)] ?? 0));
}
