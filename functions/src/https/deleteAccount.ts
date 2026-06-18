import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { requireAppCheck } from '../utils/appCheck';

const BATCH_SIZE = 500;

async function deleteCollectionDocs(
  query: FirebaseFirestore.Query,
): Promise<number> {
  let deleted = 0;
  while (true) {
    const snapshot = await query.limit(BATCH_SIZE).get();
    if (snapshot.empty) break;

    const batch = admin.firestore().batch();
    for (const doc of snapshot.docs) {
      batch.delete(doc.ref);
    }
    await batch.commit();
    deleted += snapshot.size;
    if (snapshot.size < BATCH_SIZE) break;
  }
  return deleted;
}

async function deleteSubcollection(
  parentRef: FirebaseFirestore.DocumentReference,
  subcollection: string,
): Promise<number> {
  return deleteCollectionDocs(parentRef.collection(subcollection));
}

/**
 * Deletes a user's account and as much associated data as possible.
 * Requires recent authentication.
 */
export const deleteAccount = functions.https.onCall(async (request) => {
  if (!request.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  requireAppCheck(request);

  const uid = request.auth.uid;
  const db = admin.firestore();

  try {
    const userRef = db.collection('users').doc(uid);

    // 1. Delete all user subcollections.
    const subcollections = [
      'gameHistory',
      'achievements',
      'notifications',
      'transactions',
      'followers',
      'following',
    ];
    for (const subcollection of subcollections) {
      const count = await deleteSubcollection(userRef, subcollection);
      functions.logger.info(`Deleted ${count} docs from users/${uid}/${subcollection}`);
    }

    // 2. Remove the user from social counters of users they followed / were followed by.
    const [followingSnap, followersSnap] = await Promise.all([
      userRef.collection('following').get(),
      userRef.collection('followers').get(),
    ]);

    const socialBatch = db.batch();
    for (const doc of followingSnap.docs) {
      const targetUid = doc.id;
      const targetRef = db.collection('users').doc(targetUid);
      socialBatch.update(targetRef, {
        followersCount: admin.firestore.FieldValue.increment(-1),
      });
      socialBatch.delete(db.collection('users').doc(targetUid).collection('followers').doc(uid));
    }
    for (const doc of followersSnap.docs) {
      const sourceUid = doc.id;
      const sourceRef = db.collection('users').doc(sourceUid);
      socialBatch.update(sourceRef, {
        followingCount: admin.firestore.FieldValue.increment(-1),
      });
      socialBatch.delete(db.collection('users').doc(sourceUid).collection('following').doc(uid));
    }
    await socialBatch.commit();

    // 3. Delete conversations where the user is a participant and their messages.
    const conversationsSnap = await db
      .collection('conversations')
      .where('participantUids', 'array-contains', uid)
      .get();
    for (const convDoc of conversationsSnap.docs) {
      await deleteSubcollection(convDoc.ref, 'messages');
      await convDoc.ref.delete();
    }

    // 4. Delete direct messages in the top-level collection.
    const messagesSnap = await db
      .collection('messages')
      .where('senderUid', '==', uid)
      .get();
    const messageBatch = db.batch();
    messagesSnap.docs.forEach((doc) => messageBatch.delete(doc.ref));
    await messageBatch.commit();

    // 5. Handle rooms created by the user: delete if empty, otherwise transfer ownership.
    const ownedRoomsSnap = await db.collection('rooms').where('creatorUid', '==', uid).get();
    for (const roomDoc of ownedRoomsSnap.docs) {
      const roomData = roomDoc.data();
      const playerUids = (roomData.playerUids ?? []) as string[];
      const remainingPlayers = playerUids.filter((id) => id !== uid);

      if (remainingPlayers.length === 0) {
        await deleteSubcollection(roomDoc.ref, 'chat');
        await roomDoc.ref.delete();
      } else {
        await roomDoc.ref.update({
          creatorUid: remainingPlayers[0],
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
    }

    // 6. Remove the user from tournaments they joined (upcoming only).
    const tournamentsSnap = await db
      .collection('tournaments')
      .where('participantIds', 'array-contains', uid)
      .get();
    for (const tournamentDoc of tournamentsSnap.docs) {
      const tournamentData = tournamentDoc.data();
      if (tournamentData.status === 'upcoming') {
        const participantIds = ((tournamentData.participantIds ?? []) as string[]).filter(
          (id) => id !== uid,
        );
        const maxParticipants = (tournamentData.maxParticipants as number) ?? 64;
        await tournamentDoc.ref.update({
          participantIds,
          participants: `${participantIds.length}/${maxParticipants}`,
          currentParticipants: participantIds.length,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
    }

    // 7. Delete streams hosted by the user.
    const streamsSnap = await db.collection('streams').where('hostUid', '==', uid).get();
    for (const streamDoc of streamsSnap.docs) {
      await deleteSubcollection(streamDoc.ref, 'viewers');
      await streamDoc.ref.delete();
    }

    // 8. Delete or anonymize reports.
    const reportsBySnap = await db.collection('reports').where('reporterUid', '==', uid).get();
    const reportsAboutSnap = await db.collection('reports').where('targetUid', '==', uid).get();
    const reportsBatch = db.batch();
    reportsBySnap.docs.forEach((doc) => reportsBatch.delete(doc.ref));
    reportsAboutSnap.docs.forEach((doc) => reportsBatch.delete(doc.ref));
    await reportsBatch.commit();

    // 9. Delete admin doc if present.
    const adminDoc = await db.collection('admins').doc(uid).get();
    if (adminDoc.exists) {
      await adminDoc.ref.delete();
    }

    // 10. Delete user doc and auth user.
    await userRef.delete();
    functions.logger.info(`Deleted user doc for ${uid}`);

    await admin.auth().deleteUser(uid);
    functions.logger.info(`Deleted auth user ${uid}`);

    return { success: true };
  } catch (error) {
    functions.logger.error(`Failed to delete account for ${uid}`, error);
    throw new functions.https.HttpsError(
      'internal',
      'Failed to delete account. Please try again.',
    );
  }
});
