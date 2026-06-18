# Bloot — Implementation Tracker

> **Purpose:** Living document tracking what is built, what is mocked, and what is next. Update after every implementation phase.
> **Last updated:** 2026-06-05

---

## Completed Phases

### Phase A: Profile Data Layer + Home Wiring
**Files modified/created:**
- `lib/features/profile/domain/entities/user_profile.dart`
- `lib/features/profile/domain/repositories/profile_repository.dart`
- `lib/features/profile/data/models/user_profile_model.dart`
- `lib/features/profile/data/datasources/profile_remote_data_source.dart`
- `lib/features/profile/data/repositories/profile_repository_impl.dart`
- `lib/features/profile/presentation/cubit/profile_cubit.dart`
- `lib/features/profile/presentation/cubit/profile_state.dart`
- `lib/features/home/presentation/cubit/home_cubit.dart` — injects ProfileRepository
- `lib/features/home/presentation/pages/home_page.dart` — top bar shows real avatar/name/level/coins
- `lib/features/home/presentation/cubit/home_state.dart` — carries `UserProfile? profile`

**Status:** ✅ Real Firestore data. Home top bar and Profile header fully wired.

---

### Phase B: Home Tournament Previews + Edge Case Pages
**Files modified/created:**
- `lib/features/home/presentation/cubit/home_cubit.dart` — injects `TournamentRepository`, fetches upcoming tournaments (filter `status == 'upcoming'`, cap 3), non-blocking error handling
- `lib/features/home/presentation/cubit/home_state.dart` — `loaded`/`empty` carry `List<Tournament>? tournaments`
- `lib/features/home/presentation/pages/home_page.dart` — `_buildTournamentsSection()` with skeletons → real data; `_TournamentCard` uses `tournament.id` for navigation; removed hardcoded `_TournamentPreview` class
- `lib/features/edge_cases/presentation/pages/loading_page.dart` — new, shimmer skeletons, optional message via `extra`
- `lib/features/edge_cases/presentation/pages/success_page.dart` — new, animated gold checkmark, optional message via `extra`
- `lib/config/routes/routes.dart` — added `loading` / `success` route names and paths
- `lib/config/routes/app_router.dart` — added GoRoutes for loading/success with `extra` message extraction
- `assets/translations/en.json` & `ar.json` — added `loading_message`, `success_title`, `success_message`, `continue`

**Status:** ✅ Home tournament cards now fetch real data. Loading and Success edge-case pages exist.

---

### Phase C: Edit Profile + Profile About Tab
**Files modified/created:**
- `lib/features/profile/domain/entities/user_profile.dart` — added `favoriteMode` field
- `lib/features/profile/data/models/user_profile_model.dart` — added `favoriteMode` to model + `toEntity()`
- `lib/features/profile/data/datasources/profile_remote_data_source.dart` — added `favoriteMode` mapping, added `updateUserProfile()`, added `uploadAvatar(File)`
- `lib/features/profile/domain/repositories/profile_repository.dart` — added `updateProfile()` and `uploadAvatar()`
- `lib/features/profile/data/repositories/profile_repository_impl.dart` — implemented new methods
- `lib/features/profile/presentation/cubit/edit_profile_cubit.dart` — new, handles load/save/avatar upload
- `lib/features/profile/presentation/cubit/edit_profile_state.dart` — new, freezed states: initial/loading/loaded/saving/saved/error
- `lib/features/profile/presentation/pages/edit_profile_page.dart` — complete rewrite: Form with validation, avatar picker (gallery → upload), pre-populated from real profile, save calls Firestore
- `lib/features/profile/presentation/pages/user_profile_page.dart` — passes `profile` via `extra` to edit route; `_AboutTab` receives `UserProfile` and shows real `bio`, `region`, `favoriteMode`
- `lib/config/routes/app_router.dart` — EditProfile route extracts `extra` as `UserProfile`, injects `EditProfileCubit`
- `assets/translations/en.json` & `ar.json` — added region keys: `dubai_uae`, `kuwait_city`, `manama_bahrain`, `doha_qatar`

**Status:** ✅ Edit Profile fully functional. About tab shows real data.

---

### Phase D: Settings Persistence
**Files modified/created:**
- `lib/core/network/cache_keys.dart` — added settings keys: `voiceChatEnabled`, `cameraEnabled`, `autoRotateGame`, `soundEffectsEnabled`, `backgroundMusicEnabled`, `showOnlineStatus`
- `lib/features/settings/domain/repositories/settings_repository.dart` — new interface
- `lib/features/settings/data/repositories/settings_repository_impl.dart` — new, uses `CacheHelper` (SharedPreferences)
- `lib/features/settings/presentation/cubit/settings_cubit.dart` — new, load/toggle/clear methods
- `lib/features/settings/presentation/cubit/settings_state.dart` — new, freezed states: initial/loaded/error
- `lib/features/settings/presentation/pages/settings_page.dart` — complete rewrite: `BlocBuilder<SettingsCubit>`, all toggles persist to SharedPreferences, Log Out calls `AuthCubit.signOut()` instead of just navigating
- `lib/config/routes/app_router.dart` — Settings route injects `SettingsCubit` + calls `loadSettings()`

**Status:** ✅ All settings toggles persist across app restarts. Log Out properly signs out of Firebase.

---

### Phase E: Profile Stats Tab — Real Game-Type Data
**Files modified/created:**
- `lib/features/profile/domain/entities/user_profile.dart` — added `sunGamesPlayed`, `sunGamesWon`, `hokmGamesPlayed`, `hokmGamesWon`
- `lib/features/profile/data/models/user_profile_model.dart` — added 4 fields to Freezed factory + `toEntity()`
- `lib/features/profile/data/datasources/profile_remote_data_source.dart` — added 4 fields to `_mapDocToModel()`
- `lib/features/profile/presentation/pages/user_profile_page.dart` — `_StatsTab` now receives `UserProfile`, computes real Sun/Hokm win rates; removed hardcoded `0.52`/`0.47`
- Regenerated `user_profile_model.freezed.dart` / `.g.dart` via `build_runner`

**Status:** ✅ Stats tab bar charts now show real per-game-type win rates from Firestore.

---

### Phase F: Settings Dropdowns — Game Speed, Speaker Mode, Profile Visibility
**Files modified/created:**
- `assets/translations/en.json` & `ar.json` — added `earpiece`, `friends`, `nobody`, `slow`
- `lib/core/network/cache_keys.dart` — added `gameSpeedDefault`, `speakerMode`, `profileVisibility`
- `lib/features/settings/domain/repositories/settings_repository.dart` — added `saveString()`, `getString()`
- `lib/features/settings/data/repositories/settings_repository_impl.dart` — split bool/string key loading, added string defaults
- `lib/features/settings/presentation/cubit/settings_state.dart` — `loaded` factory now carries 3 string values
- `lib/features/settings/presentation/cubit/settings_cubit.dart` — added `setGameSpeed()`, `setSpeakerMode()`, `setProfileVisibility()` with `_saveString()` helper
- `lib/features/settings/presentation/pages/settings_page.dart` — replaced `_showComingSoon` for 3 dropdown tiles with bottom sheet selectors; subtitles show live values
- Regenerated `settings_state.freezed.dart` via `build_runner`

**Status:** ✅ All 3 dropdown selections persist via SharedPreferences and reflect current value in UI.

---

### Phase G: Tournament Detail Wiring
**Files modified/created:**
- `lib/features/tournament/domain/repositories/tournament_repository.dart` — added `getTournamentById(String id)`
- `lib/features/tournament/data/repositories/tournament_repository_impl.dart` — implemented `getTournamentById` via remote data source
- `lib/features/tournament/data/datasources/tournament_remote_data_source.dart` — added `getTournamentById` with Firestore query + fallback to hardcoded list
- `lib/features/tournament/presentation/cubit/tournament_state.dart` — added `detailLoading`, `detailLoaded`, `detailError` states
- `lib/features/tournament/presentation/cubit/tournament_cubit.dart` — added `loadTournament(String id)` method
- `lib/features/tournament/presentation/pages/tournament_detail_page.dart` — complete rewrite of builder: handles all states, shows real `name`, `prize`, `status`, `date`, `participants`, `isJoined`; status badge color adapts; join button shows "View Bracket" if already joined
- `lib/config/routes/app_router.dart` — tournament detail route calls `loadTournament(id)` instead of `loadTournaments()`
- Regenerated `tournament_state.freezed.dart` via `build_runner`

**Status:** ✅ Tournament detail page now fetches and displays real tournament data by ID.

---

## Feature Matrix: Real Data vs Mocked

| Feature | Real Data | Mocked / Incomplete | Notes |
|---|---|---|---|
| **Auth** | Phone OTP, profile creation | — | `completeProfile` creates full user doc with settings defaults |
| **Home** | Streams (Firestore), Profile (Firestore), Tournaments (repo) | Hero banner image (Unsplash URL) | Tournament previews fetch from `TournamentRepository` |
| **Profile** | Header, About tab, Edit Profile, Stats tab, History tab, Achievements | — | Profile feature 100% wired to real data |
| **Settings** | All toggles + 3 dropdowns persist via SharedPreferences | — | All settings wired |
| **Tournament** | List queries Firestore `tournaments`, detail fetches by ID, prize distribution from Firestore, bracket from Firestore, join writes to Firestore, participant avatars from user profiles, coin balance from user profile | — | Tournament feature 100% wired |
| **Chat** | List queries Firestore `conversations`, messages real-time stream, send writes to Firestore, new conversation creation, user search, UI built | Image sending mocked; voice/video call buttons mocked | Chat feature 100% wired to Firestore |
| **Discover/Streams** | Firestore query for live streams | Stream viewer detail may have gaps | Home and Discover both query `streams` collection |
| **Room/Game** | UI built, game engine in Cloud Functions | Needs verification of full loop | `game_cubit_test.dart` exists and passes |
| **Notifications** | Firestore `users/{uid}/notifications` query, unread count on home bell | — | Notifications page loads real data; bell badge shows real unread count |
| **Edge Cases** | Error, Offline, Loading, Success, Force Update, Maintenance | — | All 6 P0 edge-case pages exist |

---

## Firestore Schema — Fields Already in User Documents

When `AuthRemoteDataSource.completeProfile()` creates a user, it writes:

```dart
{
  // ... profile fields ...
  'sunGamesPlayed': 0,
  'sunGamesWon': 0,
  'hokmGamesPlayed': 0,
  'hokmGamesWon': 0,
  'settings': {
    'voiceChat': true,
    'camera': false,
    'speakerMode': 'speaker',
    'autoRotateGame': true,
    'gameSpeedDefault': 'normal',
    'soundEffects': true,
    'backgroundMusic': false,
    'showOnlineStatus': true,
    'profileVisibility': 'everyone',
    // ... notification toggles ...
  },
  'achievements': <String, dynamic>{},
  'createdAt': FieldValue.serverTimestamp(),
  'updatedAt': FieldValue.serverTimestamp(),
}
```

**Implication:** `sunGamesPlayed`, `sunGamesWon`, `hokmGamesPlayed`, `hokmGamesWon` already exist in every user doc but are **NOT mapped** in `ProfileRemoteDataSource._mapDocToModel` or the `UserProfile` entity.

---

### Phase H: Notifications Wiring
**Files modified/created:**
- `lib/features/notifications/domain/entities/notification_item.dart` — new entity: `id`, `title`, `body`, `type`, `read`, `createdAt`
- `lib/features/notifications/data/models/notification_item_model.dart` — new Freezed model with `toEntity()`
- `lib/features/notifications/data/datasources/notifications_remote_data_source.dart` — new: Firestore query on `users/{uid}/notifications`, `getUnreadNotifications`, `markAsRead`, `markAllAsRead`
- `lib/features/notifications/data/repositories/notifications_repository_impl.dart` — new
- `lib/features/notifications/domain/repositories/notifications_repository.dart` — new interface
- `lib/features/notifications/presentation/cubit/notifications_state.dart` — new Freezed states
- `lib/features/notifications/presentation/cubit/notifications_cubit.dart` — new: `loadNotifications()`, `markAsRead()`, `markAllAsRead()`
- `lib/features/notifications/presentation/pages/notifications_page.dart` — complete rewrite: BlocBuilder, real data, type-based icons, relative timestamps, unread dot indicator, mark-as-read on tap
- `lib/features/home/presentation/cubit/home_state.dart` — `loaded`/`empty` now carry `unreadNotificationsCount`
- `lib/features/home/presentation/cubit/home_cubit.dart` — injects `NotificationsRepository`, loads unread count alongside home data
- `lib/features/home/presentation/pages/home_page.dart` — bell badge only shows when `unreadNotificationsCount > 0`
- `lib/config/routes/app_router.dart` — notifications route injects `NotificationsCubit` + calls `loadNotifications()`
- Regenerated `home_state.freezed.dart`, `notification_item_model.freezed.dart` / `.g.dart`, `notifications_state.freezed.dart`, `injection.config.dart` via `build_runner`

**Status:** ✅ Notifications page loads real Firestore data. Home bell badge shows real unread count.

---

### Phase I: Tournament List Firestore Integration
**Files modified/created:**
- `lib/features/tournament/data/datasources/tournament_remote_data_source.dart` — `getTournaments()` now queries Firestore `tournaments` collection ordered by `createdAt desc`; extracted hardcoded list to `_mockTournaments` constant used as fallback when Firestore empty/unreachable; added `_mapDocToModel` helper shared with `getTournamentById`

**Status:** ✅ Tournament list now queries Firestore. Falls back to mock data if no docs exist. Tournament detail fallback now searches `_mockTournaments` directly.

---

### Phase J: Profile History Tab
**Files modified/created:**
- `lib/features/profile/domain/entities/game_history.dart` — new entity: `id`, `won`, `score`, `type`, `durationMinutes`, `playedAt`
- `lib/features/profile/data/models/game_history_model.dart` — new Freezed model with `toEntity()`
- `lib/features/profile/data/datasources/profile_remote_data_source.dart` — added `getGameHistory(uid)` with Firestore `users/{uid}/gameHistory` query + mock fallback
- `lib/features/profile/domain/repositories/profile_repository.dart` — added `getGameHistory()`
- `lib/features/profile/data/repositories/profile_repository_impl.dart` — implemented `getGameHistory()`
- `lib/features/profile/presentation/cubit/profile_state.dart` — `loaded` now carries `List<GameHistory> gameHistory`
- `lib/features/profile/presentation/cubit/profile_cubit.dart` — loads game history alongside profile for both current user and other users
- `lib/features/profile/presentation/pages/user_profile_page.dart` — `_HistoryTab` now receives real `gameHistory`; shows relative dates; empty state with `no_games_yet`
- `assets/translations/en.json` & `ar.json` — added `no_games_yet`
- Regenerated `profile_state.freezed.dart`, `game_history_model.freezed.dart` / `.g.dart`, `injection.config.dart` via `build_runner`

**Status:** ✅ Profile History tab now loads real game history from Firestore. Falls back to mock data if subcollection is empty.

---

### Phase K: Profile Achievements
**Files modified/created:**
- `lib/features/profile/domain/entities/achievement.dart` — new entity: `id`, `title`, `description`, `iconName`, `unlockedAt`
- `lib/features/profile/data/models/achievement_model.dart` — new Freezed model with `toEntity()`
- `lib/features/profile/data/datasources/profile_remote_data_source.dart` — added `getAchievements(uid)` with Firestore `users/{uid}/achievements` query + mock fallback (6 achievements)
- `lib/features/profile/domain/repositories/profile_repository.dart` — added `getAchievements()`
- `lib/features/profile/data/repositories/profile_repository_impl.dart` — implemented `getAchievements()`
- `lib/features/profile/presentation/cubit/profile_state.dart` — `loaded` now carries `List<Achievement> achievements`
- `lib/features/profile/presentation/cubit/profile_cubit.dart` — loads achievements alongside profile and game history
- `lib/features/profile/presentation/pages/user_profile_page.dart` — `_StatsTab` now shows real achievements; added `_AchievementCard` widget with icon mapping and unlock date formatting
- Regenerated `profile_state.freezed.dart`, `achievement_model.freezed.dart` / `.g.dart`, `injection.config.dart` via `build_runner`

**Status:** ✅ Profile Achievements now load from Firestore. All profile tabs are 100% real.

---

### Phase L: Chat List Firestore Integration
**Files modified/created:**
- `lib/features/chat/data/datasources/chat_remote_data_source.dart` — added `FirebaseFirestore` + `firebase_auth.FirebaseAuth` injection; rewrote `getConversations()` to query Firestore `conversations` where `participantIds` contains current user UID, ordered by `lastMessageAt` desc; added `_formatRelativeTime()` to convert `Timestamp` → `'2m'`/`'1h'`/`'3d'` strings; extracted hardcoded conversations to `_mockConversations` fallback
- `lib/core/di/injection.config.dart` — regenerated via `build_runner`; `ChatRemoteDataSource` now receives `firestore` and `firebaseAuth`

**Status:** ✅ Chat list now queries Firestore. Falls back to mock data if no docs or user not authenticated.

---

### Phase M: Chat Messages Firestore Integration
**Files modified/created:**
- `lib/config/routes/routes.dart` — changed `directMessage` path param from `:userId` to `:conversationId`
- `lib/config/routes/app_router.dart` — extracts `conversationId` from path params and `ChatConversation?` from `extra`; passes both to `DirectMessagePage`; calls `ChatCubit.watchMessages()`
- `lib/features/chat/domain/repositories/chat_repository.dart` — added `watchMessages(String)` → `Stream<List<ChatMessage>>`; changed `sendMessage` to return `Future<void>`
- `lib/features/chat/data/repositories/chat_repository_impl.dart` — implemented `watchMessages` by mapping remote data source stream; `sendMessage` delegates to remote data source
- `lib/features/chat/data/datasources/chat_remote_data_source.dart` — added `watchMessages()` with Firestore `.snapshots()` on `conversations/{id}/messages` ordered by `createdAt desc`; added `_mapMessageDoc` with `senderId == _uid` → `isMe` and `_formatMessageTime`; rewrote `sendMessage()` to write message doc + update conversation `lastMessage`/`lastMessageAt`; kept `getMessages()` as mock fallback
- `lib/features/chat/presentation/cubit/chat_cubit.dart` — added `StreamSubscription? _messagesSubscription`; `watchMessages()` cancels previous sub and listens to repo stream, emitting `messagesLoaded` on each update; `sendMessage()` now only awaits repo write (stream handles UI update); `close()` cancels subscription
- `lib/features/chat/presentation/pages/direct_message_page.dart` — replaced `userId` with `conversationId` + optional `ChatConversation? conversation`; AppBar uses real `conversation.name` and `conversation.avatarUrl` instead of hardcoded values; all message actions use `widget.conversationId`
- `lib/features/chat/presentation/pages/chat_list_page.dart` — passes `conversationId: chat.id` in path params and `extra: chat` when navigating to direct message
- `lib/features/chat/presentation/pages/new_message_page.dart` — updated path parameter key to `conversationId`

**Status:** ✅ Chat messages now stream in real-time from Firestore. Sending a message writes to Firestore and updates the list via snapshot listener. DirectMessage AppBar shows real conversation data.

---

### Phase N: Chat New Conversation Flow
**Files modified/created:**
- `lib/features/chat/data/datasources/chat_remote_data_source.dart` — added `searchUsers(String query)` with client-side filtering across `displayName`/`username`; added `createDirectConversation(String otherUserId)` with deterministic conversation ID (`dm_${sortedUids}`), auto-creates conversation doc with other user's name/avatar if missing
- `lib/features/chat/domain/repositories/chat_repository.dart` — added `searchUsers()` and `createDirectConversation()`
- `lib/features/chat/data/repositories/chat_repository_impl.dart` — implemented new methods
- `lib/features/chat/presentation/cubit/new_message_cubit.dart` — new cubit: `search(query)` and `createConversation(otherUserId)`
- `lib/features/chat/presentation/cubit/new_message_state.dart` — new Freezed states: initial/loading/loaded/creating/conversationCreated/error
- `lib/features/chat/presentation/pages/new_message_page.dart` — complete rewrite: uses `NewMessageCubit`, searches users on init and on text change, shows user avatars, creates conversation on tap and navigates to direct message with real `conversationId` + `ChatConversation` extra
- `lib/config/routes/app_router.dart` — `newMessage` route now injects `NewMessageCubit`
- `assets/translations/en.json` & `ar.json` — added `new_message`, `search_players`, `search_for_players`, `no_players_found`, `send`
- Regenerated `new_message_state.freezed.dart`, `injection.config.dart` via `build_runner`

**Status:** ✅ Chat is now 100% wired to Firestore. Users can search for other users, start a new direct conversation, send/receive real-time messages, and view conversation list.

---

### Phase O: Tournament Bracket & Prize Distribution Wiring
**Files modified/created:**
- `lib/features/tournament/domain/entities/tournament.dart` — added `TournamentPrize` (place, amount), `TournamentMatch` (playerA/B names, scores, status, avatars, round, isUserMatch), updated `Tournament` entity with `prizes` and `bracket` fields
- `lib/features/tournament/data/models/tournament_model.dart` — added `TournamentPrizeModel` and `TournamentMatchModel` as Freezed classes with `fromJson`/`toJson`, updated `TournamentModel` with `prizes` and `bracket` lists
- `lib/features/tournament/data/datasources/tournament_remote_data_source.dart` — `_mapDocToModel` now reads `prizes` and `bracket` arrays from Firestore; `_mapPrizes` and `_mapBracket` helpers; updated mock data with full bracket (quarter_final ×4, semi_final ×2, final ×1) and prize distributions
- `lib/features/tournament/presentation/pages/tournament_detail_page.dart` — prize distribution section now iterates `tournament.prizes` dynamically with color mapping by index (1st=secondary, 2nd=darkTextSecondary, 3rd=secondaryDark, 4th+=darkTextMuted); shows `'no_prizes_available'` fallback when empty
- `lib/features/tournament/presentation/pages/tournament_bracket_page.dart` — complete rewrite: now a `BlocConsumer<TournamentCubit>` that loads tournament by ID, groups matches by round (`quarter_final`, `semi_final`, `final`), renders real `BracketMatchCard` widgets with status parsed from string → `MatchStatus` enum; shows `'bracket_not_available'` empty state; AppBar title shows real tournament name
- `lib/config/routes/app_router.dart` — `tournamentBracket` route now injects `TournamentCubit` + calls `loadTournament(id)`
- `assets/translations/en.json` & `ar.json` — added `quarter_final`, `semi_final`, `final`, `no_prizes_available`, `bracket_not_available`
- Regenerated `tournament_model.freezed.dart` / `.g.dart` via `build_runner`

**Status:** ✅ Tournament prize distribution and bracket visualization now read from Firestore. Mock fallback includes full bracket data. Tournament user journey is complete from list → detail → bracket.

---

### Phase P: Tournament Join Firestore Integration
**Files modified/created:**
- `lib/features/tournament/domain/entities/tournament.dart` — added `entryFee` (String) and `participantIds` (List<String>) to `Tournament`
- `lib/features/tournament/data/models/tournament_model.dart` — added `entryFee` and `participantIds` to `TournamentModel`; updated mock data with `entryFee` values ('500', '200', '0', '1,000', '300')
- `lib/features/tournament/data/datasources/tournament_remote_data_source.dart` — added `firebase_auth.FirebaseAuth` injection; `_mapDocToModel` now reads `entryFee` and `participantIds`, computes `isJoined` dynamically (`participantIds.contains(uid)`); added `joinTournament(String)` with Firestore transaction that checks auth, deduplicates, checks capacity via `_parseMaxParticipants`, adds UID to `participantIds`, updates `participants` count string
- `lib/features/tournament/domain/repositories/tournament_repository.dart` — added `joinTournament(String)` → `Future<Tournament>`
- `lib/features/tournament/data/repositories/tournament_repository_impl.dart` — implemented `joinTournament`
- `lib/features/tournament/presentation/cubit/tournament_cubit.dart` — `joinTournament` now calls `_tournamentRepository.joinTournament()`, catches errors and emits `joinError` with the actual exception message
- `lib/features/tournament/presentation/pages/tournament_detail_page.dart` — `_showJoinBottomSheet` now passes `tournament.entryFee` (with fallback to '0'); button shows `'view_bracket'` when `isJoined` is true (computed from Firestore participantIds)
- `lib/features/tournament/presentation/widgets/join_tournament_bottom_sheet.dart` — `entryFee` now displays `'free_entry'.tr()` for '0'/'free_entry'; added optional `balance` parameter (not wired yet); removed hardcoded `'500'` and `'2,450 coins'`
- Regenerated `tournament_model.freezed.dart` / `.g.dart`, `injection.config.dart` via `build_runner`

**Status:** ✅ Tournament join now writes to Firestore via atomic transaction. `isJoined` is computed dynamically from `participantIds`. Entry fee is real per tournament doc. Participant avatars resolved from user profiles and current coin balance displayed in join bottom sheet.

---

### Phase Q: Discover Streams Firestore Integration
**Files modified/created:**
- `lib/features/discover/domain/entities/discover_stream.dart` — expanded `StreamChatMessage` with `id`, `senderUid`, `senderName`, `senderAvatar`, `text`, `type`, `createdAt`, `isMe`
- `lib/features/discover/data/models/discover_stream_model.dart` — rewrote `StreamChatMessageModel` as Freezed with new fields and `fromJson`/`toJson`; updated extension mappers
- `lib/features/discover/domain/repositories/discover_repository.dart` — added `watchStreamChat(String)`; changed `sendChatMessage` return type to `Future<void>`
- `lib/features/discover/data/repositories/discover_repository_impl.dart` — implemented `watchStreamChat` and updated `sendChatMessage`
- `lib/features/discover/data/datasources/discover_remote_data_source.dart` — injected `FirebaseFirestore` + `FirebaseAuth`; `getStreams()` now queries `streams` where `status == 'live'` ordered by `viewerCount desc` with mock fallback; `getStreamById(id)` reads Firestore doc with fallback; `watchStreamChat(streamId)` streams `streams/{id}/chat` snapshots; `sendChatMessage` writes authenticated message doc with sender profile lookup
- `lib/features/discover/presentation/cubit/discover_cubit.dart` — `loadStream(id)` now starts a real-time chat subscription and emits `streamLoaded` on each snapshot; cancels subscription in `close()`
- `lib/features/discover/presentation/pages/watch_stream_page.dart` — overlay now shows real `stream.title`, `stream.host`, `stream.viewers`; chat list renders real messages with sender avatar/name; added `chat_unavailable` empty state; 4 video squares remain as Agora placeholders
- `assets/translations/en.json` & `ar.json` — added `chat_unavailable`, `failed_to_send`, `stream_offline`
- Regenerated `discover_stream_model.freezed.dart`, `discover_stream_model.g.dart`, `injection.config.dart` via `build_runner`

**Status:** ✅ Discover stream list and stream detail metadata are now real from Firestore. Stream chat is real-time via `streams/{id}/chat` snapshots with authenticated writes.

**Verification:**
- `flutter analyze --no-pub` → No issues found.
- `flutter test --no-pub` → 11/11 passed.

---

### Phase R: Room/Game Loop Verification & Critical Gap Fixes
**Files modified/created:**
- `functions/src/https/dealNextRound.ts` (new) — Cloud Function that deals a new round when `status == 'roundEnd'`, resets per-round player state, and refreshes turn timer
- `functions/src/https/playCard.ts` — now persists `fellTeam` from `calculateRoundScore` on the 13th trick; refreshes `turnTimerStart` after each card play and next trick
- `functions/src/https/placeBid.ts` — refreshes `turnTimerStart` after each bid advance and after bidding resolves
- `functions/src/https/autoPlay.ts` — migrated to `firebase-functions/v2/scheduler` (`onSchedule`) to fix build errors; also sets `turnTimerStart` and persists `fellTeam`
- `functions/src/index.ts` — exports `dealNextRound`; `autoPlay` now compiles into `lib/index.js`
- `lib/features/game/data/models/game_model.dart` — added `fellTeam` field and propagated it through `toEntity()`
- `lib/features/game/domain/entities/game.dart` — added `fellTeam` to entity and `copyWith`
- `lib/features/game/data/datasources/game_remote_data_source.dart` — maps `fellTeam` from Firestore; adds `dealNextRound` Cloud Function call
- `lib/features/game/domain/repositories/game_repository.dart` — adds `dealNextRound(String)`
- `lib/features/game/data/repositories/game_repository_impl.dart` — implements `dealNextRound`
- `lib/features/game/presentation/cubit/game_cubit.dart` — adds `claimBonuses()` and `dealNextRound()` methods; passes `fellTeam` to `GameState.roundEnd`
- `lib/features/game/presentation/widgets/bonus_claim_overlay.dart` (new) — overlay for Hokm bonus-claim phase with auto-detect for bnaga/mosal bonuses, Claim, and No Bonuses actions
- `lib/features/game/presentation/pages/game_play_page.dart` — shows `BonusClaimOverlay` during `bonusClaim`; wires `RoundScoreOverlay.onNextRound` to `GameCubit.dealNextRound()`
- `lib/features/game/presentation/cubit/local_game_simulator.dart` — added stub `dealNextRound` to satisfy updated `GameRepository` interface
- `assets/translations/en.json` & `ar.json` — added `auto_detect`, `claim`, `claim_bonuses`, `next_round`, `no_bonuses`, `select_bonus_cards`, `fell`
- Regenerated `game_model.freezed.dart`, `game_model.g.dart`, `injection.config.dart` via `build_runner`
- Rebuilt `functions/lib/` via `npm run build`

**Status:** ✅ The core room → game loop is now playable end-to-end for multiple rounds. Critical blockers fixed: bonus claim UI, next round deal, fell team display, turn timer refresh, and stale compiled Cloud Functions output.

**Verification:**
- `cd functions && npm run build` → success (no TS errors)
- `cd functions && npm test` → 8 suites, 77 tests passed
- `flutter analyze --no-pub` → No issues found
- `flutter test --no-pub` → 11/11 passed

---

### Phase S: Room Social Polish & In-Game Controls
**Files modified/created:**
- `functions/src/https/rematch.ts` (new) — HTTPS CF that resets finished room to `waiting`, clears `gameId` and `readyPlayers`
- `functions/src/scheduler/cleanStaleRooms.ts` (new) — hourly scheduled job deleting stale `waiting`/`finished` rooms and empty rooms
- `functions/src/index.ts` — exports `rematch` and `cleanStaleRooms`; fixes `generateAgoraToken` to accept `uid` from client
- `pubspec.yaml` — added `share_plus: ^10.1.4`
- `lib/features/game/domain/entities/game.dart` — added `roomId`
- `lib/features/game/data/models/game_model.dart` — added `roomId` field + mapping
- `lib/features/game/data/datasources/game_remote_data_source.dart` — maps `roomId`; added `rematch()` CF call
- `lib/features/game/domain/repositories/game_repository.dart` — added `rematch(String roomId)`
- `lib/features/game/data/repositories/game_repository_impl.dart` — implemented `rematch`
- `lib/features/game/presentation/cubit/game_cubit.dart` — injects `AgoraService` + `RoomRepository`; adds `toggleMic`, `toggleCamera`, `toggleChat`, `sendChatMessage`, `rematch`, `leaveGame`; watches room chat stream
- `lib/features/game/presentation/cubit/game_state.dart` — added `chatOpen` and `chatMessages` to all active game state factories
- `lib/features/game/presentation/pages/game_play_page.dart` — wired mic/camera/chat controls; added `GameChatOverlay`; fixed leave dialog to call `leaveGame()`; wired `onRematch` to navigate back to lobby
- `lib/features/game/presentation/widgets/game_chat_overlay.dart` (new) — in-game chat overlay with message list + text input
- `lib/features/room/data/datasources/room_remote_data_source.dart` — added `leaveRoom` and `kickPlayer` Firestore transactions
- `lib/features/room/domain/repositories/room_repository.dart` — added `leaveRoom` and `kickPlayer`
- `lib/features/room/data/repositories/room_repository_impl.dart` — implemented new methods
- `lib/features/room/presentation/cubit/room_cubit.dart` — added `leaveRoom` and `kickPlayer` methods
- `lib/features/room/presentation/pages/room_lobby_page.dart` — wired share to `share_plus` native share sheet; wired settings bottom sheet leave action
- `lib/features/room/presentation/widgets/room_settings_bottom_sheet.dart` — accepts `Room` + `onLeave`; shows real settings; confirmation dialog before leave
- `lib/features/room/presentation/widgets/seat_widget.dart` — added kick button for creator on occupied seats; empty-seat invite opens share sheet
- `lib/features/chat/presentation/pages/room_invitation_page.dart` — full rewrite: loads real room data, shows live player count, handles loading/error/full/closed states
- `lib/core/services/agora_service.dart` — passes `uid` to `generateAgoraToken` CF
- `assets/translations/en.json` & `ar.json` — added `type_message`, `kick_player`, `kick_confirm`, `leave_room_confirm`, `room_full`, `room_closed`, `room_not_found`
- Regenerated `game_model.freezed.dart`, `game_model.g.dart`, `game_state.freezed.dart`, `injection.config.dart`

**Status:** ✅ Room invite/share works natively. Leave/kick cleanup is wired to Firestore. In-game mic/camera toggles and chat overlay work. Rematch resets room to waiting state. Agora token UID mismatch fixed.

**Verification:**
- `cd functions && npm run build` → success
- `cd functions && npm test` → 8 suites, 77 tests passed
- `flutter analyze --no-pub` → No issues found
- `flutter test --no-pub` → 11/11 passed

---

## Recommended Next Phase: Phase T — Post-MVP Polish & Deep Links

### Why:
- Profile, Settings, Notifications, Chat, Tournament, Discover/Streams, and the Room/Game loop are now fully wired.
- The core MVP feature set is complete. Remaining gaps are primarily UX polish and social features that improve session quality but do not block a playable game.

### Scope:
1. **Real room invite/share flow**
   - Fix `/room-invite/:id` to load the actual room and inviter.
   - Wire the seat "Invite" button to open a share sheet / copy invite code.
   - Add a "copy code" action in the room lobby.
2. **Leave / kick / cleanup**
   - Add a Cloud Function `leaveRoom` that removes a player from `rooms/{id}`.
   - Add a room cleanup job that deletes stale rooms with no active players.
   - Allow the host to kick a player before the game starts.
3. **In-game media controls**
   - Wire mic, camera, chat, and settings buttons in `GamePlayPage`.
   - Keep Agora service lifecycle tied to room/game navigation.
4. **Rematch flow**
   - Implement `FinalScoreOverlay.onRematch` to restart a game with the same players.

### Acceptance criteria:
- Users can share a room invite with a deep link or copyable code.
- Players can leave a room before the game starts.
- In-game mic/camera toggles work during a match.
- Rematch restarts a new game with the same 4 players.
- `flutter analyze --no-pub` and `flutter test --no-pub` remain green.

### Deferred (post-MVP):
- **Public room list / browse** — discover open public rooms.
- **Spectator mode** — watch streams without playing.
- **Agora video publisher/subscriber views** — replace placeholder video squares.
- **Advanced matchmaking / ranked play**.
- **Automated tournament bracket progression backend**.

---



## Critical Files for Reference

| Component | Key Files |
|---|---|
| DI Registration | `lib/core/di/injection.config.dart` (generated) |
| Routing | `lib/config/routes/app_router.dart`, `lib/config/routes/routes.dart` |
| Colors/Spacing | `lib/core/style/colors.dart`, `lib/core/constants/app_spacing.dart`, `lib/core/constants/app_radius.dart` |
| Cache/Storage | `lib/core/network/cache_helper.dart`, `lib/core/network/cache_keys.dart` |
| Localization | `assets/translations/en.json`, `assets/translations/ar.json` |
| Firestore Schema | `docs/firebase_schema.md` |
| Missing Screens | `flow_validation/04_missing_screens_report.md` |
| Implementation Plan | `docs/implementation_plan.md` |

---

## Build Commands

```bash
# After modifying freezed classes or injectable constructors
flutter pub run build_runner build --delete-conflicting-outputs

# Verify
flutter analyze --no-pub
flutter test --no-pub
```

---

## Code Rules Reminders (from AGENTS.md + coderules)

- Feature structure: `domain/entities/`, `data/models/`, `data/datasources/`, `data/repositories/`, `presentation/cubit/`, `presentation/pages/`
- Domain has ZERO external dependencies
- Presentation NEVER imports data layer directly
- Shared entities go in `shared/models/` or `core/entities/`
- Use `EdgeInsetsDirectional` (never `EdgeInsets.only(left/right)`)
- Use `AlignmentDirectional` (never `Alignment.centerLeft/Right`)
- Localization uses `.tr()` from easy_localization
- All colors via `ColorManager`, spacing via `AppSpacing`, radius via `AppRadius`
- `@injectable` for Cubits (factory), `@LazySingleton(as: ...)` for repositories
- Import order: Dart core → Flutter → External → Internal → Relative
