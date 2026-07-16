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
    playerUids.splice(playerUids.indexOf(currentUid), 1);
    readyPlayers.splice(readyPlayers.indexOf(currentUid), 1);
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

    // If the creator is leaving and the room is streaming, end the stream
    // so it doesn't stay live after the host is gone.
    if (isCreatorLeaving && data.isStreaming === true) {
      const streamId = data.streamId as string | undefined;
      if (streamId != null && streamId.length > 0) {
        const streamRef = db.collection('streams').doc(streamId);
        transaction.update(streamRef, {
          status: 'ended',
          endedAt: FieldValue.serverTimestamp(),
        });
      }
    }

    // Mark player as disconnected in the active game document.
    const gameId = data.gameId as string | undefined;
    if (gameId != null && data.status === 'playing') {
      const gameRef = db.collection('games').doc(gameId);
      const gameDoc = await transaction.get(gameRef);
      if (gameDoc.exists) {
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
    }

    if (playerUids.length === 0) {
      // If this room was streaming, end the stream so it doesn't stay live
      // after the room is gone.
      const streamId = data.streamId as string | undefined;
      if (streamId != null && streamId.length > 0) {
        const streamRef = db.collection('streams').doc(streamId);
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
    }

    return { success: true };
  });
});
