import * as functions from 'firebase-functions';

/**
 * Verifies that the incoming callable request includes a valid App Check token.
 *
 * App Check enforcement should be enabled project-side; this helper adds a
 * defense-in-depth check for sensitive functions.
 */
export function requireAppCheck(request: functions.https.CallableRequest<unknown>) {
  // Skip App Check verification when running against the Firebase emulator
  // suite. The Flutter client does not activate App Check in emulator mode, so
  // callable requests from local development will not include an App Check
  // token.
  if (process.env.FUNCTIONS_EMULATOR) {
    return;
  }

  if (!request.app?.token?.appId) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'App Check token is missing or invalid.',
    );
  }
}
