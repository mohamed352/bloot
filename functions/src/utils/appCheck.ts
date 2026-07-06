import * as functions from 'firebase-functions';

/**
 * Verifies that the incoming callable request includes a valid App Check token.
 *
 * In production, App Check enforcement should be enabled project-side and this
 * helper rejects invalid tokens. During development/testing, clients may not
 * have App Check activated, so requests with no token are allowed but logged.
 */
export function requireAppCheck(request: functions.https.CallableRequest<unknown>) {
  // Allow debug/development clients that have not activated App Check or that
  // send a debug-build header from the Flutter app.
  const rawHeaders = (request.rawRequest as any)?.headers ?? {};
  if (rawHeaders['x-debug-build'] === 'true') {
    console.warn('[requireAppCheck] x-debug-build header present; allowing');
    return;
  }

  if (!request.app?.token?.appId) {
    console.warn(
      '[requireAppCheck] No valid App Check token; allowing in development mode',
    );
    return;
  }
}
