import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bloot/core/services/agora_service.dart';
import 'package:bloot/core/services/audio_service.dart';
import 'package:bloot/features/game/data/models/game_model.dart';
import 'package:bloot/features/game/domain/entities/game.dart';
import 'package:bloot/features/game/domain/repositories/game_repository.dart';
import 'package:bloot/features/game/presentation/cubit/game_cubit.dart';
import 'package:bloot/features/game/presentation/cubit/game_state.dart';
import 'package:bloot/features/room/domain/repositories/room_repository.dart';

class MockGameRepository extends Mock implements GameRepository {}

class MockRoomRepository extends Mock implements RoomRepository {}

class MockAgoraService extends Mock implements AgoraService {}

class MockAudioService extends Mock implements AudioService {}

void main() {
  late MockGameRepository mockRepository;
  late MockRoomRepository mockRoomRepository;
  late MockAgoraService mockAgoraService;
  late MockAudioService mockAudioService;

  setUp(() {
    mockRepository = MockGameRepository();
    mockRoomRepository = MockRoomRepository();
    mockAgoraService = MockAgoraService();
    mockAudioService = MockAudioService();
  });

  group('GameCubit', () {
    const testGame = Game(
      id: 'g1',
      players: [
        GamePlayer(uid: 'p0', name: 'Player0', avatarUrl: '', team: 'A', seatIndex: 0),
        GamePlayer(uid: 'p1', name: 'Player1', avatarUrl: '', team: 'B', seatIndex: 1),
        GamePlayer(uid: 'p2', name: 'Player2', avatarUrl: '', team: 'A', seatIndex: 2),
        GamePlayer(uid: 'p3', name: 'Player3', avatarUrl: '', team: 'B', seatIndex: 3),
      ],
      myHand: ['AH', 'KH', 'QH'],
      mySeatIndex: 0,
      playedCards: [null, null, null, null],
      scoreUs: 10,
      scoreThem: 20,
      teamAScore: 10,
      teamBScore: 20,
      trump: 'hearts',
      status: 'bidding',
      turnIndex: 0,
      currentRound: 1,
      targetScore: 152,
    );

    blocTest<GameCubit, GameState>(
      'emits [loading, bidding] when watchGame succeeds',
      build: () {
        when(() => mockRepository.watchGame('g1')).thenAnswer(
          (_) => Stream.value(testGame),
        );
        return GameCubit(
          gameRepository: mockRepository,
          roomRepository: mockRoomRepository,
          agoraService: mockAgoraService,
          audioService: mockAudioService,
        );
      },
      act: (cubit) => cubit.watchGame('g1'),
      expect: () => [
        const GameState.loading(),
        isA<GameBidding>(),
      ],
    );

    blocTest<GameCubit, GameState>(
      'emits [loading, playing] when game status is playing',
      build: () {
        final playingGame = testGame.copyWith(status: 'playing');
        when(() => mockRepository.watchGame('g1')).thenAnswer(
          (_) => Stream.value(playingGame),
        );
        return GameCubit(
          gameRepository: mockRepository,
          roomRepository: mockRoomRepository,
          agoraService: mockAgoraService,
          audioService: mockAudioService,
        );
      },
      act: (cubit) => cubit.watchGame('g1'),
      expect: () => [
        const GameState.loading(),
        isA<GamePlaying>(),
      ],
    );

    blocTest<GameCubit, GameState>(
      'emits [loading, gameEnd] when game status is gameEnd',
      build: () {
        final endGame = testGame.copyWith(status: 'gameEnd');
        when(() => mockRepository.watchGame('g1')).thenAnswer(
          (_) => Stream.value(endGame),
        );
        return GameCubit(
          gameRepository: mockRepository,
          roomRepository: mockRoomRepository,
          agoraService: mockAgoraService,
          audioService: mockAudioService,
        );
      },
      act: (cubit) => cubit.watchGame('g1'),
      expect: () => [
        const GameState.loading(),
        isA<GameGameEnd>(),
      ],
    );

    blocTest<GameCubit, GameState>(
      'placeBid calls repository.placeBid',
      build: () {
        when(() => mockRepository.placeBid('g1', 'sun')).thenAnswer((_) async {});
        return GameCubit(
          gameRepository: mockRepository,
          roomRepository: mockRoomRepository,
          agoraService: mockAgoraService,
          audioService: mockAudioService,
        );
      },
      seed: () => const GameState.bidding(game: testGame),
      act: (cubit) => cubit.placeBid('sun'),
      verify: (_) {
        verify(() => mockRepository.placeBid('g1', 'sun')).called(1);
      },
    );

    blocTest<GameCubit, GameState>(
      'playCard calls repository.playCard',
      build: () {
        when(() => mockRepository.playCard('g1', 'AH')).thenAnswer((_) async {});
        return GameCubit(
          gameRepository: mockRepository,
          roomRepository: mockRoomRepository,
          agoraService: mockAgoraService,
          audioService: mockAudioService,
        );
      },
      seed: () => const GameState.playing(game: testGame),
      act: (cubit) => cubit.playCard('AH'),
      verify: (_) {
        verify(() => mockRepository.playCard('g1', 'AH')).called(1);
      },
    );

    blocTest<GameCubit, GameState>(
      'toggleControls toggles visibility',
      build: () => GameCubit(
        gameRepository: mockRepository,
        roomRepository: mockRoomRepository,
        agoraService: mockAgoraService,
        audioService: mockAudioService,
      ),
      seed: () => const GameState.bidding(game: testGame),
      act: (cubit) => cubit.toggleControls(),
      expect: () => [
        isA<GameBidding>().having((s) => s.controlsVisible, 'controlsVisible', false),
      ],
    );

    blocTest<GameCubit, GameState>(
      'selectCard updates selected index',
      build: () => GameCubit(
        gameRepository: mockRepository,
        roomRepository: mockRoomRepository,
        agoraService: mockAgoraService,
        audioService: mockAudioService,
      ),
      seed: () => const GameState.bidding(game: testGame),
      act: (cubit) => cubit.selectCard(2),
      expect: () => [
        isA<GameBidding>().having((s) => s.selectedCardIndex, 'selectedCardIndex', 2),
      ],
    );

    blocTest<GameCubit, GameState>(
      'emits winnerTeam A when team A has higher absolute score',
      build: () {
        final endGame = testGame.copyWith(
          status: 'gameEnd',
          teamAScore: 160,
          teamBScore: 100,
          scoreUs: 160,
          scoreThem: 100,
        );
        when(() => mockRepository.watchGame('g1')).thenAnswer(
          (_) => Stream.value(endGame),
        );
        return GameCubit(
          gameRepository: mockRepository,
          roomRepository: mockRoomRepository,
          agoraService: mockAgoraService,
          audioService: mockAudioService,
        );
      },
      act: (cubit) => cubit.watchGame('g1'),
      expect: () => [
        const GameState.loading(),
        isA<GameGameEnd>().having((s) => s.winnerTeam, 'winnerTeam', 'A'),
      ],
    );

    blocTest<GameCubit, GameState>(
      'emits winnerTeam B when local player is on team B and team B wins',
      build: () {
        final endGame = testGame.copyWith(
          status: 'gameEnd',
          players: [
            const GamePlayer(uid: 'p0', name: 'Player0', avatarUrl: '', team: 'B', seatIndex: 0),
            const GamePlayer(uid: 'p1', name: 'Player1', avatarUrl: '', team: 'A', seatIndex: 1),
            const GamePlayer(uid: 'p2', name: 'Player2', avatarUrl: '', team: 'B', seatIndex: 2),
            const GamePlayer(uid: 'p3', name: 'Player3', avatarUrl: '', team: 'A', seatIndex: 3),
          ],
          mySeatIndex: 0,
          teamAScore: 100,
          teamBScore: 160,
          scoreUs: 160,
          scoreThem: 100,
        );
        when(() => mockRepository.watchGame('g1')).thenAnswer(
          (_) => Stream.value(endGame),
        );
        return GameCubit(
          gameRepository: mockRepository,
          roomRepository: mockRoomRepository,
          agoraService: mockAgoraService,
          audioService: mockAudioService,
        );
      },
      act: (cubit) => cubit.watchGame('g1'),
      expect: () => [
        const GameState.loading(),
        isA<GameGameEnd>().having((s) => s.winnerTeam, 'winnerTeam', 'B'),
      ],
    );

    blocTest<GameCubit, GameState>(
      'emits action error when placeBid fails',
      build: () {
        when(() => mockRepository.placeBid('g1', 'sun')).thenThrow(Exception('network'));
        return GameCubit(
          gameRepository: mockRepository,
          roomRepository: mockRoomRepository,
          agoraService: mockAgoraService,
          audioService: mockAudioService,
        );
      },
      seed: () => const GameState.bidding(game: testGame),
      act: (cubit) => cubit.placeBid('sun'),
      expect: () => [
        isA<GameBidding>().having((s) => s.actionInProgress, 'actionInProgress', true),
        isA<GameBidding>().having(
          (s) => s.lastActionError,
          'lastActionError',
          'Failed to place bid. Please try again.',
        ),
      ],
    );

    blocTest<GameCubit, GameState>(
      'retries when the game doc is not created yet, then loads',
      build: () {
        var calls = 0;
        when(() => mockRepository.watchGame('g1')).thenAnswer((_) {
          calls++;
          if (calls == 1) {
            return Stream<Game>.error(Exception('Game not found'));
          }
          return Stream.value(testGame);
        });
        return GameCubit(
          gameRepository: mockRepository,
          roomRepository: mockRoomRepository,
          agoraService: mockAgoraService,
          audioService: mockAudioService,
          notFoundRetryDelay: const Duration(milliseconds: 50),
        );
      },
      act: (cubit) => cubit.watchGame('g1'),
      wait: const Duration(milliseconds: 300),
      expect: () => [
        const GameState.loading(),
        isA<GameBidding>(),
      ],
      verify: (_) {
        verify(() => mockRepository.watchGame('g1')).called(2);
      },
    );

    blocTest<GameCubit, GameState>(
      'emits error after exhausting not-found retries',
      build: () {
        when(() => mockRepository.watchGame('g1')).thenAnswer(
          (_) => Stream<Game>.error(Exception('Game not found')),
        );
        return GameCubit(
          gameRepository: mockRepository,
          roomRepository: mockRoomRepository,
          agoraService: mockAgoraService,
          audioService: mockAudioService,
          notFoundRetryDelay: const Duration(milliseconds: 50),
          maxNotFoundRetries: 2,
        );
      },
      act: (cubit) => cubit.watchGame('g1'),
      wait: const Duration(milliseconds: 400),
      expect: () => [
        const GameState.loading(),
        isA<GameError>(),
      ],
      verify: (_) {
        verify(() => mockRepository.watchGame('g1')).called(3);
      },
    );

    test('GameModel.toEntity remaps team scores to local perspective', () {
      const model = GameModel(
        id: 'g1',
        players: [
          GamePlayerModel(uid: 'p0', name: 'A', avatarUrl: '', team: 'A', seatIndex: 0),
          GamePlayerModel(uid: 'p1', name: 'B', avatarUrl: '', team: 'B', seatIndex: 1, hand: ['AH']),
        ],
        myHand: [],
        mySeatIndex: 1,
        playedCards: [null, null],
        scoreUs: 0,
        scoreThem: 0,
        teamAScore: 80,
        teamBScore: 120,
        trump: 'H',
        status: 'playing',
        turnIndex: 0,
        currentRound: 1,
        targetScore: 152,
      );

      final entity = model.toEntity();
      expect(entity.mySeatIndex, 1);
      expect(entity.scoreUs, 120); // local team B
      expect(entity.scoreThem, 80);
      expect(entity.teamAScore, 80);
      expect(entity.teamBScore, 120);
    });
  });
}
