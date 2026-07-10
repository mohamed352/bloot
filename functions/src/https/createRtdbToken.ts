import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { requireAppCheck } from '../utils/appCheck';

/**
 * Creates a Firebase custom token so the WebView can authenticate its own
 * Firebase JS SDK instance and read the low-latency Realtime Database game
 * mirror with the same UID as the native Flutter app.
 */
export const createRtdbToken = functions.https.onCall(async (request) => {
  if (!request.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  requireAppCheck(request);

  try {
    const token = await admin.auth().createCustomToken(request.auth.uid);
    return { token };
  } catch (e) {
    console.error('[createRtdbToken] failed to create custom token:', e);
    throw new functions.https.HttpsError('internal', 'Failed to create RTDB token');
  }
});
