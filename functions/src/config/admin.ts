import * as admin from 'firebase-admin';

// `createCustomToken` (used to mint the RTDB auth token for the WebView) signs
// the JWT via the IAM Credentials API when running under Application Default
// Credentials, so the Admin SDK must know which service account to sign as.
//
// 2nd-gen Cloud Functions run as the Compute Engine default service account
// (`<projectNumber>-compute@developer.gserviceaccount.com`), NOT the App Engine
// `appspot` one (which does not exist for this project). That runtime SA has
// been granted `roles/iam.serviceAccountTokenCreator` on itself so it is allowed
// to call `iam.serviceAccounts.signBlob` for its own email.
//
// Override with FUNCTIONS_SERVICE_ACCOUNT if the runtime identity ever changes.
const DEFAULT_RUNTIME_SERVICE_ACCOUNT =
  '738592764893-compute@developer.gserviceaccount.com';

admin.initializeApp({
  serviceAccountId:
    process.env.FUNCTIONS_SERVICE_ACCOUNT ?? DEFAULT_RUNTIME_SERVICE_ACCOUNT,
});

export const db = admin.firestore();
export const auth = admin.auth();
export const rtdb = admin.app().database('https://bloot-89b2b-default-rtdb.firebaseio.com/');
export { admin };
