import { buildStreamPayload, isPlayingRoomAbandoned, shouldAutoCreateStream } from '../utils/streaming';

describe('buildStreamPayload', () => {
  const roomPlayers = [
    { uid: 'host', displayName: 'Hosty', avatarUrl: 'a.png', team: 'A', agoraUid: 11, isMicOn: true, isCameraOn: true },
    { uid: 'p2', displayName: '', team: 'B' },
  ];

  it('builds a live stream doc payload from room + players', () => {
    const now = new Date('2026-01-01T00:00:00Z');
    const payload = buildStreamPayload({
      roomId: 'r1',
      room: { name: 'My Room', creatorUid: 'host', agoraChannelName: 'room_r1' },
      hostUid: 'host',
      roomPlayers,
      now,
    });

    expect(payload).toMatchObject({
      roomId: 'r1',
      hostUid: 'host',
      hostName: 'Hosty',
      hostAvatar: 'a.png',
      title: 'My Room',
      status: 'live',
      viewerCount: 2,
      agoraChannelName: 'room_r1',
      playerUids: ['host', 'p2'],
      createdAt: now,
    });
    expect(payload.players).toEqual([
      { uid: 'host', name: 'Hosty', avatarUrl: 'a.png', agoraUid: 11, team: 'A', isCameraOn: true, isMicOn: true },
      { uid: 'p2', name: 'Player', avatarUrl: '', agoraUid: 0, team: 'B', isCameraOn: false, isMicOn: true },
    ]);
  });

  it('falls back to defaults for title, channel and mic state', () => {
    const payload = buildStreamPayload({
      roomId: 'r2',
      room: {},
      hostUid: 'missing',
      roomPlayers,
    });
    expect(payload.title).toBe("Host's Stream");
    expect(payload.agoraChannelName).toBe('room_r2');
    expect(payload.hostName).toBe('Host');
    // isMicOn defaults to on unless explicitly false.
    expect(payload.players[1].isMicOn).toBe(true);
  });
});

describe('shouldAutoCreateStream', () => {
  it('auto-creates for liveStream and public rooms not already streaming', () => {
    expect(shouldAutoCreateStream({ type: 'liveStream' })).toBe(true);
    expect(shouldAutoCreateStream({ type: 'liveStream', isStreaming: false })).toBe(true);
    expect(shouldAutoCreateStream({ type: 'liveStream', isStreaming: true })).toBe(false);
    expect(shouldAutoCreateStream({ type: 'public' })).toBe(true);
    expect(shouldAutoCreateStream({ type: 'public', isStreaming: true })).toBe(false);
    expect(shouldAutoCreateStream({ type: 'private' })).toBe(false);
    expect(shouldAutoCreateStream({})).toBe(false);
  });
});


describe('isPlayingRoomAbandoned', () => {
  const now = new Date('2026-01-01T01:00:00Z');
  const minutesAgo = (m: number) => new Date(now.getTime() - m * 60 * 1000);

  it('is abandoned when the room has no gameId', () => {
    expect(isPlayingRoomAbandoned({}, null, now)).toBe(true);
    expect(isPlayingRoomAbandoned({ gameId: null }, null, now)).toBe(true);
    expect(isPlayingRoomAbandoned({ gameId: '' }, null, now)).toBe(true);
  });

  it('is abandoned when the game doc is missing', () => {
    expect(isPlayingRoomAbandoned({ gameId: 'g1' }, null, now)).toBe(true);
  });

  it('is abandoned when the game has no readable updatedAt', () => {
    expect(isPlayingRoomAbandoned({ gameId: 'g1' }, {}, now)).toBe(true);
    expect(
      isPlayingRoomAbandoned({ gameId: 'g1' }, { updatedAt: 'not-a-date' }, now),
    ).toBe(true);
  });

  it('is not abandoned while the game is actively updated', () => {
    const game = { updatedAt: minutesAgo(5) };
    expect(isPlayingRoomAbandoned({ gameId: 'g1' }, game, now)).toBe(false);
  });

  it('is abandoned once the game has been silent past the stale window', () => {
    const game = { updatedAt: minutesAgo(31) };
    expect(isPlayingRoomAbandoned({ gameId: 'g1' }, game, now)).toBe(true);
  });

  it('supports Firestore Timestamp-like updatedAt values', () => {
    const fresh = { updatedAt: { toMillis: () => minutesAgo(2).getTime() } };
    const stale = { updatedAt: { toMillis: () => minutesAgo(45).getTime() } };
    expect(isPlayingRoomAbandoned({ gameId: 'g1' }, fresh, now)).toBe(false);
    expect(isPlayingRoomAbandoned({ gameId: 'g1' }, stale, now)).toBe(true);
  });

  it('treats exactly-at-threshold as still alive', () => {
    const game = { updatedAt: minutesAgo(30) };
    expect(isPlayingRoomAbandoned({ gameId: 'g1' }, game, now)).toBe(false);
  });
});
