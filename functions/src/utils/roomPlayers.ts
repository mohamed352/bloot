/**
 * Shared helpers for keeping room players consistent with the engine's
 * seat/team parity rule: teamOf(seat) = seat % 2 (0 = Team A, 1 = Team B).
 *
 * Canonical seating is [A1, B1, A2, B2] on seats [0, 1, 2, 3].
 */

export interface TeamSeatedPlayer {
  uid: string;
  team: 'A' | 'B';
  seatIndex: number;
  isReady?: boolean;
  isBot?: boolean;
}

/**
 * Converts 2 Team A + 2 Team B players to parity order [A1, B1, A2, B2],
 * reassigning seatIndex 0..3. Order within a team follows current seatIndex.
 *
 * If the input is not exactly 2v2, players are returned sorted by seatIndex
 * unchanged otherwise (defensive fallback — callers validate team balance).
 */
export function normalizeParitySeats<T extends TeamSeatedPlayer>(players: T[]): T[] {
  const bySeat = [...players].sort((a, b) => a.seatIndex - b.seatIndex);
  const teamA = bySeat.filter((p) => p.team === 'A');
  const teamB = bySeat.filter((p) => p.team === 'B');
  if (players.length !== 4 || teamA.length !== 2 || teamB.length !== 2) {
    return bySeat;
  }
  const ordered = [teamA[0], teamB[0], teamA[1], teamB[1]];
  return ordered.map((p, i) => ({ ...p, seatIndex: i }));
}

/**
 * Returns the free parity seat for a team (A: 0/2, B: 1/3), or null if the
 * team has no free seat.
 */
export function freeParitySeat(
  players: Array<Pick<TeamSeatedPlayer, 'seatIndex'>>,
  team: 'A' | 'B',
): number | null {
  const taken = new Set(players.map((p) => p.seatIndex));
  const seats = team === 'A' ? [0, 2] : [1, 3];
  for (const seat of seats) {
    if (!taken.has(seat)) return seat;
  }
  return null;
}

/**
 * Allocates a free parity seat for a joining player, preferring the team with
 * fewer players (Team A on ties). Returns null when no seat is available.
 */
export function allocateParitySeat(
  players: Array<Pick<TeamSeatedPlayer, 'team' | 'seatIndex'>>,
): { team: 'A' | 'B'; seatIndex: number } | null {
  const countA = players.filter((p) => p.team === 'A').length;
  const countB = players.filter((p) => p.team === 'B').length;
  const order: Array<'A' | 'B'> = countA <= countB ? ['A', 'B'] : ['B', 'A'];
  for (const team of order) {
    const seatIndex = freeParitySeat(players, team);
    if (seatIndex !== null) return { team, seatIndex };
  }
  return null;
}

/**
 * UIDs of players that are actually ready (bots count ready via isReady).
 */
export function computeReadyPlayers(
  players: Array<Pick<TeamSeatedPlayer, 'uid' | 'isReady'>>,
): string[] {
  return players.filter((p) => p.isReady === true).map((p) => p.uid);
}

/**
 * A full room may auto-start only when every final human player is ready;
 * bots always count as ready.
 */
export function canAutoStartGame(
  players: Array<Pick<TeamSeatedPlayer, 'isReady' | 'isBot'>>,
): boolean {
  return (
    players.length === 4 &&
    players.every((p) => p.isBot === true || p.isReady === true)
  );
}
