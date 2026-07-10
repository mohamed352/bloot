import { onDocumentWritten } from 'firebase-functions/v2/firestore';
import { mirrorGameToRtdb, removeGameFromRtdb } from '../utils/rtdbMirror';

/**
 * Mirrors the authoritative Firestore game document to Realtime Database.
 *
 * The WebView loads the Firebase JS SDK and watches the RTDB node directly,
 * avoiding the Firestore → Flutter → JS-bridge latency that was causing
 * perceptible lag during bidding and card play.
 *
 * Ended games are removed from RTDB to keep storage bounded.
 */
export const mirrorGameToRtdbTrigger = onDocumentWritten(
  {
    document: 'games/{gameId}',
    maxInstances: 10,
  },
  async (event) => {
    const after = event.data?.after;
    if (!after?.exists) {
      // Game was deleted; also delete the RTDB mirror.
      await removeGameFromRtdb(event.params.gameId);
      return;
    }

    const game = after.data() as any;
    if (game.status === 'gameEnd' || game.endedAt) {
      // Keep the final state briefly available, then remove it. The final
      // score screen is rendered from the last snapshot before removal.
      await mirrorGameToRtdb(game);
      return;
    }

    await mirrorGameToRtdb(game);
  },
);
