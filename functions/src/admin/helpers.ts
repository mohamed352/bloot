import * as functions from 'firebase-functions';
import { db } from '../config/admin';

export interface AdminDoc {
  uid: string;
  email: string;
  role: 'super_admin' | 'moderator' | 'support';
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

export async function verifyAdmin(uid: string): Promise<AdminDoc> {
  const adminDoc = await db.collection('admins').doc(uid).get();
  if (!adminDoc.exists) {
    throw new functions.https.HttpsError('permission-denied', 'Admin access required');
  }
  return adminDoc.data() as AdminDoc;
}

export async function verifyRole(
  uid: string,
  ...allowedRoles: AdminDoc['role'][]
): Promise<AdminDoc> {
  const adminDoc = await verifyAdmin(uid);
  if (!allowedRoles.includes(adminDoc.role)) {
    throw new functions.https.HttpsError('permission-denied', `${allowedRoles.join('/')} access required`);
  }
  return adminDoc;
}

type Permission = 'view' | 'moderate' | 'manage' | 'super';

const ROLE_PERMISSIONS: Record<AdminDoc['role'], Permission[]> = {
  support: ['view', 'moderate'],
  moderator: ['view', 'moderate', 'manage'],
  super_admin: ['view', 'moderate', 'manage', 'super'],
};

export async function verifyPermission(
  uid: string,
  permission: Permission,
): Promise<AdminDoc> {
  const adminDoc = await verifyAdmin(uid);
  if (!ROLE_PERMISSIONS[adminDoc.role].includes(permission)) {
    throw new functions.https.HttpsError('permission-denied', `${permission} permission required`);
  }
  return adminDoc;
}

export async function logAdminAction(
  actorUid: string,
  action: string,
  targetType: string,
  targetId: string,
  payload?: Record<string, unknown> | object,
): Promise<void> {
  await db.collection('admin_logs').add({
    actorUid,
    action,
    targetType,
    targetId,
    payload: payload ?? null,
    createdAt: new Date(),
  });
}
