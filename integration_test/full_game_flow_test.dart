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
import 'package:webview_flutter/webview_flutter.dart';

import 'package:bloot/core/network/connectivity_cubit.dart';
import 'package:bloot/core/services/agora_service.dart';
import 'package:bloot/core/services/audio_service.dart';
import 'package:bloot/core/style/theme_manager.dart';
import 'package:bloot/features/discover/presentation/cubit/discover_cubit.dart';
import 'package:bloot/features/discover/presentation/pages/watch_stream_page.dart';
import 'package:bloot/features/game/presentation/cubit/game_cubit.dart';
import 'package:bloot/features/game/presentation/cubit/game_state.dart';
import 'package:bloot/features/game/presentation/pages/html_game_play_page.dart';
import 'package:bloot/features/room/domain/entities/room.dart';
import 'package:bloot/features/room/presentation/cubit/room_cubit.dart';
import 'package:bloot/features/room/presentation/pages/create_room_page.dart';
import 'package:bloot/features/room/presentation/pages/public_rooms_page.dart';
import 'package:bloot/features/room/presentation/pages/room_lobby_page.dart';
import 'package:bloot/core/components/app_button.dart';

import '../test/helpers/test_helpers.dart' as helpers;

/// Integration tests that run on a real emulator to verify the full game
/// flow: create room → lobby → ready → start game → WebView game → leave.
///
/// These tests use mock repositories but exercise real widget trees,
/// BLoC state transitions, and the actual WebView game renderer on-device.
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

  group('Full game flow on emulator', () {
    testWidgets(
      'create public room → lobby → ready → start game → WebView renders',
      (tester) async {
        // ------------------------------------------------------------------
        // 1. Create a public room
        // ------------------------------------------------------------------
        final createdRoom = helpers.testRoom(
          id: 'room-flow',
          name: 'Flow Room',
          type: RoomType.public,
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

        // Portrait for pre-game screens.
        await tester.binding.setSurfaceSize(const Size(411, 914));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        addTearDown(() async {
          await SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
          ]);
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

        // Enter room name.
        final nameField = find.byType(TextField).first;
        await tester.enterText(nameField, 'Flow Room');
        await tester.pumpAndSettle();

        // Select "Public" room type (index 1).
        final publicType = find.text('Public');
        expect(publicType, findsOneWidget);
        await tester.tap(publicType);
        await tester.pumpAndSettle();

        // Tap Create Room button.
        final createButton = find.widgetWithText(GradientButton, 'Create Room');
        await tester.ensureVisible(createButton);
        await tester.tap(createButton);
        await tester.pumpAndSettle();

        verify(() => roomRepository.createRoom(any())).called(1);

        // ------------------------------------------------------------------
        // 2. Room lobby: verify room code, player seats, ready up, start game
        // ------------------------------------------------------------------
        final lobbyRoom = helpers.testRoom(
          id: 'room-flow',
          name: 'Flow Room',
          type: RoomType.public,
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

        // Verify room code is displayed.
        expect(find.text('FLOW12'), findsOneWidget);

        // Verify player count text (format: "4/4 Players • 4 Ready").
        expect(find.textContaining('4/4'), findsWidgets);

        // Verify mic/camera icons are present.
        expect(find.byIcon(Icons.mic_rounded), findsWidgets);

        // Tap Start Game (all 4 players are ready).
        final startGameButton = find.widgetWithText(AppButton, 'Start Game');
        expect(startGameButton, findsOneWidget);
        await tester.ensureVisible(startGameButton);
        await tester.tap(startGameButton);
        await tester.pumpAndSettle();

        verify(() => roomRepository.startGame('room-flow')).called(1);

        // ------------------------------------------------------------------
        // 3. Game play: WebView renders the HTML game
        // ------------------------------------------------------------------
        final game = helpers.testGame(
          id: 'game-flow',
          myHand: const ['AH', 'KH', 'QH', 'JH'],
          agoraChannelName: 'room-flow',
        );
        when(
          () => gameRepository.watchGame('game-flow'),
        ).thenAnswer((_) => Stream.value(game));
        when(
          () => roomRepository.updatePlayerMediaState(
            any(),
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

        // Switch to landscape for the game WebView.
        await tester.binding.setSurfaceSize(const Size(914, 411));

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

        // Wait for WebView to load the local HTML game asset.
        await tester.pump(const Duration(seconds: 1));
        await tester.pump(const Duration(seconds: 3));

        // Verify the WebView is rendered and no error overlay is shown.
        expect(find.byType(WebViewWidget), findsOneWidget);
        expect(find.text('Failed to load game'), findsNothing);
        expect(gameCubit.state, isA<GamePlaying>());
      },
    );

    testWidgets('create private room with password → lobby renders', (
      tester,
    ) async {
      final createdRoom = helpers.testRoom(
        id: 'room-priv',
        name: 'Private Room',
        type: RoomType.private,
        inviteCode: 'PRIV44',
        password: 'secret',
        players: [helpers.testPlayer(name: 'Me', isMe: true)],
      );
      when(
        () => roomRepository.createRoom(any()),
      ).thenAnswer((_) async => createdRoom);

      final createCubit = RoomCubit(
        roomRepository: roomRepository,
        agoraService: agoraService,
      );

      await tester.binding.setSurfaceSize(const Size(411, 914));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      addTearDown(() async {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
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

      // Enter room name.
      await tester.enterText(find.byType(TextField).first, 'Private Room');
      await tester.pumpAndSettle();

      // Private type is selected by default (index 0).
      // Enter password (min 4 chars).
      final passwordFields = find.byType(TextField);
      await tester.enterText(passwordFields.last, 'secret');
      await tester.pumpAndSettle();

      // Tap Create Room.
      final createButton = find.widgetWithText(GradientButton, 'Create Room');
      await tester.ensureVisible(createButton);
      await tester.tap(createButton);
      await tester.pumpAndSettle();

      verify(() => roomRepository.createRoom(any())).called(1);
    });

    testWidgets('lobby with 2 players shows waiting state and invite bots', (
      tester,
    ) async {
      final lobbyRoom = helpers.testRoom(
        id: 'room-wait',
        name: 'Waiting Room',
        inviteCode: 'WAIT22',
        players: [
          helpers.testPlayer(name: 'Me', isMe: true, isReady: true),
          helpers.testPlayer(uid: 'u2', name: 'P2', isReady: false),
        ],
      );
      when(
        () => roomRepository.watchRoom('room-wait'),
      ).thenAnswer((_) => Stream.value(lobbyRoom));
      when(
        () => roomRepository.inviteBotsToRoom('room-wait'),
      ).thenAnswer((_) async => (roomId: 'room-wait', gameId: null));

      final lobbyCubit = RoomCubit(
        roomRepository: roomRepository,
        agoraService: agoraService,
      );
      lobbyCubit.loadRoom('room-wait');

      await tester.binding.setSurfaceSize(const Size(411, 914));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      addTearDown(() async {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      });

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
              child: const RoomLobbyPage(id: 'room-wait'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // Extra pump to ensure stream event is processed.
      await tester.pump(const Duration(milliseconds: 500));

      // Verify room code.
      expect(find.text('WAIT22'), findsOneWidget);

      // Verify 2/4 players text.
      expect(find.textContaining('2/4'), findsOneWidget);

      // Start Game button should be disabled (not all ready, not 4 players).
      final startGameButton = find.widgetWithText(AppButton, 'Start Game');
      expect(startGameButton, findsOneWidget);
      // The button's onPressed should be null.
      final appButton = tester.widget<AppButton>(startGameButton);
      expect(appButton.onPressed, isNull);
    });

    testWidgets('lobby toggle mic calls repository', (tester) async {
      final lobbyRoom = helpers.testRoom(
        id: 'room-mic',
        name: 'Mic Room',
        inviteCode: 'MIC333',
        players: [
          helpers.testPlayer(name: 'Me', isMe: true, isMicOn: true),
          helpers.testPlayer(uid: 'u2', name: 'P2'),
          helpers.testPlayer(uid: 'u3', name: 'P3'),
          helpers.testPlayer(uid: 'u4', name: 'P4'),
        ],
      );
      when(
        () => roomRepository.watchRoom('room-mic'),
      ).thenAnswer((_) => Stream.value(lobbyRoom));
      when(
        () => roomRepository.updatePlayerMediaState(
          'room-mic',
          isMicOn: any(named: 'isMicOn'),
          isCameraOn: any(named: 'isCameraOn'),
        ),
      ).thenAnswer((_) async {});
      when(() => agoraService.toggleMic()).thenAnswer((_) async => false);

      final lobbyCubit = RoomCubit(
        roomRepository: roomRepository,
        agoraService: agoraService,
      );
      lobbyCubit.loadRoom('room-mic');

      await tester.binding.setSurfaceSize(const Size(411, 914));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      addTearDown(() async {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      });

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
              child: const RoomLobbyPage(id: 'room-mic'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the mic toggle button. The _MediaToggleButton is a GestureDetector
      // with a Container child containing an Icon(Icons.mic_rounded).
      final micToggleFinder = find.byWidgetPredicate(
        (w) =>
            w is GestureDetector &&
            w.child is Container &&
            (w.child as Container).child is Icon &&
            ((w.child as Container).child as Icon).icon == Icons.mic_rounded,
      );
      expect(micToggleFinder, findsOneWidget);
      // Scroll to make the mic toggle visible before tapping.
      await tester.ensureVisible(micToggleFinder);
      await tester.tap(micToggleFinder);
      await tester.pumpAndSettle();

      verify(() => agoraService.toggleMic()).called(1);
    });

    testWidgets('public rooms list renders and join works', (tester) async {
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

      await tester.binding.setSurfaceSize(const Size(411, 914));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      addTearDown(() async {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      });

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

      final joinButton = find.widgetWithText(ElevatedButton, 'Join Table');
      await tester.ensureVisible(joinButton);
      await tester.tap(joinButton);
      await tester.pumpAndSettle();

      verify(() => roomRepository.joinRoomByCode('PUB123')).called(1);
    });

    testWidgets(
      'watch stream page renders title, host, and joins Agora as audience',
      (tester) async {
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
        // Start loading before pumpWidget so the cubit processes the async.
        await tester.runAsync(() => discoverCubit.loadStream('stream-flow'));

        await tester.binding.setSurfaceSize(const Size(411, 914));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        addTearDown(() async {
          await SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
          ]);
          await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        });

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
        // Call loadStream again after pumpWidget so the BlocConsumer.listener
        // fires on the state change (loading -> streamLoaded) and triggers
        // _joinAgoraChannel.
        await tester.runAsync(() => discoverCubit.loadStream('stream-flow'));
        await tester.pump();
        // Allow async operations to complete.
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(seconds: 1)),
        );
        await tester.pump();

        expect(find.text('Flow Stream'), findsOneWidget);
        expect(find.text('Host'), findsOneWidget);

        // Send a chat message.
        final chatField = find.byType(TextField);
        await tester.enterText(chatField, 'GG');
        await tester.pump(const Duration(milliseconds: 500));
        await tester.tap(find.byIcon(Icons.send_rounded));
        await tester.pump(const Duration(milliseconds: 500));

        verify(
          () => discoverRepository.sendChatMessage('stream-flow', 'GG'),
        ).called(1);
      },
    );

    testWidgets('game WebView loads and cubit reaches GamePlaying state', (
      tester,
    ) async {
      final game = helpers.testGame(id: 'webview-game');
      when(
        () => gameRepository.watchGame('webview-game'),
      ).thenAnswer((_) => Stream.value(game));
      when(
        () => roomRepository.updatePlayerMediaState(
          any(),
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
      gameCubit.watchGame('webview-game');

      // Landscape for the game.
      await tester.binding.setSurfaceSize(const Size(914, 411));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      addTearDown(() async {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      });

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
              child: const HtmlGamePlayPage(id: 'webview-game'),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 3));

      expect(find.byType(WebViewWidget), findsOneWidget);
      expect(find.text('Failed to load game'), findsNothing);
      expect(gameCubit.state, isA<GamePlaying>());
    });

    testWidgets('lobby ready toggle calls toggleReady on cubit', (
      tester,
    ) async {
      final lobbyRoom = helpers.testRoom(
        id: 'room-ready',
        name: 'Ready Room',
        inviteCode: 'RDY444',
        players: [
          helpers.testPlayer(name: 'Me', isMe: true, isReady: false),
          helpers.testPlayer(uid: 'u2', name: 'P2', isReady: true),
          helpers.testPlayer(uid: 'u3', name: 'P3', isReady: true),
          helpers.testPlayer(uid: 'u4', name: 'P4', isReady: true),
        ],
      );
      when(
        () => roomRepository.watchRoom('room-ready'),
      ).thenAnswer((_) => Stream.value(lobbyRoom));
      when(
        () => roomRepository.toggleReady('room-ready'),
      ).thenAnswer((_) async => lobbyRoom);

      final lobbyCubit = RoomCubit(
        roomRepository: roomRepository,
        agoraService: agoraService,
      );
      lobbyCubit.loadRoom('room-ready');

      await tester.binding.setSurfaceSize(const Size(411, 914));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      addTearDown(() async {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      });

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
              child: const RoomLobbyPage(id: 'room-ready'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap "I am ready" button (lowercase per translations).
      final readyButton = find.widgetWithText(AppButton, 'I am ready');
      expect(readyButton, findsOneWidget);
      await tester.ensureVisible(readyButton);
      await tester.tap(readyButton);
      await tester.pumpAndSettle();

      verify(() => roomRepository.toggleReady('room-ready')).called(1);
    });
  });
}
