/**
 * Shared helpers for building live stream documents so startStream and game
 * auto-start paths emit identical payloads.
 */

export interface StreamRoomPlayer {
  uid: string;
  displayName?: string;
  avatarUrl?: string;
  team?: string;
  agoraUid?: number;
  isCameraOn?: boolean;
  isMicOn?: boolean;
}

export interface StreamRoomData {
  name?: string;
  creatorUid?: string;
  agoraChannelName?: string;
}

/**
 * Builds the Firestore payload for a `streams` document from a room and its
 * players. Pure function — callers decide when/where to persist it.
 */
export function buildStreamPayload(params: {
  roomId: string;
  room: StreamRoomData;
  hostUid: string;
  roomPlayers: StreamRoomPlayer[];
  now?: Date;
}): Record<string, any> {
  const { roomId, room, hostUid, roomPlayers } = params;
  const now = params.now ?? new Date();

  const players = roomPlayers.map((p) => ({
    uid: p.uid,
    name: p.displayName || 'Player',
    avatarUrl: p.avatarUrl || '',
    agoraUid: p.agoraUid || 0,
    team: p.team || 'A',
    isCameraOn: p.isCameraOn === true,
    isMicOn: p.isMicOn !== false,
  }));

  const hostPlayer = roomPlayers.find((p) => p.uid === hostUid);
  const hostName = hostPlayer?.displayName || room.creatorUid || 'Host';
  const hostAvatar = hostPlayer?.avatarUrl || '';

  return {
    roomId,
    hostUid,
    hostName,
    hostAvatar,
    title: room.name || `${hostName}'s Stream`,
    status: 'live',
    viewerCount: roomPlayers.length,
    agoraChannelName: room.agoraChannelName || `room_${roomId}`,
    players,
    playerUids: roomPlayers.map((p) => p.uid),
    createdAt: now,
  };
}

/**
 * Whether a game start should also auto-create a stream doc for the room.
 * Never duplicates an existing stream.
 */
export function shouldAutoCreateStream(room: {
  type?: string;
  isStreaming?: boolean;
}): boolean {
  return room.type === 'liveStream' && room.isStreaming !== true;
}

/** How long a playing room's game may go without a write before the room is
 * considered abandoned. Game docs are written on every action (and turn
 * timers / autoPlay keep writes coming), so 30 minutes of silence means all
 * clients disappeared without calling leaveGame. */
export const PLAYING_ROOM_STALE_MS = 30 * 60 * 1000;

/**
 * Whether a room stuck in `playing` status is abandoned: it has no game, the
 * game doc is gone, or the game has not been written to for `staleMs`.
 * Pure function so the scheduled sweeper stays unit-testable.
 */
export function isPlayingRoomAbandoned(
  room: { gameId?: string | null },
  game: { updatedAt?: unknown } | null,
  now: Date = new Date(),
  staleMs: number = PLAYING_ROOM_STALE_MS,
): boolean {
  if (room.gameId == null || room.gameId.length === 0) return true;
  if (game == null) return true;

  const updatedAt = game.updatedAt;
  let millis: number | null = null;
  if (updatedAt instanceof Date) {
    millis = updatedAt.getTime();
  } else if (typeof updatedAt === 'number') {
    millis = updatedAt;
  } else if (
    updatedAt != null &&
    typeof (updatedAt as { toMillis?: unknown }).toMillis === 'function'
  ) {
    millis = (updatedAt as { toMillis: () => number }).toMillis();
  }
  // A game with no readable updatedAt cannot prove it is alive.
  if (millis == null) return true;

  return now.getTime() - millis > staleMs;
}
