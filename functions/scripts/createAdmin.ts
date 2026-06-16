/**
 * Create an admin account in Firebase Auth + Firestore.
 *
 * Run with:
 *   npx ts-node scripts/createAdmin.ts
 *
 * Requires GOOGLE_APPLICATION_CREDENTIALS to be set, e.g. (PowerShell):
 *   $env:GOOGLE_APPLICATION_CREDENTIALS="C:\path\to\serviceAccountKey.json"
 *   npx ts-node scripts/createAdmin.ts
 */
import * as admin from 'firebase-admin';

admin.initializeApp();

const db = admin.firestore();
const auth = admin.auth();

async function createAdmin(email: string, password: string, displayName: string) {
  let user: admin.auth.UserRecord;

  try {
    user = await auth.createUser({
      email,
      password,
      displayName,
      emailVerified: true,
    });
    console.log('Created Firebase Auth user:', user.uid);
  } catch (err: any) {
    if (err.code === 'auth/email-already-exists') {
      user = await auth.getUserByEmail(email);
      console.log('Using existing Firebase Auth user:', user.uid);
    } else {
      throw err;
    }
  }

  const now = new Date();
  await db.collection('admins').doc(user.uid).set({
    uid: user.uid,
    email: user.email || email,
    displayName: user.displayName || displayName,
    role: 'super_admin',
    createdAt: now,
    updatedAt: now,
  });

  console.log('Added admin document for:', user.uid);
  console.log('You can now sign in at http://localhost:3000 with:');
  console.log('  Email:', email);
  console.log('  Password:', password);
}

// Default credentials. Change these before running.
const EMAIL = process.env.ADMIN_EMAIL || 'admin@bloot.app';
const PASSWORD = process.env.ADMIN_PASSWORD || 'BlootAdmin2024!';
const DISPLAY_NAME = process.env.ADMIN_NAME || 'Super Admin';

createAdmin(EMAIL, PASSWORD, DISPLAY_NAME)
  .then(() => process.exit(0))
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
