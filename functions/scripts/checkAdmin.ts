import * as admin from 'firebase-admin';

admin.initializeApp();

const uid = process.argv[2] || 'mJkUWwztmmMtYkJzafj0nwkcjMn1';

async function check() {
  const doc = await admin.firestore().collection('admins').doc(uid).get();
  if (!doc.exists) {
    console.log('Admin document NOT FOUND for uid:', uid);
    return;
  }
  console.log('Admin document found:');
  console.log(doc.data());
}

check()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
