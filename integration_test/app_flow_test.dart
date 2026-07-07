import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bloot/core/network/connectivity_cubit.dart';
import 'package:bloot/core/services/agora_service.dart';
import 'package:bloot/core/services/audio_service.dart';
import 'package:bloot/core/style/theme_manager.dart';
import 'package:bloot/features/discover/domain/entities/discover_stream.dart';
import 'package:bloot/features/discover/presentation/cubit/discover_cubit.dart';
import 'package:bloot/features/discover/presentation/pages/watch_stream_page.dart';
import 'package:bloot/features/game/domain/entities/game.dart';
import 'package:bloot/features/game/domain/repositories/game_repository.dart';
import 'package:bloot/features/game/presentation/cubit/game_cubit.dart';
import 'package:bloot/features/game/presentation/pages/game_play_page.dart';
import 'package:bloot/features/room/domain/entities/room.dart';
import 'package:bloot/features/room/domain/repositories/room_repository.dart';
import 'package:bloot/features/room/presentation/cubit/room_cubit.dart';
import 'package:bloot/features/room/presentation/pages/create_room_page.dart';
import 'package:bloot/features/room/presentation/pages/join_room_page.dart';
import 'package:bloot/features/room/presentation/pages/public_rooms_page.dart';
import 'package:bloot/features/room/presentation/pages/room_lobby_page.dart';
import 'package:bloot/core/components/app_button.dart';

import '../test/helpers/test_helpers.dart' as helpers;

class _MockAgoraService extends helpers.MockAgoraService {
  @override
  Future<void> joinChannel({required String channelName}) async {}

  @override
  Future<void> joinAsAudience({required String channelName}) async {}

  @override
  Future<void> leaveChannel() async {}

  @override
  Future<bool> toggleMic() async => true;

  @override
  Future<bool> toggleCamera() async => true;
}

/// Minimal shell that wraps the feature pages with the same dependencies
/// used by the production app, without starting deep-links or notifications.
class _TestAppShell extends StatelessWidget {
  const _TestAppShell({required this.home});

  final Widget home;

  @override
  Widget build(BuildContext context) {
    return EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      useOnlyLangCode: true,
      assetLoader: const helpers.TestAssetLoader(),
      child: Builder(
        builder: (context) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeManager.darkTheme,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: home,
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
  late _MockAgoraService agoraService;
  late helpers.MockAudioService audioService;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({'game_tutorial_seen': true});
    EasyLocalization.logger.enableBuildModes = [];
    registerFallbackValue(helpers.FakeCreateRoomParams());
  });

  setUp(() {
    roomRepository = MockRoomRepository();
    gameRepository = MockGameRepository();
    discoverRepository = MockDiscoverRepository();
    agoraService = _MockAgoraService();
    audioService = MockAudioService();

    when(() => agoraService.joinChannel(channelName: any(named: 'channelName')))
        .thenAnswer((_) async {});
    when(() => agoraService.joinAsAudience(channelName: any(named: 'channelName')))
        .thenAnswer((_) async {});
    when(() => agoraService.leaveChannel()).thenAnswer((_) async {});
    when(() => agoraService.toggleMic()).thenAnswer((_) async => true);
    when(() => agoraService.toggleCamera()).thenAnswer((_) async => true);
    when(() => agoraService.onAudioVolumeIndication)
        .thenAnswer((_) => const Stream.empty());
    when(() => agoraService.onUserJoined).thenAnswer((_) => const Stream.empty());
    when(() => agoraService.onUserOffline)
        .thenAnswer((_) => const Stream.empty());
  });

  group('Bloot full feature flow', () {
    testWidgets('create room -> lobby -> game -> watch stream', (tester) async {
      // ------------------------------------------------------------------
      // 1. Create a room
      // ------------------------------------------------------------------
      final createdRoom = helpers.testRoom(
        id: 'room-flow',
        name: 'Flow Room',
        type: RoomType.private,
        inviteCode: 'FLOW12',
        voiceEnabled: true,
        cameraEnabled: true,
        players: [helpers.testPlayer(uid: 'u1', name: 'Me', isMe: true)],
      );
      when(() => roomRepository.createRoom(any()))
          .thenAnswer((_) async => createdRoom);

      final createCubit = RoomCubit(
        roomRepository: roomRepository,
        agoraService: agoraService,
      );

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

      await tester.tap(find.widgetWithText(GradientButton, 'Create Room'));
      await tester.pumpAndSettle();

      verify(() => roomRepository.createRoom(any())).called(1);

      // ------------------------------------------------------------------
      // 2. Room lobby: voice/video indicators, ready, start game
      // ------------------------------------------------------------------
      final lobbyRoom = helpers.testRoom(
        id: 'room-flow',
        name: 'Flow Room',
        type: RoomType.private,
        inviteCode: 'FLOW12',
        voiceEnabled: true,
        cameraEnabled: true,
        players: [
          helpers.testPlayer(uid: 'u1', name: 'Me', isMe: true, isReady: true),
          helpers.testPlayer(uid: 'u2', name: 'Partner', isReady: true),
          helpers.testPlayer(uid: 'u3', name: 'Opp1', isReady: true),
          helpers.testPlayer(uid: 'u4', name: 'Opp2', isReady: true),
        ],
      );
      when(() => roomRepository.watchRoom('room-flow')).thenAnswer(
        (_) => Stream.value(lobbyRoom),
      );
      when(() => roomRepository.startGame('room-flow'))
          .thenAnswer((_) async => 'game-flow');
      when(() => roomRepository.updatePlayerMediaState(
            'room-flow',
            isMicOn: any(named: 'isMicOn'),
            isCameraOn: any(named: 'isCameraOn'),
          )).thenAnswer((_) async {});

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
      expect(find.byIcon(Icons.mic_rounded), findsOneWidget);
      expect(find.byIcon(Icons.videocam_off_rounded), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Start Game'));
      await tester.pumpAndSettle();

      verify(() => roomRepository.startGame('room-flow')).called(1);

      // ------------------------------------------------------------------
      // 3. Game play: render players, play a card, mic/camera toggles
      // ------------------------------------------------------------------
      final game = helpers.testGame(
        id: 'game-flow',
        status: 'playing',
        turnIndex: 0,
        mySeatIndex: 0,
        myHand: const ['AH', 'KH', 'QH'],
        agoraChannelName: 'room-flow',
      );
      when(() => gameRepository.watchGame('game-flow'))
          .thenAnswer((_) => Stream.value(game));
      when(() => gameRepository.playCard('game-flow', 'AH'))
          .thenAnswer((_) async {});
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
              child: const GamePlayPage(id: 'game-flow'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Me'), findsOneWidget);
      expect(find.text('Faisal'), findsOneWidget);

      // Let the auto-hide timer fire.
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
      when(() => discoverRepository.getStreamById('stream-flow'))
          .thenAnswer((_) async => stream);
      when(() => discoverRepository.watchStreamChat('stream-flow'))
          .thenAnswer((_) => const Stream.empty());
      when(() => discoverRepository.sendChatMessage('stream-flow', 'GG'))
          .thenAnswer((_) async {});

      final discoverCubit = DiscoverCubit(discoverRepository: discoverRepository);
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

      verify(() => discoverRepository.sendChatMessage('stream-flow', 'GG'))
          .called(1);
    });

    testWidgets('join public room flow', (tester) async {
      when(() => roomRepository.watchPublicRooms()).thenAnswer(
        (_) => Stream.value([
          helpers.testRoom(
            id: 'pub1',
            name: 'Public Flow',
            type: RoomType.public,
            inviteCode: 'PUB123',
            voiceEnabled: true,
            cameraEnabled: false,
            players: [helpers.testPlayer(uid: 'u1', name: 'Host')],
          ),
        ]),
      );
      when(() => roomRepository.joinRoomByCode('PUB123'))
          .thenAnswer((_) async => helpers.testRoom(id: 'pub1'));

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
