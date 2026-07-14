import { onDocumentWritten } from 'firebase-functions/v2/firestore';
import { logger } from 'firebase-functions/v2';
import { getOrCreateUserAgoraUid } from '../utils/agoraUid';

/**
 * Ensures every user document has a stable, unique Agora UID.
 *
 * Runs on create and update so existing users that are missing `agoraUid`
 * (e.g., from before this trigger existed) are backfilled automatically.
 */
export const assignUserAgoraUid = onDocumentWritten(
  'users/{uid}',
  async (event) => {
    const after = event.data?.after?.data();
    if (!after) {
      // User was deleted; nothing to do.
      return;
    }

    const uid = event.params.uid;
    const agoraUid = after.agoraUid as number | undefined;
    if (agoraUid && Number.isInteger(agoraUid) && agoraUid > 0) {
      return;
    }

    try {
      await getOrCreateUserAgoraUid(uid);
      logger.info('Assigned Agora UID to user', { uid });
    } catch (e) {
      logger.error('Failed to assign Agora UID to user', { uid, error: e });
      throw e;
    }
  },
);
