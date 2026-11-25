# Bloot — Performance & Reliability Review

> **Date:** 2026-08-25 · **Scope:** Full-stack lag/bug review (Flutter app, Cloud Functions, Firestore/RTDB, WebView game)
> **Method:** static analysis of `lib/`, `functions/src/`, `assets/web_game/`, rules files, and live project config.

---

## 0. Infrastructure facts (verified live)

| Fact | Value | Consequence |
|------|-------|-------------|
| Firestore location | **nam5** (North America multi-region) | All DB reads/writes happen in the US |
| RTDB instance | `bloot-42242-default-rtdb.firebaseio.com` → **us-central1** | Game-state mirror served from the US |
| Cloud Functions region | default **us-central1** | Co-located with the data ✅ |
| Users | Gulf / MENA | ~150–250ms RTT to *any* Firebase endpoint |

### Why we did NOT move functions to the Gulf (me-central2/Dammam)
A card play = 1 client→function HTTPS round trip **+ 2–4 function→Firestore round trips** inside the transaction. Moving functions to Dammam would save ~150ms on the first leg but add ~150–180ms × 2–4 on the transaction legs → **net slower**. Functions stay in us-central1 near the data. The latency budget is instead attacked via: cold-start elimination, trigger efficiency, fewer round trips, and the RTDB fast path.

> **Strategic recommendation (future):** to truly serve the Gulf market, migrate the *data* closer: create a named Firestore DB in `me-central2` + an RTDB instance in `europe-west1` (closest RTDB region) and migrate. This is a data migration project, out of scope here.

---

## 1. Findings (ranked by user-visible lag)

### 🔴 Critical

1. **Cold starts on every game action** — no `minInstances` on any callable; after idle, the first card play pays a multi-second cold start (barrel `index.ts` imports the whole engine + admin + agora-token into every instance).
2. **AFK stall up to 60s** — timeout enforcement only via `every 1 minutes` cron (`https/autoPlay.ts`), which also scans **all** active games and processes them **sequentially**.
3. **RTDB fast path can silently never activate** — WebView loads Firebase JS SDK from `https://www.gstatic.com/...` with `defer` (`play.html:283-285`). Slow/blocked CDN → game permanently on the slow Firestore→Flutter→JS-bridge path, with no signal to user or logs.
4. **Cheating possible: all hands readable** — RTDB `games/$gameId .read: auth != null` (`database.rules.json`) and Firestore rules let any participant read the full game doc; the client maps every player's hand (`game_remote_data_source.dart`). Anyone with a debugger sees all cards.

### 🟠 High

5. **Game-start race** — room flips to `playing` before the game doc exists; client patches with 5 retries × 2s → up to ~10s "starting game" stall (`game_cubit.dart`).
6. **Bot trigger pressure** — `botAutoPlay` fires on *every* game write, sleeps 400ms in-instance, `maxInstances: 10` → queueing under concurrent games.
7. **N+1 reads on home/discover** — one room-doc fetch per stream per snapshot + 1-min periodic refilter; home live-stream listener has **no `.limit()`** (`home_remote_data_source.dart`).
8. **12MB `node_modules` inside the app binary** — `assets/web_game/node_modules` matched by the pubspec asset glob (esbuild build tooling shipped to users).
9. **Trick advance depends on one client** — only the next-to-play seat fires `advanceTrick` after 2.3s; if that client dies, the game waits for the cron.

### 🟡 Medium

10. **Agora UID fallback `String.hashCode`** — collision-prone; two users can share a UID and kick each other off channels (`agora_service.dart:729`).
11. **Voice-join delay** — unbounded `streams.where(...)` query without `.limit()` + up to 4 sequential lookups in token issuance (`functions/src/index.ts:154`).
12. **Whole-page rebuilds in game page** — `context.watch<GameCubit>()` inside media controls rebuilds the Scaffold/Stack incl. WebView on every cubit emit (`html_game_play_page.dart:552`).
13. **Chat without pagination** — DMs/stream chat hard-capped at last 100; older messages unreachable; notification fan-out reads recipient docs sequentially with no spam throttle.
14. **App Check web placeholder** — reCAPTCHA key `'6Le...'` placeholder (`lib/core/config/app_check_config.dart:3`).

### ✅ Already good (kept)
Diff-based Firestore updates (`buildGameUpdate`), RTDB mirror no-op suppression, bridge push suppression once RTDB live, duplicate-safe `advanceTrick` transaction, Agora reconnect/backoff, RTDB `onDisconnect` presence.

---

## 2. Fixes applied (this branch)

| # | Fix | Files |
|---|-----|-------|
| 1 | `minInstances: 1` on hot callables (playCard, placeBid, declareProject, applyDouble, advanceTrick, startGame, dealNextRound, generateAgoraToken, createRtdbToken) + lazy admin module | `functions/src/https/*`, `functions/src/index.ts` |
| 2 | Client-driven timeout callable (`checkTurnTimeout`) + parallelized cron | `functions/src/https/autoPlay.ts`, new callable, `game_cubit.dart` |
| 3 | Firebase JS SDK bundled locally (`js/vendor/`), CDN tags removed, 3s RTDB connect watchdog + slow-sync indicator | `assets/web_game/play.html`, `js/bloot_bridge.js` |
| 4 | `startGame` writes game doc before flipping room status; client retry hack removed | `functions/src/https/startGame.ts`, `game_cubit.dart` |
| 5 | `advanceTrick` callable safe from any seated client (first-wins) | `functions/src/https/advanceTrick.ts`, `game_cubit.dart` |
| 6 | Home/discover: `.limit()` + batched room lookup | `home_remote_data_source.dart`, `discover_remote_data_source.dart` |
| 7 | pubspec assets trimmed (−12MB) | `pubspec.yaml` |
| 8 | Scoped BlocBuilder for media controls | `html_game_play_page.dart` |
| 9 | Agora UID stable fallback (CRC32) | `agora_service.dart` |
| 10 | Chat pagination + parallel notification fan-out | `chat_remote_data_source.dart`, `sendChatMessageNotification.ts` |
| 11 | Anti-cheat: hands moved to per-player docs/nodes, rules tightened | `firestore.rules`, `database.rules.json`, engine adapter, mirror, bridge |

## 3. Verification
- `flutter analyze --no-pub`, `flutter test --no-pub` — green
- `cd functions && npm run build && npm test` — green
- Deploy order: `firebase deploy --only functions,firestore:rules,database` together with the app release.
