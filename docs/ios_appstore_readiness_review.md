# iOS & App Store Readiness Review — Bloot

**Date:** 2026-07-12
**Verdict: ❌ NOT ready for iOS production / App Store submission.**
There are **3 launch-crash blockers**, **1 guaranteed rejection issue**, and several required fixes before upload.

> **Update 2026-08-14:** see "Rejection round 2 (2026-08-14)" at the bottom for the latest App Review rejection and its resolution.

---

## 🔴 CRITICAL — App will crash or fail to build on iOS

### 1. `GoogleService-Info.plist` is NOT added to the Xcode project
- File exists at `ios/Runner/GoogleService-Info.plist` (valid, bundle `com.bloot.app`) but is **not referenced in `project.pbxproj`** and not in the Runner Resources build phase.
- **Result:** Firebase fails at launch ("Could not locate configuration file") — app crashes on first Firebase call.
- **Fix:** Open `ios/Runner.xcworkspace` in Xcode → drag `GoogleService-Info.plist` into the Runner target with "Copy items if needed" checked.

### 2. Entitlements file is not wired into the build
- `ios/Runner/Runner.entitlements` exists with `com.apple.developer.applesignin` ✅, but `CODE_SIGN_ENTITLEMENTS` is **absent from `project.pbxproj`** — the file is never used.
- **Result:** Sign in with Apple fails at runtime on device.
- **Fix:** In Xcode → Runner target → Signing & Capabilities → add "Sign In with Apple" capability (this links the entitlements automatically). Also enable **Push Notifications** capability here.

### 3. Deployment target mismatch — build will fail
- `project.pbxproj`: `IPHONEOS_DEPLOYMENT_TARGET = 13.0`
- `ios/Podfile`: `platform :ios, '14.0'`
- `firebase_core 4.7.0` pulls **Firebase iOS SDK 12.x, which requires iOS 15.0**.
- **Result:** `pod install` fails / archive fails.
- **Fix:** Set **15.0** in BOTH the Xcode project (Runner target + project) and the Podfile (`platform :ios, '15.0'` and the `post_install` loop).

### 4. No `DEVELOPMENT_TEAM` set
- Signing is unconfigured; `flutter build ios --release` / archive will fail.
- **Fix:** Select your Apple Developer team in Xcode → Signing & Capabilities.

---

## 🔴 CRITICAL — Guaranteed App Store rejection

### 5. UGC reporting & blocking not reachable in the app (Guideline 1.2)
Your app has live streams, voice/video rooms and chat = user-generated content. Apple **requires** in-app tools to:
- **Report** offensive users/content — ⚠️ the Cloud Function `reportUser` EXISTS (`functions/src/https/reportUser.ts`) but is **never called from `lib/`**. There is no report button anywhere (stream, profile, chat). The translation key `report_a_problem` exists but is unused.
- **Block** abusive users — ❌ completely missing. `privacy_settings_page.dart:52-66` shows a placeholder ("No blocked users" snackbar); no `blockUser` in app or backend.

**Fix:** Add "Report" button on user profiles, streams and chat messages (wire to existing `reportUser` function), and implement a real block list (hide blocked users' content/messages/streams).

### 6. Missing Privacy Manifest (`PrivacyInfo.xcprivacy`)
- Required by Apple since May 2024 for apps using Firebase, Crashlytics, Agora, etc.
- Not present anywhere in `ios/`. Expect ITMS-91053/91054 warnings or rejection at upload.
- **Fix:** Add `ios/Runner/PrivacyInfo.xcprivacy` declaring required-reason API usage (e.g. `NSPrivacyAccessedAPICategoryUserDefaults` with reason `CA92.1`, file timestamp `C617.1` etc. per your actual SDK usage) and add it to the Xcode project.

---

## 🟡 HIGH — Features will silently not work on iOS

### 7. Push notifications will NOT work
- `aps-environment` is **commented out** in `Runner.entitlements`; no Push capability; no `remote-notification` in `UIBackgroundModes`.
- Also `FirebaseMessaging.setForegroundNotificationPresentationOptions(...)` is never called → foreground notifications are silently swallowed on iOS (`notification_service.dart`).
- **Fix:** Enable Push capability (uncomment aps-environment), add `remote-notification` background mode, upload APNs Auth Key to Firebase Console, and add the foreground presentation options call.

### 8. Voice/video calls die in background (Agora)
- `Info.plist` has **no `UIBackgroundModes` at all**. iOS suspends the app ~30s after backgrounding → calls drop. `agora_service.dart:517` "keep audio alive" is a false promise on iOS.
- **Fix:** Add `UIBackgroundModes` → `audio`.

### 9. Universal Links not configured
- Only custom scheme `bloot://` works. No `com.apple.developer.associated-domains` entitlement, no apple-app-site-association (AASA) file.
- If invite/share links are `https://` URLs, they will NOT open the app on iOS.
- **Fix:** Add associated-domains entitlement + host AASA file, or confirm all sharing uses `bloot://` links.

### 10. No `Podfile.lock`
- iOS has never been built on this machine; builds are non-reproducible. Run `cd ios && pod install` after fixing the deployment target and commit the lock file.

---

## ✅ What is already GOOD (compliant)

| Area | Status |
|---|---|
| Sign in with Apple (Guideline 4.8) | ✅ Fully implemented (`sign_in_with_apple` + Firebase `OAuthProvider`), Apple button shown on iOS only alongside Google |
| Account deletion (Guideline 5.1.1(v)) | ✅ Full in-app deletion (Settings → Danger Zone) + server-side purge Cloud Function `deleteAccount` |
| Privacy policy / Terms in app | ✅ Present, linked from settings & signup; terms acceptance required at signup |
| Permission strings (camera/mic/photos) | ✅ Present in Info.plist |
| `ITSAppUsesNonExemptEncryption` | ✅ Set to false |
| Payments / coins (Guideline 3.1.1) | ✅ No purchase flow exists → compliant today. ⚠️ When coin purchasing/gifting ships, it MUST use Apple IAP |
| Android-only code | ✅ None found; platform branching is clean |
| All packages | ✅ iOS-supported (agora, audioplayers, webview wkwebview, image_picker, firebase, etc.) |
| Location | ✅ Not used — no concerns |

---

## 🟠 App Store Connect metadata (manual steps at submission)

1. **Age rating: 17+** — unrestricted UGC, live streaming, chat, voice/video (terms already say 18+, but there is no DOB/age gate in the app — consider adding one).
2. **Privacy Policy URL** — must be hosted at a public URL and entered in App Store Connect (in-app page alone is not enough).
3. **App Privacy (nutrition label)** — declare data collection: email, name, photos, voice/video (not stored), user content, identifiers, usage data (Firebase Analytics/Crashlytics).
4. Sign in with Apple already enabled in Firebase ✅ — make sure the Services ID / key config matches the iOS bundle `com.bloot.app`.

---

## 🟢 Minor / recommended

- Permission strings & legal pages are **English only** — app supports Arabic; localize or reviewers/Arabic users see English.
- "Last updated: May 2024" on privacy policy is stale.
- `Share.share(...)` calls lack `sharePositionOrigin` → can crash share sheet on **iPad**.
- `AVAudioSession` activated at launch with `.playAndRecord` is aggressive (early mic indicator); consider activating on room join.
- Terms §6 mentions coin purchases being "final" but no purchases exist — adjust or implement IAP when monetizing.
- Consider capturing Apple's first-auth `givenName`/email into the profile.

---

## Fix checklist (in order)

1. [x] Raise deployment target to **15.0** (pbxproj + Podfile + post_install) ✅ DONE
2. [x] Add `GoogleService-Info.plist` to Runner target in Xcode ✅ DONE (wired in project.pbxproj)
3. [x] Enable capabilities in Xcode: **Sign In with Apple** (entitlements now linked), **Push Notifications** (aps-environment enabled), **Background Modes (Audio, Remote notifications)** ✅ DONE in files — ⚠️ still verify in Xcode Signing & Capabilities that it shows no errors
4. [ ] Set `DEVELOPMENT_TEAM` — **YOU MUST DO THIS** in Xcode (needs your Apple Developer account)
5. [x] Add `PrivacyInfo.xcprivacy` to the project ✅ DONE
6. [ ] `cd ios && pod install` on a Mac, commit `Podfile.lock` (requires macOS)
7. [x] Add Report UI (profile/stream/chat) wired to `reportUser` + implement Block user ✅ DONE (new `lib/features/moderation/` + `blockUser`/`unblockUser` Cloud Functions)
8. [x] Add `setForegroundNotificationPresentationOptions` in notification service ✅ DONE
9. [ ] (Optional) Universal Links / associated domains + AASA
10. [ ] Test full flow on a real iPhone: Apple sign-in, Google sign-in, voice room (background test), push, account deletion
11. [ ] App Store Connect: 17+ rating, privacy policy URL, privacy nutrition label
12. [ ] Deploy new backend: `firebase deploy --only firestore:rules,functions` (block feature + new rules)


---

## Rejection round 2 (2026-08-14) — App Review on build 1.0 (19)

Apple rejected the resubmission with three issues. Resolution implemented on 2026-08-14:

### 1. Guideline 4 (Design) — Sign in with Apple re-asks for the user's name
- **Issue:** The app requested `fullName`/`email` scopes but discarded them; first-time Apple users had to type a display name on the complete-profile screen.
- **Fix (code):** `auth_remote_data_source.dart` now captures `givenName`/`familyName` from the Apple credential (with a Firebase profile-name fallback for Google/Apple re-auths), exposes it via `consumePrefillDisplayName()`, and `AuthCubit` carries it in `AuthState.profileRequired.prefilledDisplayName`. `CompleteProfilePage` pre-fills the display-name field from it. Username and the ToS checkbox are still asked — Apple does not provide a username and the app requires one for chat/search, so this is compliant.

### 2. Guideline 2.5.4 (Performance) — `audio` in UIBackgroundModes
- **Issue:** Reviewers found no audible content in the background.
- **Decision:** KEEP the mode — Agora voice chat in game rooms/streams intentionally continues in background (`agora_service.dart enterBackgroundMode()`), which is a legitimate use.
- **Fix (code):** Removed the `AVAudioSession.setActive(true)` at app launch from `AppDelegate.swift` (it made the declaration look speculative and showed the mic indicator early). Agora activates its own audio session on channel join. Also switched `aps-environment` to `production` in `Runner.entitlements`.
- **Fix (manual, App Review reply):** Attach a physical-device screen recording showing voice continuing while the app is backgrounded (two accounts in a room; navigate to Home Screen in the recording) and reference it in the App Review Information notes.

### 3. Guideline 2.1(a) (Information Needed) — demo account
- **Issue:** No username+password demo account; the app only had social sign-in.
- **Fix (code):** Added a visible "Sign in with Email" button on the login page → new `EmailSignInPage` (`/email-sign-in`, public route) backed by `signInWithEmailAndPassword` through `AuthRemoteDataSource.signInWithEmailPassword` → `AuthRepository.signInWithEmail` → `AuthCubit.signInWithEmail`.
- **Fix (backend scripts):**
  - `functions/scripts/createDemoReviewer.ts` (`npm run seed:reviewer`) — creates `reviewer@bloot.app` with a complete Firestore profile (`isProfileComplete: true`, stats, coins).
  - `functions/scripts/seedDemoContent.ts` (`npm run seed:demo`) — seeds 3 bot users, DM conversations/messages, followers/following, and game history for the reviewer.
- **Fix (manual, App Store Connect):** Add the demo credentials to App Review Information → Demo Account, and notes: sign in with email → Home → "Play with Bots" for a full 4-player game with live voice/chat; a live stream appears in Discover.
- **Watch out:** verify App Check (App Attest/DeviceCheck) works on the release build so `createRoomWithBots` succeeds for the reviewer.
