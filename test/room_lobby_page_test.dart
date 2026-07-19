import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'dart:async';

import 'package:bloot/features/room/domain/entities/room.dart';
import 'package:bloot/features/room/presentation/cubit/room_cubit.dart';
import 'package:bloot/features/room/presentation/cubit/room_state.dart';
import 'package:bloot/features/room/presentation/pages/room_lobby_page.dart';
import 'package:bloot/features/room/presentation/widgets/seat_widget.dart';

import 'helpers/test_helpers.dart';

void main() {
  late MockRoomRepository roomRepository;
  late MockAgoraService agoraService;
  late RoomCubit cubit;
  late GoRouter router;

  GoRouter buildRouter() {
    return GoRouter(
      initialLocation: '/room/r1',
      routes: [
        GoRoute(
          path: '/room/:id',
          name: 'roomLobby',
          builder: (context, state) =>
              RoomLobbyPage(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/game/:id',
          name: 'gamePlay',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Game'))),
        ),
      ],
    );
  }

  setUpAll(setupWidgetTests);

  setUp(() {
    roomRepository = MockRoomRepository();
    agoraService = MockAgoraService();
    stubAgoraServiceDefaults(agoraService);

    cubit = RoomCubit(
      roomRepository: roomRepository,
      agoraService: agoraService,
    );
    router = buildRouter();
  });

  tearDown(() async {
    await cubit.close();
  });

  group('RoomLobbyPage', () {
    testWidgets('renders room code and player seats', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await runWithFakeHttp(() async {
        when(() => roomRepository.watchRoom('r1')).thenAnswer(
          (_) => Stream.value(
            testRoom(
              players: [
                testPlayer(name: 'Me', isMe: true),
                testPlayer(uid: 'u2', name: 'Partner'),
                testPlayer(uid: 'u3', name: 'Opp1', team: 'B'),
                testPlayer(uid: 'u4', name: 'Opp2', team: 'B'),
              ],
            ),
          ),
        );

        cubit.loadRoom('r1');
        await tester.pumpWidget(
          buildTestableWidgetWithRouter(
            router: router,
            roomCubit: cubit,
            agoraService: agoraService,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('ABC123'), findsOneWidget);
        expect(find.text('Me'), findsOneWidget);
        expect(find.text('Partner'), findsOneWidget);
        expect(find.text('Opp1'), findsOneWidget);
        expect(find.text('Opp2'), findsOneWidget);
      });
    });

    testWidgets('shows mic and camera toggle buttons', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await runWithFakeHttp(() async {
        when(() => roomRepository.watchRoom('r1')).thenAnswer(
          (_) => Stream.value(
            testRoom(
              cameraEnabled: true,
              players: [testPlayer(name: 'Me', isMe: true)],
            ),
          ),
        );

        cubit.loadRoom('r1');
        await tester.pumpWidget(
          buildTestableWidgetWithRouter(
            router: router,
            roomCubit: cubit,
            agoraService: agoraService,
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.widgetWithIcon(GestureDetector, Icons.mic_rounded),
          findsOneWidget,
        );
        expect(
          find.widgetWithIcon(GestureDetector, Icons.videocam_off_rounded),
          findsOneWidget,
        );
      });
    });

    testWidgets('hides media toggles when room has no voice or camera', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await runWithFakeHttp(() async {
        when(() => roomRepository.watchRoom('r1')).thenAnswer(
          (_) => Stream.value(
            testRoom(
              voiceEnabled: false,
              players: [testPlayer(name: 'Me', isMe: true)],
            ),
          ),
        );

        cubit.loadRoom('r1');
        await tester.pumpWidget(
          buildTestableWidgetWithRouter(
            router: router,
            roomCubit: cubit,
            agoraService: agoraService,
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.widgetWithIcon(GestureDetector, Icons.mic_rounded),
          findsNothing,
        );
        expect(
          find.widgetWithIcon(GestureDetector, Icons.mic_off_rounded),
          findsNothing,
        );
        expect(
          find.widgetWithIcon(GestureDetector, Icons.videocam_off_rounded),
          findsNothing,
        );
      });
    });

    testWidgets('toggles ready state when ready button tapped', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await runWithFakeHttp(() async {
        when(() => roomRepository.watchRoom('r1')).thenAnswer(
          (_) => Stream.value(
            testRoom(players: [testPlayer(name: 'Me', isMe: true)]),
          ),
        );
        when(
          () => roomRepository.toggleReady('r1'),
        ).thenAnswer((_) async => testRoom());

        cubit.loadRoom('r1');
        await tester.pumpWidget(
          buildTestableWidgetWithRouter(
            router: router,
            roomCubit: cubit,
            agoraService: agoraService,
          ),
        );
        await tester.pumpAndSettle();

        final readyButton = find.text('I am ready');
        expect(readyButton, findsOneWidget);
        await tester.tap(readyButton);
        await tester.pumpAndSettle();

        verify(() => roomRepository.toggleReady('r1')).called(1);
      });
    });

    testWidgets('start game button disabled when not all ready', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await runWithFakeHttp(() async {
        when(() => roomRepository.watchRoom('r1')).thenAnswer(
          (_) => Stream.value(
            testRoom(players: [testPlayer(name: 'Me', isMe: true)]),
          ),
        );

        cubit.loadRoom('r1');
        await tester.pumpWidget(
          buildTestableWidgetWithRouter(
            router: router,
            roomCubit: cubit,
            agoraService: agoraService,
          ),
        );
        await tester.pumpAndSettle();

        final startButton = find.widgetWithText(ElevatedButton, 'Ready 0/4');
        expect(startButton, findsOneWidget);
        expect(tester.widget<ElevatedButton>(startButton).onPressed, isNull);
      });
    });

    testWidgets('start game button enabled when all ready and creator', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await runWithFakeHttp(() async {
        when(() => roomRepository.watchRoom('r1')).thenAnswer(
          (_) => Stream.value(
            testRoom(
              players: [
                testPlayer(name: 'Me', isMe: true, isReady: true),
                testPlayer(uid: 'u2', name: 'Partner', isReady: true),
                testPlayer(uid: 'u3', name: 'Opp1', isReady: true, team: 'B'),
                testPlayer(uid: 'u4', name: 'Opp2', isReady: true, team: 'B'),
              ],
            ),
          ),
        );
        when(
          () => roomRepository.startGame('r1'),
        ).thenAnswer((_) async => 'g1');

        cubit.loadRoom('r1');
        await tester.pumpWidget(
          buildTestableWidgetWithRouter(
            router: router,
            roomCubit: cubit,
            agoraService: agoraService,
          ),
        );
        await tester.pumpAndSettle();

        final startButton = find.widgetWithText(ElevatedButton, 'Start Game');
        expect(startButton, findsOneWidget);
        expect(tester.widget<ElevatedButton>(startButton).onPressed, isNotNull);

        await tester.tap(startButton);
        await tester.pump();

        verify(() => roomRepository.startGame('r1')).called(1);
      });
    });

    testWidgets('toggles microphone through Agora service', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await runWithFakeHttp(() async {
        when(() => roomRepository.watchRoom('r1')).thenAnswer(
          (_) => Stream.value(
            testRoom(players: [testPlayer(name: 'Me', isMe: true)]),
          ),
        );
        when(
          () => roomRepository.updatePlayerMediaState(
            'r1',
            isMicOn: any(named: 'isMicOn'),
            isCameraOn: any(named: 'isCameraOn'),
          ),
        ).thenAnswer((_) async {});
        when(() => agoraService.toggleMic()).thenAnswer((_) async => false);

        cubit.loadRoom('r1');
        await tester.pumpWidget(
          buildTestableWidgetWithRouter(
            router: router,
            roomCubit: cubit,
            agoraService: agoraService,
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(
          find.widgetWithIcon(GestureDetector, Icons.mic_rounded),
        );
        await tester.pump();

        verify(() => agoraService.toggleMic()).called(1);
        verify(
          () => roomRepository.updatePlayerMediaState(
            'r1',
            isMicOn: false,
            isCameraOn: false,
          ),
        ).called(1);
      });
    });

    testWidgets('derives seats from teams regardless of join order', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await runWithFakeHttp(() async {
        // Local player is NOT at index 0 and their partner is not at index 1:
        // seats must be derived from teams, not list positions.
        when(() => roomRepository.watchRoom('r1')).thenAnswer(
          (_) => Stream.value(
            testRoom(
              players: [
                testPlayer(uid: 'u3', name: 'Opp1', team: 'B'),
                testPlayer(uid: 'u2', name: 'Partner'),
                testPlayer(name: 'Me', isMe: true),
                testPlayer(uid: 'u4', name: 'Opp2', team: 'B'),
              ],
            ),
          ),
        );

        cubit.loadRoom('r1');
        await tester.pumpWidget(
          buildTestableWidgetWithRouter(
            router: router,
            roomCubit: cubit,
            agoraService: agoraService,
          ),
        );
        await tester.pumpAndSettle();

        SeatWidget seatAt(SeatPosition position) {
          return tester.widget<SeatWidget>(
            find.byWidgetPredicate(
              (w) => w is SeatWidget && w.position == position,
            ),
          );
        }

        expect(seatAt(SeatPosition.bottom).player?.name, 'Me');
        expect(seatAt(SeatPosition.top).player?.name, 'Partner');
        expect(seatAt(SeatPosition.left).player?.name, 'Opp1');
        expect(seatAt(SeatPosition.right).player?.name, 'Opp2');
      });
    });

    testWidgets('shows empty seats with safe fallbacks for incomplete rooms', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await runWithFakeHttp(() async {
        when(() => roomRepository.watchRoom('r1')).thenAnswer(
          (_) => Stream.value(
            testRoom(players: [testPlayer(name: 'Me', isMe: true)]),
          ),
        );

        cubit.loadRoom('r1');
        await tester.pumpWidget(
          buildTestableWidgetWithRouter(
            router: router,
            roomCubit: cubit,
            agoraService: agoraService,
          ),
        );
        await tester.pumpAndSettle();

        SeatWidget seatAt(SeatPosition position) {
          return tester.widget<SeatWidget>(
            find.byWidgetPredicate(
              (w) => w is SeatWidget && w.position == position,
            ),
          );
        }

        expect(seatAt(SeatPosition.bottom).player?.name, 'Me');
        expect(seatAt(SeatPosition.top).player, isNull);
        expect(seatAt(SeatPosition.left).player, isNull);
        expect(seatAt(SeatPosition.right).player, isNull);
        expect(find.text('Me'), findsOneWidget);
      });
    });

    testWidgets('shows snackbar and navigates home when kicked', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await runWithFakeHttp(() async {
        final roomController = StreamController<Room>();
        addTearDown(roomController.close);
        when(
          () => roomRepository.watchRoom('r1'),
        ).thenAnswer((_) => roomController.stream);

        final kickRouter = GoRouter(
          initialLocation: '/room/r1',
          routes: [
            GoRoute(
              path: '/room/:id',
              name: 'roomLobby',
              builder: (context, state) =>
                  RoomLobbyPage(id: state.pathParameters['id']!),
            ),
            GoRoute(
              path: '/home',
              name: 'home',
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text('Home'))),
            ),
          ],
        );

        cubit.loadRoom('r1');
        await tester.pumpWidget(
          buildTestableWidgetWithRouter(
            router: kickRouter,
            roomCubit: cubit,
            agoraService: agoraService,
          ),
        );
        await tester.pump();

        // First snapshot: local user is in the room.
        roomController.add(
          testRoom(players: [testPlayer(name: 'Me', isMe: true)]),
        );
        await tester.pump();
        await tester.pump();
        expect(find.text('ABC123'), findsOneWidget);

        // Later snapshot: local user was removed (kicked by the host).
        roomController.add(
          testRoom(
            players: [testPlayer(uid: 'u2', name: 'Host')],
          ),
        );
        // The kick cleanup is async (cancel subscriptions, leave Agora), so
        // flush several frames before asserting.
        for (var i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        expect(cubit.state, isA<RoomKicked>());
        expect(find.text('Home'), findsOneWidget);
        expect(find.byType(SnackBar), findsOneWidget);
        expect(
          find.text('You were removed from the room by the host.'),
          findsOneWidget,
        );
        verifyNever(() => roomRepository.leaveRoom(any()));
      });
    });

    testWidgets('shows live stream controls for creator in live stream room', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await runWithFakeHttp(() async {
        when(() => roomRepository.watchRoom('r1')).thenAnswer(
          (_) => Stream.value(
            testRoom(
              type: RoomType.liveStream,
              players: [testPlayer(name: 'Me', isMe: true)],
            ),
          ),
        );

        cubit.loadRoom('r1');
        await tester.pumpWidget(
          buildTestableWidgetWithRouter(
            router: router,
            roomCubit: cubit,
            agoraService: agoraService,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Go Live'), findsOneWidget);
      });
    });
  });
}
