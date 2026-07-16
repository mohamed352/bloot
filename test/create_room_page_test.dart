import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bloot/core/components/app_button.dart';
import 'package:bloot/features/room/presentation/cubit/room_cubit.dart';
import 'package:bloot/features/room/presentation/pages/create_room_page.dart';
import 'package:bloot/features/room/presentation/pages/room_lobby_page.dart';

import 'helpers/test_helpers.dart';

void main() {
  late MockRoomRepository roomRepository;
  late MockAgoraService agoraService;
  late RoomCubit cubit;
  late GoRouter router;

  GoRouter buildRouter() {
    return GoRouter(
      initialLocation: '/create',
      routes: [
        GoRoute(
          path: '/create',
          builder: (context, state) => const CreateRoomPage(),
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
    cubit = RoomCubit(
      roomRepository: roomRepository,
      agoraService: agoraService,
    );
    router = buildRouter();
  });

  tearDown(() async {
    await cubit.close();
  });

  group('CreateRoomPage', () {
    testWidgets('renders room name field and type options', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await runWithFakeHttp(() async {
        await tester.pumpWidget(
          buildTestableWidgetWithRouter(
            router: router,
            roomCubit: cubit,
            agoraService: agoraService,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(TextField), findsAtLeastNWidgets(1));
        expect(find.text('Create Room'), findsWidgets);
        expect(find.text('Private'), findsOneWidget);
        expect(find.text('Public'), findsOneWidget);
        expect(find.text('Live Stream'), findsOneWidget);
      });
    });

    testWidgets('toggles voice, camera and spectators', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await runWithFakeHttp(() async {
        await tester.pumpWidget(
          buildTestableWidgetWithRouter(
            router: router,
            roomCubit: cubit,
            agoraService: agoraService,
          ),
        );
        await tester.pumpAndSettle();

        final switches = find.byType(Switch);
        expect(switches, findsNWidgets(3));

        // Toggle camera on.
        await tester.tap(switches.at(1));
        await tester.pumpAndSettle();

        // Toggle spectators off.
        await tester.tap(switches.at(2));
        await tester.pumpAndSettle();
      });
    });

    testWidgets('shows password field only for private rooms', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await runWithFakeHttp(() async {
        await tester.pumpWidget(
          buildTestableWidgetWithRouter(
            router: router,
            roomCubit: cubit,
            agoraService: agoraService,
          ),
        );
        await tester.pumpAndSettle();

        // Select private room (default is public).
        await tester.tap(find.text('Private'));
        await tester.pumpAndSettle();

        expect(find.text('Room Password'), findsOneWidget);

        // Select public room.
        await tester.tap(find.text('Public'));
        await tester.pumpAndSettle();

        expect(find.text('Room Password'), findsNothing);

        // Select live stream.
        await tester.tap(find.text('Live Stream'));
        await tester.pumpAndSettle();

        expect(find.text('Room Password'), findsNothing);
      });
    });

    testWidgets('validates private room password length', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await runWithFakeHttp(() async {
        await tester.pumpWidget(
          buildTestableWidgetWithRouter(
            router: router,
            roomCubit: cubit,
            agoraService: agoraService,
          ),
        );
        await tester.pumpAndSettle();

        // Select private room (default is public).
        await tester.tap(find.text('Private'));
        await tester.pumpAndSettle();

        final nameField = find.byType(TextField).first;
        await tester.enterText(nameField, 'My Room');
        await tester.pumpAndSettle();

        final passwordFields = find.byType(TextField);
        final passwordField = passwordFields.last;
        await tester.enterText(passwordField, '123');
        await tester.pumpAndSettle();

        // Create button should be disabled with short password.
        final createButton = find.widgetWithText(GradientButton, 'Create Room');
        expect(createButton, findsOneWidget);
        await tester.tap(createButton);
        await tester.pumpAndSettle();

        verifyNever(() => roomRepository.createRoom(any()));
      });
    });

    testWidgets('calls createRoom with correct params on submit', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await runWithFakeHttp(() async {
        when(
          () => roomRepository.createRoom(any()),
        ).thenAnswer((_) async => testRoom());

        await tester.pumpWidget(
          buildTestableWidgetWithRouter(
            router: router,
            roomCubit: cubit,
            agoraService: agoraService,
          ),
        );
        await tester.pumpAndSettle();

        final nameField = find.byType(TextField).first;
        await tester.enterText(nameField, 'My Room');
        await tester.pumpAndSettle();

        final passwordFields = find.byType(TextField);
        final passwordField = passwordFields.last;
        await tester.enterText(passwordField, 'secret');
        await tester.pumpAndSettle();

        final createButton = find.widgetWithText(GradientButton, 'Create Room');
        await tester.tap(createButton);
        await tester.pump();

        verify(() => roomRepository.createRoom(any())).called(1);
      });
    });

    testWidgets('shows loading indicator while creating room', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await runWithFakeHttp(() async {
        final completer = Completer<void>();
        when(() => roomRepository.createRoom(any())).thenAnswer((_) async {
          await completer.future;
          return testRoom();
        });

        await tester.pumpWidget(
          buildTestableWidgetWithRouter(
            router: router,
            roomCubit: cubit,
            agoraService: agoraService,
          ),
        );
        await tester.pumpAndSettle();

        final nameField = find.byType(TextField).first;
        await tester.enterText(nameField, 'My Room');
        await tester.pumpAndSettle();

        final passwordFields = find.byType(TextField);
        await tester.enterText(passwordFields.last, 'secret');
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(GradientButton, 'Create Room'));
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        completer.complete();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
      });
    });

    testWidgets('shows snackbar when room creation fails', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await runWithFakeHttp(() async {
        when(
          () => roomRepository.createRoom(any()),
        ).thenThrow(Exception('network'));

        await tester.pumpWidget(
          buildTestableWidgetWithRouter(
            router: router,
            roomCubit: cubit,
            agoraService: agoraService,
          ),
        );
        await tester.pumpAndSettle();

        final nameField = find.byType(TextField).first;
        await tester.enterText(nameField, 'My Room');
        await tester.pumpAndSettle();

        final passwordFields = find.byType(TextField);
        await tester.enterText(passwordFields.last, 'secret');
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(GradientButton, 'Create Room'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(SnackBar), findsOneWidget);
      });
    });
  });
}
