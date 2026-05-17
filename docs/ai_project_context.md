# Bloot — AI Project Context

> **Purpose:** Detailed project structure, state management patterns, UI/styling conventions, data layer specifics, and development workflow. Used by AI agents to understand the full project architecture.

---

## 1. Detailed Folder Structure Per Feature

Every feature follows the same internal structure. Below is the canonical pattern, then a feature-by-feature breakdown.

### Canonical Feature Structure

```
features/{feature_name}/
├── domain/
│   ├── entities/
│   │   └── {feature_name}.dart          # Pure business entity (no freezed)
│   ├── repositories/
│   │   └── {feature_name}_repository.dart  # Abstract repository interface
│   └── use_cases/                        # Optional — only for complex logic
│       └── {action}_use_case.dart
├── data/
│   ├── models/
│   │   └── {feature_name}_model.dart     # Freezed data model + fromJson/toJson
│   ├── datasources/
│   │   ├── {feature_name}_remote_data_source.dart   # Firestore/Agora calls
│   │   └── {feature_name}_local_data_source.dart    # Optional local caching
│   └── repositories/
│       └── {feature_name}_repository_impl.dart       # Implements domain interface
└── presentation/
    ├── cubit/
    │   ├── {feature_name}_cubit.dart     # State management logic
    │   └── {feature_name}_state.dart     # Freezed state definitions
    ├── pages/
    │   └── {feature_name}_page.dart      # Main page widget
    └── widgets/
        ├── {component_name}_widget.dart  # Feature-specific widgets
        └── ...
```

### Feature Breakdown

#### `auth/`
```
auth/
├── domain/
│   ├── entities/
│   │   └── user.dart                    # User entity (id, phone, displayName, username, avatar, level, xp, coins)
│   ├── repositories/
│   │   └── auth_repository.dart         # login(phone), verifyOtp(code), completeProfile(params), getCurrentUser()
│   └── use_cases/
│       └── complete_profile_use_case.dart  # Validate profile data before submission
├── data/
│   ├── models/
│   │   └── user_model.dart              # Freezed User with fromJson/toJson, Firestore field mapping
│   ├── datasources/
│   │   └── auth_remote_data_source.dart # Firebase Auth + Firestore user creation
│   └── repositories/
│       └── auth_repository_impl.dart
└── presentation/
    ├── cubit/
    │   ├── auth_cubit.dart               # States: initial, loading, otpSent, authenticated, error
    │   └── auth_state.dart               # Freezed states
    ├── pages/
    │   ├── login_page.dart               # Phone input + OTP flow
    │   ├── otp_verification_page.dart     # 4-digit code entry
    │   └── complete_profile_page.dart    # Name, username, avatar setup
    └── widgets/
        ├── phone_input.dart
        ├── otp_input.dart
        └── avatar_picker.dart
```

#### `home/`
```
home/
├── domain/
│   ├── entities/
│   │   └── home_feed.dart               # Aggregated feed entity
│   └── repositories/
│       └── home_repository.dart          # getLiveStreams(), getTournaments(), getQuickActions()
├── data/
│   ├── models/
│   │   └── home_feed_model.dart
│   ├── datasources/
│   │   └── home_remote_data_source.dart  # Firestore queries for streams + tournaments
│   └── repositories/
│       └── home_repository_impl.dart
└── presentation/
    ├── cubit/
    │   ├── home_cubit.dart               # States: initial, loading, loaded, error
    │   └── home_state.dart
    ├── pages/
    │   └── home_page.dart                # Hero banner, quick actions, live streams, tournaments
    └── widgets/
        ├── hero_banner.dart
        ├── quick_action_card.dart
        ├── live_stream_list.dart
        └── tournament_preview_card.dart
```

#### `discover/`
```
discover/
├── domain/
│   ├── entities/
│   │   └── stream_filter.dart           # Filter criteria entity
│   └── repositories/
│       └── discover_repository.dart      # searchStreams(query), filterStreams(filter), getCategories()
├── data/
│   ├── models/
│   │   └── stream_filter_model.dart
│   ├── datasources/
│   │   └── discover_remote_data_source.dart
│   └── repositories/
│       └── discover_repository_impl.dart
└── presentation/
    ├── cubit/
    │   ├── discover_cubit.dart           # States: initial, loading, loaded, searching, filtered, error
    │   └── discover_state.dart
    ├── pages/
    │   └── discover_page.dart
    └── widgets/
        ├── search_bar_widget.dart
        ├── filter_tabs.dart
        ├── stream_grid.dart
        └── stream_card.dart              # Shared with home, but with grid layout variant
```

#### `rooms/`
```
rooms/
├── domain/
│   ├── entities/
│   │   ├── room.dart                    # Room entity (id, name, type, settings, players, status)
│   │   └── player_seat.dart             # Player seat (player, team, ready status, mic/cam status)
│   ├── repositories/
│   │   └── room_repository.dart          # createRoom(), joinRoom(), leaveRoom(), updateSettings(), watchRoom()
│   └── use_cases/
│       ├── create_room_use_case.dart
│       └── join_room_use_case.dart
├── data/
│   ├── models/
│   │   ├── room_model.dart
│   │   └── player_seat_model.dart
│   ├── datasources/
│   │   └── room_remote_data_source.dart  # Firestore rooms collection + real-time listener
│   └── repositories/
│       └── room_repository_impl.dart
└── presentation/
    ├── cubit/
    │   ├── create_room_cubit.dart
│   │   ├── room_lobby_cubit.dart          # States: loading, waiting, allReady, gameStarting, error
    │   │   └── create_room_state.dart
    │   └── room_lobby_state.dart
    ├── pages/
    │   ├── create_room_page.dart
    │   └── room_lobby_page.dart
    └── widgets/
        ├── player_seat_widget.dart       # Video square + status indicators
        ├── room_settings_card.dart
        └── room_code_share.dart
```

#### `game/`
```
game/
├── domain/
│   ├── entities/
│   │   ├── game.dart                    # Game entity (id, roomId, type, state, currentTrick, scores)
│   │   ├── card_entity.dart             # Playing card (suit, rank)
│   │   ├── trick.dart                   # Current trick entity
│   │   └── game_rules.dart              # Baloot rules constants
│   ├── repositories/
│   │   └── game_repository.dart          # startGame(), playCard(), declareHokm(), watchGameState()
│   └── use_cases/
│       ├── validate_card_play_use_case.dart  # Check if card play is legal
│       ├── calculate_score_use_case.dart     # Score calculation per round
│       └── determine_winner_use_case.dart    # Game end detection
├── data/
│   ├── models/
│   │   ├── game_model.dart
│   │   ├── card_model.dart
│   │   └── trick_model.dart
│   ├── datasources/
│   │   ├── game_remote_data_source.dart  # Firestore games collection + real-time state
│   │   └── baloot_engine.dart            # Local game logic (card validation, trick resolution)
│   └── repositories/
│       └── game_repository_impl.dart
└── presentation/
    ├── cubit/
    │   ├── game_cubit.dart               # States: dealing, waitingForTurn, yourTurn, trickWon, roundEnd, gameEnd
    │   └── game_state.dart
    ├── pages/
    │   └── game_play_page.dart           # Landscape-only game screen
    └── widgets/
        ├── game_table_widget.dart
        ├── player_video_square.dart
        ├── card_hand_widget.dart
        ├── card_widget.dart
        ├── score_display_widget.dart
        └── game_controls_widget.dart
```

#### `stream/`
```
stream/
├── domain/
│   ├── entities/
│   │   └── stream_view.dart             # Viewer-mode stream entity
│   └── repositories/
│       └── stream_repository.dart        # watchStream(), joinStreamViewer(), leaveStream()
├── data/
│   ├── models/
│   │   └── stream_view_model.dart
│   ├── datasources/
│   │   └── stream_remote_data_source.dart # Agora channel join + Firestore stream doc
│   └── repositories/
│       └── stream_repository_impl.dart
└── presentation/
    ├── cubit/
    │   ├── stream_viewer_cubit.dart       # States: loading, streaming, paused, ended, error
    │   └── stream_viewer_state.dart
    ├── pages/
    │   └── stream_viewer_page.dart        # Portrait + landscape viewer
    └── widgets/
        ├── viewer_video_grid.dart
        ├── viewer_game_table.dart
        ├── viewer_chat.dart
        └── interaction_buttons.dart
```

#### `tournaments/`
```
tournaments/
├── domain/
│   ├── entities/
│   │   ├── tournament.dart              # Tournament entity
│   │   └── bracket.dart                # Bracket/matchup entity
│   └── repositories/
│       └── tournament_repository.dart    # getTournaments(), getTournament(id), joinTournament()
├── data/
│   ├── models/
│   │   ├── tournament_model.dart
│   │   └── bracket_model.dart
│   ├── datasources/
│   │   └── tournament_remote_data_source.dart
│   └── repositories/
│       └── tournament_repository_impl.dart
└── presentation/
    ├── cubit/
    │   ├── tournament_list_cubit.dart
│   │   ├── tournament_detail_cubit.dart
    │   └── tournament_list_state.dart
    │   └── tournament_detail_state.dart
    ├── pages/
    │   ├── tournament_list_page.dart
    │   └── tournament_detail_page.dart
    └── widgets/
        ├── tournament_card.dart
        ├── bracket_widget.dart
        └── prize_distribution_card.dart
```

#### `chat/`
```
chat/
├── domain/
│   ├── entities/
│   │   ├── message.dart                 # Chat message entity
│   │   └── conversation.dart            # Conversation/thread entity
│   └── repositories/
│       └── chat_repository.dart          # getConversations(), getMessages(convId), sendMessage()
├── data/
│   ├── models/
│   │   ├── message_model.dart
│   │   └── conversation_model.dart
│   ├── datasources/
│   │   └── chat_remote_data_source.dart  # Firestore messages subcollection + real-time
│   └── repositories/
│       └── chat_repository_impl.dart
└── presentation/
    ├── cubit/
    │   ├── chat_list_cubit.dart
│   │   ├── chat_conversation_cubit.dart
    │   └── chat_list_state.dart
    │   └── chat_conversation_state.dart
    ├── pages/
    │   ├── chat_list_page.dart
    │   └── dm_page.dart
    └── widgets/
        ├── message_bubble.dart
        ├── quick_action_chips.dart
        └── room_invitation_card.dart
```

#### `profile/`
```
profile/
├── domain/
│   ├── entities/
│   │   └── user_profile.dart            # Extended profile entity (stats, achievements, history)
│   └── repositories/
│       └── profile_repository.dart       # getProfile(userId), updateProfile(params), getStats(userId)
├── data/
│   ├── models/
│   │   ├── user_profile_model.dart
│   │   └── game_stats_model.dart
│   ├── datasources/
│   │   └── profile_remote_data_source.dart
│   └── repositories/
│       └── profile_repository_impl.dart
└── presentation/
    ├── cubit/
    │   ├── profile_cubit.dart
│   │   ├── edit_profile_cubit.dart
    │   └── profile_state.dart
    │   └── edit_profile_state.dart
    ├── pages/
    │   ├── profile_page.dart
    │   └── edit_profile_page.dart
    └── widgets/
        ├── stats_card.dart
        ├── achievement_badge.dart
        └── game_history_item.dart
```

#### `settings/`
```
settings/
├── domain/
│   └── repositories/
│       └── settings_repository.dart       # getSettings(), updateSettings(), deleteAccount()
├── data/
│   ├── datasources/
│   │   └── settings_local_data_source.dart  # SharedPreferences for cached settings
│   └── repositories/
│       └── settings_repository_impl.dart
└── presentation/
    ├── cubit/
    │   ├── settings_cubit.dart
    │   └── settings_state.dart
    ├── pages/
    │   ├── settings_page.dart
    │   ├── privacy_policy_page.dart
    │   ├── terms_page.dart
    │   └── about_page.dart
    └── widgets/
        └── settings_section.dart
```

---

## 2. State Management Patterns

### 2.1 Cubit Pattern (Primary)

Every feature uses `Cubit` (not full `Bloc`) for state management. Cubits are simpler and sufficient for most UI state.

**State definition (freezed):**

```dart
@freezed
class HomeState with _$HomeState {
  const factory HomeState.initial() = HomeInitial;
  const factory HomeState.loading() = HomeLoading;
  const factory HomeState.loaded({
    required List<StreamItem> liveStreams,
    required List<Tournament> upcomingTournaments,
  }) = HomeLoaded;
  const factory HomeState.error({required String message}) = HomeError;
}
```

**Cubit definition:**

```dart
class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _repository;

  HomeCubit(this._repository) : super(const HomeState.initial());

  Future<void> loadHome() async {
    emit(const HomeState.loading());
    try {
      final streams = await _repository.getLiveStreams();
      final tournaments = await _repository.getUpcomingTournaments();
      emit(HomeState.loaded(
        liveStreams: streams,
        upcomingTournaments: tournaments,
      ));
    } catch (e) {
      emit(HomeState.error(message: e.toString()));
    }
  }
}
```

**Widget usage:**

```dart
BlocProvider(
  create: (context) => HomeCubit(context.read<HomeRepository>())..loadHome(),
  child: BlocBuilder<HomeCubit, HomeState>(
    builder: (context, state) {
      return state.when(
        initial: () => const SizedBox.shrink(),
        loading: () => const HomeLoadingWidget(),
        loaded: (streams, tournaments) => HomeContentWidget(
          streams: streams,
          tournaments: tournaments,
        ),
        error: (message) => HomeErrorWidget(message: message),
      );
    },
  ),
)
```

### 2.2 Real-Time State (Firestore Streams)

For features that need real-time updates (game state, room status, chat), use `emitForEach`:

```dart
Future<void> watchRoom(String roomId) async {
  emit(const RoomState.loading());
  await emitForEach(
    _repository.watchRoom(roomId),
    onData: (room) => RoomState.loaded(room: room),
    onError: (error, _) => RoomState.error(message: error.toString()),
  );
}
```

### 2.3 State Conventions

- **Loading state** — Always show loading state before async operations. Use skeleton/shimmer animations.
- **Error state** — Every Cubit that performs async work must have an error state with a user-friendly message.
- **Initial state** — Every Cubit starts with `initial()` state. Data loading is triggered explicitly.
- **No state mutation** — States are immutable (freezed). Never mutate state directly.

---

## 3. UI & Styling

### 3.1 flutter_screenutil

Use `flutter_screenutil` for responsive sizing:

```dart
// Sizing
16.w      // width-based responsive
16.h      // height-based responsive
16.r      // radius-based (min of w and h)
16.sp     // text size (respects font scaling)

// Preferred: Use .w for horizontal, .h for vertical, .r for radius, .sp for text
```

### 3.2 Dark Theme Setup

```dart
ThemeData get darkTheme => ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: ColorManager.black,
  primaryColor: ColorManager.purple,
  colorScheme: const ColorScheme.dark(
    primary: ColorManager.purple,
    secondary: ColorManager.gold,
    surface: ColorManager.surfaceElevated,
    error: ColorManager.error,
  ),
  fontFamily: 'Cairo',  // Primary font, Inter for English
  textTheme: textTheme,
  cardTheme: CardThemeData(
    color: ColorManager.surfaceElevated,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.r),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: ColorManager.surfaceMuted,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
    ),
  ),
  elevatedButtonTheme: elevatedButtonTheme,
  // ... see DESIGN.md for full token mapping
);
```

### 3.3 RTL Configuration

```dart
MaterialApp(
  localizationsDelegates: [...],
  supportedLocales: [Locale('ar'), Locale('en')],
  locale: Locale('ar'),  // Default Arabic
  theme: darkTheme,
  builder: (context, child) {
    return Directionality(
      textDirection: TextDirection.rtl,  // Default RTL
      child: child!,
    );
  },
)
```

### 3.4 Typography in Flutter

```dart
TextTheme get textTheme => TextTheme(
  headlineLarge: TextStyle(fontFamily: 'Inter', fontSize: 28.sp, fontWeight: FontWeight.w800, color: ColorManager.onSurface),
  headlineMedium: TextStyle(fontFamily: 'Inter', fontSize: 24.sp, fontWeight: FontWeight.w700, color: ColorManager.onSurface),
  titleLarge: TextStyle(fontFamily: 'Inter', fontSize: 18.sp, fontWeight: FontWeight.w700, color: ColorManager.onSurface),
  titleMedium: TextStyle(fontFamily: 'Inter', fontSize: 15.sp, fontWeight: FontWeight.w600, color: ColorManager.onSurface),
  bodyLarge: TextStyle(fontFamily: 'Inter', fontSize: 14.sp, fontWeight: FontWeight.w400, color: ColorManager.onSurface),
  bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 14.sp, fontWeight: FontWeight.w500, color: ColorManager.onSurface),
  labelLarge: TextStyle(fontFamily: 'Inter', fontSize: 15.sp, fontWeight: FontWeight.w600, color: ColorManager.onSurface),
  bodySmall: TextStyle(fontFamily: 'Inter', fontSize: 12.sp, fontWeight: FontWeight.w400, color: ColorManager.onSurfaceMuted),
  labelSmall: TextStyle(fontFamily: 'Inter', fontSize: 10.sp, fontWeight: FontWeight.w700, color: ColorManager.onSurface),
);
```

When rendering Arabic text, detect locale and apply:
- Font: `Cairo` instead of `Inter`
- Size: `fontSize + 2`
- `height: lineHeight + 0.3`
- No `letterSpacing`

---

## 4. Data Layer

### 4.1 Firestore Collections

See `docs/firebase_schema.md` for the complete schema. Key collections:

- `users` — User profiles, stats, settings
- `rooms` — Game rooms, players, settings
- `games` — Active games, state, cards, tricks
- `streams` — Stream metadata, viewer counts
- `tournaments` — Tournament definitions, brackets
- `messages` — Direct messages and room chat
- `reports` — User/player reports

### 4.2 Firestore Real-Time Listeners

Use `snapshots()` for features requiring real-time updates:

```dart
Stream<List<RoomModel>> watchRooms() {
  return _firestore
      .collection('rooms')
      .where('status', isEqualTo: 'waiting')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => RoomModel.fromJson(doc.data()!..['id'] = doc.id))
          .toList());
}
```

### 4.3 Agora Voice/Video

```dart
class AgoraService {
  Future<void> joinChannel({
    required String channelName,
    required String token,
    required int uid,
  }) async {
    await _engine.joinChannel(
      token: token,
      channelId: channelName,
      info: '',
      uid: uid,
    );
  }

  Future<void> leaveChannel() async {
    await _engine.leaveChannel();
  }

  Future<void> toggleMic(bool muted) async {
    await _engine.muteLocalAudioStream(muted);
  }

  Future<void> toggleCamera(bool disabled) async {
    await _engine.muteLocalVideoStream(disabled);
  }
}
```

Agora tokens are generated server-side via Cloud Functions and passed to the client.

### 4.4 Repository Pattern

```dart
// Domain interface
abstract class RoomRepository {
  Future<List<Room>> getRooms();
  Stream<List<Room>> watchRooms();
  Future<Room> createRoom(RoomParams params);
  Future<void> joinRoom(String roomId, String userId);
  Future<void> leaveRoom(String roomId, String userId);
}

// Data implementation
class RoomRepositoryImpl implements RoomRepository {
  final RoomRemoteDataSource _remoteDataSource;

  @override
  Stream<List<Room>> watchRooms() {
    return _remoteDataSource.watchRooms().map((models) =>
      models.map((model) => model.toEntity()).toList()
    );
  }

  // ... other methods
}

// Model mapping
extension on RoomModel {
  Room toEntity() => Room(
    id: id,
    name: name,
    type: RoomType.values.firstWhere((e) => e.name == type),
    playerIds: playerIds,
    // ...
  );
}
```

---

## 5. Navigation (go_router)

```dart
final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
    GoRoute(path: '/welcome', builder: (_, __) => const WelcomePage()),
    GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
    GoRoute(path: '/otp', builder: (_, __) => const OtpPage()),
    GoRoute(path: '/profile-setup', builder: (_, __) => const CompleteProfilePage()),
    GoRoute(path: '/home', builder: (_, __) => const HomePage()),
    GoRoute(path: '/discover', builder: (_, __) => const DiscoverPage()),
    GoRoute(path: '/create-room', builder: (_, __) => const CreateRoomPage()),
    GoRoute(path: '/room/:id', builder: (_, state) => RoomLobbyPage(roomId: state.pathParameters['id']!)),
    GoRoute(path: '/game/:id', builder: (_, state) => GamePlayPage(gameId: state.pathParameters['id']!)),
    GoRoute(path: '/stream/:id', builder: (_, state) => StreamViewerPage(streamId: state.pathParameters['id']!)),
    GoRoute(path: '/tournaments', builder: (_, __) => const TournamentListPage()),
    GoRoute(path: '/tournaments/:id', builder: (_, state) => TournamentDetailPage(tournamentId: state.pathParameters['id']!)),
    GoRoute(path: '/chat', builder: (_, __) => const ChatListPage()),
    GoRoute(path: '/chat/:id', builder: (_, state) => DmPage(conversationId: state.pathParameters['id']!)),
    GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
    GoRoute(path: '/profile/:id', builder: (_, state) => ProfilePage(userId: state.pathParameters['id']!)),
    GoRoute(path: '/edit-profile', builder: (_, __) => const EditProfilePage()),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
  ],
  redirect: (context, state) {
    final authState = /* check auth */;
    if (!authState.isLoggedIn && state.matchedLocation != '/login') {
      return '/login';
    }
    return null;
  },
);
```

---

## 6. Single App, Multiple Modes

Bloot is a single app with two distinct user modes:

1. **Player Mode** — The user is actively playing Baloot in a room. They see: game table, their cards, opponent/partner videos, score, controls.
2. **Viewer Mode** — The user is watching a stream. They see: 4 video squares, game table (read-only), chat, interactions (like, gift, follow).

Both modes share the same app shell (bottom navigation, auth, profile). The distinction is handled in routing and state:

```dart
// In route configuration
GoRoute(
  path: '/room/:id',
  builder: (_, state) => RoomLobbyPage(roomId: state.pathParameters['id']!),
),
GoRoute(
  path: '/stream/:id',
  builder: (_, state) => StreamViewerPage(streamId: state.pathParameters['id']!),
),
```

The game play screen auto-detects whether the user is a player or viewer based on room membership.

---

## 7. Development Workflow

### 7.1 Dependency Injection

Use `get_it` for service location:

```dart
final sl = GetIt.instance;

void setupDependencies() {
  // Services
  sl.registerSingleton<AgoraService>(AgoraService());

  // Repositories (domain interfaces → data implementations)
  sl.registerFactory<AuthRepository>(() => AuthRepositoryImpl(
    remoteDataSource: sl<AuthRemoteDataSource>(),
  ));
  sl.registerFactory<RoomRepository>(() => RoomRepositoryImpl(
    remoteDataSource: sl<RoomRemoteDataSource>(),
  ));
  // ... etc.
}
```

### 7.2 Running the App

```bash
flutter pub get              # Install dependencies
flutter run                  # Run on connected device
flutter run -d chrome        # Run on web (for UI testing)
flutter run --flavor dev     # Run with dev environment
```

### 7.3 Testing

```bash
flutter test                           # Run all tests
flutter test test/features/game/       # Run game feature tests
flutter test --coverage                 # Generate coverage report
```

### 7.4 Build

```bash
flutter build apk --flavor production   # Android APK
flutter build ios --flavor production    # iOS (requires Xcode)
```

### 7.5 Environment Configuration

```
lib/core/constants/
├── app_config.dart        # Environment-specific configs (API keys, Agora app ID, etc.)
├── api_keys.dart          # API keys (loaded from env vars, NOT committed)
└── firestore_config.dart  # Firestore collection names as constants
```