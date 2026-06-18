import { db } from '../config/admin';

/**
 * Deterministic string hash (Java-style) for generating integer Agora UIDs.
 */
function hashCode(str: string): number {
  let hash = 0;
  for (let i = 0; i < str.length; i++) {
    const char = str.charCodeAt(i);
    hash = ((hash << 5) - hash) + char;
    hash |= 0; // Convert to 32bit integer
  }
  return Math.abs(hash);
}

interface PlayerInfo {
  uid: string;
  displayName: string;
  avatarUrl: string;
}

async function fetchPlayerInfos(uids: string[]): Promise<PlayerInfo[]> {
  const uniqueUids = Array.from(new Set(uids.filter(Boolean)));
  const docs = await Promise.all(uniqueUids.map((uid) => db.collection('users').doc(uid).get()));
  const infoByUid = new Map<string, PlayerInfo>();
  docs.forEach((doc) => {
    const data = doc.data();
    if (doc.exists && data) {
      infoByUid.set(doc.id, {
        uid: doc.id,
        displayName: String(data.displayName ?? 'Player'),
        avatarUrl: String(data.avatarUrl ?? ''),
      });
    }
  });
  return uids.map((uid) =>
    infoByUid.get(uid) ?? { uid, displayName: 'Player', avatarUrl: '' },
  );
}

/**
 * Creates a 4-player room for a tournament match using the supplied fixed teams.
 * Returns the created room ID.
 */
export async function createTournamentMatchRoom({
  tournamentId,
  matchId,
  teamAPlayerIds,
  teamBPlayerIds,
}: {
  tournamentId: string;
  matchId: string;
  teamAPlayerIds: string[];
  teamBPlayerIds: string[];
}): Promise<string> {
  if (teamAPlayerIds.length !== 2 || teamBPlayerIds.length !== 2) {
    throw new Error('Each team must have exactly 2 players');
  }

  const [teamAInfos, teamBInfos] = await Promise.all([
    fetchPlayerInfos(teamAPlayerIds),
    fetchPlayerInfos(teamBPlayerIds),
  ]);

  const roomRef = db.collection('rooms').doc();
  const now = new Date();

  const seatA0 = teamAInfos[0];
  const seatA1 = teamAInfos[1];
  const seatB0 = teamBInfos[0];
  const seatB1 = teamBInfos[1];

  await roomRef.set({
    id: roomRef.id,
    name: `Tournament Match`,
    type: 'tournament',
    tournamentId,
    matchId,
    status: 'waiting',
    voiceEnabled: true,
    cameraEnabled: false,
    allowSpectators: true,
    gameSpeed: 'normal',
    players: [
      {
        uid: seatA0.uid,
        displayName: seatA0.displayName,
        avatarUrl: seatA0.avatarUrl,
        team: 'A',
        seatIndex: 0,
        isReady: false,
        isMicOn: true,
        isCameraOn: false,
        agoraUid: hashCode(seatA0.uid),
        joinedAt: now,
      },
      {
        uid: seatA1.uid,
        displayName: seatA1.displayName,
        avatarUrl: seatA1.avatarUrl,
        team: 'A',
        seatIndex: 1,
        isReady: false,
        isMicOn: true,
        isCameraOn: false,
        agoraUid: hashCode(seatA1.uid),
        joinedAt: now,
      },
      {
        uid: seatB0.uid,
        displayName: seatB0.displayName,
        avatarUrl: seatB0.avatarUrl,
        team: 'B',
        seatIndex: 2,
        isReady: false,
        isMicOn: true,
        isCameraOn: false,
        agoraUid: hashCode(seatB0.uid),
        joinedAt: now,
      },
      {
        uid: seatB1.uid,
        displayName: seatB1.displayName,
        avatarUrl: seatB1.avatarUrl,
        team: 'B',
        seatIndex: 3,
        isReady: false,
        isMicOn: true,
        isCameraOn: false,
        agoraUid: hashCode(seatB1.uid),
        joinedAt: now,
      },
    ],
    playerUids: [...teamAPlayerIds, ...teamBPlayerIds],
    teamA: teamAPlayerIds,
    teamB: teamBPlayerIds,
    readyPlayers: [],
    currentPlayerCount: 4,
    maxPlayers: 4,
    agoraChannelName: `tournament_${tournamentId}_${matchId}`,
    createdAt: now,
    updatedAt: now,
  });

  return roomRef.id;
}
