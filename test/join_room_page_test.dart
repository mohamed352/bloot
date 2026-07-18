import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bloot/features/room/domain/entities/room.dart';
import 'package:bloot/features/room/presentation/cubit/room_cubit.dart';
import 'package:bloot/features/room/presentation/pages/join_room_page.dart';
import 'package:bloot/features/room/presentation/pages/public_rooms_page.dart';
import 'package:bloot/features/room/presentation/pages/room_lobby_page.dart';

import 'helpers/test_helpers.dart';

void main() {
  late MockRoomRepository roomRepository;
  late MockAgoraService agoraService;
  late RoomCubit cubit;
  late GoRouter router;

  GoRouter buildRouter(Widget home) {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => home),
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

  group('JoinRoomPage', () {
    testWidgets('renders code input and join button', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      router = buildRouter(const JoinRoomPage());
      await runWithFakeHttp(() async {
        await tester.pumpWidget(
          buildTestableWidgetWithRouter(
            router: router,
            roomCubit: cubit,
            agoraService: agoraService,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(TextField), findsNWidgets(1));
        expect(find.text('Join Room'), findsWidgets);
      });
    });

    testWidgets('checks password requirement when 6-char code entered', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      router = buildRouter(const JoinRoomPage());
      await runWithFakeHttp(() async {
        when(
          () => roomRepository.isPasswordRequired('ABC123'),
        ).thenAnswer((_) async => true);

        await tester.pumpWidget(
          buildTestableWidgetWithRouter(
            router: router,
            roomCubit: cubit,
            agoraService: agoraService,
          ),
        );
        await tester.pumpAndSettle();

        final codeField = find.byType(TextField).first;
        await tester.enterText(codeField, 'ABC123');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        verify(() => roomRepository.isPasswordRequired('ABC123')).called(1);
      });
    });

    testWidgets('joins room with code and password', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      router = buildRouter(const JoinRoomPage());
      await runWithFakeHttp(() async {
        when(
          () => roomRepository.isPasswordRequired('ABC123'),
        ).thenAnswer((_) async => true);
        when(
          () => roomRepository.joinRoomByCode(
            'ABC123',
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => testRoom());

        await tester.pumpWidget(
          buildTestableWidgetWithRouter(
            router: router,
            roomCubit: cubit,
            agoraService: agoraService,
          ),
        );
        await tester.pumpAndSettle();

        final fields = find.byType(TextField);
        await tester.enterText(fields.first, 'ABC123');
        await tester.pumpAndSettle();
        await tester.enterText(fields.last, 'secret');
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(ElevatedButton, 'Join Room'));
        await tester.pump();

        verify(
          () => roomRepository.joinRoomByCode('ABC123', password: 'secret'),
        ).called(1);
      });
    });

    testWidgets('shows snackbar when join fails', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      router = buildRouter(const JoinRoomPage());
      await runWithFakeHttp(() async {
        when(
          () => roomRepository.isPasswordRequired('ABC123'),
        ).thenAnswer((_) async => false);
        when(
          () => roomRepository.joinRoomByCode(
            'ABC123',
            password: any(named: 'password'),
          ),
        ).thenThrow(Exception('network'));

        await tester.pumpWidget(
          buildTestableWidgetWithRouter(
            router: router,
            roomCubit: cubit,
            agoraService: agoraService,
          ),
        );
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField).first, 'ABC123');
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(ElevatedButton, 'Join Room'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(SnackBar), findsOneWidget);
      });
    });
  });

  group('PublicRoomsPage', () {
    testWidgets('loads and displays public rooms', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      router = buildRouter(const PublicRoomsPage());
      await runWithFakeHttp(() async {
        when(() => roomRepository.watchPublicRooms()).thenAnswer(
          (_) => Stream.value([
            testRoom(
              id: 'r2',
              name: 'Public Room',
              type: RoomType.public,
              inviteCode: 'PUB001',
              players: [testPlayer(name: 'Host')],
            ),
          ]),
        );

        await tester.pumpWidget(
          buildTestableWidgetWithRouter(
            router: router,
            roomCubit: cubit,
            agoraService: agoraService,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Public Room'), findsOneWidget);
        expect(find.text('Host'), findsOneWidget);
        expect(find.text('Join Table'), findsOneWidget);
      });
    });

    testWidgets('card join does not join as player when room is not live', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      router = buildRouter(const PublicRoomsPage());
      await runWithFakeHttp(() async {
        when(() => roomRepository.watchPublicRooms()).thenAnswer(
          (_) => Stream.value([
            testRoom(
              id: 'r2',
              name: 'Public Room',
              type: RoomType.public,
              inviteCode: 'PUB001',
              players: [testPlayer(name: 'Host')],
            ),
          ]),
        );

        await tester.pumpWidget(
          buildTestableWidgetWithRouter(
            router: router,
            roomCubit: cubit,
            agoraService: agoraService,
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(ElevatedButton, 'Join Table'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // The card never joins the room as a player; it shows a localized
        // not-live message instead.
        expect(find.byType(SnackBar), findsOneWidget);
        expect(
          find.text('This table is not live right now.'),
          findsOneWidget,
        );
        verifyNever(() => roomRepository.joinRoomByCode('PUB001'));
      });
    });

    testWidgets('shows empty state when no public rooms', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      router = buildRouter(const PublicRoomsPage());
      await runWithFakeHttp(() async {
        when(
          () => roomRepository.watchPublicRooms(),
        ).thenAnswer((_) => Stream.value([]));

        await tester.pumpWidget(
          buildTestableWidgetWithRouter(
            router: router,
            roomCubit: cubit,
            agoraService: agoraService,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('No public rooms'), findsOneWidget);
      });
    });
  });
}
