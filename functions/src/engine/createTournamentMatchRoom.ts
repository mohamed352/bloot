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

/**
 * Creates a 4-player room for a tournament match.
 * Returns the created room ID.
 */
export async function createTournamentMatchRoom({
  tournamentId,
  matchId,
  playerAUid,
  playerBUid,
  participantPool,
}: {
  tournamentId: string;
  matchId: string;
  playerAUid: string;
  playerBUid: string;
  participantPool: string[];
}): Promise<string> {
  // Get user profiles for the two captains
  const [userADoc, userBDoc] = await Promise.all([
    db.collection('users').doc(playerAUid).get(),
    db.collection('users').doc(playerBUid).get(),
  ]);

  const userA = userADoc.data();
  const userB = userBDoc.data();

  // Pick random partners from the remaining participant pool
  const remaining = participantPool.filter(
    (uid) => uid !== playerAUid && uid !== playerBUid,
  );

  // Shuffle remaining to pick random partners
  for (let i = remaining.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [remaining[i], remaining[j]] = [remaining[j], remaining[i]];
  }

  const partnerA = remaining[0] ?? playerAUid;
  const partnerB = remaining[1] ?? playerBUid;

  const teamA = [playerAUid, partnerA];
  const teamB = [playerBUid, partnerB];

  const roomRef = db.collection('rooms').doc();
  const now = new Date();

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
        uid: playerAUid,
        displayName: userA?.displayName ?? 'Player A',
        avatarUrl: userA?.avatarUrl ?? '',
        team: 'A',
        seatIndex: 0,
        isReady: false,
        isMicOn: true,
        isCameraOn: false,
        agoraUid: hashCode(playerAUid),
        joinedAt: now,
      },
      {
        uid: partnerA,
        displayName: 'Partner A',
        avatarUrl: '',
        team: 'A',
        seatIndex: 1,
        isReady: false,
        isMicOn: true,
        isCameraOn: false,
        agoraUid: hashCode(partnerA),
        joinedAt: now,
      },
      {
        uid: playerBUid,
        displayName: userB?.displayName ?? 'Player B',
        avatarUrl: userB?.avatarUrl ?? '',
        team: 'B',
        seatIndex: 2,
        isReady: false,
        isMicOn: true,
        isCameraOn: false,
        agoraUid: hashCode(playerBUid),
        joinedAt: now,
      },
      {
        uid: partnerB,
        displayName: 'Partner B',
        avatarUrl: '',
        team: 'B',
        seatIndex: 3,
        isReady: false,
        isMicOn: true,
        isCameraOn: false,
        agoraUid: hashCode(partnerB),
        joinedAt: now,
      },
    ],
    playerUids: [...teamA, ...teamB],
    teamA,
    teamB,
    readyPlayers: [],
    currentPlayerCount: 4,
    maxPlayers: 4,
    agoraChannelName: `tournament_${tournamentId}_${matchId}`,
    createdAt: now,
    updatedAt: now,
  });

  return roomRef.id;
}
