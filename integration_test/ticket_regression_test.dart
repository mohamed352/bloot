import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/components/app_button.dart';
import 'package:bloot/core/network/connectivity_cubit.dart';
import 'package:bloot/core/services/agora_service.dart';
import 'package:bloot/core/services/audio_service.dart';
import 'package:bloot/core/style/theme_manager.dart';
import 'package:bloot/features/chat/presentation/pages/room_invitation_page.dart';
import 'package:bloot/features/game/domain/entities/game.dart';
import 'package:bloot/features/game/domain/repositories/game_repository.dart';
import 'package:bloot/features/game/presentation/cubit/game_cubit.dart';
import 'package:bloot/features/game/presentation/cubit/game_state.dart';
import 'package:bloot/features/game/presentation/pages/html_game_play_page.dart';
import 'package:bloot/features/room/domain/exceptions/room_exception.dart';
import 'package:bloot/features/room/domain/repositories/room_repository.dart';
import 'package:bloot/features/room/presentation/cubit/room_cubit.dart';

import '../test/helpers/test_helpers.dart' as helpers;

/// On-device regression tests for the two Firebase App Distribution tester
/// tickets (builds 10-11):
///
/// 1. "The join button in the game invitation displays an infinite loading
///    indicator" — the RoomInvitationPage Join button must always settle:
///    navigate on success, show the error and re-enable on failure.
/// 2. "This error appears while clicking on watch game in the live show"
///    ("You don't have access to watch this game / Failed to load game") —
///    a spectator watching a live game must reach the game view, and a real
///    permission denial must show the specific message instead of spinning.
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class _TicketAssetLoader extends AssetLoader {
  const _TicketAssetLoader();

  static const Map<String, dynamic> _translations = {
    'room_invitation': 'Room Invitation',
    'invited_you_to_join': 'invited you to join',
    'join_room': 'Join Room',
    'login_to_join': 'Login to Join',
    'decline': 'Decline',
    'room_not_found': 'Room not found',
    'try_again': 'Try Again',
    'room_full': 'Room is full',
    'room_closed': 'Room is closed',
    'roomPlayerCount': '{current}/{max} Players',
    'private': 'Private',
    'public': 'Public',
    'starting_game': 'Starting game...',
    'game_load_failed': 'Failed to load game',
    'game_watch_no_access': "You don't have access to watch this game.",
    'game_ended': 'This game has ended',
  };

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      _translations;
}

Widget _shell({required GoRouter router, List<BlocProvider<dynamic>> blocProviders = const [], List<RepositoryProvider<dynamic>> repoProviders = const []}) {
  return EasyLocalization(
    supportedLocales: const [Locale('en'), Locale('ar')],
    path: 'assets/translations',
    fallbackLocale: const Locale('en'),
    startLocale: const Locale('en'),
    useOnlyLangCode: true,
    assetLoader: const _TicketAssetLoader(),
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
                ...blocProviders,
                BlocProvider<ConnectivityCubit>(
                  create: (_) => ConnectivityCubit(),
                ),
              ],
              // MultiRepositoryProvider asserts a non-empty provider list, so
              // only wrap when the test actually provides repositories.
              child: repoProviders.isEmpty
                  ? (child ?? const SizedBox.shrink())
                  : MultiRepositoryProvider(
                      providers: repoProviders,
                      child: child ?? const SizedBox.shrink(),
                    ),
            );
          },
        );
      },
    ),
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late helpers.MockRoomRepository roomRepository;
  late helpers.MockGameRepository gameRepository;
  late helpers.MockAgoraService agoraService;
  late helpers.MockAudioService audioService;
  late MockFirebaseAuth firebaseAuth;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({'game_tutorial_seen': true});
    EasyLocalization.logger.enableBuildModes = [];
    registerFallbackValue(helpers.FakeCreateRoomParams());
  });

  setUp(() async {
    roomRepository = helpers.MockRoomRepository();
    gameRepository = helpers.MockGameRepository();
    agoraService = helpers.MockAgoraService();
    audioService = helpers.MockAudioService();
    firebaseAuth = MockFirebaseAuth();

    helpers.stubAgoraServiceDefaults(agoraService);
    when(() => firebaseAuth.currentUser).thenReturn(MockUser());
    when(() => gameRepository.createRtdbToken()).thenAnswer((_) async => null);

    final getIt = GetIt.instance;
    await getIt.reset();
    getIt.registerSingleton<RoomRepository>(roomRepository);
    getIt.registerSingleton<GameRepository>(gameRepository);
    getIt.registerSingleton<AgoraService>(agoraService);
    getIt.registerSingleton<FirebaseAuth>(firebaseAuth);
    // RoomInvitationPage builds its cubit via getIt<RoomCubit>().
    getIt.registerFactory<RoomCubit>(
      () => RoomCubit(
        roomRepository: roomRepository,
        agoraService: agoraService,
      ),
    );
  });

  GoRouter buildRouter() {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, _) => const RoomInvitationPage(id: 'inv1')),
        GoRoute(
          path: '/room/:id',
          name: RouteNames.roomLobby,
          builder: (_, _) => const Scaffold(body: Text('LOBBY_STUB')),
        ),
        GoRoute(
          path: '/login',
          name: RouteNames.login,
          builder: (_, _) => const Scaffold(body: Text('LOGIN_STUB')),
        ),
      ],
    );
  }

  group('Ticket 1: invitation Join button never spins forever', () {
    Future<void> pumpInvitationPage(WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(411, 914));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(_shell(router: buildRouter()));
      await tester.pumpAndSettle();
    }

    testWidgets('join failure stops the spinner and shows the error', (tester) async {
      await helpers.runWithFakeHttp(() async {
        final room = helpers.testRoom(id: 'inv1', inviteCode: 'INV123');
        when(() => roomRepository.watchRoom('inv1'))
            .thenAnswer((_) => Stream.value(room));
        when(() => roomRepository.joinRoomByCode('INV123',
                password: any(named: 'password')))
            .thenThrow(const RoomException('Room is full.'));

        await pumpInvitationPage(tester);

        // Room content loaded — Join button is available (no initial spinner).
        final joinButton = find.widgetWithText(GradientButton, 'Join Room');
        expect(joinButton, findsOneWidget);

        await tester.tap(joinButton);
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // The error surfaced and the button is interactive again — no
        // infinite loading indicator anywhere.
        expect(find.text('Room is full.'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.widgetWithText(GradientButton, 'Join Room'), findsOneWidget);
      });
    });

    testWidgets('join success navigates to the lobby and clears the spinner', (tester) async {
      await helpers.runWithFakeHttp(() async {
        final room = helpers.testRoom(id: 'inv1', inviteCode: 'INV123');
        when(() => roomRepository.watchRoom('inv1'))
            .thenAnswer((_) => Stream.value(room));
        when(() => roomRepository.joinRoomByCode('INV123',
                password: any(named: 'password')))
            .thenAnswer((_) async => room);

        await pumpInvitationPage(tester);

        await tester.tap(find.widgetWithText(GradientButton, 'Join Room'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(find.text('LOBBY_STUB'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });
    });
  });

  group('Ticket 2: spectator watching a live game', () {
    Future<void> pumpSpectatorGame(WidgetTester tester, GameCubit cubit) async {
      await tester.binding.setSurfaceSize(const Size(914, 411));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      addTearDown(() async {
        await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      });

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => BlocProvider<GameCubit>.value(
              value: cubit,
              child: const HtmlGamePlayPage(id: 'g1', isSpectator: true),
            ),
          ),
        ],
      );

      await tester.pumpWidget(_shell(
        router: router,
        repoProviders: [
          RepositoryProvider<AgoraService>(create: (_) => agoraService),
          RepositoryProvider<AudioService>(create: (_) => audioService),
        ],
      ));
    }

    testWidgets('watching a live game loads without the no-access error', (tester) async {
      when(() => gameRepository.watchGameAsSpectator('g1'))
          .thenAnswer((_) => Stream.value(helpers.testGame()));
      when(() => roomRepository.updatePlayerMediaState(any(),
              isMicOn: any(named: 'isMicOn'), isCameraOn: any(named: 'isCameraOn')))
          .thenAnswer((_) async {});

      final cubit = GameCubit(
        gameRepository: gameRepository,
        roomRepository: roomRepository,
        agoraService: agoraService,
        audioService: audioService,
      )..watchGameAsSpectator('g1');

      await pumpSpectatorGame(tester, cubit);
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 3));

      expect(find.byType(WebViewWidget), findsOneWidget);
      expect(find.text('Failed to load game'), findsNothing);
      expect(
        find.text("You don't have access to watch this game."),
        findsNothing,
      );
      expect(cubit.state, isA<GamePlaying>());
    });

    testWidgets('a real permission denial shows the specific message, not a spinner', (tester) async {
      // Emit the denial asynchronously, like a real Firestore stream, so the
      // page's BlocListener is attached by the time the error arrives.
      Stream<Game> denialStream() async* {
        await Future<void>.delayed(Duration.zero);
        throw FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied');
      }
      when(() => gameRepository.watchGameAsSpectator('g1'))
          .thenAnswer((_) => denialStream());

      final cubit = GameCubit(
        gameRepository: gameRepository,
        roomRepository: roomRepository,
        agoraService: agoraService,
        audioService: audioService,
      );

      await pumpSpectatorGame(tester, cubit);
      // Let the real-time denial stream fire, the listener mark the error,
      // and the translations finish loading before asserting on text.
      cubit.watchGameAsSpectator('g1');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(seconds: 2));

      // The user sees the meaningful access message immediately instead of an
      // endless "Starting game..." spinner.
      expect(
        find.text("You don't have access to watch this game."),
        findsOneWidget,
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(cubit.state, isA<GameError>());
    });
  });
}
