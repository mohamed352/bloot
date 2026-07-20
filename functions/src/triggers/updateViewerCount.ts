import { onDocumentWritten } from 'firebase-functions/v2/firestore';
import { db } from '../config/admin';

/**
 * Keeps stream.viewerCount and stream.peakViewerCount in sync with the
 * streams/{streamId}/viewers subcollection.
 */
export const updateViewerCount = onDocumentWritten(
  'streams/{streamId}/viewers/{viewerId}',
  async (event) => {
    const { streamId } = event.params;
    const streamRef = db.collection('streams').doc(streamId);

    try {
      await db.runTransaction(async (transaction) => {
        const streamDoc = await transaction.get(streamRef);
        if (!streamDoc.exists) return;

        const streamData = streamDoc.data()!;
        const viewersSnap = await streamRef.collection('viewers').count().get();
        const spectatorCount = viewersSnap.data().count;

        // Include room players in the viewer count so the total reflects
        // everyone watching (players + spectators).
        const playerUids = streamData.playerUids as string[] | undefined;
        const playerCount = Array.isArray(playerUids) ? playerUids.length : 0;
        const viewerCount = spectatorCount + playerCount;

        const peakViewerCount = Math.max(
          viewerCount,
          (streamData.peakViewerCount as number) ?? 0,
        );

        transaction.update(streamRef, {
          spectatorCount,
          viewerCount,
          peakViewerCount,
          updatedAt: new Date(),
        });
      });
    } catch (error) {
      console.error(`Failed to update viewer count for stream ${streamId}`, error);
    }
  },
);
