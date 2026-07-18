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
    viewerCount: 0,
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
