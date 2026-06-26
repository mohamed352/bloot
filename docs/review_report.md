# Bloot — Full App Review & Solo Gameplay Testing Report

> **Review date:** 2026-06-16  
> **Reviewer:** Kimi Code CLI  
> **Scope:** Flutter app, Cloud Functions backend, Firestore schema, UX flows, and full Baloot gameplay loop.  
> **Goal:** Validate that the app works end-to-end, with special focus on 4-player gameplay testing as a solo developer.

---

## 1. Executive Summary

### 1.1 What Was Reviewed
- **Design & spec documents:** `docs/DESIGN.md`, `docs/game_rules.md`, `docs/implementation_plan.md`, `docs/firebase_schema.md`, `docs/AGENTS.md`.
- **Flutter app:** All major features (auth, home, discover, rooms, game, stream, chat, profile, settings).
- **Backend:** Cloud Functions game engine (dealing, bidding, trick play, scoring, bonuses, autoplay).
- **Tests:** Flutter unit/bloc/widget tests + Cloud Functions Jest tests.
- **Local gameplay:** `LocalGameSimulator` (1 human + 3 bots) and simulated full games.

### 1.2 Overall Health
| Area | Status | Notes |
|------|--------|-------|
| Core game engine (Cloud Functions) | ✅ Strong | Comprehensive Jest tests; rules implemented correctly. |
| Local 4-player simulator | ✅ Works | Can play full games solo on one device. |
| Flutter game UI | ⚠️ Mostly works | Landscape-only; some dead controls. |
| Auth & onboarding | ⚠️ Functional but gaps | Phone OTP works; social login placeholders. |
| Streaming/spectator | ⚠️ Partial | Stream discovery exists; viewer interactions mostly placeholders. |
| Social/chat | ⚠️ Partial | DM and room chat exist; room invites via chat may need verification. |
| Localization | ⚠️ Mostly good | Some hardcoded English on operational screens. |
| Integration/E2E tests | ❌ Missing | No Flutter integration tests; no automated 4-player online test. |

**Bottom line:** The app is functional enough for core Baloot gameplay, but several documented MVP features are still placeholders or partially wired. The biggest risk for a solo developer is verifying the real online 4-player path; this review provides a path to do that with Firebase emulator + bot harness.

---

## 2. Test Baseline

### 2.1 Flutter Tests
- **Status:** ✅ Passed
- **Command:** `flutter test --coverage --no-pub`
- **Result:** 61 tests passed, 0 failed (added 4 new local-simulator tests)
- **Static analysis:** ✅ `flutter analyze --no-pub` — No issues found
- **Line coverage:** 28.4% overall
  - auth: 73.6% (121 lines, 89 hit)
  - game: 31.9% (2039 lines, 651 hit)
  - lib/core: 3.1% (458 lines, 14 hit)
  - room: 0.0% (35 lines, 0 hit)
- **Note:** Coverage is concentrated in auth and game cubits. Repository implementations, room feature, and most UI screens are untested.

### 2.2 Cloud Functions Tests
- **Status:** ✅ Passed (after fixing TypeScript compile errors)
- **Command:** `cd functions && npm test`
- **Build:** ✅ `cd functions && npm run build` — compiles cleanly
- **Result:** 85 tests passed, 0 failed
- **Warning:** `scoring.test.ts` logs `console.error("Scoring mismatch...")` because unit tests use partial card distributions. This is expected in unit tests but indicates the engine will loudly flag any real dealing/trick-taking bug.

### 2.3 Coverage Gaps
| Layer | Coverage | Missing |
|-------|----------|---------|
| Game engine (Functions) | High | Minor edge cases around disconnects. |
| Game Cubit | Medium | Error-state branches, rematch, leave game. |
| Game page widget | Low | Only loading/playing state snapshots tested. |
| Room Cubit | None | All room flows untested. |
| Auth Cubit | High | OTP resend edge cases not covered. |
| Repository implementations | None | No Firebase emulator tests. |
| Integration/E2E | None | Biggest gap. |

---

## 3. Feature Review Matrix

### Phase 0 — Infrastructure
| Feature | Spec Status | Implemented | Issues | Priority |
|---------|-------------|-------------|--------|----------|
| Flutter project structure | ✅ | ✅ | Feature-first layout matches plan. | — |
| Dependencies / pubspec | ✅ | ✅ | All key packages present. | — |
| ColorManager / ThemeManager | ✅ | ✅ | Dark-only theme implemented. | — |
| Localization (AR/EN) | ✅ | ⚠️ | `easy_localization` wired, but `ForceUpdatePage` and `MaintenancePage` use hardcoded English; `startLocale` forced to Arabic ignoring device locale. | Medium |
| go_router routes | ✅ | ✅ | All routes defined; shell route for tabs. | — |
| Firebase project config | ✅ | ✅ | `firebase_options.dart` present. | — |
| Firestore rules | ✅ | ✅ | Rules file present; schema matches docs. | — |
| CI pipeline | ⚠️ | ⚠️ | `.github/workflows/ci.yml` runs Flutter analyze/test and Functions build/test. Missing web_admin job, coverage thresholds, integration tests. | Low |
| Fastlane | ❌ | ❌ | Not present. | Low |

### Phase 1 — Auth & Home
| Feature | Spec Status | Implemented | Issues | Priority |
|---------|-------------|-------------|--------|----------|
| Phone input + country selector | ✅ | ✅ | Default +966; country picker works. | — |
| OTP screen | ✅ | ⚠️ | Implemented as 4-digit; design docs mention 6-digit OTP. | Medium |
| Profile setup | ✅ | ✅ | Name, username, avatar, ToS. | — |
| Username availability | ✅ | ✅ | Debounced Firestore check. | — |
| Auth Cubit | ✅ | ✅ | OTP, profile completion, sign-out, delete account tested. | — |
| Welcome/onboarding | ✅ | ⚠️ | Static value-prop screen; docs describe swipeable 3-card onboarding. | Low |
| Social login (Apple/Google) | P2 | ❌ | Buttons show "Coming soon" snackbar; not wired. | Medium |
| Home screen | ✅ | ✅ | Hero banner, quick actions, live streams list. | — |
| Bottom navigation | ✅ | ✅ | 5 items, center gold Play button. | — |
| Pull-to-refresh / skeletons | ✅ | ✅ | Present on Home and Discover. | — |
| Notification bell | ✅ | ⚠️ | UI exists; unread-dot behavior not verified. | Low |

### Phase 2 — Rooms & Game
| Feature | Spec Status | Implemented | Issues | Priority |
|---------|-------------|-------------|--------|----------|
| Create room form | ✅ | ✅ | Name, type, voice/camera, advanced settings. | — |
| Room preview card | ✅ | ✅ | Live preview renders. | — |
| Room lobby | ✅ | ✅ | 4 seats, ready toggle, code copy/share, chat. | — |
| Start game (creator only) | ✅ | ✅ | Enabled when 4 ready. | — |
| Kick player | ✅ | ✅ | Creator-only. | — |
| Game play landscape | ✅ | ✅ | Orientation locked; seats, table, hand visible. | — |
| Card fan / selection / play | ✅ | ✅ | Tap to select, tap to play; animations work. | — |
| Valid/invalid card dimming | ✅ | ✅ | Illegal cards visually disabled. | — |
| Bidding (Sun/Hokm/Pass) | ✅ | ✅ | Overlay works; rules enforced server-side. | — |
| Bonus claim (Bnaga/Mosal) | ✅ | ✅ | Overlay and auto-detection present. | — |
| Trick winner animation | ✅ | ✅ | Brief winner highlight. | — |
| Score display | ✅ | ✅ | "Us — Them" visible. | — |
| Round/game end overlays | ✅ | ✅ | Round summary and final score overlays. | — |
| Auto-hide controls | ✅ | ✅ | Top/bottom controls hide after inactivity. | — |
| Mic/camera toggles in game | ✅ | ⚠️ | Toggles present; settings icon has empty `onPressed`. | Medium |
| Turn indicator | ✅ | ✅ | Glowing border on active seat. | — |
| Leave game / rematch | ✅ | ✅ | Dialogs and Cloud Functions present. | — |
| Portrait game mode | ❌ | ❌ | Not implemented; landscape only. | Low |

### Phase 3 — Streaming
| Feature | Spec Status | Implemented | Issues | Priority |
|---------|-------------|-------------|--------|----------|
| Stream discovery grid | ✅ | ⚠️ | Grid loads; search bar is decorative (no search logic). | Medium |
| Filter chips | ✅ | ⚠️ | UI present; filtering logic not verified. | Medium |
| Watch stream page | ✅ | ⚠️ | 2×2 video grid, chat, viewer count; Like/Gift/Follow are placeholders. | Medium |
| LIVE badge | ✅ | ✅ | Pulsing red badge visible. | — |
| Stream chat | ✅ | ⚠️ | Chat list/input present; gifts/likes not wired. | Medium |
| Stream end handling | ✅ | ⚠️ | Trigger exists but not manually verified. | Low |

### Phase 5 — Social, Profile, Settings, Edge Cases
| Feature | Spec Status | Implemented | Issues | Priority |
|---------|-------------|-------------|--------|----------|
| Chat list + DM | ✅ | ⚠️ | UI and backend present; real-time delivery not stress-tested. | Medium |
| Room invitations in chat | ✅ | ⚠️ | Data model exists; join/decline flow not verified. | Medium |
| Profile / stats / history | ✅ | ⚠️ | Screens exist; stats accuracy depends on `processGameEnd` trigger. | Medium |
| Edit profile | ✅ | ✅ | Form and update flow present. | — |
| Settings | ✅ | ⚠️ | Sections present; some toggles may be UI-only. | Low |
| Offline / error / success screens | ✅ | ⚠️ | Screens exist; `ForceUpdatePage`/`MaintenancePage` not fully localized. | Medium |
| Deep links (room invites) | ✅ | ⚠️ | Route exists; not verified on device. | Medium |
| Push notifications | P1 | ⚠️ | FCM tokens stored; notification triggers present but delivery not verified. | Medium |
| Accessibility / touch targets | ✅ | ⚠️ | Not systematically verified. | Low |
| Haptic / sound effects | ✅ | ⚠️ | Sound service exists; not verified on all events. | Low |

---

## 4. Gameplay-Specific Findings

### 4.1 Local Simulator (`LocalGameSimulator`)
- **Route:** `/game-sim` (debug-only button on Home).
- **Human seat:** 0, Team A.
- **Bots:** Faisal (seat 1, Team B), Omar (seat 2, Team A), Khalid (seat 3, Team B).
- **Status:** Functional. Plays full games with delays and animations.
- **Bugs found and fixed during review:**
  1. **All-pass redeal reset dealer to 0** instead of keeping the same dealer. Fixed by preserving `dealerIndex` across the redeal.
  2. **Undocumented +10 last-trick bonus** was applied in the simulator but is not in `docs/game_rules.md` nor in the Cloud Functions engine. Removed for consistency.
  3. **No bidding validation** in the simulator — human/bots could bid illegal Sun-after-Sun or Hokm without holding the face-up suit. Added `isValidBid()` matching the Cloud Functions rules.
  4. **Bonus tiebreak did not compare highest sequence card**, diverging from the authoritative engine. Updated `_compareBonuses()` and `_highestSequenceCard()` to match.
- **Tests added/updated:** `test/local_game_simulator_test.dart` now covers dealer preservation, bidding validation, and sequence tiebreak.

### 4.2 Online Multiplayer Path
- **Flow is correct:** create room → join → ready → `startGame` Cloud Function → deal → bid → play → score → repeat/end.
- **Real-time sync:** Firestore `.snapshots()` drives UI; actions call HTTPS Cloud Functions.
- **Security:** Game doc writes are server-only; clients call functions. Good anti-cheat design.
- **Solo testing gap:** The online path has not been exercised with 4 real/automated seats end-to-end. This is the main deliverable of the bot harness.

### 4.3 Cloud Functions Engine
- **Files:** `functions/src/engine/*.ts`.
- **Test coverage:** Comprehensive Jest suite covering deck, deal, bidding, trick, scoring, bonuses, autoplay, and full integration.
- **Bugs found and fixed during review:**
  2. **`functions/src/engine/bonuses.ts` sequence tiebreak bug** — `getHighestSequenceCard` ranked `10` above `J`, `Q`, and `K` in sequence tiebreaks. Fixed to the correct order `A > K > Q > J > 10 > 9 > ... > 2` and added a regression test.
- **Confidence:** High that the authoritative engine is now correct.

### 4.4 Potential Rule/Logic Risks
| Risk | Where | Mitigation |
|------|-------|------------|
| Local simulator engine diverges from Cloud Functions engine | `local_game_simulator.dart` vs `functions/src/engine/*.ts` | Compare test cases; run same scenarios on both. |
| Bonus resolution edge cases | `functions/src/engine/bonuses.ts` | Jest tests cover most; verify with real hands. |
| Turn timeout / autoplay | `functions/src/scheduler/autoPlay.ts` | Hard to test without emulator; bot harness can trigger timeouts. |
| Disconnect handling | `functions/src/scheduler/autoPlay.ts` | Needs emulator + forced disconnect test. |
| Game-end trigger (`processGameEnd`) | `functions/src/triggers/processGameEnd.ts` | Needs full online game to verify stats/room updates. |

---

## 5. Critical Issues Found During Code Review

### 5.1 High Priority
1. **Social login buttons are non-functional.** Users tapping Apple/Google see "Coming soon". This creates friction and looks unprofessional. File: auth login page.
2. **Game settings icon does nothing.** Empty `onPressed` in `GamePlayPage` controls. File: `lib/features/game/presentation/pages/game_play_page.dart`.
3. **Discover search is decorative.** Search bar has no search logic. File: `lib/features/discover/presentation/pages/discover_page.dart`.
4. **Stream viewer interactions are placeholders.** Like/Gift/Follow buttons not wired. File: `lib/features/stream/presentation/pages/watch_stream_page.dart`.
5. **OTP digit mismatch.** Code implements 4-digit OTP; design docs specify 6-digit. File: `lib/features/auth/presentation/pages/otp_page.dart`.

### 5.2 Medium Priority
6. **Welcome screen is static, not swipeable onboarding.** Docs describe 3-card carousel. File: `lib/features/auth/presentation/pages/welcome_page.dart`.
7. **ForceUpdate/Maintenance pages not fully localized.** Hardcoded English breaks Arabic-first policy. Files: `lib/features/app/presentation/pages/force_update_page.dart`, `maintenance_page.dart`.
8. **App ignores device locale on first launch.** `startLocale` hardcoded to Arabic. File: `lib/main.dart`.
9. **No portrait game mode.** Landscape-only may exclude some users. Design decision D013, but worth noting.
10. **"Play with Bots" is debug-only.** Regular users have no practice mode. File: `lib/features/home/presentation/pages/home_page.dart`.

### 5.3 Low Priority
11. **No integration/E2E tests.** Biggest quality gap.
12. **Widget test coverage is thin.** Only `GamePlayPage` loading/playing states.
13. **No web_admin CI job.** CI only covers Flutter and Functions.
14. **Placeholder `widget_test.dart`.** Should be removed or replaced.

---

## 6. Solo 4-Player Gameplay Testing Strategy

Because you are a solo developer, use this layered approach to test the full 4-player loop without other humans:

### Layer 1 — Local Simulator (Immediate)
- Tap the debug "Play with Bots" button on Home.
- Play 10+ full games covering Sun/Hokm, win/fall, bonuses, multi-round games.
- Log any UI crashes, wrong scores, or illegal plays.

### Layer 2 — Firebase Emulator + Manual Multi-Instance (Next)
- Start `firebase emulators:start`.
- Configure Flutter to use emulator in debug builds.
- Launch 4 Flutter instances (emulators or devices).
- Create a room in one, join with the other three, play a full game.
- This verifies real Cloud Functions + Firestore sync.

### Layer 3 — Automated Bot Harness (Recommended) ✅ Implemented
- Created `tools/bot_harness/`, a standalone Node.js/TypeScript tool.
- It signs in 3 anonymous bot users, joins a room by invite code, toggles ready, and auto-bids/auto-claims/auto-plays on each bot's turn.
- Build verified: `npm run build` passes.
- **How to use:** see `tools/bot_harness/README.md`.
- **Not yet run end-to-end** because it requires the Firebase emulator + a running Flutter app instance. This is the recommended next step for the developer.

---

## 8. UX / Functional Smoke Test Findings

These findings come from code review against the design docs and the explore agents' screen audits. They should be verified on a real device/emulator.

| Screen / Flow | Status | Finding | Priority |
|---------------|--------|---------|----------|
| **Login** | ⚠️ | Apple/Google buttons show "Coming soon" snackbar; not wired. | High |
| **OTP** | ⚠️ | Implemented as 4-digit; design docs specify 6-digit. | Medium |
| **Welcome** | ⚠️ | Static value-prop screen; docs describe 3-card swipeable onboarding. | Low |
| **Home** | ✅ | Hero banner, quick actions, live streams list, bottom nav present. | — |
| **Home** | ⚠️ | "Play with Bots" is debug-only (`kDebugMode`). No practice mode for users. | Medium |
| **Discover** | ⚠️ | Search bar has no `onChanged`/`onSubmitted`; decorative only. | Medium |
| **Discover** | ⚠️ | Filter chips call `selectFilter` but actual filtering logic not verified. | Medium |
| **Watch Stream** | ⚠️ | Like, Gift, Follow action buttons have no `onTap` (only Share works). | Medium |
| **Create Room** | ✅ | Form, preview card, Firestore creation present. | — |
| **Room Lobby** | ✅ | Seats, ready toggle, code copy/share, chat present. | — |
| **Game Play** | ⚠️ | Settings icon in controls has empty `onPressed: () {}`. | High |
| **Game Play** | ✅ | Landscape lock, card fan, bidding/bonus overlays, score display present. | — |
| **Game Play** | ⚠️ | No portrait mode. Documented design decision, but limits some users. | Low |
| **Force Update** | ⚠️ | Hardcoded English strings (`Update Required`, `Update Now`). | Medium |
| **Maintenance** | ⚠️ | Title and fallback message hardcoded English. | Medium |
| **main.dart** | ⚠️ | `startLocale` forced to Arabic; ignores device locale on first launch. | Medium |
| **Localization** | ⚠️ | Most screens use `.tr()`; edge-case screens need audit. | Low |

## 10. Prioritized Action Items

### 🔴 Critical (fix before any public release)
1. **Verify the bot harness end-to-end** — run `firebase emulators:start`, create a room in the Flutter app, and run `npm run start -- --code XXXXXX` in `tools/bot_harness/`.
2. **Test the online 4-player path manually** if possible (3 emulators/devices) to validate Firestore real-time sync, Cloud Functions, and Agora.
3. **Add integration tests** for at least one full game flow (auth → room → start → play → end).

### 🟠 High (strongly recommended)
4. Wire or hide social login buttons (`login_page.dart`); showing "Coming soon" looks unfinished.
5. Give the game settings icon an action or remove it (`game_play_page.dart`).
6. Add a user-facing "Practice with Bots" mode using `LocalGameSimulator` (currently debug-only).

### 🟡 Medium (polish)
7. Implement Discover search (currently decorative).
8. Wire Like/Gift/Follow on stream viewer or hide until implemented.
9. Localize `ForceUpdatePage` and `MaintenancePage` fallback text.
10. Decide OTP digit count (4 vs 6) and align code, design, and backend.
11. Use device locale for `startLocale` instead of forcing Arabic.

### 🟢 Low (nice-to-have)
12. Replace placeholder `widget_test.dart` with a real smoke test or remove it.
13. Add CI job for `web_admin` tests.
14. Expand widget tests for at least auth and room flows.

## 11. Conclusion

The Bloot app has a solid foundation: the Cloud Functions Baloot engine is well-tested and now fixes two real bugs found during this review, the Flutter game UI is functional, and the local simulator lets a solo developer play full 4-player games on one device.

The biggest remaining risk is **verifying the real online multiplayer path**. To solve this permanently, this review delivers:
- ✅ Fixes to the game engine (TypeScript compile errors, sequence tiebreak bug).
- ✅ Fixes to the local simulator (dealer reset, last-trick bonus, bidding validation, bonus tiebreak).
- ✅ A reusable bot harness (`tools/bot_harness/`) that fills 3 seats automatically.
- ✅ A comprehensive review report documenting feature gaps and UX issues.

**Recommended immediate next step:** run the bot harness against the emulator and play at least one full online game. That will surface any remaining real-time sync, timing, or UI issues that solo code review cannot catch.
