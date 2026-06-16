import * as functions from 'firebase-functions';
import { db } from '../config/admin';

/**
 * One-time function to seed the first super admin.
 * Only works when the `admins` collection is empty.
 * The authenticated caller is promoted to super_admin.
 */
export const seedFirstSuperAdmin = functions.https.onCall(async (request) => {
  if (!request.auth?.uid) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  const existing = await db.collection('admins').limit(1).get();
  if (!existing.empty) {
    throw new functions.https.HttpsError(
      'failed-precondition',
      'Admins collection is not empty. Use the admin dashboard to manage admins.',
    );
  }

  const uid = request.auth.uid;
  const email = request.auth.token.email || '';
  const now = new Date();

  await db.collection('admins').doc(uid).set({
    uid,
    email,
    displayName: email.split('@')[0] || 'Super Admin',
    role: 'super_admin',
    createdAt: now,
    updatedAt: now,
  });

  await db.collection('admin_logs').add({
    actorUid: uid,
    action: 'seedFirstSuperAdmin',
    targetType: 'admin',
    targetId: uid,
    payload: { email },
    createdAt: now,
  });

  return { success: true, role: 'super_admin' };
});
