import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bloot/core/services/agora_service.dart';
import 'package:bloot/features/game/presentation/cubit/game_cubit.dart';
import 'package:bloot/features/game/presentation/cubit/game_state.dart';
import 'package:bloot/features/room/presentation/cubit/room_cubit.dart';
import 'package:bloot/features/room/presentation/cubit/room_state.dart';

import 'helpers/test_helpers.dart';

void main() {
  group('RoomCubit voice/video flow', () {
    late MockRoomRepository roomRepository;
    late MockAgoraService agoraService;

    setUp(() {
      roomRepository = MockRoomRepository();
      agoraService = MockAgoraService();
      stubAgoraServiceDefaults(agoraService);
      when(() => agoraService.toggleMic()).thenAnswer((_) async => true);
      when(() => agoraService.toggleCamera()).thenAnswer((_) async => true);
    });

    RoomCubit buildCubit() =>
        RoomCubit(roomRepository: roomRepository, agoraService: agoraService);

    blocTest<RoomCubit, RoomState>(
      'joins Agora voice channel when participant and voice enabled',
      build: () {
        when(() => roomRepository.watchRoom('r1')).thenAnswer(
          (_) => Stream.value(
            testRoom(players: [testPlayer(name: 'Me', isMe: true)]),
          ),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.loadRoom('r1'),
      expect: () => [
        const RoomState.loading(),
        isA<RoomLoaded>().having((s) => s.room.id, 'room id', 'r1'),
      ],
      verify: (_) {
        verify(
          () => agoraService.joinChannel(channelName: 'room_r1'),
        ).called(1);
      },
    );

    blocTest<RoomCubit, RoomState>(
      'joins Agora video channel when participant and camera enabled',
      build: () {
        when(() => roomRepository.watchRoom('r1')).thenAnswer(
          (_) => Stream.value(
            testRoom(
              voiceEnabled: false,
              cameraEnabled: true,
              players: [testPlayer(name: 'Me', isMe: true)],
            ),
          ),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.loadRoom('r1'),
      expect: () => [
        const RoomState.loading(),
        isA<RoomLoaded>().having((s) => s.room.id, 'room id', 'r1'),
      ],
      verify: (_) {
        verify(
          () => agoraService.joinChannel(channelName: 'room_r1'),
        ).called(1);
      },
    );

    blocTest<RoomCubit, RoomState>(
      'does not join Agora when user is spectator only',
      build: () {
        when(
          () => roomRepository.watchRoom('r1'),
        ).thenAnswer((_) => Stream.value(testRoom(players: const [])));
        return buildCubit();
      },
      act: (cubit) => cubit.loadRoom('r1'),
      expect: () => [
        const RoomState.loading(),
        isA<RoomLoaded>().having(
          (s) => s.room.players.isEmpty,
          'no players',
          true,
        ),
      ],
      verify: (_) {
        verifyNever(
          () =>
              agoraService.joinChannel(channelName: any(named: 'channelName')),
        );
      },
    );

    blocTest<RoomCubit, RoomState>(
      'leaves Agora channel when leaving room',
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
      verify: (_) {
        verify(() => agoraService.leaveChannel()).called(1);
      },
    );

    blocTest<RoomCubit, RoomState>(
      'updates player isSpeaking from volume indication',
      build: () {
        final volumeController =
            StreamController<AgoraAudioVolumeIndicationEvent>.broadcast();
        addTearDown(() async => volumeController.close());
        when(
          () => agoraService.onAudioVolumeIndication,
        ).thenAnswer((_) => volumeController.stream);
        when(() => roomRepository.watchRoom('r1')).thenAnswer(
          (_) => Stream.value(
            testRoom(
              players: [testPlayer(name: 'Me', isMe: true, agoraUid: 123)],
            ),
          ),
        );

        return buildCubit();
      },
      act: (cubit) async {
        cubit.loadRoom('r1');
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => [
        const RoomState.loading(),
        isA<RoomLoaded>().having(
          (s) => s.room.players.first.isSpeaking,
          'not speaking',
          false,
        ),
      ],
    );

    blocTest<RoomCubit, RoomState>(
      'toggleMic updates media state through repository',
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
        return buildCubit();
      },
      act: (cubit) async {
        cubit.loadRoom('r1');
        await Future<void>.delayed(Duration.zero);
        await cubit.toggleMic('r1');
      },
      verify: (_) {
        verify(
          () => roomRepository.updatePlayerMediaState(
            'r1',
            isMicOn: true,
            isCameraOn: false,
          ),
        ).called(1);
      },
    );
  });

  group('GameCubit voice/video flow', () {
    late MockGameRepository gameRepository;
    late MockRoomRepository roomRepository;
    late MockAgoraService agoraService;
    late MockAudioService audioService;

    setUp(() {
      gameRepository = MockGameRepository();
      roomRepository = MockRoomRepository();
      agoraService = MockAgoraService();
      audioService = MockAudioService();
      when(
        () => agoraService.joinChannel(
          channelName: any(named: 'channelName'),
          agoraUid: any(named: 'agoraUid'),
          subscribeVideo: any(named: 'subscribeVideo'),
        ),
      ).thenAnswer((_) async {});
      when(() => agoraService.leaveChannel()).thenAnswer((_) async {});
      when(() => agoraService.toggleMic()).thenAnswer((_) async => true);
      when(() => agoraService.toggleCamera()).thenAnswer((_) async => true);
    });

    GameCubit buildCubit() => GameCubit(
      gameRepository: gameRepository,
      roomRepository: roomRepository,
      agoraService: agoraService,
      audioService: audioService,
    );

    blocTest<GameCubit, GameState>(
      'joins Agora when game has agoraChannelName',
      build: () {
        when(
          () => gameRepository.watchGame('g1'),
        ).thenAnswer((_) => Stream.value(testGame()));
        return buildCubit();
      },
      act: (cubit) => cubit.watchGame('g1'),
      expect: () => [const GameState.loading(), isA<GamePlaying>()],
      verify: (_) {
        verify(
          () => agoraService.joinChannel(
            channelName: 'room_r1',
            agoraUid: any(named: 'agoraUid'),
            subscribeVideo: false,
          ),
        ).called(1);
      },
    );

    blocTest<GameCubit, GameState>(
      'does not join Agora when channel name is missing',
      build: () {
        when(
          () => gameRepository.watchGame('g1'),
        ).thenAnswer((_) => Stream.value(testGame(agoraChannelName: null)));
        return buildCubit();
      },
      act: (cubit) => cubit.watchGame('g1'),
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

    blocTest<GameCubit, GameState>(
      'toggleMic updates player media state in room',
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
        return buildCubit();
      },
      act: (cubit) async {
        cubit.watchGame('g1');
        await Future<void>.delayed(Duration.zero);
        await cubit.toggleMic();
      },
      verify: (_) {
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
      'leaves Agora channel when game cubit closes',
      build: () {
        when(
          () => gameRepository.watchGame('g1'),
        ).thenAnswer((_) => Stream.value(testGame()));
        return buildCubit();
      },
      act: (cubit) async {
        cubit.watchGame('g1');
        await Future<void>.delayed(Duration.zero);
        await cubit.close();
      },
      verify: (_) {
        verify(() => agoraService.leaveChannel()).called(1);
      },
    );
  });
}
