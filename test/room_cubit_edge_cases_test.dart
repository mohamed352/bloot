import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bloot/core/services/agora_service.dart';
import 'package:bloot/features/room/domain/entities/create_room_params.dart';
import 'package:bloot/features/room/domain/entities/room.dart';
import 'package:bloot/features/room/domain/exceptions/room_exception.dart';
import 'package:bloot/features/room/presentation/cubit/room_cubit.dart';
import 'package:bloot/features/room/presentation/cubit/room_state.dart';

import 'helpers/test_helpers.dart';

void main() {
  setUpAll(setupWidgetTests);

  late MockRoomRepository roomRepository;
  late MockAgoraService agoraService;

  setUp(() {
    roomRepository = MockRoomRepository();
    agoraService = MockAgoraService();
    stubAgoraServiceDefaults(agoraService);
  });

  RoomCubit buildCubit() =>
      RoomCubit(roomRepository: roomRepository, agoraService: agoraService);

  final loadedRoom = testRoom(players: [testPlayer(name: 'Me', isMe: true)]);

  group('leaveRoom error handling', () {
    blocTest<RoomCubit, RoomState>(
      'emits error then restores loaded state on RoomException',
      build: () {
        when(
          () => roomRepository.watchRoom('r1'),
        ).thenAnswer((_) => Stream.value(loadedRoom));
        when(
          () => roomRepository.leaveRoom('r1'),
        ).thenThrow(const RoomException('Cannot leave'));
        return buildCubit();
      },
      act: (cubit) async {
        cubit.loadRoom('r1');
        await Future<void>.delayed(Duration.zero);
        await cubit.leaveRoom('r1');
      },
      skip: 2,
      expect: () => [
        isA<RoomError>().having((s) => s.message, 'message', 'Cannot leave'),
        isA<RoomLoaded>(),
      ],
    );

    blocTest<RoomCubit, RoomState>(
      'emits generic error then restores loaded state on generic exception',
      build: () {
        when(
          () => roomRepository.watchRoom('r1'),
        ).thenAnswer((_) => Stream.value(loadedRoom));
        when(
          () => roomRepository.leaveRoom('r1'),
        ).thenThrow(Exception('network'));
        return buildCubit();
      },
      act: (cubit) async {
        cubit.loadRoom('r1');
        await Future<void>.delayed(Duration.zero);
        await cubit.leaveRoom('r1');
      },
      skip: 2,
      expect: () => [
        const RoomState.error(
          message: 'Failed to leave room. Please try again.',
        ),
        isA<RoomLoaded>(),
      ],
    );
  });

  group('kickPlayer error handling', () {
    blocTest<RoomCubit, RoomState>(
      'emits error then restores state on RoomException',
      build: () {
        when(
          () => roomRepository.watchRoom('r1'),
        ).thenAnswer((_) => Stream.value(loadedRoom));
        when(
          () => roomRepository.kickPlayer('r1', 'u2'),
        ).thenThrow(const RoomException('Not host'));
        return buildCubit();
      },
      act: (cubit) async {
        cubit.loadRoom('r1');
        await Future<void>.delayed(Duration.zero);
        await cubit.kickPlayer('r1', 'u2');
      },
      skip: 2,
      expect: () => [
        isA<RoomError>().having((s) => s.message, 'message', 'Not host'),
        isA<RoomLoaded>(),
      ],
    );

    blocTest<RoomCubit, RoomState>(
      'emits generic error then restores state on generic exception',
      build: () {
        when(
          () => roomRepository.watchRoom('r1'),
        ).thenAnswer((_) => Stream.value(loadedRoom));
        when(
          () => roomRepository.kickPlayer('r1', 'u2'),
        ).thenThrow(Exception('network'));
        return buildCubit();
      },
      act: (cubit) async {
        cubit.loadRoom('r1');
        await Future<void>.delayed(Duration.zero);
        await cubit.kickPlayer('r1', 'u2');
      },
      skip: 2,
      expect: () => [
        const RoomState.error(
          message: 'Failed to kick player. Please try again.',
        ),
        isA<RoomLoaded>(),
      ],
    );
  });

  group('toggleReady error handling', () {
    blocTest<RoomCubit, RoomState>(
      'emits error then restores state on RoomException',
      build: () {
        when(
          () => roomRepository.watchRoom('r1'),
        ).thenAnswer((_) => Stream.value(loadedRoom));
        when(
          () => roomRepository.toggleReady('r1'),
        ).thenThrow(const RoomException('Not in room'));
        return buildCubit();
      },
      act: (cubit) async {
        cubit.loadRoom('r1');
        await Future<void>.delayed(Duration.zero);
        await cubit.toggleReady('r1');
      },
      skip: 2,
      expect: () => [
        isA<RoomError>().having((s) => s.message, 'message', 'Not in room'),
        isA<RoomLoaded>(),
      ],
    );

    blocTest<RoomCubit, RoomState>(
      'emits generic error then restores state on generic exception',
      build: () {
        when(
          () => roomRepository.watchRoom('r1'),
        ).thenAnswer((_) => Stream.value(loadedRoom));
        when(
          () => roomRepository.toggleReady('r1'),
        ).thenThrow(Exception('network'));
        return buildCubit();
      },
      act: (cubit) async {
        cubit.loadRoom('r1');
        await Future<void>.delayed(Duration.zero);
        await cubit.toggleReady('r1');
      },
      skip: 2,
      expect: () => [
        const RoomState.error(message: 'Failed to update ready status.'),
        isA<RoomLoaded>(),
      ],
    );

    blocTest<RoomCubit, RoomState>(
      'does nothing when not in loaded state',
      build: buildCubit,
      act: (cubit) => cubit.toggleReady('r1'),
      expect: () => const <RoomState>[],
    );
  });

  group('toggleMic error handling', () {
    blocTest<RoomCubit, RoomState>(
      'emits error when AgoraService throws',
      build: () {
        when(
          () => roomRepository.watchRoom('r1'),
        ).thenAnswer((_) => Stream.value(loadedRoom));
        when(
          () => agoraService.toggleMic(),
        ).thenThrow(Exception('Agora error'));
        return buildCubit();
      },
      act: (cubit) async {
        cubit.loadRoom('r1');
        await Future<void>.delayed(Duration.zero);
        await cubit.toggleMic('r1');
      },
      skip: 2,
      expect: () => [
        const RoomState.error(message: 'Failed to toggle microphone.'),
        isA<RoomLoaded>(),
      ],
    );

    blocTest<RoomCubit, RoomState>(
      'emits error when repository throws RoomException',
      build: () {
        when(
          () => roomRepository.watchRoom('r1'),
        ).thenAnswer((_) => Stream.value(loadedRoom));
        when(() => agoraService.toggleMic()).thenAnswer((_) async => true);
        when(
          () => roomRepository.updatePlayerMediaState(
            'r1',
            isMicOn: any(named: 'isMicOn'),
            isCameraOn: any(named: 'isCameraOn'),
          ),
        ).thenThrow(const RoomException('Firestore error'));
        return buildCubit();
      },
      act: (cubit) async {
        cubit.loadRoom('r1');
        await Future<void>.delayed(Duration.zero);
        await cubit.toggleMic('r1');
      },
      skip: 2,
      expect: () => [
        isA<RoomError>().having((s) => s.message, 'message', 'Firestore error'),
        isA<RoomLoaded>(),
      ],
    );

    blocTest<RoomCubit, RoomState>(
      'does nothing when not in loaded state',
      build: buildCubit,
      act: (cubit) => cubit.toggleMic('r1'),
      expect: () => const <RoomState>[],
    );
  });

  group('toggleCamera error handling', () {
    blocTest<RoomCubit, RoomState>(
      'emits error when AgoraService throws',
      build: () {
        when(
          () => roomRepository.watchRoom('r1'),
        ).thenAnswer((_) => Stream.value(loadedRoom));
        when(
          () => agoraService.toggleCamera(),
        ).thenThrow(Exception('Agora error'));
        return buildCubit();
      },
      act: (cubit) async {
        cubit.loadRoom('r1');
        await Future<void>.delayed(Duration.zero);
        await cubit.toggleCamera('r1');
      },
      skip: 2,
      expect: () => [
        const RoomState.error(message: 'Failed to toggle camera.'),
        isA<RoomLoaded>(),
      ],
    );

    blocTest<RoomCubit, RoomState>(
      'emits error when repository throws RoomException',
      build: () {
        when(
          () => roomRepository.watchRoom('r1'),
        ).thenAnswer((_) => Stream.value(loadedRoom));
        when(() => agoraService.toggleCamera()).thenAnswer((_) async => true);
        when(
          () => roomRepository.updatePlayerMediaState(
            'r1',
            isMicOn: any(named: 'isMicOn'),
            isCameraOn: any(named: 'isCameraOn'),
          ),
        ).thenThrow(const RoomException('Permission denied'));
        return buildCubit();
      },
      act: (cubit) async {
        cubit.loadRoom('r1');
        await Future<void>.delayed(Duration.zero);
        await cubit.toggleCamera('r1');
      },
      skip: 2,
      expect: () => [
        isA<RoomError>().having(
          (s) => s.message,
          'message',
          'Permission denied',
        ),
        isA<RoomLoaded>(),
      ],
    );

    blocTest<RoomCubit, RoomState>(
      'does nothing when not in loaded state',
      build: buildCubit,
      act: (cubit) => cubit.toggleCamera('r1'),
      expect: () => const <RoomState>[],
    );
  });

  group('startStream error handling', () {
    blocTest<RoomCubit, RoomState>(
      'emits error then restores state on failure',
      build: () {
        when(
          () => roomRepository.watchRoom('r1'),
        ).thenAnswer((_) => Stream.value(loadedRoom));
        when(
          () => roomRepository.startStream('r1'),
        ).thenThrow(Exception('Stream error'));
        return buildCubit();
      },
      act: (cubit) async {
        cubit.loadRoom('r1');
        await Future<void>.delayed(Duration.zero);
        await cubit.startStream('r1');
      },
      skip: 2,
      expect: () => [
        const RoomState.error(
          message: 'Failed to start stream. Please try again.',
        ),
        isA<RoomLoaded>(),
      ],
    );

    blocTest<RoomCubit, RoomState>(
      'does nothing when not in loaded state',
      build: buildCubit,
      act: (cubit) => cubit.startStream('r1'),
      expect: () => const <RoomState>[],
    );
  });

  group('endStream error handling', () {
    blocTest<RoomCubit, RoomState>(
      'emits error then restores state on failure',
      build: () {
        when(
          () => roomRepository.endStream('r1'),
        ).thenThrow(Exception('Stream error'));
        return buildCubit();
      },
      seed: () => RoomState.loaded(
        room: testRoom(
          type: RoomType.liveStream,
          players: [testPlayer(name: 'Creator', isMe: true)],
        ).copyWith(isStreaming: true, streamId: 'stream-r1'),
      ),
      act: (cubit) => cubit.endStream('r1'),
      expect: () => [
        const RoomState.error(
          message: 'Failed to end stream. Please try again.',
        ),
        isA<RoomLoaded>(),
      ],
    );

    blocTest<RoomCubit, RoomState>(
      'does nothing when not in loaded state',
      build: buildCubit,
      act: (cubit) => cubit.endStream('r1'),
      expect: () => const <RoomState>[],
    );
  });

  group('inviteBotsToRoom error handling', () {
    blocTest<RoomCubit, RoomState>(
      'emits error then restores state on RoomException',
      build: () {
        when(
          () => roomRepository.inviteBotsToRoom('r1'),
        ).thenThrow(const RoomException('No bots available'));
        return buildCubit();
      },
      seed: () => RoomState.loaded(room: loadedRoom),
      act: (cubit) => cubit.inviteBotsToRoom('r1'),
      expect: () => [
        isA<RoomError>().having(
          (s) => s.message,
          'message',
          'No bots available',
        ),
        isA<RoomLoaded>(),
      ],
    );

    blocTest<RoomCubit, RoomState>(
      'emits generic error then restores state on generic exception',
      build: () {
        when(
          () => roomRepository.inviteBotsToRoom('r1'),
        ).thenThrow(Exception('network'));
        return buildCubit();
      },
      seed: () => RoomState.loaded(room: loadedRoom),
      act: (cubit) => cubit.inviteBotsToRoom('r1'),
      expect: () => [
        const RoomState.error(
          message: 'Failed to invite bots. Please try again.',
        ),
        isA<RoomLoaded>(),
      ],
    );
  });

  group('createRoom generic exception', () {
    blocTest<RoomCubit, RoomState>(
      'emits generic error on non-RoomException',
      build: () {
        when(
          () => roomRepository.createRoom(any()),
        ).thenThrow(Exception('network'));
        return buildCubit();
      },
      act: (cubit) => cubit.createRoom(
        const CreateRoomParams(name: 'Test', type: RoomType.private),
      ),
      expect: () => [
        const RoomState.loading(),
        const RoomState.error(
          message: 'Failed to create room. Please try again.',
        ),
      ],
    );
  });

  group('Agora join with custom channel name', () {
    blocTest<RoomCubit, RoomState>(
      'uses room.agoraChannelName when provided',
      build: () {
        when(() => roomRepository.watchRoom('r1')).thenAnswer(
          (_) => Stream.value(
            testRoom(
              agoraChannelName: 'custom_channel',
              players: [testPlayer(name: 'Me', isMe: true)],
            ),
          ),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.loadRoom('r1'),
      expect: () => [const RoomState.loading(), isA<RoomLoaded>()],
      verify: (_) {
        verify(
          () => agoraService.joinChannel(channelName: 'custom_channel'),
        ).called(1);
      },
    );
  });

  group('Volume indication with no changes', () {
    blocTest<RoomCubit, RoomState>(
      'does not emit when volume event has no speaking changes',
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
              players: [
                testPlayer(
                  name: 'Me',
                  isMe: true,
                  agoraUid: 101,
                  isSpeaking: false,
                ),
              ],
            ),
          ),
        );
        return buildCubit();
      },
      act: (cubit) async {
        cubit.loadRoom('r1');
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);
        // Send a volume event with volume below threshold (no one speaking)
        // This should NOT produce a new emit since isSpeaking is already false
      },
      skip: 1,
      expect: () => [
        isA<RoomLoaded>().having(
          (s) => s.room.players.first.isSpeaking,
          'not speaking',
          false,
        ),
      ],
    );
  });

  group('loadRoom re-entrancy', () {
    blocTest<RoomCubit, RoomState>(
      'calling loadRoom twice cancels previous subscription',
      build: () {
        when(
          () => roomRepository.watchRoom('r1'),
        ).thenAnswer((_) => Stream.value(loadedRoom));
        when(
          () => roomRepository.watchRoom('r2'),
        ).thenAnswer((_) => Stream.value(testRoom(id: 'r2')));
        return buildCubit();
      },
      act: (cubit) async {
        cubit.loadRoom('r1');
        await Future<void>.delayed(Duration.zero);
        cubit.loadRoom('r2');
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => [
        const RoomState.loading(),
        isA<RoomLoaded>().having((s) => s.room.id, 'room id', 'r1'),
        const RoomState.loading(),
        isA<RoomLoaded>().having((s) => s.room.id, 'room id', 'r2'),
      ],
    );
  });

  group('close cleanup', () {
    blocTest<RoomCubit, RoomState>(
      'close leaves Agora channel if joined',
      build: () {
        when(
          () => roomRepository.watchRoom('r1'),
        ).thenAnswer((_) => Stream.value(loadedRoom));
        return buildCubit();
      },
      act: (cubit) async {
        cubit.loadRoom('r1');
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);
        await cubit.close();
      },
      verify: (_) {
        verify(() => agoraService.leaveChannel()).called(1);
      },
    );

    blocTest<RoomCubit, RoomState>(
      'close does not leave Agora when never joined',
      build: () {
        when(
          () => roomRepository.watchRoom('r1'),
        ).thenAnswer((_) => Stream.value(testRoom(players: const [])));
        return buildCubit();
      },
      act: (cubit) async {
        cubit.loadRoom('r1');
        await Future<void>.delayed(Duration.zero);
        await cubit.close();
      },
      verify: (_) {
        verifyNever(() => agoraService.leaveChannel());
      },
    );
  });

  group('joinRoomByCode generic exception', () {
    blocTest<RoomCubit, RoomState>(
      'emits generic error on non-RoomException',
      build: () {
        when(
          () => roomRepository.joinRoomByCode(
            'CODE123',
            password: any(named: 'password'),
          ),
        ).thenThrow(Exception('network'));
        return buildCubit();
      },
      act: (cubit) => cubit.joinRoomByCode('CODE123'),
      expect: () => [
        const RoomState.loading(),
        const RoomState.error(
          message: 'Failed to join room. Please check the code and try again.',
        ),
      ],
    );
  });

  group('startGame generic exception', () {
    blocTest<RoomCubit, RoomState>(
      'emits generic error on non-RoomException',
      build: () {
        when(
          () => roomRepository.startGame('r1'),
        ).thenThrow(Exception('network'));
        return buildCubit();
      },
      act: (cubit) => cubit.startGame('r1'),
      expect: () => [
        const RoomState.loading(),
        const RoomState.error(
          message: 'Failed to start game. Please try again.',
        ),
      ],
    );
  });

  group('createRoomWithBots generic exception', () {
    blocTest<RoomCubit, RoomState>(
      'emits generic error on non-RoomException',
      build: () {
        when(
          () => roomRepository.createRoomWithBots(),
        ).thenThrow(Exception('network'));
        return buildCubit();
      },
      act: (cubit) => cubit.createRoomWithBots(),
      expect: () => [
        const RoomState.loading(),
        const RoomState.error(
          message: 'Failed to start game with bots. Please try again.',
        ),
      ],
    );
  });

  group('watchPublicRooms error', () {
    blocTest<RoomCubit, RoomState>(
      'emits error when public rooms stream fails',
      build: () {
        when(
          () => roomRepository.watchPublicRooms(),
        ).thenAnswer((_) => Stream.error(Exception('network')));
        return buildCubit();
      },
      act: (cubit) => cubit.watchPublicRooms(),
      expect: () => [
        const RoomState.loading(),
        const RoomState.error(
          message: 'Failed to load public rooms. Please try again.',
        ),
      ],
    );
  });
}
