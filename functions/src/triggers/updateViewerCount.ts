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

        const viewersSnap = await streamRef.collection('viewers').count().get();
        const viewerCount = viewersSnap.data().count;

        const streamData = streamDoc.data()!;
        const peakViewerCount = Math.max(
          viewerCount,
          (streamData.peakViewerCount as number) ?? 0,
        );

        transaction.update(streamRef, {
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
