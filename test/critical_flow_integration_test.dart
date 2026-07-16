import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bloot/core/services/agora_service.dart';
import 'package:bloot/core/services/audio_service.dart';
import 'package:bloot/features/discover/domain/entities/discover_stream.dart';
import 'package:bloot/features/discover/domain/repositories/discover_repository.dart';
import 'package:bloot/features/discover/presentation/cubit/discover_cubit.dart';
import 'package:bloot/features/discover/presentation/cubit/discover_state.dart';
import 'package:bloot/features/game/domain/entities/game.dart';
import 'package:bloot/features/game/domain/repositories/game_repository.dart';
import 'package:bloot/features/game/presentation/cubit/game_cubit.dart';
import 'package:bloot/features/game/presentation/cubit/game_state.dart';
import 'package:bloot/features/room/domain/entities/room.dart';
import 'package:bloot/features/room/domain/exceptions/room_exception.dart';
import 'package:bloot/features/room/domain/repositories/room_repository.dart';
import 'package:bloot/features/room/presentation/cubit/room_cubit.dart';
import 'package:bloot/features/room/presentation/cubit/room_state.dart';

import 'helpers/test_helpers.dart';

void main() {
  setUpAll(setupWidgetTests);

  late MockRoomRepository roomRepository;
  late MockGameRepository gameRepository;
  late MockDiscoverRepository discoverRepository;
  late MockAgoraService agoraService;
  late MockAudioService audioService;

  setUp(() {
    roomRepository = MockRoomRepository();
    gameRepository = MockGameRepository();
    discoverRepository = MockDiscoverRepository();
    agoraService = MockAgoraService();
    audioService = MockAudioService();
    stubAgoraServiceDefaults(agoraService);
  });

  // ===========================================================================
  // 1. Full Room → Game Journey
  // ===========================================================================
  group('Full room → game journey', () {
    StreamController<Room>? roomController;
    StreamController<Game>? gameController;

    blocTest<RoomCubit, RoomState>(
      'create room → players join → ready up → game starts → Agora joins',
      build: () {
        when(
          () => roomRepository.createRoom(any()),
        ).thenAnswer((_) async => testRoom());
        return RoomCubit(
          roomRepository: roomRepository,
          agoraService: agoraService,
        );
      },
      act: (cubit) => cubit.createRoom(
        const CreateRoomParams(name: 'Test Room', type: RoomType.private),
      ),
      expect: () => [
        const RoomState.loading(),
        isA<RoomCreated>().having((s) => s.room.id, 'room id', 'r1'),
      ],
      verify: (_) {
        verify(() => roomRepository.createRoom(any())).called(1);
      },
    );

    blocTest<RoomCubit, RoomState>(
      'players join, ready up, and game starts with Agora channel join',
      build: () {
        roomController = StreamController<Room>();
        addTearDown(() async => roomController!.close());
        when(
          () => roomRepository.watchRoom('r1'),
        ).thenAnswer((_) => roomController!.stream);
        return RoomCubit(
          roomRepository: roomRepository,
          agoraService: agoraService,
        );
      },
      act: (cubit) async {
        cubit.loadRoom('r1');
        await Future<void>.delayed(Duration.zero);

        // Player 1 (host) joins
        roomController!.add(
          testRoom(players: [testPlayer(name: 'Host', isMe: true)]),
        );
        await Future<void>.delayed(Duration.zero);

        // Player 2 joins
        roomController!.add(
          testRoom(
            players: [
              testPlayer(name: 'Host', isMe: true, isReady: true),
              testPlayer(uid: 'u2', name: 'P2'),
            ],
          ),
        );
        await Future<void>.delayed(Duration.zero);

        // Players 3 and 4 join, all ready
        roomController!.add(
          testRoom(
            players: [
              testPlayer(name: 'Host', isMe: true, isReady: true),
              testPlayer(uid: 'u2', name: 'P2', isReady: true),
              testPlayer(uid: 'u3', name: 'P3', isReady: true),
              testPlayer(uid: 'u4', name: 'P4', isReady: true),
            ],
          ),
        );
        await Future<void>.delayed(Duration.zero);

        // Game starts
        roomController!.add(
          testRoom(
            status: RoomStatus.playing,
            gameId: 'g1',
            players: [
              testPlayer(name: 'Host', isMe: true, isReady: true),
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
        isA<RoomLoaded>().having((s) => s.room.players.length, '1 player', 1),
        isA<RoomLoaded>().having((s) => s.room.players.length, '2 players', 2),
        isA<RoomLoaded>().having((s) => s.room.players.length, '4 players', 4),
        isA<RoomGameStarted>().having((s) => s.gameId, 'gameId', 'g1'),
      ],
      verify: (_) {
        verify(
          () => agoraService.joinChannel(channelName: 'room_r1'),
        ).called(1);
      },
    );

    blocTest<GameCubit, GameState>(
      'game lifecycle: dealing → bidding → playing → trickEnd → roundEnd → gameEnd',
      build: () {
        gameController = StreamController<Game>();
        addTearDown(() async => gameController!.close());
        when(
          () => gameRepository.watchGame('g1'),
        ).thenAnswer((_) => gameController!.stream);
        return GameCubit(
          gameRepository: gameRepository,
          roomRepository: roomRepository,
          agoraService: agoraService,
          audioService: audioService,
        );
      },
      act: (cubit) async {
        cubit.watchGame('g1');
        await Future<void>.delayed(Duration.zero);

        final g = testGame();

        // Dealing
        gameController!.add(g.copyWith(status: 'dealing'));
        await Future<void>.delayed(Duration.zero);

        // Bidding
        gameController!.add(g.copyWith(status: 'bidding'));
        await Future<void>.delayed(Duration.zero);

        // Playing
        gameController!.add(g.copyWith(status: 'playing'));
        await Future<void>.delayed(Duration.zero);

        // Trick end (local team wins)
        gameController!.add(
          g.copyWith(
            status: 'trickEnd',
            currentTrick: Trick(
              trickNumber: 1,
              trickLeaderIndex: 0,
              winnerSeat: 0,
            ),
          ),
        );
        await Future<void>.delayed(Duration.zero);

        // Round end
        gameController!.add(
          g.copyWith(status: 'roundEnd', scoreUs: 100, scoreThem: 52),
        );
        await Future<void>.delayed(Duration.zero);

        // Game end (local team wins)
        gameController!.add(
          g.copyWith(
            status: 'gameEnd',
            teamAScore: 152,
            teamBScore: 100,
            scoreUs: 152,
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
        isA<GameRoundEnd>().having((s) => s.teamAPoints, 'points', 100),
        isA<GameGameEnd>().having((s) => s.winnerTeam, 'winner', 'A'),
      ],
      verify: (_) {
        verify(() => audioService.playTrickWinSound()).called(1);
        verify(() => audioService.playRoundEndSound()).called(1);
        verify(() => audioService.playGameWinSound()).called(1);
      },
    );
  });

  // ===========================================================================
  // 2. Stream Room Journey
  // ===========================================================================
  group('Stream room journey', () {
    StreamController<Room>? roomController;
    StreamController<DiscoverStream>? streamController;
    StreamController<List<StreamChatMessage>>? chatController;

    blocTest<RoomCubit, RoomState>(
      'host creates room, goes live, stream updates in real-time',
      build: () {
        roomController = StreamController<Room>();
        addTearDown(() async => roomController!.close());
        when(
          () => roomRepository.watchRoom('r1'),
        ).thenAnswer((_) => roomController!.stream);
        when(
          () => roomRepository.startStream('r1'),
        ).thenAnswer((_) async => testRoom());
        return RoomCubit(
          roomRepository: roomRepository,
          agoraService: agoraService,
        );
      },
      act: (cubit) async {
        cubit.loadRoom('r1');
        await Future<void>.delayed(Duration.zero);

        // Room loaded, not streaming
        roomController!.add(
          testRoom(
            type: RoomType.liveStream,
            players: [testPlayer(name: 'Host', isMe: true)],
          ),
        );
        await Future<void>.delayed(Duration.zero);

        // Host starts stream
        await cubit.startStream('r1');

        // Stream is now live (real-time update)
        roomController!.add(
          testRoom(
            type: RoomType.liveStream,
            isStreaming: true,
            streamId: 'stream-r1',
            players: [testPlayer(name: 'Host', isMe: true)],
          ),
        );
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => [
        const RoomState.loading(),
        isA<RoomLoaded>().having(
          (s) => s.room.isStreaming,
          'not streaming',
          false,
        ),
        isA<RoomLoaded>().having((s) => s.room.isStreaming, 'streaming', true),
      ],
      verify: (_) {
        verify(() => roomRepository.startStream('r1')).called(1);
      },
    );

    blocTest<DiscoverCubit, DiscoverState>(
      'audience watches stream: loads stream, joins Agora as audience, chat flows',
      build: () {
        streamController = StreamController<DiscoverStream>();
        chatController = StreamController<List<StreamChatMessage>>();
        addTearDown(() async {
          await streamController!.close();
          await chatController!.close();
        });
        when(
          () => discoverRepository.getStreamById('s1'),
        ).thenAnswer((_) async => testStream());
        when(
          () => discoverRepository.watchStream('s1'),
        ).thenAnswer((_) => streamController!.stream);
        when(
          () => discoverRepository.watchStreamChat('s1'),
        ).thenAnswer((_) => chatController!.stream);
        return DiscoverCubit(discoverRepository: discoverRepository);
      },
      act: (cubit) async {
        cubit.loadStream('s1');
        await Future<void>.delayed(Duration.zero);

        // Stream doc update (viewer count increases)
        streamController!.add(testStream(viewers: 100));
        await Future<void>.delayed(Duration.zero);

        // Chat messages arrive
        chatController!.add([
          const StreamChatMessage(
            id: 'm1',
            senderUid: 'u2',
            senderName: 'Viewer1',
            text: 'Great stream!',
          ),
        ]);
        await Future<void>.delayed(Duration.zero);

        // More chat messages
        chatController!.add([
          const StreamChatMessage(
            id: 'm1',
            senderUid: 'u2',
            senderName: 'Viewer1',
            text: 'Great stream!',
          ),
          const StreamChatMessage(
            id: 'm2',
            senderUid: 'u3',
            senderName: 'Viewer2',
            text: 'Nice play!',
          ),
        ]);
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => [
        const DiscoverState.loading(),
        DiscoverState.streamLoaded(stream: testStream(), messages: const []),
        DiscoverState.streamLoaded(
          stream: testStream(viewers: 100),
          messages: const [],
        ),
        DiscoverState.streamLoaded(
          stream: testStream(viewers: 100),
          messages: [
            const StreamChatMessage(
              id: 'm1',
              senderUid: 'u2',
              senderName: 'Viewer1',
              text: 'Great stream!',
            ),
          ],
        ),
        DiscoverState.streamLoaded(
          stream: testStream(viewers: 100),
          messages: [
            const StreamChatMessage(
              id: 'm1',
              senderUid: 'u2',
              senderName: 'Viewer1',
              text: 'Great stream!',
            ),
            const StreamChatMessage(
              id: 'm2',
              senderUid: 'u3',
              senderName: 'Viewer2',
              text: 'Nice play!',
            ),
          ],
        ),
      ],
    );
  });

  // ===========================================================================
  // 3. Audio Room with Speaker Changes
  // ===========================================================================
  group('Audio room with speaker changes', () {
    StreamController<Room>? roomController;
    StreamController<AgoraAudioVolumeIndicationEvent>? volumeController;

    blocTest<RoomCubit, RoomState>(
      'multiple speakers detected via volume indication, then stop speaking',
      build: () {
        roomController = StreamController<Room>.broadcast();
        volumeController =
            StreamController<AgoraAudioVolumeIndicationEvent>.broadcast();
        addTearDown(() async {
          await roomController!.close();
          await volumeController!.close();
        });
        when(
          () => agoraService.onAudioVolumeIndication,
        ).thenAnswer((_) => volumeController!.stream);
        when(
          () => roomRepository.watchRoom('r1'),
        ).thenAnswer((_) => roomController!.stream);
        return RoomCubit(
          roomRepository: roomRepository,
          agoraService: agoraService,
        );
      },
      act: (cubit) async {
        cubit.loadRoom('r1');
        await Future<void>.delayed(Duration.zero);

        // Room with 2 players, neither speaking
        roomController!.add(
          testRoom(
            players: [
              testPlayer(uid: 'u1', name: 'Host', isMe: true, agoraUid: 101),
              testPlayer(uid: 'u2', name: 'P2', agoraUid: 102),
            ],
          ),
        );
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        // P2 starts speaking
        volumeController!.add(
          AgoraAudioVolumeIndicationEvent(
            speakers: [AudioVolumeInfo(uid: 102, volume: 200, vad: 1)],
          ),
        );
        await Future<void>.delayed(Duration.zero);

        // Both speaking
        volumeController!.add(
          AgoraAudioVolumeIndicationEvent(
            speakers: [
              AudioVolumeInfo(uid: 101, volume: 150, vad: 1),
              AudioVolumeInfo(uid: 102, volume: 200, vad: 1),
            ],
          ),
        );
        await Future<void>.delayed(Duration.zero);

        // No one speaking (empty speakers list)
        volumeController!.add(
          const AgoraAudioVolumeIndicationEvent(speakers: []),
        );
        await Future<void>.delayed(Duration.zero);
      },
      skip: 2,
      expect: () => [
        // P2 starts speaking
        isA<RoomLoaded>().having(
          (s) => s.room.players[1].isSpeaking,
          'P2 speaking',
          true,
        ),
        // Both speaking
        isA<RoomLoaded>().having(
          (s) => s.room.players[0].isSpeaking,
          'Host speaking',
          true,
        ),
        // No one speaking
        isA<RoomLoaded>().having(
          (s) => s.room.players[0].isSpeaking,
          'Host not speaking',
          false,
        ),
      ],
    );
  });

  // ===========================================================================
  // 4. Room to Game Agora Channel Handoff
  // ===========================================================================
  group('Room to game Agora channel handoff', () {
    test('room and game share the same Agora channel name', () {
      final room = testRoom(agoraChannelName: 'room_r1');
      final game = testGame(agoraChannelName: 'room_r1');

      expect(room.agoraChannelName, 'room_r1');
      expect(game.agoraChannelName, 'room_r1');
      expect(room.agoraChannelName, game.agoraChannelName);
    });

    blocTest<GameCubit, GameState>(
      'game cubit joins same Agora channel as room, leaves on close',
      build: () {
        when(() => gameRepository.watchGame('g1')).thenAnswer(
          (_) => Stream.value(testGame(agoraChannelName: 'room_r1')),
        );
        return GameCubit(
          gameRepository: gameRepository,
          roomRepository: roomRepository,
          agoraService: agoraService,
          audioService: audioService,
        );
      },
      act: (cubit) async {
        cubit.watchGame('g1');
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);
        await cubit.close();
      },
      verify: (_) {
        verify(
          () => agoraService.joinChannel(
            channelName: 'room_r1',
            agoraUid: any(named: 'agoraUid'),
            subscribeVideo: false,
          ),
        ).called(1);
        verify(() => agoraService.leaveChannel()).called(1);
      },
    );
  });

  // ===========================================================================
  // 5. Concurrent Operations
  // ===========================================================================
  group('Concurrent operations', () {
    StreamController<Room>? roomController;
    StreamController<Game>? gameController;

    blocTest<RoomCubit, RoomState>(
      'toggle mic while room stream updates',
      build: () {
        roomController = StreamController<Room>.broadcast();
        addTearDown(() async => roomController!.close());
        when(
          () => roomRepository.watchRoom('r1'),
        ).thenAnswer((_) => roomController!.stream);
        when(() => agoraService.toggleMic()).thenAnswer((_) async => true);
        when(
          () => roomRepository.updatePlayerMediaState(
            'r1',
            isMicOn: any(named: 'isMicOn'),
            isCameraOn: any(named: 'isCameraOn'),
          ),
        ).thenAnswer((_) async {});
        return RoomCubit(
          roomRepository: roomRepository,
          agoraService: agoraService,
        );
      },
      act: (cubit) async {
        cubit.loadRoom('r1');
        await Future<void>.delayed(Duration.zero);

        // Initial room state
        roomController!.add(
          testRoom(players: [testPlayer(name: 'Me', isMe: true)]),
        );
        await Future<void>.delayed(Duration.zero);

        // Toggle mic and simultaneously receive a room update
        await cubit.toggleMic('r1');
        roomController!.add(
          testRoom(
            players: [
              testPlayer(name: 'Me', isMe: true, isMicOn: true),
              testPlayer(uid: 'u2', name: 'P2'),
            ],
          ),
        );
        await Future<void>.delayed(Duration.zero);
      },
      verify: (_) {
        verify(() => agoraService.toggleMic()).called(1);
        verify(
          () => roomRepository.updatePlayerMediaState(
            'r1',
            isMicOn: any(named: 'isMicOn'),
            isCameraOn: any(named: 'isCameraOn'),
          ),
        ).called(1);
      },
    );

    blocTest<GameCubit, GameState>(
      'placeBid while game stream updates with new state',
      build: () {
        gameController = StreamController<Game>.broadcast();
        addTearDown(() async => gameController!.close());
        when(
          () => gameRepository.watchGame('g1'),
        ).thenAnswer((_) => gameController!.stream);
        when(
          () => gameRepository.placeBid('g1', 'sun'),
        ).thenAnswer((_) async {});
        return GameCubit(
          gameRepository: gameRepository,
          roomRepository: roomRepository,
          agoraService: agoraService,
          audioService: audioService,
        );
      },
      act: (cubit) async {
        cubit.watchGame('g1');
        await Future<void>.delayed(Duration.zero);

        // Game in bidding state
        gameController!.add(testGame(status: 'bidding'));
        await Future<void>.delayed(Duration.zero);

        // Place bid while a new game update arrives
        await cubit.placeBid('sun');
        gameController!.add(testGame(status: 'bidding', turnIndex: 1));
        await Future<void>.delayed(Duration.zero);
      },
      verify: (_) {
        verify(() => gameRepository.placeBid('g1', 'sun')).called(1);
      },
    );
  });

  // ===========================================================================
  // 6. Error Recovery
  // ===========================================================================
  group('Error recovery', () {
    StreamController<Game>? gameController;
    StreamController<Room>? roomController;

    blocTest<GameCubit, GameState>(
      'game stream error then recovers when stream resumes',
      build: () {
        gameController = StreamController<Game>();
        addTearDown(() async => gameController!.close());
        when(
          () => gameRepository.watchGame('g1'),
        ).thenAnswer((_) => gameController!.stream);
        return GameCubit(
          gameRepository: gameRepository,
          roomRepository: roomRepository,
          agoraService: agoraService,
          audioService: audioService,
        );
      },
      act: (cubit) async {
        cubit.watchGame('g1');
        await Future<void>.delayed(Duration.zero);

        // Error arrives
        gameController!.addError(Exception('network'));
        await Future<void>.delayed(Duration.zero);

        // Game data arrives, recovering
        gameController!.add(testGame(status: 'playing'));
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => [
        const GameState.loading(),
        const GameState.error(message: 'Failed to load game.'),
        isA<GamePlaying>(),
      ],
    );

    blocTest<RoomCubit, RoomState>(
      'room stream error then recovers when stream resumes',
      build: () {
        roomController = StreamController<Room>();
        addTearDown(() async => roomController!.close());
        when(
          () => roomRepository.watchRoom('r1'),
        ).thenAnswer((_) => roomController!.stream);
        return RoomCubit(
          roomRepository: roomRepository,
          agoraService: agoraService,
        );
      },
      act: (cubit) async {
        cubit.loadRoom('r1');
        await Future<void>.delayed(Duration.zero);

        // Error arrives
        roomController!.addError(const RoomException('Temporary error'));
        await Future<void>.delayed(Duration.zero);

        // Room data arrives, recovering
        roomController!.add(
          testRoom(players: [testPlayer(name: 'Me', isMe: true)]),
        );
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => [
        const RoomState.loading(),
        isA<RoomError>().having((s) => s.message, 'message', 'Temporary error'),
        isA<RoomLoaded>(),
      ],
    );

    blocTest<RoomCubit, RoomState>(
      'room stream generic error emits generic message then recovers',
      build: () {
        roomController = StreamController<Room>();
        addTearDown(() async => roomController!.close());
        when(
          () => roomRepository.watchRoom('r1'),
        ).thenAnswer((_) => roomController!.stream);
        return RoomCubit(
          roomRepository: roomRepository,
          agoraService: agoraService,
        );
      },
      act: (cubit) async {
        cubit.loadRoom('r1');
        await Future<void>.delayed(Duration.zero);

        // Generic error arrives
        roomController!.addError(Exception('network'));
        await Future<void>.delayed(Duration.zero);

        // Room data arrives, recovering
        roomController!.add(
          testRoom(players: [testPlayer(name: 'Me', isMe: true)]),
        );
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => [
        const RoomState.loading(),
        const RoomState.error(
          message: 'Failed to load room. Please try again.',
        ),
        isA<RoomLoaded>(),
      ],
    );
  });

  // ===========================================================================
  // 7. Rematch Flow
  // ===========================================================================
  group('Rematch flow', () {
    blocTest<GameCubit, GameState>(
      'rematch calls repository with room id from game state',
      build: () {
        when(() => gameRepository.rematch('r1')).thenAnswer((_) async {});
        return GameCubit(
          gameRepository: gameRepository,
          roomRepository: roomRepository,
          agoraService: agoraService,
          audioService: audioService,
        );
      },
      seed: () => GameState.gameEnd(
        game: testGame(status: 'gameEnd', roomId: 'r1'),
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
        return GameCubit(
          gameRepository: gameRepository,
          roomRepository: roomRepository,
          agoraService: agoraService,
          audioService: audioService,
        );
      },
      seed: () => GameState.gameEnd(
        game: testGame(status: 'gameEnd', roomId: null),
        winnerTeam: 'A',
      ),
      act: (cubit) => cubit.rematch(),
      expect: () => const <GameState>[],
      verify: (_) {
        verifyNever(() => gameRepository.rematch(any()));
      },
    );
  });

  // ===========================================================================
  // 8. Spectator Mode
  // ===========================================================================
  group('Spectator mode', () {
    blocTest<GameCubit, GameState>(
      'watchGameAsSpectator uses spectator stream and joins Agora',
      build: () {
        when(() => gameRepository.watchGameAsSpectator('g1')).thenAnswer(
          (_) => Stream.value(testGame(agoraChannelName: 'room_r1')),
        );
        return GameCubit(
          gameRepository: gameRepository,
          roomRepository: roomRepository,
          agoraService: agoraService,
          audioService: audioService,
        );
      },
      act: (cubit) => cubit.watchGameAsSpectator('g1'),
      expect: () => [const GameState.loading(), isA<GamePlaying>()],
      verify: (_) {
        verify(() => gameRepository.watchGameAsSpectator('g1')).called(1);
        verify(
          () => agoraService.joinChannel(
            channelName: 'room_r1',
            agoraUid: any(named: 'agoraUid'),
            subscribeVideo: false,
          ),
        ).called(1);
      },
    );
  });

  // ===========================================================================
  // 9. Leave Game Full Flow
  // ===========================================================================
  group('Leave game full flow', () {
    blocTest<GameCubit, GameState>(
      'leaveGame cancels subscription, leaves room, leaves Agora, emits initial',
      build: () {
        when(
          () => gameRepository.watchGame('g1'),
        ).thenAnswer((_) => Stream.value(testGame()));
        when(() => roomRepository.leaveRoom('r1')).thenAnswer((_) async {});
        return GameCubit(
          gameRepository: gameRepository,
          roomRepository: roomRepository,
          agoraService: agoraService,
          audioService: audioService,
        );
      },
      act: (cubit) async {
        cubit.watchGame('g1');
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);
        await cubit.leaveGame();
      },
      skip: 3,
      expect: () => [const GameState.initial()],
      verify: (_) {
        verify(() => roomRepository.leaveRoom('r1')).called(1);
        verify(() => agoraService.leaveChannel()).called(1);
      },
    );
  });
}
