# Bloot Release Checklist

This checklist covers the manual steps required after the automated build/fix
pass to ship a production-ready app and backend.

## Firebase Console (manual)

1. **Register Android app**
   - Download `google-services.json` for package `com.bloot.app`.
   - Replace `android/app/google-services.json`.
   - Enable Google Play Integrity / App Check for Android.

2. **Register iOS app**
   - Download `GoogleService-Info.plist` for bundle ID `com.bloot.app`.
   - Replace `ios/Runner/GoogleService-Info.plist`.
   - Enable App Attest / DeviceCheck for App Check.

3. **Web / reCAPTCHA**
   - In **Project settings > App Check > Web provider**, create a reCAPTCHA v3
     site key.
   - Update `lib/core/config/app_check_config.dart`:
     ```dart
     static const String recaptchaSiteKey = 'YOUR_REAL_RECAPTCHA_V3_SITE_KEY';
     ```

4. **Enforce App Check**
   - In the Firebase Console, go to **App Check** and enforce App Check for
     Cloud Firestore, Cloud Functions, and Cloud Storage once you have verified
     that real clients obtain valid App Check tokens.

5. **Remote Config defaults**
   - Publish the following default parameters in Firebase Remote Config so the
     app behaves correctly before the first fetch:
     - `force_update_version` (string, e.g. `""`)
     - `force_update_store_url` (string)
     - `maintenance_mode` (boolean, `false`)
     - `maintenance_message` (string)
     - `min_supported_version` (string)
     - `min_android_version` (string)
     - `min_ios_version` (string)
     - `enable_streaming` (boolean, `true`)
     - `agora_app_id` (string) — optional; when empty the compiled
       `AgoraConfig.appId` fallback is used.

6. **Cloud Functions secrets**
   - Set `AGORA_APP_CERTIFICATE` secret:
     ```bash
     firebase functions:secrets:set AGORA_APP_CERTIFICATE
     ```
   - The `AGORA_APP_ID` parameter is already declared in `functions/src/index.ts`
     and will be prompted on deploy if not set.

## Agora

1. Ensure the Agora App ID in `lib/core/config/agora_config.dart` matches the
   project registered in the Agora Console.
2. Optionally override it from Firebase Remote Config with the `agora_app_id`
   key.

## Android Release Keystore

1. Run one of the keystore generators from the `android/` directory:
   ```bash
   # Git Bash / WSL / macOS / Linux
   bash create_upload_keystore.sh
   
   # PowerShell
   .\create_upload_keystore.ps1
   ```
2. Copy `android/key.properties.template` to `android/key.properties` and fill
   in the passwords you entered during keystore creation.
3. Keep `android/app/upload-keystore.jks` and `key.properties` private and back
   them up securely. They are already ignored by `.gitignore`.

## Deployment

```bash
# Flutter
flutter build apk --release
flutter build appbundle --release

# iOS (macOS only)
flutter build ios --release

# Functions
firebase deploy --only functions

# Security rules
firebase deploy --only firestore:rules,firestore:indexes,storage

# Web admin
firebase deploy --only hosting
```

## Post-release

- Monitor Crashlytics for new crashes.
- Monitor Cloud Functions logs for Eventarc / trigger errors.
- Rotate any credentials that may have been exposed in earlier commits.
