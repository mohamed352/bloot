import { GameDocument } from '../models/game';
import { CardString, getCardPoints, getSuit } from '../models/card';

/**
 * Calculates the total card points for a collection of cards.
 */
export function countCardPoints(cards: CardString[], trumpSuit: string | null): number {
  return cards.reduce((sum, card) => {
    const isTrump = trumpSuit !== null && getSuit(card) === trumpSuit;
    return sum + getCardPoints(card, isTrump);
  }, 0);
}

/**
 * Calculates round scores and determines if a team fell.
 * Also applies bonus points (Hokm only).
 */
export function calculateRoundScore(game: GameDocument): {
  teamAPoints: number;
  teamBPoints: number;
  fell: 'A' | 'B' | null;
} {
  if (!game.gameType) {
    throw new Error('Game type must be set before scoring');
  }

  // Gather all taken cards for each team
  const teamACards: CardString[] = [];
  const teamBCards: CardString[] = [];

  for (const [, player] of Object.entries(game.players)) {
    if (player.team === 'A') {
      teamACards.push(...player.takenCards);
    } else {
      teamBCards.push(...player.takenCards);
    }
  }

  const teamACardPoints = countCardPoints(teamACards, game.trumpSuit);
  const teamBCardPoints = countCardPoints(teamBCards, game.trumpSuit);

  const totalCardPoints = teamACardPoints + teamBCardPoints;
  const expectedTotal = game.gameType === 'sun' ? 120 : 152;

  // In a correctly played round, total card points must equal the expected total.
  // A mismatch indicates a bug in dealing or trick-taking; log loudly but do not
  // silently normalize, which can hide engine defects and produce unfair outcomes.
  if (totalCardPoints > 0 && Math.abs(totalCardPoints - expectedTotal) > 0) {
    console.error(
      `Scoring mismatch: ${game.gameType} total=${totalCardPoints}, expected=${expectedTotal}`,
      { teamA: teamACardPoints, teamB: teamBCardPoints },
    );
  }

  const biddingTeam = game.biddingTeam;
  if (!biddingTeam) {
    return {
      teamAPoints: teamACardPoints,
      teamBPoints: teamBCardPoints,
      fell: null,
    };
  }

  if (game.gameType === 'sun') {
    // Bidding team must score > 60
    const bidderPoints = biddingTeam === 'A' ? teamACardPoints : teamBCardPoints;
    if (bidderPoints <= 60) {
      return {
        teamAPoints: biddingTeam === 'A' ? 0 : 120,
        teamBPoints: biddingTeam === 'B' ? 0 : 120,
        fell: biddingTeam,
      };
    }
    return {
      teamAPoints: teamACardPoints,
      teamBPoints: teamBCardPoints,
      fell: null,
    };
  }

  // Hokm mode
  const bidderPoints = biddingTeam === 'A' ? teamACardPoints : teamBCardPoints;
  const opponentPoints = biddingTeam === 'A' ? teamBCardPoints : teamACardPoints;

  if (bidderPoints <= opponentPoints) {
    // Bidding team falls: opponents get 152 + all raw bonuses from BOTH teams.
    // We intentionally use the raw claimed bonuses here because the claim-resolution
    // step nullifies the falling team's bonuses, but the rules award every claimed
    // bonus to the winning side when the bidding team falls.
    const totalBonuses = sumTeamBonuses(game, 'A') + sumTeamBonuses(game, 'B');

    return {
      teamAPoints: biddingTeam === 'A' ? 0 : 152 + totalBonuses,
      teamBPoints: biddingTeam === 'B' ? 0 : 152 + totalBonuses,
      fell: biddingTeam,
    };
  }

  // Both teams keep their points including their own valid bonuses.
  // Use pre-resolved bonus points if the bonus claim phase ran; otherwise sum raw claims.
  const { teamABonuses, teamBBonuses } = getEffectiveBonuses(game);

  return {
    teamAPoints: teamACardPoints + teamABonuses,
    teamBPoints: teamBCardPoints + teamBBonuses,
    fell: null,
  };
}

function sumTeamBonuses(game: GameDocument, team: 'A' | 'B'): number {
  let sum = 0;
  for (const player of Object.values(game.players)) {
    if (player.team === team && player.bonuses) {
      sum += player.bonuses.reduce((s, b) => s + b.points, 0);
    }
  }
  return sum;
}

function getEffectiveBonuses(game: GameDocument): { teamABonuses: number; teamBBonuses: number } {
  if (game.resolvedBonuses) {
    return {
      teamABonuses: game.resolvedBonuses.teamA,
      teamBBonuses: game.resolvedBonuses.teamB,
    };
  }
  return {
    teamABonuses: sumTeamBonuses(game, 'A'),
    teamBBonuses: sumTeamBonuses(game, 'B'),
  };
}

/**
 * Checks if the game has ended (a team reached target score).
 */
export function checkGameEnd(
  teamAScore: number,
  teamBScore: number,
  target: number,
): 'A' | 'B' | null {
  if (teamAScore >= target) return 'A';
  if (teamBScore >= target) return 'B';
  return null;
}
