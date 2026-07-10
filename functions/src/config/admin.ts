import * as admin from 'firebase-admin';

admin.initializeApp();

export const db = admin.firestore();
export const auth = admin.auth();
export const rtdb = admin.app().database('https://bloot-89b2b-default-rtdb.firebaseio.com/');
export { admin };
