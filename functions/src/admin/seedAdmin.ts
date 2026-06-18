import * as functions from 'firebase-functions';
import { db } from '../config/admin';

/**
 * One-time function to seed the first super admin.
 * Only works when the `admins` collection is empty and the caller's email
 * matches the deployment-time configured `INITIAL_SUPER_ADMIN_EMAIL`.
 */
const INITIAL_SUPER_ADMIN_EMAIL = functions.params.defineString(
  'INITIAL_SUPER_ADMIN_EMAIL',
  {
    description:
      'Email address allowed to seed the first super admin. Required to prevent privilege escalation.',
    default: '',
  },
);

export const seedFirstSuperAdmin = functions.https.onCall(
  {
    memory: '256MiB',
  },
  async (request) => {
    if (!request.auth?.uid) {
      throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
    }

    const allowedEmail = INITIAL_SUPER_ADMIN_EMAIL.value().trim().toLowerCase();
    if (!allowedEmail) {
      throw new functions.https.HttpsError(
        'failed-precondition',
        'INITIAL_SUPER_ADMIN_EMAIL is not configured. Set it via Firebase Functions configuration before seeding.',
      );
    }

    const callerEmail = (request.auth.token.email || '').toLowerCase();
    if (callerEmail !== allowedEmail) {
      throw new functions.https.HttpsError(
        'permission-denied',
        'Caller email does not match the configured initial super admin email.',
      );
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
  },
);
