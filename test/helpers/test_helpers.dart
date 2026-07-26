import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'engine_state_fixture.dart';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bloot/core/network/connectivity_cubit.dart';
import 'package:bloot/core/services/agora_service.dart';
import 'package:bloot/core/services/audio_service.dart';
import 'package:bloot/core/style/theme_manager.dart';
import 'package:bloot/features/discover/domain/entities/discover_stream.dart';
import 'package:bloot/features/discover/domain/repositories/discover_repository.dart';
import 'package:bloot/features/discover/presentation/cubit/discover_cubit.dart';
import 'package:bloot/features/game/domain/entities/game.dart';
import 'package:bloot/features/game/domain/repositories/game_repository.dart';
import 'package:bloot/features/game/presentation/cubit/game_cubit.dart';
import 'package:bloot/features/room/domain/entities/room.dart';
import 'package:bloot/features/room/domain/repositories/room_repository.dart';
import 'package:bloot/features/room/presentation/cubit/room_cubit.dart';
import 'package:bloot/generated/locale_keys.g.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockRoomRepository extends Mock implements RoomRepository {}

class MockGameRepository extends Mock implements GameRepository {}

class MockDiscoverRepository extends Mock implements DiscoverRepository {}

class MockAudioService extends Mock implements AudioService {}

class FakeCreateRoomParams extends Fake implements CreateRoomParams {}

/// A mock [AgoraService] that provides safe defaults for widget tests.
///
/// Override getters/methods as needed for specific test scenarios.
class MockAgoraService extends Mock implements AgoraService {
  @override
  bool get isMicOn => false;

  @override
  bool get isCameraOn => false;

  @override
  Future<void> enterBackgroundMode() async {}

  @override
  Future<void> leaveBackgroundMode() async {}

  @override
  Future<void> subscribeToRemoteVideo() async {}

  @override
  Future<void> unsubscribeFromRemoteVideo() async {}

  @override
  Widget getLocalVideoView({VideoSourceType? sourceType}) =>
      const SizedBox.shrink();

  @override
  Widget getRemoteVideoView(int remoteUid) => const SizedBox.shrink();
}

/// Stubs the Agora service methods that are commonly exercised by Bloot pages.
///
/// Call this in `setUp` for widget tests that use [MockAgoraService].
void stubAgoraServiceDefaults(MockAgoraService service) {
  when(
    () => service.joinChannel(
      channelName: any(named: 'channelName'),
      agoraUid: any(named: 'agoraUid'),
      subscribeVideo: any(named: 'subscribeVideo'),
    ),
  ).thenAnswer((_) async {});
  when(
    () => service.joinAsAudience(
      channelName: any(named: 'channelName'),
      agoraUid: any(named: 'agoraUid'),
    ),
  ).thenAnswer((_) async {});
  when(() => service.leaveChannel()).thenAnswer((_) async {});
  when(() => service.toggleMic()).thenAnswer((_) async => false);
  when(() => service.toggleCamera()).thenAnswer((_) async => false);
  when(
    () => service.setMediaState(
      micOn: any(named: 'micOn'),
      cameraOn: any(named: 'cameraOn'),
    ),
  ).thenAnswer((_) async {});
  when(
    () => service.onAudioVolumeIndication,
  ).thenAnswer((_) => const Stream.empty());
  when(() => service.onUserJoined).thenAnswer((_) => const Stream.empty());
  when(() => service.onUserOffline).thenAnswer((_) => const Stream.empty());
}

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeHttpClient extends Fake implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _FakeHttpClientRequest();
}

class _FakeHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  HttpHeaders get headers => _FakeHttpHeaders();

  @override
  Future<HttpClientResponse> close() async => _FakeHttpClientResponse();
}

class _FakeHttpHeaders extends Fake implements HttpHeaders {}

class _FakeHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => 0;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return const Stream<List<int>>.empty().listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

/// Minimal asset loader that returns the translation keys used by the tests.
class TestAssetLoader extends AssetLoader {
  const TestAssetLoader();

  static Map<String, dynamic> get _translations => {
    'create_room': 'Create Room',
    'room_name': 'Room Name',
    'room_type': 'Room Type',
    'private': 'Private',
    'public': 'Public',
    'live_stream': 'Live Stream',
    'invite_only': 'Invite Only',
    'anyone_can_join': 'Anyone can join',
    'broadcast_to_viewers': 'Broadcast to viewers',
    'voice_chat': 'Voice Chat',
    'camera': 'Camera',
    'allow_spectators': 'Allow Spectators',
    'room_password': 'Room Password',
    'enter_password': 'Enter password',
    'password_min_length': 'Password must be at least 4 characters',
    'validationFieldRequired': 'This field is required',
    'private_room_password_required': 'Password required for private room',
    'cancel': 'Cancel',
    'on': 'On',
    'off': 'Off',
    'us': 'Us',
    'them': 'Them',
    'skip': 'Skip',
    'tutorial_tap_to_play': 'Tap to Play',
    'tutorial_tap_to_play_desc': 'Tap the table to play your card.',
    'tutorial_voice_chat': 'Voice Chat',
    'tutorial_voice_chat_desc': 'Talk to other players.',
    'tutorial_chat': 'Chat',
    'tutorial_chat_desc': 'Send messages.',
    'tutorial_win': 'Win',
    'tutorial_win_desc': 'Win the game.',
    'you': 'You',
    'victory': 'Victory!',
    'defeat': 'Defeat',
    'congratulations_on_win': 'Congratulations on your win!',
    'better_luck_next_time': 'Better luck next time!',
    'rematch': 'Rematch',
    'room_lobby': 'Room Lobby',
    'room_code': 'Room Code',
    'room_code_copied': 'Room code copied',
    'players': 'players',
    'ready': 'Ready',
    'your_partner': 'Your Partner',
    'opponent_1': 'Opponent 1',
    'opponent_2': 'Opponent 2',
    'vs': 'VS',
    'empty': 'Empty',
    'invite': 'Invite',
    'room_settings': 'Room Settings',
    'spectators': 'Spectators',
    'allowed': 'Allowed',
    'not_allowed': 'Not Allowed',
    'i_am_ready': 'I am ready',
    'not_ready': 'Not ready',
    'start_game': 'Start Game',
    'invite_bots': 'Invite Bots',
    'join_room': 'Join Room',
    'pasteFromClipboard': 'Paste from Clipboard',
    'password_required_for_locked_room': 'Password required',
    'live': 'LIVE',
    'say_something': 'Say something',
    'chat_unavailable': 'Chat unavailable',
    'like': 'Like',
    'share': 'Share',
    'follow': 'Follow',
    'send': 'Send',
    'hokm_spades': 'Hokm Spades',
    'streaming_live': 'Streaming Live',
    'go_live': 'Go Live',
    'end_stream': 'End Stream',
    'public_rooms': 'Public Rooms',
    'no_public_rooms': 'No public rooms',
    'room_not_live': 'This table is not live right now.',
    'kicked_from_room': 'You were removed from the room by the host.',
    'join_table': 'Join Table',
    'spectate': 'Spectate',
    'liveBadge': 'LIVE',
    'no_live_streams': 'No live streams',
    'discover_streams': 'Discover Streams',
    'waiting_for_players': 'Waiting for players',
    LocaleKeys.labelOn: 'On',
    LocaleKeys.playersCount: '{current}/{max}',
    LocaleKeys.shareRoomMessage: 'Join my room {code}',
    LocaleKeys.appName: 'Bloot',
    LocaleKeys.commonNoInternet: 'No internet connection',
  };

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      _translations;
}

// ---------------------------------------------------------------------------
// Test wrappers
// ---------------------------------------------------------------------------

/// Runs a test body inside a zone that returns a fake HTTP client.
///
/// This prevents network image requests from failing during widget tests.
Future<void> runWithFakeHttp(Future<void> Function() testBody) async {
  await HttpOverrides.runZoned(
    testBody,
    createHttpClient: (_) => _FakeHttpClient(),
  );
}

/// Builds a [MaterialApp.router] wrapped with the minimal dependencies needed
/// by Bloot pages, using a custom [GoRouter].
///
/// Useful for pages that call [BuildContext.pushNamed] in their listeners.
Widget buildTestableWidgetWithRouter({
  required GoRouter router,
  RoomCubit? roomCubit,
  GameCubit? gameCubit,
  DiscoverCubit? discoverCubit,
  AgoraService? agoraService,
  AudioService? audioService,
  ConnectivityCubit? connectivityCubit,
}) {
  return EasyLocalization(
    supportedLocales: const [Locale('en'), Locale('ar')],
    path: 'assets/translations',
    fallbackLocale: const Locale('en'),
    startLocale: const Locale('en'),
    useOnlyLangCode: true,
    assetLoader: const TestAssetLoader(),
    child: Builder(
      builder: (context) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: ThemeManager.darkTheme,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          routerConfig: router,
          builder: (context, child) {
            return MultiBlocProvider(
              providers: [
                if (roomCubit != null)
                  BlocProvider<RoomCubit>.value(value: roomCubit),
                if (gameCubit != null)
                  BlocProvider<GameCubit>.value(value: gameCubit),
                if (discoverCubit != null)
                  BlocProvider<DiscoverCubit>.value(value: discoverCubit),
                if (connectivityCubit != null)
                  BlocProvider<ConnectivityCubit>.value(
                    value: connectivityCubit,
                  )
                else
                  BlocProvider<ConnectivityCubit>(
                    create: (_) => ConnectivityCubit(),
                  ),
              ],
              child: MultiRepositoryProvider(
                providers: [
                  if (agoraService != null)
                    RepositoryProvider<AgoraService>(
                      create: (_) => agoraService,
                    ),
                  if (audioService != null)
                    RepositoryProvider<AudioService>(
                      create: (_) => audioService,
                    ),
                ],
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
        );
      },
    ),
  );
}

/// Builds a widget wrapped with the minimal dependencies needed by Bloot pages.
///
/// - [child] is the page under test.
/// - [roomCubit], [gameCubit], and [discoverCubit] are optional cubits to inject.
/// - [agoraService] and [audioService] are injected as repositories.
Widget buildTestableWidget(
  Widget child, {
  RoomCubit? roomCubit,
  GameCubit? gameCubit,
  DiscoverCubit? discoverCubit,
  AgoraService? agoraService,
  AudioService? audioService,
  ConnectivityCubit? connectivityCubit,
}) {
  return EasyLocalization(
    supportedLocales: const [Locale('en'), Locale('ar')],
    path: 'assets/translations',
    fallbackLocale: const Locale('en'),
    startLocale: const Locale('en'),
    useOnlyLangCode: true,
    assetLoader: const TestAssetLoader(),
    child: Builder(
      builder: (context) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeManager.darkTheme,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          home: MultiBlocProvider(
            providers: [
              if (roomCubit != null)
                BlocProvider<RoomCubit>.value(value: roomCubit),
              if (gameCubit != null)
                BlocProvider<GameCubit>.value(value: gameCubit),
              if (discoverCubit != null)
                BlocProvider<DiscoverCubit>.value(value: discoverCubit),
              if (connectivityCubit != null)
                BlocProvider<ConnectivityCubit>.value(value: connectivityCubit)
              else
                BlocProvider<ConnectivityCubit>(
                  create: (_) => ConnectivityCubit(),
                ),
            ],
            child: MultiRepositoryProvider(
              providers: [
                if (agoraService != null)
                  RepositoryProvider<AgoraService>(create: (_) => agoraService),
                if (audioService != null)
                  RepositoryProvider<AudioService>(create: (_) => audioService),
              ],
              child: child,
            ),
          ),
        );
      },
    ),
  );
}

// ---------------------------------------------------------------------------
// GetIt helpers
// ---------------------------------------------------------------------------

/// Resets GetIt and registers the provided mocks so the real app can use them.
///
/// Useful for integration tests or widget tests that instantiate pages via
/// the router / DI rather than direct injection.
Future<void> registerTestDependencies({
  RoomRepository? roomRepository,
  GameRepository? gameRepository,
  DiscoverRepository? discoverRepository,
  AgoraService? agoraService,
  AudioService? audioService,
}) async {
  final getIt = GetIt.instance;
  await getIt.reset();

  if (roomRepository != null) {
    if (getIt.isRegistered<RoomRepository>()) {
      getIt.unregister<RoomRepository>();
    }
    getIt.registerSingleton<RoomRepository>(roomRepository);
  }
  if (gameRepository != null) {
    if (getIt.isRegistered<GameRepository>()) {
      getIt.unregister<GameRepository>();
    }
    getIt.registerSingleton<GameRepository>(gameRepository);
  }
  if (discoverRepository != null) {
    if (getIt.isRegistered<DiscoverRepository>()) {
      getIt.unregister<DiscoverRepository>();
    }
    getIt.registerSingleton<DiscoverRepository>(discoverRepository);
  }
  if (agoraService != null) {
    if (getIt.isRegistered<AgoraService>()) {
      getIt.unregister<AgoraService>();
    }
    getIt.registerSingleton<AgoraService>(agoraService);
  }
  if (audioService != null) {
    if (getIt.isRegistered<AudioService>()) {
      getIt.unregister<AudioService>();
    }
    getIt.registerSingleton<AudioService>(audioService);
  }
}

// ---------------------------------------------------------------------------
// Shared setup
// ---------------------------------------------------------------------------

/// Initializes the test binding and shared preferences for widget tests.
void setupWidgetTests() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({'game_tutorial_seen': true});
  EasyLocalization.logger.enableBuildModes = [];
  registerFallbackValue(FakeCreateRoomParams());
}

// ---------------------------------------------------------------------------
// Test data factories
// ---------------------------------------------------------------------------

Room testRoom({
  String id = 'r1',
  String name = 'Test Room',
  RoomType type = RoomType.private,
  String inviteCode = 'ABC123',
  String? agoraChannelName = 'room_r1',
  List<RoomPlayer>? players,
  RoomStatus status = RoomStatus.waiting,
  String? gameId,
  bool voiceEnabled = true,
  bool cameraEnabled = false,
  bool allowSpectators = true,
  String? password,
  String creatorUid = 'u1',
  bool isStreaming = false,
  String? streamId,
}) {
  return Room(
    id: id,
    name: name,
    type: type,
    inviteCode: inviteCode,
    agoraChannelName: agoraChannelName,
    players: players ?? [const RoomPlayer(uid: 'u1', name: 'Me', isMe: true)],
    status: status,
    gameId: gameId,
    voiceEnabled: voiceEnabled,
    cameraEnabled: cameraEnabled,
    allowSpectators: allowSpectators,
    password: password,
    creatorUid: creatorUid,
    isStreaming: isStreaming,
    streamId: streamId,
  );
}

RoomPlayer testPlayer({
  String uid = 'u1',
  String name = 'Player',
  bool isMe = false,
  bool isReady = false,
  String team = 'A',
  bool isMicOn = true,
  bool isCameraOn = false,
  int? agoraUid,
  bool isSpeaking = false,
}) {
  return RoomPlayer(
    uid: uid,
    name: name,
    isMe: isMe,
    isReady: isReady,
    team: team,
    isMicOn: isMicOn,
    isCameraOn: isCameraOn,
    agoraUid: agoraUid,
    isSpeaking: isSpeaking,
  );
}

Game testGame({
  String id = 'g1',
  String status = 'playing',
  int turnIndex = 0,
  int mySeatIndex = 0,
  List<String> myHand = const ['AH', 'KH', 'QH', 'JH'],
  List<GamePlayer>? players,
  String? roomId = 'r1',
  String? agoraChannelName = 'room_r1',
  // Default to a voice-enabled game: the factory also defaults an Agora
  // channel, and existing Agora tests assume media is available.
  bool voiceEnabled = true,
  bool cameraEnabled = false,
  Map<String, dynamic>? engineState,
}) {
  return Game(
    id: id,
    status: status,
    turnIndex: turnIndex,
    mySeatIndex: mySeatIndex,
    myHand: myHand,
    engineState:
        engineState ??
        (jsonDecode(kTestEngineStateJson) as Map<String, dynamic>),
    players:
        players ??
        const [
          GamePlayer(
            uid: 'p0',
            name: 'Me',
            avatarUrl: '',
            team: 'A',
            seatIndex: 0,
          ),
          GamePlayer(
            uid: 'p1',
            name: 'Faisal',
            avatarUrl: '',
            team: 'B',
            seatIndex: 1,
          ),
          GamePlayer(
            uid: 'p2',
            name: 'Omar',
            avatarUrl: '',
            team: 'A',
            seatIndex: 2,
          ),
          GamePlayer(
            uid: 'p3',
            name: 'Khalid',
            avatarUrl: '',
            team: 'B',
            seatIndex: 3,
          ),
        ],
    playedCards: const [null, null, null, null],
    scoreUs: 0,
    scoreThem: 0,
    teamAScore: 0,
    teamBScore: 0,
    trump: 'hearts',
    currentRound: 1,
    targetScore: 152,
    roomId: roomId,
    agoraChannelName: agoraChannelName,
    voiceEnabled: voiceEnabled,
    cameraEnabled: cameraEnabled,
  );
}

DiscoverStream testStream({
  String id = 's1',
  String title = 'Live Baloot',
  String host = 'Ali',
  int viewers = 42,
  String? agoraChannelName = 'stream_s1',
  List<StreamPlayer>? players,
}) {
  return DiscoverStream(
    id: id,
    title: title,
    host: host,
    viewers: viewers,
    avatarUrl: '',
    agoraChannelName: agoraChannelName,
    players:
        players ??
        const [
          StreamPlayer(uid: 'p1', name: 'Ali', agoraUid: 101),
          StreamPlayer(uid: 'p2', name: 'Faisal', agoraUid: 102, team: 'B'),
          StreamPlayer(uid: 'p3', name: 'Omar', agoraUid: 103, team: 'B'),
          StreamPlayer(uid: 'p4', name: 'Khalid', agoraUid: 104),
        ],
  );
}
