import { createGameDocument, loadMatch, saveMatch } from '../engine/gameAdapter';
import { BalootEngine } from '../engine/balootEngine';

describe('gameAdapter', () => {
  it('creates a valid game document', () => {
    const game = createGameDocument('g1', 'r1', [
      { uid: 'a', displayName: 'A', team: 'A', seatIndex: 0, agoraUid: 1, isMuted: false, hasCamera: true },
      { uid: 'b', displayName: 'B', team: 'B', seatIndex: 1 },
      { uid: 'c', displayName: 'C', team: 'A', seatIndex: 2 },
      { uid: 'd', displayName: 'D', team: 'B', seatIndex: 3 },
    ]);

    expect(game.status).toBe('bidding');
    expect(game.players['0'].hand).toHaveLength(5);
    expect(game.engineState).toBeDefined();
    expect(game.players['0'].agoraUid).toBe(1);
    expect(game.players['0'].hasCamera).toBe(true);
  });

  it('finalizes bidding and exposes 8-card hands', () => {
    const game = createGameDocument('g1', 'r1', [
      { uid: 'a', displayName: 'A', team: 'A', seatIndex: 0 },
      { uid: 'b', displayName: 'B', team: 'B', seatIndex: 1 },
      { uid: 'c', displayName: 'C', team: 'A', seatIndex: 2 },
      { uid: 'd', displayName: 'D', team: 'B', seatIndex: 3 },
    ]);

    const engine = new BalootEngine();
    const match = loadMatch(game);
    engine.applyBid(match, match.state!.bidding.turn, { type: 'sun' });
    saveMatch(game, match);

    expect(game.status).toBe('playing');
    expect(game.gameType).toBe('sun');
    expect(game.players['0'].hand).toHaveLength(8);
    expect(game.currentTrick.cards['0']).toBeNull();
  });

  it('defensively sorts roomPlayers by seatIndex before seating', () => {
    const game = createGameDocument('g1', 'r1', [
      { uid: 'd', displayName: 'D', team: 'B', seatIndex: 3 },
      { uid: 'a', displayName: 'A', team: 'A', seatIndex: 0 },
      { uid: 'c', displayName: 'C', team: 'A', seatIndex: 2 },
      { uid: 'b', displayName: 'B', team: 'B', seatIndex: 1 },
    ]);

    expect(game.playerUids).toEqual(['a', 'b', 'c', 'd']);
    expect(game.players['0'].uid).toBe('a');
    expect(game.players['1'].uid).toBe('b');
    expect(game.players['2'].uid).toBe('c');
    expect(game.players['3'].uid).toBe('d');
  });
});
