# Bloot — Master Implementation Plan

> **Purpose:** Phase-by-phase implementation plan with decisions log, feature checklists, and QA tests. This is the single source of truth for what gets built, when, and how it's verified.

---

## 1. Decisions Log

| ID | Decision | Date | Rationale |
|----|----------|------|-----------|
| D001 | Flutter + Firebase | Initial | Cross-platform mobile, fast iteration, real-time support |
| D002 | Dark-only theme for MVP | Initial | Target audience expects premium dark UI; reduces design scope |
| D003 | Arabic RTL-first | Initial | Primary market is Gulf/MENA; Arabic is the primary language |
| D004 | Agora for voice/video | Initial | Proven RTC SDK, good Arabic region support, Firebase-friendly |
| D005 | Feature-first architecture | Initial | Scalable, testable, clear ownership per feature |
| D006 | flutter_bloc/Cubit for state | Initial | Predictable state, good tooling, community support |
| D007 | freezed for models | Initial | Immutability, union types, copyWith, JSON serialization |
| D008 | go_router for navigation | Initial | Deep links, named routes, Firebase Dynamic Links |
| D009 | Phone OTP auth only (MVP) | Initial | Primary market uses phone numbers; social auth deferred |
| D010 | Single app, player + viewer modes | Initial | Reduces codebase complexity; modes are UI paths, not separate apps |
| D011 | Firestore, not Realtime DB | Initial | Better querying, closer to document model, Cloud Functions support |
| D012 | No light theme in MVP | Initial | See D002; reduces design and implementation scope significantly |
| D013 | Landscape-locked for game play | Initial | Baloot requires 4 players visible; landscape gives the best UX |
| D014 | Cloud Functions for game logic | Initial | Game rules must be validated server-side to prevent cheating |
| D015 | Khaleeji Baloot rules only (MVP) | Initial | Standard Gulf rules; other variants deferred to post-MVP |

---

## 2. Phase 0: Infrastructure

**Goal:** Set up project skeleton, CI/CD, and foundational services.

### 2.1 Feature Checklist

- [ ] Flutter project initialized with feature-first structure
- [ ] `pubspec.yaml` with all dependencies:
  - `flutter_bloc`, `freezed`, `freezed_annotation`
  - `go_router`
  - `cloud_firestore`, `firebase_auth`, `firebase_storage`, `firebase_messaging`
  - `agora_rtc_engine`
  - `flutter_screenutil`
  - `json_annotation`, `json_serializable`
  - `get_it` (DI)
  - `logger`
- [ ] `analysis_options.yaml` with lint rules (see coderules)
- [ ] `ColorManager` class with all design tokens from DESIGN.md
- [ ] `ThemeManager` class generating dark-only `ThemeData`
- [ ] `AppLocalizations` setup (ARB files for AR and EN)
- [ ] `go_router` configuration with all routes defined
- [ ] `main.dart` with DI setup, theme, localization, router
- [ ] Firebase project created (Android + iOS)
- [ ] Firestore security rules deployed (see firebase_schema.md)
- [ ] Cloud Functions project initialized
- [ ] Agora project created, App ID configured
- [ ] GitHub Actions CI pipeline:
  - `flutter analyze`
  - `dart format --set-exit-if-changed .`
  - `flutter test`
  - Build APK/IPA on PR
- [ ] Fastlane setup for Android + iOS deployment

### 2.2 QA Tests

| Test | Method | Criteria |
|------|--------|----------|
| Project builds | `flutter build apk --debug` | No errors |
| Project runs | `flutter run` on emulator | App launches to splash screen |
| Lint passes | `flutter analyze` | Zero warnings |
| Format passes | `dart format --set-exit-if-changed .` | All files formatted |
| Theme renders | Manual | Dark theme, `#0A0A0F` background, purple primary |
| Localization | Manual | Arabic text renders with Cairo, English with Inter |
| RTL layout | Manual | `dir="rtl"` flips layout correctly |

---

## 3. Phase 1: Auth & Home

**Goal:** Phone authentication, profile setup, and home screen with live streams.

### 3.1 Feature Checklist

#### Auth
- [ ] Phone input screen with country code selector (default +966)
- [ ] OTP verification screen (4-digit code, auto-focus, resend timer)
- [ ] Profile setup screen (displayName, username, avatar upload)
- [ ] Username availability check (real-time Firestore query)
- [ ] Auth state management (Cubit: initial, otpSent, authenticated, error)
- [ ] Firebase Auth phone sign-in integration
- [ ] User document creation in Firestore on sign-up
- [ ] Terms of Service acceptance (checkbox + links)

#### Home
- [ ] Home screen with hero banner ("Baloot Live")
- [ ] Quick action cards (3): Play with Friends, Voice Tables, Live Stream
- [ ] Live streams list (real-time Firestore listener)
- [ ] Empty state for no streams
- [ ] Bottom navigation (5 items: Home, Discover, Play, Chat, Profile)
- [ ] Pull-to-refresh on home content
- [ ] Skeleton loading states
- [ ] Notification bell icon with unread badge

### 3.2 QA Tests

| Test | Method | Criteria |
|------|--------|----------|
| Phone input | Manual | Accepts valid phone numbers, shows country selector |
| OTP sent | Manual | OTP delivered to phone, 4-digit input works |
| Invalid OTP | Manual | Red border on invalid code, error message |
| Profile creation | Manual | Name, username, avatar save to Firestore |
| Username check | Manual | Real-time feedback on availability |
| Home loads | Manual | Stream cards load with real-time updates |
| Home empty state | Manual | Shows "No live streams" when none exist |
| Bottom nav | Manual | 5 items, center "Play" highlighted gold |
| RTL on home | Manual | Arabic text flows correctly, nav icons flip |
| Pull-to-refresh | Manual | Stream list updates on pull |

---

## 4. Phase 2: Rooms & Game

**Goal:** Create rooms, room lobby, and the core Baloot game play experience.

### 4.1 Feature Checklist

#### Create Room
- [ ] Room creation form (name, type, voice/camera toggles)
- [ ] Room type cards (Private, Public, Live Stream)
- [ ] Advanced settings (min level, game speed, password)
- [ ] Room preview card (live preview of room appearance)
- [ ] Firestore room document creation
- [ ] Agora channel creation for room

#### Room Lobby
- [ ] 4-player seat layout (2x2 grid)
- [ ] Player video squares with mic/camera indicators
- [ ] Empty seat states (pulsing border, "Waiting...", invite button)
- [ ] Ready/not-ready toggle per player
- [ ] Team assignment display (Team A purple, Team B gold)
- [ ] Room code display and copy/share buttons
- [ ] "Start Game" button (disabled until 4 players ready, only creator can start)
- [ ] Kick player functionality (room creator only)
- [ ] Room chat drawer (quick messages + text input)

#### Game Play (Landscape)
- [ ] Landscape orientation lock on entry
- [ ] 4 video squares positioned around game table
- [ ] Game table surface in center
- [ ] Card hand display (fanned, overlapping)
- [ ] Card selection (tap to raise, tap again to play)
- [ ] Valid/invalid card dimming
- [ ] Trump suit declaration (Hokm mode)
- [ ] Trick play sequence (each player plays a card)
- [ ] Trick winner animation
- [ ] Score display ("Us: X — Them: Y")
- [ ] Round end summary overlay
- [ ] Game end celebration overlay
- [ ] Auto-hiding controls (3s timeout, tap to reveal)
- [ ] Mic/camera toggles during game
- [ ] Turn indicator (glowing border on active player)
- [ ] Baloot rules engine (Cloud Functions):
  - Card dealing (8 cards each)
  - Sun rules (120 target, must score >60, no trump, no bonuses)
  - Hokm rules (trump declaration, bid-based target)
  - Trick resolution (suit following, trump beats)
  - Score calculation
  - Game end detection

### 4.2 QA Tests

| Test | Method | Criteria |
|------|--------|----------|
| Create private room | Manual | Room created in Firestore, invite code generated |
| Create public room | Manual | Room appears in discovery |
| Join room via code | Manual | Player enters room, seat fills |
| 4 players ready | Manual | "Start Game" enabled when all 4 ready |
| Start game | Manual | Game screen opens in landscape |
| Card dealing | Manual | 8 cards per player, cards visible |
| Play a card | Manual | Card moves to center, turn passes |
| Invalid card play | Manual | Dimmed, not playable |
| Trick winner | Manual | Correct player wins trick, cards clear |
| Round end | Manual | Score summary shown |
| Game end | Manual | Winner celebration, stats update |
| Leave room | Manual | Confirmation dialog, clean exit |
| Landscape lock | Manual | Game screen locked to landscape |
| Mic toggle | Manual | Green/red indicator toggles |
| Camera toggle | Manual | Video feed appears/hides |
| RTL in game | Manual | Opponent positions flipped correctly |

---

## 5. Phase 3: Streaming

**Goal:** Spectator mode for watching live Baloot games, chat, and interactions.

### 5.1 Feature Checklist

#### Stream Viewer
- [ ] 4 video squares (2x2 portrait, row landscape)
- [ ] Read-only game table (cards played, scores)
- [ ] Player cards NOT shown (only played cards visible)
- [ ] LIVE badge (animated, always visible)
- [ ] Viewer count (real-time update)
- [ ] Chat panel (scrollable messages, text input)
- [ ] Interaction buttons (like, gift, share, follow)
- [ ] Portrait and landscape support
- [ ] Stream auto-end when host leaves

#### Stream Discovery
- [ ] Search bar with real-time search
- [ ] Filter tabs (Popular, New, Top Rated, Voice Only, Following)
- [ ] Advanced filter bottom sheet
- [ ] Stream card grid (2 columns)
- [ ] Pull-to-refresh
- [ ] Infinite scroll / pagination
- [ ] Empty state

### 5.2 QA Tests

| Test | Method | Criteria |
|------|--------|----------|
| Watch stream | Manual | 4 videos visible, game table readable |
| Chat in stream | Manual | Message sent and visible |
| Like a stream | Manual | Like count increments |
| LIVE badge | Manual | Red, pulsing, always visible |
| Viewer count | Manual | Updates when viewers join/leave |
| Stream discovery | Manual | Stream cards load, filters work |
| Search streams | Manual | Results match query |
| Landscape viewer | Manual | Layout adapts, chat moves to side |
| Stream end | Manual | Viewer notified when stream ends |

---

## 6. Phase 4: Social & Polish

**Goal:** Chat, profile, settings, error handling, offline support, and final polish.

### 7.1 Feature Checklist

#### Chat
- [ ] Chat list (recent conversations with unread badges)
- [ ] Direct messages (send/receive text and images)
- [ ] Room invitations in chat (join/decline)
- [ ] Quick action chips (Good game, Nice move, etc.)
- [ ] Real-time message delivery

#### Profile
- [ ] Profile screen (avatar, name, username, level, stats)
- [ ] Stats tab (win rate, game breakdown, level progress)
- [ ] History tab (game results with won/lost, scores)
- [ ] Achievements section (badges: earned/locked)
- [ ] Edit profile (name, username, bio, photo, region)
- [ ] Other user's profile (follow/unfollow)

#### Settings
- [ ] Settings screen (all sections)
- [ ] Game-specific settings (voice, camera, rotation, speed)
- [ ] Notification settings
- [ ] Privacy settings
- [ ] Account management (logout, delete)

#### Error & Edge Cases
- [ ] Error state screen (try again CTA)
- [ ] Offline state screen (retry CTA)
- [ ] Loading overlay (contextual messages)
- [ ] Success state (gold checkmark animation)
- [ ] Network error handling in all async operations
- [ ] Auth token refresh
- [ ] Deep links (room invitations)

#### Accessibility & Polish
- [ ] Minimum touch targets (48px, 44px for game)
- [ ] Screen reader labels for all interactive elements
- [ ] Haptic feedback on button presses and game events
- [ ] Smooth page transitions (shared elements where possible)
- [ ] Card sound effects (deal, play, trick win, game end)
- [ ] Background service for Agora audio (call mode)
- [ ] Push notification handling
- [ ] App icons and splash screen

### 7.2 QA Tests

| Test | Method | Criteria |
|------|--------|----------|
| Send DM | Manual | Message delivered, conversation appears |
| Room invitation | Manual | Invite sent, join/decline works |
| Profile stats | Manual | Games, wins, level display correctly |
| Edit profile | Manual | Changes save and reflect immediately |
| Settings persist | Manual | Settings survive app restart |
| Offline state | Manual | Offline screen shown, retry works |
| Error state | Manual | Error shown, try again works |
| Deep link | Manual | Room invite link opens app |
| Touch targets | Manual | All targets >= 44px |
| Screen reader | Manual | All elements labeled |

---

## 7. Testing Strategy

### 8.1 Unit Tests

| Area | What to Test |
|------|-------------|
| Baloot engine | Card dealing, trick resolution, score calculation, valid card detection |
| Cubits | State transitions for every event (loading, success, error) |
| Models | Freezed fromJson/toJson, copyWith, equality |
| Use cases | Business logic validation (join room, play card) |
| Repositories | Data mapping between models and entities |

### 8.2 Widget Tests

| Area | What to Test |
|------|-------------|
| Buttons | Primary, gold, ghost button renders correctly |
| Stream card | Renders LIVE badge, viewer count, host info |
| Player video square | Renders player info, mic/camera indicators |
| Game card | Renders face/back, selection state |
| Score display | Renders scores, gold accent on leading team |
| Text input | Focus state, error state, RTL support |
| Bottom navigation | Renders 5 items, center gold play button |

### 8.3 Integration Tests

| Area | What to Test |
|------|-------------|
| Auth flow | Phone input → OTP → profile setup → home |
| Room flow | Create room → join → lobby → start game |
| Game flow | Deal → play cards → trick → round → game end |
| Stream flow | Discover stream → watch → chat → interactions |
| Chat flow | Open chat → send message → receive reply |

### 8.4 Manual Test Matrix

| Area | Device | Orientation | Language | Network |
|------|--------|-------------|----------|---------|
| Auth | iPhone 15 | Portrait | AR | WiFi |
| Auth | Pixel 8 | Portrait | EN | WiFi |
| Home | iPhone 15 | Portrait | AR | WiFi |
| Game | iPhone 15 | Landscape | AR | WiFi |
| Game | Pixel 8 | Landscape | EN | WiFi |
| Stream | iPhone 15 | Portrait + Landscape | AR | WiFi |
| Game | iPhone SE | Landscape | AR | 3G |
| Chat | Pixel 8 | Portrait | EN | WiFi |
| offline | Both | Portrait | Both | None |

---

## 8. Post-MVP Roadmap

| Priority | Feature | Notes |
|----------|---------|-------|
| P1 | Light theme | Design system supports it; implementation deferred |
| P1 | Social auth | Apple Sign In, Google Sign In |
| P1 | Push notifications | FCM for room invites |
| P2 | Replay | Watch completed games |
| P2 | Spectator chat | Chat in streams with moderation |
| P2 | Gifting system | Virtual gifts with coin economy |
| P2 | Leaderboards | Global and regional leaderboards |
| P3 | Custom card backs | Unlockable cosmetics |
| P3 | Reactions | Emoji reactions during streams |
| P3 | Screen sharing | Host can share game view |
| P3 | Other Baloot variants | Egyptian rules, Hijazi rules |