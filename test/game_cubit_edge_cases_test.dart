import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bloot/core/services/agora_service.dart';
import 'package:bloot/core/services/audio_service.dart';
import 'package:bloot/features/game/domain/entities/game.dart';
import 'package:bloot/features/game/domain/repositories/game_repository.dart';
import 'package:bloot/features/game/presentation/cubit/game_cubit.dart';
import 'package:bloot/features/game/presentation/cubit/game_state.dart';
import 'package:bloot/features/room/domain/repositories/room_repository.dart';

import 'helpers/test_helpers.dart';

void main() {
  setUpAll(setupWidgetTests);

  late MockGameRepository gameRepository;
  late MockRoomRepository roomRepository;
  late MockAgoraService agoraService;
  late MockAudioService audioService;

  setUp(() {
    gameRepository = MockGameRepository();
    roomRepository = MockRoomRepository();
    agoraService = MockAgoraService();
    audioService = MockAudioService();
    stubAgoraServiceDefaults(agoraService);
  });

  GameCubit buildCubit() => GameCubit(
    gameRepository: gameRepository,
    roomRepository: roomRepository,
    agoraService: agoraService,
    audioService: audioService,
  );

  group('claimBonuses', () {
    blocTest<GameCubit, GameState>(
      'calls repository on success',
      build: () {
        when(
          () => gameRepository.claimBonuses('g1', any()),
        ).thenAnswer((_) async {});
        return buildCubit();
      },
      seed: () => GameState.bonusClaim(game: testGame(status: 'bonusClaim')),
      act: (cubit) => cubit.claimBonuses([
        {
          'type': 'seria',
          'cards': ['AH', 'KH'],
        },
      ]),
      verify: (_) {
        verify(() => gameRepository.claimBonuses('g1', any())).called(1);
      },
    );

    blocTest<GameCubit, GameState>(
      'emits action error on failure',
      build: () {
        when(
          () => gameRepository.claimBonuses('g1', any()),
        ).thenThrow(Exception('network'));
        return buildCubit();
      },
      seed: () => GameState.bonusClaim(game: testGame(status: 'bonusClaim')),
      act: (cubit) => cubit.claimBonuses([
        {
          'type': 'seria',
          'cards': ['AH'],
        },
      ]),
      expect: () => [
        isA<GameBonusClaim>().having(
          (s) => s.actionInProgress,
          'actionInProgress',
          true,
        ),
        isA<GameBonusClaim>().having(
          (s) => s.lastActionError,
          'error',
          'Failed to claim bonuses. Please try again.',
        ),
      ],
    );

    blocTest<GameCubit, GameState>(
      'does nothing when not in bonusClaim state',
      build: buildCubit,
      seed: () => GameState.playing(game: testGame()),
      act: (cubit) => cubit.claimBonuses([
        {'type': 'seria'},
      ]),
      verify: (_) {
        verifyNever(() => gameRepository.claimBonuses(any(), any()));
      },
    );
  });

  group('dealNextRound', () {
    blocTest<GameCubit, GameState>(
      'calls repository on success',
      build: () {
        when(() => gameRepository.dealNextRound('g1')).thenAnswer((_) async {});
        return buildCubit();
      },
      seed: () => GameState.roundEnd(
        game: testGame(status: 'roundEnd'),
        teamAPoints: 80,
        teamBPoints: 40,
      ),
      act: (cubit) => cubit.dealNextRound(),
      verify: (_) {
        verify(() => gameRepository.dealNextRound('g1')).called(1);
      },
    );

    blocTest<GameCubit, GameState>(
      'emits action error on failure',
      build: () {
        when(
          () => gameRepository.dealNextRound('g1'),
        ).thenThrow(Exception('network'));
        return buildCubit();
      },
      seed: () => GameState.roundEnd(
        game: testGame(status: 'roundEnd'),
        teamAPoints: 80,
        teamBPoints: 40,
      ),
      act: (cubit) => cubit.dealNextRound(),
      expect: () => [
        isA<GameRoundEnd>().having(
          (s) => s.actionInProgress,
          'actionInProgress',
          true,
        ),
        isA<GameRoundEnd>().having(
          (s) => s.lastActionError,
          'error',
          'Failed to start next round. Please try again.',
        ),
      ],
    );

    blocTest<GameCubit, GameState>(
      'does nothing when not in roundEnd state',
      build: buildCubit,
      seed: () => GameState.playing(game: testGame()),
      act: (cubit) => cubit.dealNextRound(),
      verify: (_) {
        verifyNever(() => gameRepository.dealNextRound(any()));
      },
    );
  });

  group('declareProject', () {
    blocTest<GameCubit, GameState>(
      'calls repository on success',
      build: () {
        when(
          () => gameRepository.declareProject('g1', any()),
        ).thenAnswer((_) async {});
        return buildCubit();
      },
      seed: () => GameState.bidding(game: testGame(status: 'bidding')),
      act: (cubit) => cubit.declareProject(['baloot']),
      verify: (_) {
        verify(() => gameRepository.declareProject('g1', ['baloot'])).called(1);
      },
    );

    blocTest<GameCubit, GameState>(
      'emits action error on failure',
      build: () {
        when(
          () => gameRepository.declareProject('g1', any()),
        ).thenThrow(Exception('network'));
        return buildCubit();
      },
      seed: () => GameState.bidding(game: testGame(status: 'bidding')),
      act: (cubit) => cubit.declareProject(['baloot']),
      expect: () => [
        isA<GameBidding>().having(
          (s) => s.actionInProgress,
          'actionInProgress',
          true,
        ),
        isA<GameBidding>().having(
          (s) => s.lastActionError,
          'error',
          'Failed to declare project. Please try again.',
        ),
      ],
    );
  });

  group('applyDouble', () {
    blocTest<GameCubit, GameState>(
      'calls repository on success',
      build: () {
        when(
          () => gameRepository.applyDouble('g1', 'double'),
        ).thenAnswer((_) async {});
        return buildCubit();
      },
      seed: () => GameState.playing(game: testGame()),
      act: (cubit) => cubit.applyDouble('double'),
      verify: (_) {
        verify(() => gameRepository.applyDouble('g1', 'double')).called(1);
      },
    );

    blocTest<GameCubit, GameState>(
      'emits action error on failure',
      build: () {
        when(
          () => gameRepository.applyDouble('g1', 'double'),
        ).thenThrow(Exception('network'));
        return buildCubit();
      },
      seed: () => GameState.playing(game: testGame()),
      act: (cubit) => cubit.applyDouble('double'),
      expect: () => [
        isA<GamePlaying>().having(
          (s) => s.actionInProgress,
          'actionInProgress',
          true,
        ),
        isA<GamePlaying>().having(
          (s) => s.lastActionError,
          'error',
          'Failed to apply double. Please try again.',
        ),
      ],
    );
  });

  group('claimQaid', () {
    blocTest<GameCubit, GameState>(
      'calls repository on success',
      build: () {
        when(
          () => gameRepository.claimQaid('g1', any()),
        ).thenAnswer((_) async {});
        return buildCubit();
      },
      seed: () => GameState.playing(game: testGame()),
      act: (cubit) => cubit.claimQaid('violation'),
      verify: (_) {
        verify(() => gameRepository.claimQaid('g1', 'violation')).called(1);
      },
    );

    blocTest<GameCubit, GameState>(
      'calls repository with null claimType',
      build: () {
        when(
          () => gameRepository.claimQaid('g1', any()),
        ).thenAnswer((_) async {});
        return buildCubit();
      },
      seed: () => GameState.playing(game: testGame()),
      act: (cubit) => cubit.claimQaid(null),
      verify: (_) {
        verify(() => gameRepository.claimQaid('g1', null)).called(1);
      },
    );

    blocTest<GameCubit, GameState>(
      'emits action error on failure',
      build: () {
        when(
          () => gameRepository.claimQaid('g1', any()),
        ).thenThrow(Exception('network'));
        return buildCubit();
      },
      seed: () => GameState.playing(game: testGame()),
      act: (cubit) => cubit.claimQaid('violation'),
      expect: () => [
        isA<GamePlaying>().having(
          (s) => s.actionInProgress,
          'actionInProgress',
          true,
        ),
        isA<GamePlaying>().having(
          (s) => s.lastActionError,
          'error',
          'Failed to claim qaid. Please try again.',
        ),
      ],
    );
  });

  group('claimSawa', () {
    blocTest<GameCubit, GameState>(
      'calls repository on success',
      build: () {
        when(() => gameRepository.claimSawa('g1')).thenAnswer((_) async {});
        return buildCubit();
      },
      seed: () => GameState.playing(game: testGame()),
      act: (cubit) => cubit.claimSawa(),
      verify: (_) {
        verify(() => gameRepository.claimSawa('g1')).called(1);
      },
    );

    blocTest<GameCubit, GameState>(
      'emits action error on failure',
      build: () {
        when(
          () => gameRepository.claimSawa('g1'),
        ).thenThrow(Exception('network'));
        return buildCubit();
      },
      seed: () => GameState.playing(game: testGame()),
      act: (cubit) => cubit.claimSawa(),
      expect: () => [
        isA<GamePlaying>().having(
          (s) => s.actionInProgress,
          'actionInProgress',
          true,
        ),
        isA<GamePlaying>().having(
          (s) => s.lastActionError,
          'error',
          'Failed to claim sawa. Please try again.',
        ),
      ],
    );
  });

  group('hideControls', () {
    blocTest<GameCubit, GameState>(
      'sets controlsVisible to false',
      build: buildCubit,
      seed: () => GameState.playing(game: testGame()),
      act: (cubit) => cubit.hideControls(),
      expect: () => [
        isA<GamePlaying>().having(
          (s) => s.controlsVisible,
          'controlsVisible',
          false,
        ),
      ],
    );

    blocTest<GameCubit, GameState>(
      'does nothing when in initial state',
      build: buildCubit,
      act: (cubit) => cubit.hideControls(),
      expect: () => const <GameState>[],
    );
  });

  group('clearLastActionError', () {
    blocTest<GameCubit, GameState>(
      'sets lastActionError to null',
      build: buildCubit,
      seed: () =>
          GameState.playing(game: testGame(), lastActionError: 'Some error'),
      act: (cubit) => cubit.clearLastActionError(),
      expect: () => [
        isA<GamePlaying>().having(
          (s) => s.lastActionError,
          'lastActionError',
          isNull,
        ),
      ],
    );
  });

  group('emitActionError', () {
    blocTest<GameCubit, GameState>(
      'sets actionInProgress false and lastActionError message',
      build: buildCubit,
      seed: () => GameState.playing(game: testGame()),
      act: (cubit) => cubit.emitActionError('Custom error'),
      expect: () => [
        isA<GamePlaying>().having(
          (s) => s.lastActionError,
          'error',
          'Custom error',
        ),
      ],
    );
  });

  group('placeBid works from non-bidding state', () {
    blocTest<GameCubit, GameState>(
      'placeBid succeeds even when in playing state (uses _currentGame)',
      build: () {
        when(
          () => gameRepository.placeBid('g1', 'sun'),
        ).thenAnswer((_) async {});
        return buildCubit();
      },
      seed: () => GameState.playing(game: testGame()),
      act: (cubit) => cubit.placeBid('sun'),
      verify: (_) {
        verify(() => gameRepository.placeBid('g1', 'sun')).called(1);
      },
    );
  });

  group('playCard works from non-playing state', () {
    blocTest<GameCubit, GameState>(
      'playCard succeeds even when in bidding state (uses _currentGame)',
      build: () {
        when(
          () => gameRepository.playCard('g1', 'AH'),
        ).thenAnswer((_) async {});
        return buildCubit();
      },
      seed: () => GameState.bidding(game: testGame(status: 'bidding')),
      act: (cubit) => cubit.playCard('AH'),
      verify: (_) {
        verify(() => gameRepository.playCard('g1', 'AH')).called(1);
      },
    );
  });

  group('Game signature deduplication', () {
    StreamController<Game>? controller;

    blocTest<GameCubit, GameState>(
      'identical game state emitted twice produces only one emit',
      build: () {
        controller = StreamController<Game>();
        addTearDown(() async => controller!.close());
        when(
          () => gameRepository.watchGame('g1'),
        ).thenAnswer((_) => controller!.stream);
        return buildCubit();
      },
      act: (cubit) async {
        cubit.watchGame('g1');
        await Future<void>.delayed(Duration.zero);
        final g = testGame();
        controller!.add(g);
        await Future<void>.delayed(Duration.zero);
        // Same signature → should be deduplicated
        controller!.add(g);
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => [const GameState.loading(), isA<GamePlaying>()],
    );
  });

  group('bonusClaim status', () {
    blocTest<GameCubit, GameState>(
      'emits GameBonusClaim when status is bonusClaim',
      build: () {
        when(
          () => gameRepository.watchGame('g1'),
        ).thenAnswer((_) => Stream.value(testGame(status: 'bonusClaim')));
        return buildCubit();
      },
      act: (cubit) => cubit.watchGame('g1'),
      expect: () => [const GameState.loading(), isA<GameBonusClaim>()],
    );
  });

  group('roundEnd with fellTeam', () {
    blocTest<GameCubit, GameState>(
      'emits GameRoundEnd with fellTeam value',
      build: () {
        when(() => gameRepository.watchGame('g1')).thenAnswer(
          (_) => Stream.value(
            testGame(status: 'roundEnd').copyWith(fellTeam: 'B'),
          ),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.watchGame('g1'),
      expect: () => [
        const GameState.loading(),
        isA<GameRoundEnd>().having((s) => s.fellTeam, 'fellTeam', 'B'),
      ],
    );
  });

  group('leaveGame error handling', () {
    blocTest<GameCubit, GameState>(
      'emits action error when leaveRoom throws',
      build: () {
        when(
          () => gameRepository.watchGame('g1'),
        ).thenAnswer((_) => Stream.value(testGame()));
        when(
          () => roomRepository.leaveRoom('r1'),
        ).thenThrow(Exception('network'));
        return buildCubit();
      },
      act: (cubit) async {
        cubit.watchGame('g1');
        await Future<void>.delayed(Duration.zero);
        await cubit.leaveGame();
      },
      skip: 3,
      expect: () => [
        isA<GamePlaying>().having(
          (s) => s.lastActionError,
          'error',
          'Failed to leave game. Please try again.',
        ),
      ],
    );
  });

  group('toggleMic error in game', () {
    blocTest<GameCubit, GameState>(
      'emits action error when AgoraService throws',
      build: () {
        when(
          () => gameRepository.watchGame('g1'),
        ).thenAnswer((_) => Stream.value(testGame()));
        when(
          () => agoraService.toggleMic(),
        ).thenThrow(Exception('Agora error'));
        return buildCubit();
      },
      act: (cubit) async {
        cubit.watchGame('g1');
        await Future<void>.delayed(Duration.zero);
        await cubit.toggleMic();
      },
      skip: 2,
      expect: () => [
        isA<GamePlaying>().having(
          (s) => s.lastActionError,
          'error',
          'Failed to toggle microphone.',
        ),
      ],
    );
  });

  group('toggleCamera error in game', () {
    blocTest<GameCubit, GameState>(
      'emits action error when AgoraService throws',
      build: () {
        when(
          () => gameRepository.watchGame('g1'),
        ).thenAnswer((_) => Stream.value(testGame()));
        when(
          () => agoraService.toggleCamera(),
        ).thenThrow(Exception('Agora error'));
        return buildCubit();
      },
      act: (cubit) async {
        cubit.watchGame('g1');
        await Future<void>.delayed(Duration.zero);
        await cubit.toggleCamera();
      },
      skip: 2,
      expect: () => [
        isA<GamePlaying>().having(
          (s) => s.lastActionError,
          'error',
          'Failed to toggle camera.',
        ),
      ],
    );
  });

  group('rematch error', () {
    blocTest<GameCubit, GameState>(
      'emits action error when repository throws',
      build: () {
        when(
          () => gameRepository.rematch('r1'),
        ).thenThrow(Exception('network'));
        return buildCubit();
      },
      seed: () => GameState.gameEnd(
        game: testGame(status: 'gameEnd'),
        winnerTeam: 'A',
      ),
      act: (cubit) => cubit.rematch(),
      expect: () => [
        isA<GameGameEnd>().having(
          (s) => s.actionInProgress,
          'actionInProgress',
          true,
        ),
        isA<GameGameEnd>().having(
          (s) => s.lastActionError,
          'error',
          'Failed to rematch. Please try again.',
        ),
      ],
    );
  });

  group('loadGame alias', () {
    blocTest<GameCubit, GameState>(
      'loadGame calls same path as watchGame',
      build: () {
        when(
          () => gameRepository.watchGame('g1'),
        ).thenAnswer((_) => Stream.value(testGame()));
        return buildCubit();
      },
      act: (cubit) => cubit.loadGame('g1'),
      expect: () => [const GameState.loading(), isA<GamePlaying>()],
      verify: (_) {
        verify(() => gameRepository.watchGame('g1')).called(1);
      },
    );
  });

  group('watchGameAsSpectator with no agoraChannelName', () {
    blocTest<GameCubit, GameState>(
      'does not join Agora when channel name is null',
      build: () {
        when(
          () => gameRepository.watchGameAsSpectator('g1'),
        ).thenAnswer((_) => Stream.value(testGame(agoraChannelName: null)));
        return buildCubit();
      },
      act: (cubit) => cubit.watchGameAsSpectator('g1'),
      expect: () => [const GameState.loading(), isA<GamePlaying>()],
      verify: (_) {
        verifyNever(
          () => agoraService.joinChannel(
            channelName: any(named: 'channelName'),
            agoraUid: any(named: 'agoraUid'),
            subscribeVideo: any(named: 'subscribeVideo'),
          ),
        );
      },
    );
  });

  group('placeBid does nothing when no current game', () {
    blocTest<GameCubit, GameState>(
      'does nothing when in initial state',
      build: buildCubit,
      act: (cubit) => cubit.placeBid('sun'),
      expect: () => const <GameState>[],
      verify: (_) {
        verifyNever(() => gameRepository.placeBid(any(), any()));
      },
    );
  });

  group('playCard does nothing when no current game', () {
    blocTest<GameCubit, GameState>(
      'does nothing when in initial state',
      build: buildCubit,
      act: (cubit) => cubit.playCard('AH'),
      expect: () => const <GameState>[],
      verify: (_) {
        verifyNever(() => gameRepository.playCard(any(), any()));
      },
    );
  });

  group('toggleMic does nothing when no roomId', () {
    blocTest<GameCubit, GameState>(
      'does nothing when game has no roomId',
      build: () {
        when(
          () => gameRepository.watchGame('g1'),
        ).thenAnswer((_) => Stream.value(testGame(roomId: null)));
        return buildCubit();
      },
      act: (cubit) async {
        cubit.watchGame('g1');
        await Future<void>.delayed(Duration.zero);
        await cubit.toggleMic();
      },
      skip: 2,
      verify: (_) {
        verifyNever(() => agoraService.toggleMic());
      },
    );
  });

  group('roundEnd sound plays on transition', () {
    StreamController<Game>? controller;

    blocTest<GameCubit, GameState>(
      'roundEnd sound plays when transitioning from playing to roundEnd',
      build: () {
        controller = StreamController<Game>();
        addTearDown(() async => controller!.close());
        when(
          () => gameRepository.watchGame('g1'),
        ).thenAnswer((_) => controller!.stream);
        when(() => audioService.playRoundEndSound()).thenAnswer((_) async {});
        return buildCubit();
      },
      act: (cubit) async {
        cubit.watchGame('g1');
        await Future<void>.delayed(Duration.zero);
        final g = testGame();
        controller!.add(g.copyWith(status: 'playing'));
        await Future<void>.delayed(Duration.zero);
        controller!.add(g.copyWith(status: 'roundEnd'));
        await Future<void>.delayed(Duration.zero);
      },
      verify: (_) {
        verify(() => audioService.playRoundEndSound()).called(1);
      },
    );
  });
}
