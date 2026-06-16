import * as functions from 'firebase-functions';
import { db } from '../config/admin';
import { verifyAdmin, logAdminAction, AdminDoc } from './helpers';
import {
  AddAdminInput,
  RemoveAdminInput,
  UpdateAdminRoleInput,
  SuccessResponse,
} from './types';

function assertAuth(request: functions.https.CallableRequest<unknown>): string {
  if (!request.auth?.uid) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }
  return request.auth.uid;
}

function assertSuperAdmin(admin: AdminDoc): void {
  if (admin.role !== 'super_admin') {
    throw new functions.https.HttpsError('permission-denied', 'Super admin access required');
  }
}

export const addAdmin = functions.https.onCall(async (request) => {
  const actorUid = assertAuth(request);
  const actor = await verifyAdmin(actorUid);
  assertSuperAdmin(actor);

  const { uid, email, role } = request.data as AddAdminInput;
  if (!uid || typeof uid !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing uid');
  }
  if (!email || typeof email !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing email');
  }
  if (!role || typeof role !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing role');
  }

  const adminRef = db.collection('admins').doc(uid);
  const existing = await adminRef.get();
  if (existing.exists) {
    throw new functions.https.HttpsError('already-exists', 'Admin already exists');
  }
  const validRoles: AdminDoc['role'][] = ['super_admin', 'moderator', 'support'];
  if (!validRoles.includes(role as AdminDoc['role'])) {
    throw new functions.https.HttpsError('invalid-argument', 'Invalid role');
  }

  const now = new Date();
  await adminRef.set({
    uid,
    email,
    role,
    createdAt: now,
    updatedAt: now,
  });

  await logAdminAction(actorUid, 'addAdmin', 'admin', uid, { email, role });
  return { success: true } as SuccessResponse;
});

export const removeAdmin = functions.https.onCall(async (request) => {
  const actorUid = assertAuth(request);
  const actor = await verifyAdmin(actorUid);
  assertSuperAdmin(actor);

  const { uid } = request.data as RemoveAdminInput;
  if (!uid || typeof uid !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing uid');
  }

  if (uid === actorUid) {
    throw new functions.https.HttpsError('invalid-argument', 'Cannot remove yourself');
  }

  const target = await db.collection('admins').doc(uid).get();
  if (!target.exists) {
    throw new functions.https.HttpsError('not-found', 'Admin not found');
  }
  if (target.data()!.role === 'super_admin') {
    const superAdminCount = await db.collection('admins').where('role', '==', 'super_admin').count().get();
    if (superAdminCount.data().count <= 1) {
      throw new functions.https.HttpsError('failed-precondition', 'Cannot remove the last super admin');
    }
  }

  await db.collection('admins').doc(uid).delete();

  await logAdminAction(actorUid, 'removeAdmin', 'admin', uid, {});
  return { success: true } as SuccessResponse;
});

export const updateAdminRole = functions.https.onCall(async (request) => {
  const actorUid = assertAuth(request);
  const actor = await verifyAdmin(actorUid);
  assertSuperAdmin(actor);

  const { uid, role } = request.data as UpdateAdminRoleInput;
  if (!uid || typeof uid !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing uid');
  }
  if (!role || typeof role !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing role');
  }

  if (uid === actorUid && role !== 'super_admin') {
    throw new functions.https.HttpsError('invalid-argument', 'Cannot demote yourself');
  }

  const validRoles: AdminDoc['role'][] = ['super_admin', 'moderator', 'support'];
  if (!validRoles.includes(role as AdminDoc['role'])) {
    throw new functions.https.HttpsError('invalid-argument', 'Invalid role');
  }

  const adminRef = db.collection('admins').doc(uid);
  await db.runTransaction(async (transaction) => {
    const adminDoc = await transaction.get(adminRef);
    if (!adminDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Admin not found');
    }
    if (adminDoc.data()!.role === 'super_admin' && role !== 'super_admin') {
      const superAdminCountSnap = await db
        .collection('admins')
        .where('role', '==', 'super_admin')
        .count()
        .get();
      if (superAdminCountSnap.data().count <= 1) {
        throw new functions.https.HttpsError('failed-precondition', 'Cannot demote the last super admin');
      }
    }
    transaction.update(adminRef, {
      role,
      updatedAt: new Date(),
    });
  });

  await logAdminAction(actorUid, 'updateAdminRole', 'admin', uid, { role });
  return { success: true } as SuccessResponse;
});
