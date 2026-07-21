import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:bloot/core/services/agora_service.dart';
import 'package:bloot/features/game/domain/entities/game.dart';
import 'package:bloot/features/game/presentation/cubit/game_cubit.dart';
import 'package:bloot/features/game/presentation/cubit/game_state.dart';
import 'package:bloot/features/room/domain/entities/room.dart';
import 'package:bloot/features/room/domain/exceptions/room_exception.dart';
import 'package:bloot/features/room/presentation/cubit/room_cubit.dart';
import 'package:bloot/features/room/presentation/cubit/room_state.dart';

import 'helpers/test_helpers.dart';

/// Tests that simulate multi-user interactions (multiple players joining rooms,
/// speaking simultaneously, starting games, streaming, etc.) using mock
/// repositories and controlled streams. These replace the need for multiple
/// physical devices during development.
void main() {
  setUpAll(setupWidgetTests);

  // ===========================================================================
  // Room multi-user scenarios
  // ===========================================================================
  group('Room multi-user scenarios', () {
    late MockRoomRepository roomRepository;
    late MockAgoraService agoraService;
    late StreamController<Room> roomController;
    late StreamController<List<Room>> roomsController;

    setUp(() {
      roomRepository = MockRoomRepository();
      agoraService = MockAgoraService();
      stubAgoraServiceDefaults(agoraService);
      roomController = StreamController<Room>();
      roomsController = StreamController<List<Room>>();
    });

    tearDown(() {
      roomController.close();
      roomsController.close();
    });

    RoomCubit buildCubit() =>
        RoomCubit(roomRepository: roomRepository, agoraService: agoraService);

    blocTest<RoomCubit, RoomState>(
      'players join one by one via real-time stream updates',
      build: () {
        when(
          () => roomRepository.watchRoom('r1'),
        ).thenAnswer((_) => roomController.stream);
        return buildCubit();
      },
      act: (cubit) async {
        cubit.loadRoom('r1');
        await Future<void>.delayed(Duration.zero);
        roomController.add(
          testRoom(players: [testPlayer(name: 'Host', isMe: true)]),
        );
        await Future<void>.delayed(Duration.zero);
        roomController.add(
          testRoom(
            players: [
              testPlayer(name: 'Host', isMe: true),
              testPlayer(uid: 'u2', name: 'P2'),
            ],
          ),
        );
        await Future<void>.delayed(Duration.zero);
        roomController.add(
          testRoom(
            players: [
              testPlayer(name: 'Host', isMe: true),
              testPlayer(uid: 'u2', name: 'P2'),
              testPlayer(uid: 'u3', name: 'P3'),
            ],
          ),
        );
        await Future<void>.delayed(Duration.zero);
        roomController.add(
          testRoom(
            players: [
              testPlayer(name: 'Host', isMe: true),
              testPlayer(uid: 'u2', name: 'P2'),
              testPlayer(uid: 'u3', name: 'P3'),
              testPlayer(uid: 'u4', name: 'P4'),
            ],
          ),
        );
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => [
        const RoomState.loading(),
        isA<RoomLoaded>().having((s) => s.room.players.length, '1 player', 1),
        isA<RoomLoaded>().having((s) => s.room.players.length, '2 players', 2),
        isA<RoomLoaded>().having((s) => s.room.players.length, '3 players', 3),
        isA<RoomLoaded>().having((s) => s.room.players.length, '4 players', 4),
      ],
    );

    blocTest<RoomCubit, RoomState>(
      'players become ready one by one until all ready',
      build: () {
        when(
          () => roomRepository.watchRoom('r1'),
        ).thenAnswer((_) => roomController.stream);
        return buildCubit();
      },
      act: (cubit) async {
        cubit.loadRoom('r1');
        await Future<void>.delayed(Duration.zero);
        roomController.add(
          testRoom(
            players: [
              testPlayer(name: 'Me', isMe: true),
              testPlayer(uid: 'u2', name: 'P2'),
              testPlayer(uid: 'u3', name: 'P3'),
              testPlayer(uid: 'u4', name: 'P4'),
            ],
          ),
        );
        await Future<void>.delayed(Duration.zero);
        roomController.add(
          testRoom(
            players: [
              testPlayer(name: 'Me', isMe: true),
              testPlayer(uid: 'u2', name: 'P2', isReady: true),
              testPlayer(uid: 'u3', name: 'P3'),
              testPlayer(uid: 'u4', name: 'P4'),
            ],
          ),
        );
        await Future<void>.delayed(Duration.zero);
        roomController.add(
          testRoom(
            players: [
              testPlayer(name: 'Me', isMe: true),
              testPlayer(uid: 'u2', name: 'P2', isReady: true),
              testPlayer(uid: 'u3', name: 'P3', isReady: true),
              testPlayer(uid: 'u4', name: 'P4'),
            ],
          ),
        );
        await Future<void>.delayed(Duration.zero);
        roomController.add(
          testRoom(
            players: [
              testPlayer(name: 'Me', isMe: true, isReady: true),
              testPlayer(uid: 'u2', name: 'P2', isReady: true),
              testPlayer(uid: 'u3', name: 'P3', isReady: true),
              testPlayer(uid: 'u4', name: 'P4', isReady: true),
            ],
          ),
        );
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => [
        const RoomState.loading(),
        isA<RoomLoaded>().having(
          (s) => s.room.players.where((p) => p.isReady).length,
          'none ready',
          0,
        ),
        isA<RoomLoaded>().having(
          (s) => s.room.players.where((p) => p.isReady).length,
          '1 ready',
          1,
        ),
        isA<RoomLoaded>().having(
          (s) => s.room.players.where((p) => p.isReady).length,
          '2 ready',
          2,
        ),
        isA<RoomLoaded>().having(
          (s) => s.room.players.where((p) => p.isReady).length,
          'all ready',
          4,
        ),
      ],
    );

    blocTest<RoomCubit, RoomState>(
      'room transitions from waiting to playing triggers gameStarted',
      build: () {
        when(
          () => roomRepository.watchRoom('r1'),
        ).thenAnswer((_) => roomController.stream);
        return buildCubit();
      },
      act: (cubit) async {
        cubit.loadRoom('r1');
        await Future<void>.delayed(Duration.zero);
        roomController.add(
          testRoom(
            players: [
              testPlayer(name: 'Me', isMe: true, isReady: true),
              testPlayer(uid: 'u2', name: 'P2', isReady: true),
              testPlayer(uid: 'u3', name: 'P3', isReady: true),
              testPlayer(uid: 'u4', name: 'P4', isReady: true),
            ],
          ),
        );
        await Future<void>.delayed(Duration.zero);
        roomController.add(
          testRoom(
            status: RoomStatus.playing,
            gameId: 'g-multi',
            players: [
              testPlayer(name: 'Me', isMe: true, isReady: true),
              testPlayer(uid: 'u2', name: 'P2', isReady: true),
              testPlayer(uid: 'u3', name: 'P3', isReady: true),
              testPlayer(uid: 'u4', name: 'P4', isReady: true),
            ],
          ),
        );
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => [
        const RoomState.loading(),
        isA<RoomLoaded>(),
        isA<RoomGameStarted>().having((s) => s.gameId, 'gameId', 'g-multi'),
      ],
    );

    blocTest<RoomCubit, RoomState>(
      'host kicks a player and room updates in real-time',
      build: () {
        when(
          () => roomRepository.watchRoom('r1'),
        ).thenAnswer((_) => roomController.stream);
        when(
          () => roomRepository.kickPlayer('r1', 'u2'),
        ).thenAnswer((_) async {});
        return buildCubit();
      },
      act: (cubit) async {
        cubit.loadRoom('r1');
        await Future<void>.delayed(Duration.zero);
        roomController.add(
          testRoom(
            players: [
              testPlayer(name: 'Host', isMe: true),
              testPlayer(uid: 'u2', name: 'Victim'),
              testPlayer(uid: 'u3', name: 'P3'),
              testPlayer(uid: 'u4', name: 'P4'),
            ],
          ),
        );
        await Future<void>.delayed(Duration.zero);
        await cubit.kickPlayer('r1', 'u2');
        roomController.add(
          testRoom(
            players: [
              testPlayer(name: 'Host', isMe: true),
              testPlayer(uid: 'u3', name: 'P3'),
              testPlayer(uid: 'u4', name: 'P4'),
            ],
          ),
        );
        await Future<void>.delayed(Duration.zero);
      },
      verify: (_) {
        verify(() => roomRepository.kickPlayer('r1', 'u2')).called(1);
      },
    );

    blocTest<RoomCubit, RoomState>(
      'createRoomWithBots starts game immediately',
      build: () {
        when(
          () => roomRepository.createRoomWithBots(),
        ).thenAnswer((_) async => (roomId: 'r-bots', gameId: 'g-bots'));
        return buildCubit();
      },
      act: (cubit) => cubit.createRoomWithBots(),
      expect: () => [
        const RoomState.loading(),
        const RoomState.gameStarted(gameId: 'g-bots'),
      ],
      verify: (_) {
        verify(() => roomRepository.createRoomWithBots()).called(1);
      },
    );

    blocTest<RoomCubit, RoomState>(
      'createRoomWithBots emits error on failure',
      build: () {
        when(
          () => roomRepository.createRoomWithBots(),
        ).thenThrow(const RoomException('Server busy'));
        return buildCubit();
      },
      act: (cubit) => cubit.createRoomWithBots(),
      expect: () => [
        const RoomState.loading(),
        const RoomState.error(message: 'Server busy'),
      ],
    );

    blocTest<RoomCubit, RoomState>(
      'inviteBotsToRoom starts game when room becomes full',
      build: () {
        when(
          () => roomRepository.inviteBotsToRoom('r1'),
        ).thenAnswer((_) async => (roomId: 'r1', gameId: 'g-bots-fill'));
        return buildCubit();
      },
      seed: () => RoomState.loaded(
        room: testRoom(players: [testPlayer(name: 'Me', isMe: true)]),
      ),
      act: (cubit) => cubit.inviteBotsToRoom('r1'),
      expect: () => [const RoomState.gameStarted(gameId: 'g-bots-fill')],
      verify: (_) {
        verify(() => roomRepository.inviteBotsToRoom('r1')).called(1);
      },
    );

    blocTest<RoomCubit, RoomState>(
      'inviteBotsToRoom does nothing when gameId is null',
      build: () {
        when(
          () => roomRepository.inviteBotsToRoom('r1'),
        ).thenAnswer((_) async => (roomId: 'r1', gameId: null));
        return buildCubit();
      },
      seed: () => RoomState.loaded(
        room: testRoom(
          players: [
            testPlayer(name: 'Me', isMe: true),
            testPlayer(uid: 'u2', name: 'P2'),
          ],
        ),
      ),
      act: (cubit) => cubit.inviteBotsToRoom('r1'),
      expect: () => const <RoomState>[],
    );

    blocTest<RoomCubit, RoomState>(
      'inviteBotsToRoom does nothing when not in loaded state',
      build: buildCubit,
      act: (cubit) => cubit.inviteBotsToRoom('r1'),
      expect: () => const <RoomState>[],
    );

    blocTest<RoomCubit, RoomState>(
      'startStream updates room to streaming state via real-time stream',
      build: () {
        when(
          () => roomRepository.watchRoom('r1'),
        ).thenAnswer((_) => roomController.stream);
        when(
          () => roomRepository.startStream('r1'),
        ).thenAnswer((_) async => testRoom().copyWith(isStreaming: true));
        return buildCubit();
      },
      act: (cubit) async {
        cubit.loadRoom('r1');
        await Future<void>.delayed(Duration.zero);
        roomController.add(
          testRoom(
            type: RoomType.liveStream,
            players: [testPlayer(name: 'Creator', isMe: true)],
          ),
        );
        await Future<void>.delayed(Duration.zero);
        await cubit.startStream('r1');
        roomController.add(
          testRoom(
            type: RoomType.liveStream,
            players: [testPlayer(name: 'Creator', isMe: true)],
          ).copyWith(isStreaming: true, streamId: 'stream-r1'),
        );
        await Future<void>.delayed(Duration.zero);
      },
      verify: (_) {
        verify(() => roomRepository.startStream('r1')).called(1);
      },
    );

    blocTest<RoomCubit, RoomState>(
      'endStream updates room to non-streaming state',
      build: () {
        when(
          () => roomRepository.endStream('r1'),
        ).thenAnswer((_) async => testRoom());
        return buildCubit();
      },
      seed: () => RoomState.loaded(
        room: testRoom(
          type: RoomType.liveStream,
          players: [testPlayer(name: 'Creator', isMe: true)],
        ).copyWith(isStreaming: true, streamId: 'stream-r1'),
      ),
      act: (cubit) => cubit.endStream('r1'),
      verify: (_) {
        verify(() => roomRepository.endStream('r1')).called(1);
      },
    );

    blocTest<RoomCubit, RoomState>(
      'startStream does nothing when not in loaded state',
      build: buildCubit,
      act: (cubit) => cubit.startStream('r1'),
      expect: () => const <RoomState>[],
    );

    blocTest<RoomCubit, RoomState>(
      'endStream does nothing when not in loaded state',
      build: buildCubit,
      act: (cubit) => cubit.endStream('r1'),
      expect: () => const <RoomState>[],
    );

    blocTest<RoomCubit, RoomState>(
      'toggleCamera updates media state through repository',
      build: () {
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
        when(() => agoraService.toggleCamera()).thenAnswer((_) async => true);
        return buildCubit();
      },
      act: (cubit) async {
        cubit.loadRoom('r1');
        await Future<void>.delayed(Duration.zero);
        await cubit.toggleCamera('r1');
      },
      verify: (_) {
        verify(() => agoraService.toggleCamera()).called(1);
        verify(
          () => roomRepository.updatePlayerMediaState(
            'r1',
            isMicOn: false,
            isCameraOn: true,
          ),
        ).called(1);
      },
    );

    blocTest<RoomCubit, RoomState>(
      'leaveRoom cleans up Agora channel and subscriptions',
      build: () {
        when(() => roomRepository.watchRoom('r1')).thenAnswer(
          (_) => Stream.value(
            testRoom(players: [testPlayer(name: 'Me', isMe: true)]),
          ),
        );
        when(() => roomRepository.leaveRoom('r1')).thenAnswer((_) async {});
        return buildCubit();
      },
      act: (cubit) async {
        cubit.loadRoom('r1');
        await Future<void>.delayed(Duration.zero);
        await cubit.leaveRoom('r1');
      },
      expect: () => [
        const RoomState.loading(),
        isA<RoomLoaded>(),
        const RoomState.initial(),
      ],
      verify: (_) {
        verify(() => roomRepository.leaveRoom('r1')).called(1);
        verify(() => agoraService.leaveChannel()).called(1);
      },
    );

    blocTest<RoomCubit, RoomState>(
      'public rooms list updates in real-time as rooms appear and disappear',
      build: () {
        when(
          () => roomRepository.watchPublicRooms(),
        ).thenAnswer((_) => roomsController.stream);
        return buildCubit();
      },
      act: (cubit) async {
        cubit.watchPublicRooms();
        await Future<void>.delayed(Duration.zero);
        roomsController.add([
          testRoom(id: 'pub1', name: 'Room A', type: RoomType.public),
        ]);
        await Future<void>.delayed(Duration.zero);
        roomsController.add([
          testRoom(id: 'pub1', name: 'Room A', type: RoomType.public),
          testRoom(id: 'pub2', name: 'Room B', type: RoomType.public),
          testRoom(id: 'pub3', name: 'Room C', type: RoomType.public),
        ]);
        await Future<void>.delayed(Duration.zero);
        roomsController.add([
          testRoom(id: 'pub2', name: 'Room B', type: RoomType.public),
        ]);
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => [
        const RoomState.loading(),
        isA<RoomPublicListLoaded>().having((s) => s.rooms.length, '1 room', 1),
        isA<RoomPublicListLoaded>().having((s) => s.rooms.length, '3 rooms', 3),
        isA<RoomPublicListLoaded>().having(
          (s) => s.rooms.length,
          '1 room after others left',
          1,
        ),
      ],
    );

    blocTest<RoomCubit, RoomState>(
      'gameStarted emitted only once even if room stream sends playing multiple times',
      build: () {
        when(
          () => roomRepository.watchRoom('r1'),
        ).thenAnswer((_) => roomController.stream);
        return buildCubit();
      },
      act: (cubit) async {
        cubit.loadRoom('r1');
        await Future<void>.delayed(Duration.zero);
        roomController.add(
          testRoom(
            status: RoomStatus.playing,
            gameId: 'g-dedup',
            players: [testPlayer(name: 'Me', isMe: true)],
          ),
        );
        await Future<void>.delayed(Duration.zero);
        roomController.add(
          testRoom(
            status: RoomStatus.playing,
            gameId: 'g-dedup',
            players: [testPlayer(name: 'Me', isMe: true)],
          ),
        );
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => [
        const RoomState.loading(),
        isA<RoomGameStarted>().having((s) => s.gameId, 'gameId', 'g-dedup'),
        // Second playing event falls through to _emitMergedState since
        // _gameStartedEmitted is already true.
        isA<RoomLoaded>(),
      ],
    );
  });

  // ===========================================================================
  // Multi-speaker voice scenarios
  // ===========================================================================
  group('Multi-speaker voice scenarios', () {
    late MockRoomRepository roomRepository;
    late MockAgoraService agoraService;
    late StreamController<AgoraAudioVolumeIndicationEvent> volumeController;

    setUp(() {
      roomRepository = MockRoomRepository();
      agoraService = MockAgoraService();
      stubAgoraServiceDefaults(agoraService);
      volumeController = StreamController<AgoraAudioVolumeIndicationEvent>();
    });

    tearDown(() => volumeController.close);

    blocTest<RoomCubit, RoomState>(
      'multiple players speaking simultaneously updates isSpeaking for all',
      build: () {
        when(
          () => agoraService.onAudioVolumeIndication,
        ).thenAnswer((_) => volumeController.stream);
        when(() => roomRepository.watchRoom('r1')).thenAnswer(
          (_) => Stream.value(
            testRoom(
              players: [
                testPlayer(name: 'Me', isMe: true, agoraUid: 101),
                testPlayer(uid: 'u2', name: 'P2', agoraUid: 102),
                testPlayer(uid: 'u3', name: 'P3', agoraUid: 103),
                testPlayer(uid: 'u4', name: 'P4', agoraUid: 104),
              ],
            ),
          ),
        );
        return RoomCubit(
          roomRepository: roomRepository,
          agoraService: agoraService,
        );
      },
      act: (cubit) async {
        cubit.loadRoom('r1');
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);
        volumeController.add(
          const AgoraAudioVolumeIndicationEvent(
            speakers: [
              AudioVolumeInfo(uid: 101, volume: 80),
              AudioVolumeInfo(uid: 103, volume: 70),
            ],
          ),
        );
        await Future<void>.delayed(Duration.zero);
      },
      skip: 1,
      expect: () => [
        isA<RoomLoaded>().having(
          (s) => s.room.players.where((p) => p.isSpeaking).length,
          'none speaking',
          0,
        ),
        isA<RoomLoaded>().having(
          (s) => s.room.players.where((p) => p.isSpeaking).length,
          '2 speaking',
          2,
        ),
      ],
    );

    blocTest<RoomCubit, RoomState>(
      'player stops speaking resets isSpeaking',
      build: () {
        when(
          () => agoraService.onAudioVolumeIndication,
        ).thenAnswer((_) => volumeController.stream);
        when(() => roomRepository.watchRoom('r1')).thenAnswer(
          (_) => Stream.value(
            testRoom(
              players: [testPlayer(name: 'Me', isMe: true, agoraUid: 101)],
            ),
          ),
        );
        return RoomCubit(
          roomRepository: roomRepository,
          agoraService: agoraService,
        );
      },
      act: (cubit) async {
        cubit.loadRoom('r1');
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);
        volumeController.add(
          const AgoraAudioVolumeIndicationEvent(
            speakers: [AudioVolumeInfo(uid: 101, volume: 80)],
          ),
        );
        await Future<void>.delayed(Duration.zero);
        volumeController.add(
          const AgoraAudioVolumeIndicationEvent(
            speakers: [AudioVolumeInfo(uid: 101, volume: 20)],
          ),
        );
        await Future<void>.delayed(Duration.zero);
      },
      skip: 1,
      expect: () => [
        isA<RoomLoaded>().having(
          (s) => s.room.players.first.isSpeaking,
          'not speaking initially',
          false,
        ),
        isA<RoomLoaded>().having(
          (s) => s.room.players.first.isSpeaking,
          'speaking',
          true,
        ),
        isA<RoomLoaded>().having(
          (s) => s.room.players.first.isSpeaking,
          'stopped speaking',
          false,
        ),
      ],
    );

    blocTest<RoomCubit, RoomState>(
      'Agora join failure does not crash the cubit',
      build: () {
        when(
          () => agoraService.joinChannel(
            channelName: any(named: 'channelName'),
            agoraUid: any(named: 'agoraUid'),
            subscribeVideo: any(named: 'subscribeVideo'),
          ),
        ).thenAnswer((_) async => throw Exception('Agora network error'));
        when(() => roomRepository.watchRoom('r1')).thenAnswer(
          (_) => Stream.value(
            testRoom(players: [testPlayer(name: 'Me', isMe: true)]),
          ),
        );
        return RoomCubit(
          roomRepository: roomRepository,
          agoraService: agoraService,
        );
      },
      act: (cubit) async {
        cubit.loadRoom('r1');
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => [
        const RoomState.loading(),
        isA<RoomLoaded>().having((s) => s.room.id, 'room id', 'r1'),
      ],
    );
  });

  // ===========================================================================
  // Game multi-user scenarios
  // ===========================================================================
  group('Game multi-user scenarios', () {
    late MockGameRepository gameRepository;
    late MockRoomRepository roomRepository;
    late MockAgoraService agoraService;
    late MockAudioService audioService;
    late StreamController<Game> gameController;

    setUp(() {
      gameRepository = MockGameRepository();
      roomRepository = MockRoomRepository();
      agoraService = MockAgoraService();
      audioService = MockAudioService();
      stubAgoraServiceDefaults(agoraService);
      gameController = StreamController<Game>();
    });

    tearDown(() => gameController.close);

    GameCubit buildCubit() => GameCubit(
      gameRepository: gameRepository,
      roomRepository: roomRepository,
      agoraService: agoraService,
      audioService: audioService,
    );

    blocTest<GameCubit, GameState>(
      'full game lifecycle: dealing → bidding → playing → trickEnd → roundEnd → gameEnd',
      build: () {
        when(
          () => gameRepository.watchGame('g1'),
        ).thenAnswer((_) => gameController.stream);
        return buildCubit();
      },
      act: (cubit) async {
        cubit.watchGame('g1');
        await Future<void>.delayed(Duration.zero);
        final g = testGame();
        gameController.add(g.copyWith(status: 'dealing'));
        await Future<void>.delayed(Duration.zero);
        gameController.add(g.copyWith(status: 'bidding'));
        await Future<void>.delayed(Duration.zero);
        gameController.add(g.copyWith(status: 'playing'));
        await Future<void>.delayed(Duration.zero);
        gameController.add(
          g.copyWith(
            status: 'trickEnd',
            currentTrick: const Trick(
              trickNumber: 1,
              trickLeaderIndex: 0,
              winnerSeat: 0,
            ),
          ),
        );
        await Future<void>.delayed(Duration.zero);
        gameController.add(
          g.copyWith(status: 'roundEnd', scoreUs: 80, scoreThem: 40),
        );
        await Future<void>.delayed(Duration.zero);
        gameController.add(
          g.copyWith(
            status: 'gameEnd',
            teamAScore: 160,
            teamBScore: 100,
            scoreUs: 160,
            scoreThem: 100,
          ),
        );
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => [
        const GameState.loading(),
        isA<GameDealing>(),
        isA<GameBidding>(),
        isA<GamePlaying>(),
        isA<GameTrickEnd>(),
        isA<GameRoundEnd>(),
        isA<GameGameEnd>().having((s) => s.winnerTeam, 'winner', 'A'),
      ],
    );

    blocTest<GameCubit, GameState>(
      'spectator watches game without joining Agora as broadcaster',
      build: () {
        when(
          () => gameRepository.watchGameAsSpectator('g1'),
        ).thenAnswer((_) => Stream.value(testGame()));
        return buildCubit();
      },
      act: (cubit) => cubit.watchGameAsSpectator('g1'),
      expect: () => [const GameState.loading(), isA<GamePlaying>()],
      verify: (_) {
        verify(() => gameRepository.watchGameAsSpectator('g1')).called(1);
      },
    );

    blocTest<GameCubit, GameState>(
      'rematch calls repository.rematch with roomId',
      build: () {
        when(() => gameRepository.rematch('r1')).thenAnswer((_) async {});
        return buildCubit();
      },
      seed: () => GameState.gameEnd(
        game: testGame(status: 'gameEnd'),
        winnerTeam: 'A',
      ),
      act: (cubit) => cubit.rematch(),
      verify: (_) {
        verify(() => gameRepository.rematch('r1')).called(1);
      },
    );

    blocTest<GameCubit, GameState>(
      'rematch does nothing when roomId is null',
      build: () {
        when(() => gameRepository.rematch(any())).thenAnswer((_) async {});
        return buildCubit();
      },
      seed: () => GameState.gameEnd(
        game: testGame(roomId: null, status: 'gameEnd'),
        winnerTeam: 'A',
      ),
      act: (cubit) => cubit.rematch(),
      verify: (_) {
        verifyNever(() => gameRepository.rematch(any()));
      },
    );

    blocTest<GameCubit, GameState>(
      'leaveGame cancels subscription, leaves room, and leaves Agora',
      build: () {
        when(
          () => gameRepository.watchGame('g1'),
        ).thenAnswer((_) => Stream.value(testGame()));
        when(() => roomRepository.leaveRoom('r1')).thenAnswer((_) async {});
        return buildCubit();
      },
      act: (cubit) async {
        cubit.watchGame('g1');
        await Future<void>.delayed(Duration.zero);
        await cubit.leaveGame();
      },
      expect: () => [
        const GameState.loading(),
        isA<GamePlaying>(),
        isA<GamePlaying>().having(
          (s) => s.actionInProgress,
          'actionInProgress',
          true,
        ),
        const GameState.initial(),
      ],
      verify: (_) {
        verify(() => roomRepository.leaveRoom('r1')).called(1);
        verify(() => agoraService.leaveChannel()).called(1);
      },
    );

    blocTest<GameCubit, GameState>(
      'toggleMic in game updates media state through room repository',
      build: () {
        when(
          () => gameRepository.watchGame('g1'),
        ).thenAnswer((_) => Stream.value(testGame()));
        when(
          () => roomRepository.updatePlayerMediaState(
            'r1',
            isMicOn: any(named: 'isMicOn'),
            isCameraOn: any(named: 'isCameraOn'),
          ),
        ).thenAnswer((_) async {});
        when(() => agoraService.toggleMic()).thenAnswer((_) async => true);
        return buildCubit();
      },
      act: (cubit) async {
        cubit.watchGame('g1');
        await Future<void>.delayed(Duration.zero);
        await cubit.toggleMic();
      },
      verify: (_) {
        verify(() => agoraService.toggleMic()).called(1);
        verify(
          () => roomRepository.updatePlayerMediaState(
            'r1',
            isMicOn: true,
            isCameraOn: false,
          ),
        ).called(1);
      },
    );

    blocTest<GameCubit, GameState>(
      'toggleCamera in game updates media state through room repository',
      build: () {
        when(
          () => gameRepository.watchGame('g1'),
        ).thenAnswer((_) => Stream.value(testGame()));
        when(
          () => roomRepository.updatePlayerMediaState(
            'r1',
            isMicOn: any(named: 'isMicOn'),
            isCameraOn: any(named: 'isCameraOn'),
          ),
        ).thenAnswer((_) async {});
        when(() => agoraService.toggleCamera()).thenAnswer((_) async => true);
        return buildCubit();
      },
      act: (cubit) async {
        cubit.watchGame('g1');
        await Future<void>.delayed(Duration.zero);
        await cubit.toggleCamera();
      },
      verify: (_) {
        verify(() => agoraService.toggleCamera()).called(1);
        verify(
          () => roomRepository.updatePlayerMediaState(
            'r1',
            isMicOn: false,
            isCameraOn: true,
          ),
        ).called(1);
      },
    );

    blocTest<GameCubit, GameState>(
      'playCard error shows action error but does not crash',
      build: () {
        when(
          () => gameRepository.playCard('g1', 'AH'),
        ).thenThrow(Exception('network'));
        return buildCubit();
      },
      seed: () => GameState.playing(game: testGame()),
      act: (cubit) => cubit.playCard('AH'),
      expect: () => [
        isA<GamePlaying>().having(
          (s) => s.actionInProgress,
          'actionInProgress',
          true,
        ),
        isA<GamePlaying>().having(
          (s) => s.lastActionError,
          'error',
          'Failed to play card. Please try again.',
        ),
      ],
    );

    blocTest<GameCubit, GameState>(
      'placeBid is re-entrancy guarded — second call during first is ignored',
      build: () {
        final completer = Completer<void>();
        when(() => gameRepository.placeBid('g1', 'sun')).thenAnswer((_) async {
          await completer.future;
        });
        return buildCubit();
      },
      seed: () => GameState.bidding(game: testGame()),
      act: (cubit) async {
        cubit.placeBid('sun');
        await Future<void>.delayed(Duration.zero);
        await cubit.placeBid('sun');
      },
      verify: (_) {
        verify(() => gameRepository.placeBid('g1', 'sun')).called(1);
      },
    );

    blocTest<GameCubit, GameState>(
      'playCard is re-entrancy guarded — second call during first is ignored',
      build: () {
        final completer = Completer<void>();
        when(() => gameRepository.playCard('g1', 'AH')).thenAnswer((_) async {
          await completer.future;
        });
        return buildCubit();
      },
      seed: () => GameState.playing(game: testGame()),
      act: (cubit) async {
        cubit.playCard('AH');
        await Future<void>.delayed(Duration.zero);
        await cubit.playCard('AH');
      },
      verify: (_) {
        verify(() => gameRepository.playCard('g1', 'AH')).called(1);
      },
    );

    blocTest<GameCubit, GameState>(
      'game stream error emits error state',
      build: () {
        when(
          () => gameRepository.watchGame('g1'),
        ).thenAnswer((_) => Stream.error(Exception('Firestore error')));
        return buildCubit();
      },
      act: (cubit) => cubit.watchGame('g1'),
      expect: () => [
        const GameState.loading(),
        const GameState.error(message: 'game_load_failed'),
      ],
    );

    blocTest<GameCubit, GameState>(
      'trick win sound plays when local team wins trick',
      build: () {
        when(
          () => gameRepository.watchGame('g1'),
        ).thenAnswer((_) => gameController.stream);
        when(() => audioService.playTrickWinSound()).thenAnswer((_) async {});
        return buildCubit();
      },
      act: (cubit) async {
        cubit.watchGame('g1');
        await Future<void>.delayed(Duration.zero);
        final g = testGame();
        gameController.add(g.copyWith(status: 'playing'));
        await Future<void>.delayed(Duration.zero);
        gameController.add(
          g.copyWith(
            status: 'trickEnd',
            currentTrick: const Trick(
              trickNumber: 1,
              trickLeaderIndex: 0,
              winnerSeat: 0,
            ),
          ),
        );
        await Future<void>.delayed(Duration.zero);
      },
      verify: (_) {
        verify(() => audioService.playTrickWinSound()).called(1);
      },
    );

    blocTest<GameCubit, GameState>(
      'game win sound plays when local team wins game',
      build: () {
        when(
          () => gameRepository.watchGame('g1'),
        ).thenAnswer((_) => gameController.stream);
        when(() => audioService.playGameWinSound()).thenAnswer((_) async {});
        return buildCubit();
      },
      act: (cubit) async {
        cubit.watchGame('g1');
        await Future<void>.delayed(Duration.zero);
        final g = testGame();
        gameController.add(g.copyWith(status: 'playing'));
        await Future<void>.delayed(Duration.zero);
        gameController.add(
          g.copyWith(
            status: 'gameEnd',
            teamAScore: 160,
            teamBScore: 100,
            scoreUs: 160,
            scoreThem: 100,
          ),
        );
        await Future<void>.delayed(Duration.zero);
      },
      verify: (_) {
        verify(() => audioService.playGameWinSound()).called(1);
      },
    );

    blocTest<GameCubit, GameState>(
      'game lose sound plays when opponent team wins game',
      build: () {
        when(
          () => gameRepository.watchGame('g1'),
        ).thenAnswer((_) => gameController.stream);
        when(() => audioService.playGameLoseSound()).thenAnswer((_) async {});
        return buildCubit();
      },
      act: (cubit) async {
        cubit.watchGame('g1');
        await Future<void>.delayed(Duration.zero);
        final g = testGame();
        gameController.add(g.copyWith(status: 'playing'));
        await Future<void>.delayed(Duration.zero);
        gameController.add(
          g.copyWith(
            status: 'gameEnd',
            teamAScore: 100,
            teamBScore: 160,
            scoreUs: 100,
            scoreThem: 160,
          ),
        );
        await Future<void>.delayed(Duration.zero);
      },
      verify: (_) {
        verify(() => audioService.playGameLoseSound()).called(1);
      },
    );

    blocTest<GameCubit, GameState>(
      'closing game cubit leaves Agora channel but does NOT leave room',
      build: () {
        when(
          () => gameRepository.watchGame('g1'),
        ).thenAnswer((_) => Stream.value(testGame()));
        return buildCubit();
      },
      act: (cubit) async {
        cubit.watchGame('g1');
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);
        await cubit.close();
      },
      verify: (_) {
        verify(() => agoraService.leaveChannel()).called(1);
        verifyNever(() => roomRepository.leaveRoom(any()));
      },
    );
  });
}
