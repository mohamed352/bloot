import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bloot/core/components/app_button.dart';
import 'package:bloot/features/room/domain/entities/create_room_params.dart';
import 'package:bloot/features/room/domain/entities/room.dart';
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

    testWidgets('never shows a password field, even for private rooms', (
      tester,
    ) async {
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

        // Default (public): only the room name field.
        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('Room Password'), findsNothing);

        // Select private room.
        await tester.tap(find.text('Private'));
        await tester.pumpAndSettle();

        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('Room Password'), findsNothing);
      });
    });

    testWidgets('creates a private room with a null password', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await runWithFakeHttp(() async {
        CreateRoomParams? captured;
        when(() => roomRepository.createRoom(any())).thenAnswer((invocation) async {
          captured =
              invocation.positionalArguments.first as CreateRoomParams;
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

        // Select private room (default is public).
        await tester.tap(find.text('Private'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField).first, 'My Room');
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(GradientButton, 'Create Room'));
        await tester.pump();

        verify(() => roomRepository.createRoom(any())).called(1);
        expect(captured, isNotNull);
        expect(captured!.type, RoomType.private);
        expect(captured!.password, isNull);
      });
    });

    testWidgets('shows error and does not create when name is empty', (
      tester,
    ) async {
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

        // Leave the name empty and tap create.
        final createButton = find.widgetWithText(GradientButton, 'Create Room');
        expect(createButton, findsOneWidget);
        await tester.tap(createButton);
        await tester.pumpAndSettle();

        // Inline validation error is shown and nothing is created.
        expect(find.text('This field is required'), findsOneWidget);
        verifyNever(() => roomRepository.createRoom(any()));

        // Typing a name clears the error.
        await tester.enterText(find.byType(TextField).first, 'My Room');
        await tester.pumpAndSettle();
        expect(find.text('This field is required'), findsNothing);
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

        await tester.tap(find.widgetWithText(GradientButton, 'Create Room'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(SnackBar), findsOneWidget);
      });
    });
  });
}
