import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { requireAppCheck } from '../utils/appCheck';

/**
 * Deletes a user's account and all associated data.
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
    // Delete user subcollections
    const subcollections = ['gameHistory', 'achievements', 'notifications', 'transactions'];
    const userRef = db.collection('users').doc(uid);

    for (const subcollection of subcollections) {
      const snapshot = await userRef.collection(subcollection).get();
      const batch = db.batch();
      snapshot.docs.forEach((doc) => batch.delete(doc.ref));
      await batch.commit();
      functions.logger.info(`Deleted ${snapshot.size} docs from users/${uid}/${subcollection}`);
    }

    // Delete user doc
    await userRef.delete();
    functions.logger.info(`Deleted user doc for ${uid}`);

    // Delete auth user
    await admin.auth().deleteUser(uid);
    functions.logger.info(`Deleted auth user ${uid}`);

    return { success: true };
  } catch (error) {
    functions.logger.error(`Failed to delete account for ${uid}`, error);
    throw new functions.https.HttpsError('internal', 'Failed to delete account. Please try again.');
  }
});
