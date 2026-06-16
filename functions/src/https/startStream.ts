import * as functions from 'firebase-functions';
import { db } from '../config/admin';
import { requireAppCheck } from '../utils/appCheck';

export const startStream = functions.https.onCall(async (request) => {
  if (!request.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  requireAppCheck(request);

  const authUid = request.auth.uid;
  const { roomId } = request.data;
  if (!roomId || typeof roomId !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing roomId');
  }

  const roomRef = db.collection('rooms').doc(roomId);
  const streamRef = db.collection('streams').doc();

  return db.runTransaction(async (transaction) => {
    const roomDoc = await transaction.get(roomRef);
    if (!roomDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Room not found');
    }

    const room = roomDoc.data()!;

    // Only creator can start stream
    if (room.creatorUid !== authUid) {
      throw new functions.https.HttpsError('permission-denied', 'Only creator can start stream');
    }

    // Must not already be streaming
    if (room.isStreaming === true) {
      throw new functions.https.HttpsError('failed-precondition', 'Room is already streaming');
    }

    // Build player list for stream doc
    const roomPlayers = (room.players || []) as Array<{
      uid: string;
      displayName: string;
      avatarUrl?: string;
      team: string;
      agoraUid?: number;
      isCameraOn?: boolean;
      isMicOn?: boolean;
    }>;

    const players = roomPlayers.map((p) => ({
      uid: p.uid,
      name: p.displayName || 'Player',
      avatarUrl: p.avatarUrl || '',
      agoraUid: p.agoraUid || 0,
      team: p.team || 'A',
      isCameraOn: p.isCameraOn === true,
      isMicOn: p.isMicOn !== false,
    }));

    // Find host name from creator
    const hostPlayer = roomPlayers.find((p) => p.uid === authUid);
    const hostName = hostPlayer?.displayName || room.creatorUid || 'Host';
    const hostAvatar = hostPlayer?.avatarUrl || '';

    const now = new Date();

    // Create stream document
    transaction.set(streamRef, {
      roomId,
      hostUid: authUid,
      hostName,
      hostAvatar,
      title: room.name || `${hostName}'s Stream`,
      status: 'live',
      viewerCount: 0,
      agoraChannelName: room.agoraChannelName || `room_${roomId}`,
      players,
      createdAt: now,
    });

    // Update room
    transaction.update(roomRef, {
      isStreaming: true,
      streamId: streamRef.id,
      updatedAt: now,
    });

    return { streamId: streamRef.id };
  });
});
