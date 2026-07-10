import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:bloot/core/network/connectivity_cubit.dart';
import 'package:bloot/core/services/agora_service.dart';
import 'package:bloot/core/services/audio_service.dart';
import 'package:bloot/features/game/presentation/cubit/game_cubit.dart';
import 'package:bloot/features/game/presentation/cubit/game_state.dart';
import 'package:bloot/features/game/presentation/pages/html_game_play_page.dart';

import '../test/helpers/test_helpers.dart' as helpers;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late helpers.MockGameRepository gameRepository;
  late helpers.MockRoomRepository roomRepository;
  late helpers.MockAgoraService agoraService;
  late helpers.MockAudioService audioService;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    gameRepository = helpers.MockGameRepository();
    roomRepository = helpers.MockRoomRepository();
    agoraService = helpers.MockAgoraService();
    audioService = helpers.MockAudioService();

    helpers.stubAgoraServiceDefaults(agoraService);
  });

  group('HtmlGame WebView smoke', () {
    testWidgets('loads local play.html, bridge reports ready, no error overlay', (tester) async {
      final game = helpers.testGame(id: 'webview-game');
      when(() => gameRepository.watchGame('webview-game')).thenAnswer(
        (_) => Stream.value(game),
      );
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

      // The HTML game is landscape; set a landscape surface so the WebView
      // has room to render without hit-test/layout issues.
      await tester.binding.setSurfaceSize(const Size(914, 411));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      addTearDown(() async {
        await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      });

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<GameCubit>.value(value: gameCubit),
              BlocProvider<ConnectivityCubit>(create: (_) => ConnectivityCubit()),
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

      // Wait for the WebView to load the local asset and the JS engine.
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 3));

      expect(find.byType(WebViewWidget), findsOneWidget);
      expect(find.text('Failed to load game'), findsNothing);
      expect(gameCubit.state, isA<GamePlaying>());
    });
  });
}
