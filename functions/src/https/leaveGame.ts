import * as functions from 'firebase-functions';
import { FieldValue } from 'firebase-admin/firestore';
import { db } from '../config/admin';
import { requireAppCheck } from '../utils/appCheck';

/**
 * Server-side handler for a player leaving a room/game.
 *
 * Since game documents are client-read-only, this function updates both the
 * room and the active game document (marking the player disconnected) in a
 * single transaction.
 */
export const leaveGame = functions.https.onCall(async (request) => {
  if (!request.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  requireAppCheck(request);

  const { roomId } = request.data;
  if (!roomId || typeof roomId !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing roomId');
  }

  const currentUid = request.auth.uid;
  const roomRef = db.collection('rooms').doc(roomId);

  return db.runTransaction(async (transaction) => {
    const doc = await transaction.get(roomRef);
    if (!doc.exists) {
      // The room is already gone, so the user has effectively left. Treat as
      // success to avoid errors when the client back-presses before the room
      // document is fully replicated to the server.
      return { success: true };
    }

    const data = doc.data()!;
    const players = Array.from(data.players as any[] ?? []);
    const playerUids = Array.from(data.playerUids as string[] ?? []);
    const readyPlayers = Array.from(data.readyPlayers as string[] ?? []);
    const teamA = Array.from(data.teamA as string[] ?? []);
    const teamB = Array.from(data.teamB as string[] ?? []);

    const playerIndex = players.findIndex((p: any) => p.uid === currentUid);
    if (playerIndex === -1) {
      throw new functions.https.HttpsError('permission-denied', 'Not a player in this room');
    }

    players.splice(playerIndex, 1);
    // Guard every splice: indexOf returns -1 when the uid is absent, and
    // splice(-1, 1) would silently remove the LAST element, corrupting the
    // arrays (this made subsequent leave attempts fail for everyone).
    const playerUidsIndex = playerUids.indexOf(currentUid);
    if (playerUidsIndex !== -1) playerUids.splice(playerUidsIndex, 1);
    const readyPlayersIndex = readyPlayers.indexOf(currentUid);
    if (readyPlayersIndex !== -1) readyPlayers.splice(readyPlayersIndex, 1);
    const teamAIndex = teamA.indexOf(currentUid);
    if (teamAIndex !== -1) teamA.splice(teamAIndex, 1);
    const teamBIndex = teamB.indexOf(currentUid);
    if (teamBIndex !== -1) teamB.splice(teamBIndex, 1);

    let newCreatorUid: string | undefined;
    const oldCreatorUid = data.creatorUid as string | undefined;
    const isCreatorLeaving = oldCreatorUid === currentUid;
    if (isCreatorLeaving && playerUids.length > 0) {
      newCreatorUid = playerUids[0];
    }

    // Read the stream doc up-front: Firestore transactions require all reads
    // to happen before any writes.
    const streamId = data.streamId as string | undefined;
    const hasActiveStream =
      data.isStreaming === true && streamId != null && streamId.length > 0;
    let streamRef: FirebaseFirestore.DocumentReference | null = null;
    let streamDoc: FirebaseFirestore.DocumentSnapshot | null = null;
    if (hasActiveStream) {
      streamRef = db.collection('streams').doc(streamId!);
      streamDoc = await transaction.get(streamRef);
    }

    // Also read the game doc up-front (all reads before all writes).
    const gameId = data.gameId as string | undefined;
    const hasActiveGame = gameId != null && data.status === 'playing';
    let gameRef: FirebaseFirestore.DocumentReference | null = null;
    let gameDoc: FirebaseFirestore.DocumentSnapshot | null = null;
    if (hasActiveGame) {
      gameRef = db.collection('games').doc(gameId!);
      gameDoc = await transaction.get(gameRef);
    }

    // If the creator is leaving and the room is streaming, end the stream
    // so it doesn't stay live after the host is gone.
    let streamContinues = false;
    if (isCreatorLeaving && hasActiveStream && streamRef != null) {
      transaction.update(streamRef, {
        status: 'ended',
        endedAt: FieldValue.serverTimestamp(),
      });
    } else if (hasActiveStream && playerUids.length > 0) {
      // A non-creator player left: keep the stream doc's roster and viewer
      // count in sync with the room.
      streamContinues = true;
    }

    // Mark player as disconnected in the active game document.
    if (gameRef != null && gameDoc != null && gameDoc.exists) {
      const gameData = gameDoc.data()!;
      const gamePlayers = { ...(gameData.players as Record<string, any> ?? {}) };
      for (const entry of Object.entries(gamePlayers)) {
        const p = entry[1] as Record<string, any>;
        if (p.uid === currentUid) {
          gamePlayers[entry[0]] = {
            ...p,
            isConnected: false,
            leftAt: FieldValue.serverTimestamp(),
          };
          break;
        }
      }
      transaction.update(gameRef, { players: gamePlayers });
    }

    if (playerUids.length === 0) {
      // If this room was streaming, end the stream so it doesn't stay live
      // after the room is gone.
      if (hasActiveStream && streamRef != null && !isCreatorLeaving) {
        transaction.update(streamRef, {
          status: 'ended',
          endedAt: FieldValue.serverTimestamp(),
        });
      }
      transaction.delete(roomRef);
    } else {
      const updateData: Record<string, any> = {
        players,
        playerUids,
        readyPlayers,
        teamA,
        teamB,
        currentPlayerCount: players.length,
        updatedAt: FieldValue.serverTimestamp(),
      };
      if (newCreatorUid != null) {
        updateData.creatorUid = newCreatorUid;
      }
      if (isCreatorLeaving && data.isStreaming === true) {
        updateData.isStreaming = false;
        updateData.streamId = null;
      }
      transaction.update(roomRef, updateData);

      if (streamContinues && streamRef != null && streamDoc != null && streamDoc.exists) {
        const spectatorCount =
          (streamDoc.data()?.spectatorCount as number | undefined) ?? 0;
        transaction.update(streamRef, {
          players: players.map((p: any) => ({
            uid: p.uid,
            name: p.displayName ?? p.name ?? 'Player',
            avatarUrl: p.avatarUrl ?? '',
            agoraUid: p.agoraUid ?? 0,
            team: p.team ?? 'A',
            isCameraOn: p.isCameraOn === true,
            isMicOn: p.isMicOn !== false,
          })),
          playerUids,
          viewerCount: playerUids.length + spectatorCount,
        });
      }
    }

    return { success: true };
  });
});
