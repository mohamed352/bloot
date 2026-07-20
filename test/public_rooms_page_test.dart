import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bloot/features/room/domain/entities/room.dart';
import 'package:bloot/features/room/presentation/cubit/room_cubit.dart';
import 'package:bloot/features/room/presentation/pages/public_rooms_page.dart';
import 'package:bloot/features/room/presentation/pages/room_lobby_page.dart';

import 'helpers/test_helpers.dart';

void main() {
  late MockRoomRepository roomRepository;
  late MockAgoraService agoraService;
  late RoomCubit cubit;

  GoRouter buildRouter() {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const PublicRoomsPage()),
        GoRoute(
          path: '/stream/:id',
          name: 'watchStream',
          builder: (context, state) => Scaffold(
            body: Center(child: Text('Stream ${state.pathParameters['id']}')),
          ),
        ),
        GoRoute(
          path: '/room/:id',
          name: 'roomLobby',
          builder: (context, state) =>
              RoomLobbyPage(id: state.pathParameters['id']!),
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
  });

  tearDown(() async {
    await cubit.close();
  });

  Future<void> pumpPage(
    WidgetTester tester, {
    required List<Room> rooms,
    GoRouter? router,
  }) async {
    when(
      () => roomRepository.watchPublicRooms(),
    ).thenAnswer((_) => Stream.value(rooms));
    await tester.pumpWidget(
      buildTestableWidgetWithRouter(
        router: router ?? buildRouter(),
        roomCubit: cubit,
        agoraService: agoraService,
      ),
    );
    await tester.pumpAndSettle();
  }

  group('PublicRoomsPage', () {
    testWidgets('tapping a live room card opens the watch stream page', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await runWithFakeHttp(() async {
        await pumpPage(
          tester,
          rooms: [
            testRoom(
              id: 'r2',
              name: 'Live Room',
              type: RoomType.public,
              isStreaming: true,
              streamId: 'stream-r2',
              players: [testPlayer(name: 'Host')],
            ),
          ],
        );

        await tester.tap(find.widgetWithText(ElevatedButton, 'Join Table'));
        await tester.pumpAndSettle();

        expect(find.text('Stream stream-r2'), findsOneWidget);
        verifyNever(
          () => roomRepository.joinRoomByCode(
            any(),
            password: any(named: 'password'),
          ),
        );
      });
    });

    testWidgets('tapping a waiting room card joins the room as a player', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await runWithFakeHttp(() async {
        when(
          () => roomRepository.joinRoomByCode(
            'ABC123',
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => testRoom());

        await pumpPage(
          tester,
          rooms: [
            testRoom(
              id: 'r2',
              name: 'Idle Room',
              type: RoomType.public,
              players: [testPlayer(name: 'Host')],
            ),
          ],
        );

        await tester.tap(find.widgetWithText(ElevatedButton, 'Join Table'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // A waiting (not yet live) room joins the lobby as a player through
        // the room's invite code instead of showing a not-live error.
        verify(
          () => roomRepository.joinRoomByCode(
            'ABC123',
            password: any(named: 'password'),
          ),
        ).called(1);
        expect(find.byType(SnackBar), findsNothing);
      });
    });

    testWidgets('tapping a live card without a streamId shows not-live', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await runWithFakeHttp(() async {
        await pumpPage(
          tester,
          rooms: [
            testRoom(
              id: 'r2',
              name: 'Broken Room',
              type: RoomType.public,
              isStreaming: true,
              players: [testPlayer(name: 'Host')],
            ),
          ],
        );

        await tester.tap(find.widgetWithText(ElevatedButton, 'Join Table'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(SnackBar), findsOneWidget);
        verifyNever(
          () => roomRepository.joinRoomByCode(
            any(),
            password: any(named: 'password'),
          ),
        );
      });
    });

    testWidgets('search-by-code joins the room as a player', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await runWithFakeHttp(() async {
        when(
          () => roomRepository.joinRoomByCode(
            'ABC123',
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => testRoom());

        await pumpPage(tester, rooms: const []);

        await tester.enterText(find.byType(TextField), 'abc123');
        await tester.pump();
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        verify(
          () => roomRepository.joinRoomByCode(
            'ABC123',
            password: any(named: 'password'),
          ),
        ).called(1);
      });
    });
  });
}
