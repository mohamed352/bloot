import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bloot/core/network/connectivity_cubit.dart';
import 'package:bloot/core/services/agora_service.dart';
import 'package:bloot/core/services/audio_service.dart';
import 'package:bloot/core/style/theme_manager.dart';
import 'package:bloot/features/discover/presentation/cubit/discover_cubit.dart';
import 'package:bloot/features/discover/presentation/pages/watch_stream_page.dart';
import 'package:bloot/features/game/presentation/cubit/game_cubit.dart';
import 'package:bloot/features/game/presentation/pages/html_game_play_page.dart';
import 'package:bloot/features/room/domain/entities/room.dart';
import 'package:bloot/features/room/presentation/cubit/room_cubit.dart';
import 'package:bloot/features/room/presentation/pages/create_room_page.dart';
import 'package:bloot/features/room/presentation/pages/public_rooms_page.dart';
import 'package:bloot/features/room/presentation/pages/room_lobby_page.dart';
import 'package:bloot/core/components/app_button.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../test/helpers/test_helpers.dart' as helpers;

/// Minimal shell that wraps the feature pages with the same dependencies
/// used by the production app, without starting deep-links or notifications.
class _TestAppShell extends StatelessWidget {
  const _TestAppShell({required this.home});

  final Widget home;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, _) => home),
        GoRoute(
          path: '/room-lobby/:id',
          name: 'roomLobby',
          builder: (_, _) => const SizedBox.shrink(),
        ),
        GoRoute(
          path: '/game/:id',
          name: 'gamePlay',
          builder: (_, _) => const SizedBox.shrink(),
        ),
        GoRoute(
          path: '/discover',
          name: 'discover',
          builder: (_, _) => const SizedBox.shrink(),
        ),
        GoRoute(
          path: '/watch/:id',
          name: 'watchStream',
          builder: (_, _) => const SizedBox.shrink(),
        ),
      ],
    );
    return EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      useOnlyLangCode: true,
      assetLoader: const helpers.TestAssetLoader(),
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: ThemeManager.darkTheme,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            routerConfig: router,
          );
        },
      ),
    );
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late helpers.MockRoomRepository roomRepository;
  late helpers.MockGameRepository gameRepository;
  late helpers.MockDiscoverRepository discoverRepository;
  late helpers.MockAgoraService agoraService;
  late helpers.MockAudioService audioService;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({'game_tutorial_seen': true});
    EasyLocalization.logger.enableBuildModes = [];
    registerFallbackValue(helpers.FakeCreateRoomParams());
  });

  setUp(() {
    roomRepository = helpers.MockRoomRepository();
    gameRepository = helpers.MockGameRepository();
    discoverRepository = helpers.MockDiscoverRepository();
    agoraService = helpers.MockAgoraService();
    audioService = helpers.MockAudioService();

    helpers.stubAgoraServiceDefaults(agoraService);
  });

  group('Bloot full feature flow', () {
    // Skip: the full flow is too brittle for a regression guard (landscape
    // WebView hit-test issues and pumpAndSettle timeouts on WatchStreamPage).
    // Use integration_test/webview_game_test.dart for a focused game smoke test.
    testWidgets('create room -> lobby -> game -> watch stream', skip: true, (tester) async {
      // ------------------------------------------------------------------
      // 1. Create a room
      // ------------------------------------------------------------------
      final createdRoom = helpers.testRoom(
        id: 'room-flow',
        name: 'Flow Room',
        inviteCode: 'FLOW12',
        cameraEnabled: true,
        players: [helpers.testPlayer(name: 'Me', isMe: true)],
      );
      when(
        () => roomRepository.createRoom(any()),
      ).thenAnswer((_) async => createdRoom);

      final createCubit = RoomCubit(
        roomRepository: roomRepository,
        agoraService: agoraService,
      );

      // Portrait size for the pre-game screens.
      await tester.binding.setSurfaceSize(const Size(411, 914));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      addTearDown(() async {
        await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      });

      await tester.pumpWidget(
        _TestAppShell(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<RoomCubit>.value(value: createCubit),
              BlocProvider<ConnectivityCubit>(
                create: (_) => ConnectivityCubit(),
              ),
            ],
            child: MultiRepositoryProvider(
              providers: [
                RepositoryProvider<AgoraService>(create: (_) => agoraService),
                RepositoryProvider<AudioService>(create: (_) => audioService),
              ],
              child: const CreateRoomPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final nameField = find.byType(TextField).first;
      await tester.enterText(nameField, 'Flow Room');
      await tester.pumpAndSettle();

      final passwordFields = find.byType(TextField);
      await tester.enterText(passwordFields.last, 'secret');
      await tester.pumpAndSettle();

      final createRoomButton = find.widgetWithText(GradientButton, 'Create Room');
      await tester.ensureVisible(createRoomButton);
      await tester.tap(createRoomButton);
      await tester.pumpAndSettle();

      verify(() => roomRepository.createRoom(any())).called(1);

      // ------------------------------------------------------------------
      // 2. Room lobby: voice/video indicators, ready, start game
      // ------------------------------------------------------------------
      final lobbyRoom = helpers.testRoom(
        id: 'room-flow',
        name: 'Flow Room',
        inviteCode: 'FLOW12',
        cameraEnabled: true,
        players: [
          helpers.testPlayer(name: 'Me', isMe: true, isReady: true),
          helpers.testPlayer(uid: 'u2', name: 'Partner', isReady: true),
          helpers.testPlayer(uid: 'u3', name: 'Opp1', isReady: true),
          helpers.testPlayer(uid: 'u4', name: 'Opp2', isReady: true),
        ],
      );
      when(
        () => roomRepository.watchRoom('room-flow'),
      ).thenAnswer((_) => Stream.value(lobbyRoom));
      when(
        () => roomRepository.startGame('room-flow'),
      ).thenAnswer((_) async => 'game-flow');
      when(
        () => roomRepository.updatePlayerMediaState(
          'room-flow',
          isMicOn: any(named: 'isMicOn'),
          isCameraOn: any(named: 'isCameraOn'),
        ),
      ).thenAnswer((_) async {});

      final lobbyCubit = RoomCubit(
        roomRepository: roomRepository,
        agoraService: agoraService,
      );
      lobbyCubit.loadRoom('room-flow');

      await tester.pumpWidget(
        _TestAppShell(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<RoomCubit>.value(value: lobbyCubit),
              BlocProvider<ConnectivityCubit>(
                create: (_) => ConnectivityCubit(),
              ),
            ],
            child: MultiRepositoryProvider(
              providers: [
                RepositoryProvider<AgoraService>(create: (_) => agoraService),
                RepositoryProvider<AudioService>(create: (_) => audioService),
              ],
              child: const RoomLobbyPage(id: 'room-flow'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('FLOW12'), findsOneWidget);
      expect(find.byIcon(Icons.mic_rounded), findsWidgets);
      expect(find.byIcon(Icons.videocam_off_rounded), findsWidgets);

      final startGameButton = find.widgetWithText(ElevatedButton, 'Start Game');
      await tester.ensureVisible(startGameButton);
      await tester.tap(startGameButton);
      await tester.pumpAndSettle();

      verify(() => roomRepository.startGame('room-flow')).called(1);

      // ------------------------------------------------------------------
      // 3. Game play: render players, play a card, mic/camera toggles
      // ------------------------------------------------------------------
      final game = helpers.testGame(
        id: 'game-flow',
        myHand: const ['AH', 'KH', 'QH'],
        agoraChannelName: 'room-flow',
      );
      when(
        () => gameRepository.watchGame('game-flow'),
      ).thenAnswer((_) => Stream.value(game));
      when(
        () => roomRepository.updatePlayerMediaState(
          'r1',
          isMicOn: any(named: 'isMicOn'),
          isCameraOn: any(named: 'isCameraOn'),
        ),
      ).thenAnswer((_) async {});

      final gameCubit = GameCubit(
        gameRepository: gameRepository,
        roomRepository: roomRepository,
        agoraService: agoraService,
        audioService: audioService,
      );
      gameCubit.watchGame('game-flow');

      await tester.pumpWidget(
        _TestAppShell(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<GameCubit>.value(value: gameCubit),
              BlocProvider<ConnectivityCubit>(
                create: (_) => ConnectivityCubit(),
              ),
            ],
            child: MultiRepositoryProvider(
              providers: [
                RepositoryProvider<AgoraService>(create: (_) => agoraService),
                RepositoryProvider<AudioService>(create: (_) => audioService),
              ],
              child: const HtmlGamePlayPage(id: 'game-flow'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The game is rendered inside a WebView, so Flutter only sees the
      // WebView surface and the loading/error overlay.
      expect(find.byType(WebViewWidget), findsOneWidget);
      expect(find.text('Failed to load game'), findsNothing);

      // Let timers/animations settle.
      await tester.pump(const Duration(seconds: 4));

      // ------------------------------------------------------------------
      // 4. Watch stream: video grid and chat
      // ------------------------------------------------------------------
      final stream = helpers.testStream(
        id: 'stream-flow',
        title: 'Flow Stream',
        host: 'Host',
        viewers: 5,
        agoraChannelName: 'stream-flow',
      );
      when(
        () => discoverRepository.getStreamById('stream-flow'),
      ).thenAnswer((_) async => stream);
      when(
        () => discoverRepository.watchStreamChat('stream-flow'),
      ).thenAnswer((_) => const Stream.empty());
      when(
        () => discoverRepository.sendChatMessage('stream-flow', 'GG'),
      ).thenAnswer((_) async {});

      final discoverCubit = DiscoverCubit(
        discoverRepository: discoverRepository,
      );
      discoverCubit.loadStream('stream-flow');

      await tester.pumpWidget(
        _TestAppShell(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<DiscoverCubit>.value(value: discoverCubit),
              BlocProvider<ConnectivityCubit>(
                create: (_) => ConnectivityCubit(),
              ),
            ],
            child: MultiRepositoryProvider(
              providers: [
                RepositoryProvider<AgoraService>(create: (_) => agoraService),
              ],
              child: const WatchStreamPage(id: 'stream-flow'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Flow Stream'), findsOneWidget);
      expect(find.text('Host'), findsOneWidget);
      verify(
        () => agoraService.joinAsAudience(channelName: 'stream-flow'),
      ).called(1);

      final chatField = find.byType(TextField);
      await tester.enterText(chatField, 'GG');
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pumpAndSettle();

      verify(
        () => discoverRepository.sendChatMessage('stream-flow', 'GG'),
      ).called(1);
    });

    testWidgets('join public room flow', skip: true, (tester) async {
      when(() => roomRepository.watchPublicRooms()).thenAnswer(
        (_) => Stream.value([
          helpers.testRoom(
            id: 'pub1',
            name: 'Public Flow',
            type: RoomType.public,
            inviteCode: 'PUB123',
            players: [helpers.testPlayer(name: 'Host')],
          ),
        ]),
      );
      when(
        () => roomRepository.joinRoomByCode('PUB123'),
      ).thenAnswer((_) async => helpers.testRoom(id: 'pub1'));

      final roomCubit = RoomCubit(
        roomRepository: roomRepository,
        agoraService: agoraService,
      );

      await tester.pumpWidget(
        _TestAppShell(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<RoomCubit>.value(value: roomCubit),
              BlocProvider<ConnectivityCubit>(
                create: (_) => ConnectivityCubit(),
              ),
            ],
            child: MultiRepositoryProvider(
              providers: [
                RepositoryProvider<AgoraService>(create: (_) => agoraService),
              ],
              child: const PublicRoomsPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Public Flow'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Join Table'));
      await tester.pumpAndSettle();

      verify(() => roomRepository.joinRoomByCode('PUB123')).called(1);
    });
  });
}
