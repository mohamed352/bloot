import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bloot/features/game/domain/entities/game.dart';
import 'package:bloot/features/game/domain/repositories/game_repository.dart';
import 'package:bloot/features/game/presentation/cubit/game_cubit.dart';
import 'package:bloot/features/game/presentation/cubit/local_game_simulator.dart';
import 'package:bloot/core/services/agora_service.dart';
import 'package:bloot/core/style/app_colors.dart';
import 'package:bloot/core/services/audio_service.dart';
import 'package:bloot/core/network/connectivity_cubit.dart';
import 'package:bloot/features/game/presentation/pages/game_play_page.dart';
import 'package:bloot/features/game/presentation/widgets/playing_card/playing_card.dart';
import 'package:bloot/features/room/domain/repositories/room_repository.dart';

class MockGameRepository extends Mock implements GameRepository {}

class MockRoomRepository extends Mock implements RoomRepository {}

class MockAudioService extends Mock implements AudioService {}

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
  Stream<AgoraAudioVolumeIndicationEvent> get onAudioVolumeIndication =>
      const Stream.empty();

  @override
  Widget getLocalVideoView({VideoSourceType? sourceType}) =>
      const SizedBox.shrink();

  @override
  Widget getRemoteVideoView(int remoteUid) => const SizedBox.shrink();
}

class _FakeHttpClient extends Fake implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    return _FakeHttpClientRequest();
  }
}

class _FakeHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  HttpHeaders get headers => _FakeHttpHeaders();

  @override
  Future<HttpClientResponse> close() async {
    return _FakeHttpClientResponse();
  }
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

/// A minimal asset loader that returns an empty map.
class _TestAssetLoader extends AssetLoader {
  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return <String, dynamic>{
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
    };
  }
}

void main() {
  late MockGameRepository mockRepository;
  late MockRoomRepository mockRoomRepository;
  late MockAgoraService mockAgoraService;
  late GameCubit cubit;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({'game_tutorial_seen': true});
    EasyLocalization.logger.enableBuildModes = [];
    await EasyLocalization.ensureInitialized();
  });

  setUp(() {
    mockRepository = MockGameRepository();
    mockRoomRepository = MockRoomRepository();
    mockAgoraService = MockAgoraService();
    cubit = GameCubit(
      gameRepository: mockRepository,
      roomRepository: mockRoomRepository,
      agoraService: mockAgoraService,
      audioService: MockAudioService(),
    );
  });

  tearDown(() {
    cubit.close();
  });

  Widget buildTestableWidget(Widget child) {
    return EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      assetLoader: _TestAssetLoader(),
      child: MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<GameCubit>.value(value: cubit),
            BlocProvider<ConnectivityCubit>(create: (_) => ConnectivityCubit()),
          ],
          child: MultiRepositoryProvider(
            providers: [
              RepositoryProvider<AgoraService>(create: (_) => mockAgoraService),
              RepositoryProvider<AudioService>(
                create: (_) => MockAudioService(),
              ),
            ],
            child: child,
          ),
        ),
      ),
    );
  }

  Future<void> runWithFakeHttp(Future<void> Function() testBody) async {
    await HttpOverrides.runZoned(
      testBody,
      createHttpClient: (_) => _FakeHttpClient(),
    );
  }

  group('GamePlayPage', () {
    const testGame = Game(
      id: 'g1',
      players: [
        GamePlayer(
          uid: 'p0',
          name: 'Khalid',
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
          name: 'You',
          avatarUrl: '',
          team: 'B',
          seatIndex: 3,
        ),
      ],
      myHand: [
        'AH',
        'KH',
        'QH',
        'JH',
        '10H',
        '9H',
        '8H',
        '7H',
        '6H',
        '5H',
        '4H',
        '3H',
        '2H',
      ],
      mySeatIndex: 3,
      playedCards: [null, null, null, null],
      scoreUs: 10,
      scoreThem: 20,
      teamAScore: 20,
      teamBScore: 10,
      trump: 'hearts',
      status: 'playing',
      turnIndex: 3,
      currentRound: 1,
      targetScore: 152,
    );

    testWidgets('renders without error in loading state', (tester) async {
      when(
        () => mockRepository.watchGame('g1'),
      ).thenAnswer((_) => const Stream.empty());

      cubit.watchGame('g1');
      await tester.pumpWidget(
        buildTestableWidget(const GamePlayPage(id: 'g1')),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Let the auto-hide timer fire
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('shows player names when playing', (tester) async {
      await runWithFakeHttp(() async {
        when(
          () => mockRepository.watchGame('g1'),
        ).thenAnswer((_) => Stream.value(testGame));

        cubit.watchGame('g1');
        await tester.pumpWidget(
          buildTestableWidget(const GamePlayPage(id: 'g1')),
        );
        await tester.pumpAndSettle();

        expect(find.text('You'), findsOneWidget);
        expect(find.text('Khalid'), findsOneWidget);
        expect(find.text('Faisal'), findsOneWidget);
        expect(find.text('Omar'), findsOneWidget);

        // Let the auto-hide timer fire
        await tester.pump(const Duration(seconds: 4));
      });
    });

    testWidgets('shows score numbers', (tester) async {
      await runWithFakeHttp(() async {
        when(
          () => mockRepository.watchGame('g1'),
        ).thenAnswer((_) => Stream.value(testGame));

        cubit.watchGame('g1');
        await tester.pumpWidget(
          buildTestableWidget(const GamePlayPage(id: 'g1')),
        );
        await tester.pumpAndSettle();

        // Score chip shows 10 and 20
        expect(find.text('10'), findsWidgets);
        expect(find.text('20'), findsWidgets);

        // Let the auto-hide timer fire
        await tester.pump(const Duration(seconds: 4));
      });
    });

    testWidgets('plays card on tap when it is my turn', (tester) async {
      await runWithFakeHttp(() async {
        when(
          () => mockRepository.watchGame('g1'),
        ).thenAnswer((_) => Stream.value(testGame));
        when(
          () => mockRepository.playCard('g1', 'AH'),
        ).thenAnswer((_) async {});

        cubit.watchGame('g1');
        await tester.pumpWidget(
          buildTestableWidget(const GamePlayPage(id: 'g1')),
        );
        await tester.pumpAndSettle();

        final cardFinder = find.byType(PlayingCardWidget);
        expect(cardFinder, findsWidgets);

        await tester.tap(cardFinder.first);
        await tester.pumpAndSettle();

        verify(() => mockRepository.playCard('g1', 'AH')).called(1);

        // Let the auto-hide timer fire
        await tester.pump(const Duration(seconds: 4));
      });
    });

    testWidgets('plays card on drag to table when it is my turn', (
      tester,
    ) async {
      await runWithFakeHttp(() async {
        when(
          () => mockRepository.watchGame('g1'),
        ).thenAnswer((_) => Stream.value(testGame));
        when(
          () => mockRepository.playCard('g1', 'AH'),
        ).thenAnswer((_) async {});

        cubit.watchGame('g1');
        await tester.pumpWidget(
          buildTestableWidget(const GamePlayPage(id: 'g1')),
        );
        await tester.pumpAndSettle();

        final cardFinder = find.byType(PlayingCardWidget);
        expect(cardFinder, findsWidgets);

        final cardRect = tester.getRect(cardFinder.first);
        final cardCenter = cardRect.center;

        // The game table is the only AspectRatio in the layout.
        final tableFinder = find.byType(AspectRatio);
        expect(tableFinder, findsOneWidget);
        final tableCenter = tester.getCenter(tableFinder);

        await tester.drag(
          cardFinder.first,
          tableCenter - cardCenter,
        );
        await tester.pumpAndSettle();

        verify(() => mockRepository.playCard('g1', 'AH')).called(1);

        // Let the auto-hide timer fire
        await tester.pump(const Duration(seconds: 4));
      });
    });
  });

  group('GamePlayPage with LocalGameSimulator', () {
    setUp(() {
      final getIt = GetIt.instance;
      getIt.registerSingleton<RoomRepository>(MockRoomRepository());
      getIt.registerSingleton<AgoraService>(mockAgoraService);
      getIt.registerSingleton<AudioService>(MockAudioService());
    });

    tearDown(() async {
      await GetIt.instance.reset();
    });

    Widget buildSimWidget() {
      return EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        assetLoader: _TestAssetLoader(),
        child: MaterialApp(
          theme: ThemeData.dark().copyWith(
            extensions: const <ThemeExtension<dynamic>>[AppColors.dark],
          ),
          home: MultiBlocProvider(
            providers: [
              BlocProvider<GameCubit>(
                create: (_) => LocalGameSimulator()..watchGame('sim_1'),
              ),
              BlocProvider<ConnectivityCubit>(
                create: (_) => ConnectivityCubit(),
              ),
            ],
            child: RepositoryProvider<AgoraService>(
              create: (_) => mockAgoraService,
              child: const GamePlayPage(id: 'sim_1'),
            ),
          ),
        ),
      );
    }

    testWidgets('renders dealing state and does not show camera loading', (
      tester,
    ) async {
      await runWithFakeHttp(() async {
        await tester.pumpWidget(buildSimWidget());
        await tester.pump();

        // Should be in loading/dealing state briefly.
        expect(find.byType(CircularProgressIndicator), findsNothing);

        // Wait for the microtask and the dealing state to be emitted.
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byType(CircularProgressIndicator), findsNothing);

        // Let the auto-hide timer fire.
        await tester.pump(const Duration(seconds: 4));
      });
    });
  });
}
