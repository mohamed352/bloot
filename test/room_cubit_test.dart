import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bloot/core/services/agora_service.dart';
import 'package:bloot/features/room/domain/entities/room.dart';
import 'package:bloot/features/room/domain/exceptions/room_exception.dart';
import 'package:bloot/features/room/domain/repositories/room_repository.dart';
import 'package:bloot/features/room/presentation/cubit/room_cubit.dart';
import 'package:bloot/features/room/presentation/cubit/room_state.dart';

class MockRoomRepository extends Mock implements RoomRepository {}

class MockAgoraService extends Mock implements AgoraService {}

class FakeCreateRoomParams extends Fake implements CreateRoomParams {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeCreateRoomParams());
  });

  late MockRoomRepository roomRepository;
  late MockAgoraService agoraService;

  setUp(() {
    roomRepository = MockRoomRepository();
    agoraService = MockAgoraService();
    when(() => agoraService.joinChannel(channelName: any(named: 'channelName')))
        .thenAnswer((_) async {});
    when(() => agoraService.leaveChannel()).thenAnswer((_) async {});
    when(() => agoraService.onAudioVolumeIndication)
        .thenAnswer((_) => const Stream.empty());
    when(() => agoraService.toggleMic()).thenAnswer((_) async => false);
    when(() => agoraService.toggleCamera()).thenAnswer((_) async => false);
    when(() => agoraService.isMicOn).thenReturn(true);
    when(() => agoraService.isCameraOn).thenReturn(false);
  });

  const room = Room(
    id: 'r1',
    name: 'Test Room',
    type: RoomType.private,
  );

  const roomWithMe = Room(
    id: 'r1',
    name: 'Test Room',
    type: RoomType.private,
    players: [
      RoomPlayer(uid: 'u1', name: 'Me', isMe: true),
    ],
  );

  RoomCubit buildCubit() => RoomCubit(
        roomRepository: roomRepository,
        agoraService: agoraService,
      );

  group('createRoom', () {
    blocTest<RoomCubit, RoomState>(
      'emits created state on success',
      build: buildCubit,
      setUp: () {
        when(() => roomRepository.createRoom(any()))
            .thenAnswer((_) async => room);
      },
      act: (cubit) => cubit.createRoom(
        const CreateRoomParams(name: 'Test', type: RoomType.private),
      ),
      expect: () => [
        const RoomState.loading(),
        const RoomState.created(room: room),
      ],
    );

    blocTest<RoomCubit, RoomState>(
      'emits error on RoomException',
      build: buildCubit,
      setUp: () {
        when(() => roomRepository.createRoom(any()))
            .thenThrow(const RoomException('Name taken'));
      },
      act: (cubit) => cubit.createRoom(
        const CreateRoomParams(name: 'Test', type: RoomType.private),
      ),
      expect: () => [
        const RoomState.loading(),
        const RoomState.error(message: 'Name taken'),
      ],
    );
  });

  group('loadRoom', () {
    blocTest<RoomCubit, RoomState>(
      'emits loaded state with room',
      build: () {
        when(() => roomRepository.watchRoom('r1'))
            .thenAnswer((_) => Stream.value(room));
        when(() => roomRepository.watchChatMessages('r1'))
            .thenAnswer((_) => Stream.value(const []));
        return buildCubit();
      },
      act: (cubit) => cubit.loadRoom('r1'),
      expect: () => [
        const RoomState.loading(),
        isA<RoomLoaded>().having((s) => s.room.id, 'room id', 'r1'),
        isA<RoomLoaded>().having((s) => s.room.id, 'room id', 'r1'),
      ],
    );

    blocTest<RoomCubit, RoomState>(
      'emits gameStarted when room status is playing',
      build: () {
        final playingRoom = room.copyWith(
          status: RoomStatus.playing,
          gameId: 'g1',
        );
        when(() => roomRepository.watchRoom('r1'))
            .thenAnswer((_) => Stream.value(playingRoom));
        when(() => roomRepository.watchChatMessages('r1'))
            .thenAnswer((_) => const Stream.empty());
        return buildCubit();
      },
      act: (cubit) => cubit.loadRoom('r1'),
      expect: () => [
        const RoomState.loading(),
        isA<RoomGameStarted>().having((s) => s.gameId, 'gameId', 'g1'),
      ],
    );

    blocTest<RoomCubit, RoomState>(
      'emits error when room stream fails',
      build: () {
        when(() => roomRepository.watchRoom('r1'))
            .thenAnswer((_) => Stream.error(Exception('network')));
        when(() => roomRepository.watchChatMessages('r1'))
            .thenAnswer((_) => Stream.value(const []));
        return buildCubit();
      },
      act: (cubit) => cubit.loadRoom('r1'),
      expect: () => [
        const RoomState.loading(),
        const RoomState.error(message: 'Failed to load room. Please try again.'),
      ],
    );

    blocTest<RoomCubit, RoomState>(
      'joins agora when participant and voice enabled',
      build: () {
        when(() => roomRepository.watchRoom('r1'))
            .thenAnswer((_) => Stream.value(roomWithMe));
        when(() => roomRepository.watchChatMessages('r1'))
            .thenAnswer((_) => Stream.value(const []));
        return buildCubit();
      },
      act: (cubit) => cubit.loadRoom('r1'),
      expect: () => [
        const RoomState.loading(),
        isA<RoomLoaded>().having((s) => s.room.players.first.isMe, 'isMe', true),
        isA<RoomLoaded>().having((s) => s.room.players.first.isMe, 'isMe', true),
      ],
    );
  });

  group('joinRoomByCode', () {
    blocTest<RoomCubit, RoomState>(
      'emits created state on success',
      build: buildCubit,
      setUp: () {
        when(
          () => roomRepository.joinRoomByCode(
            'CODE123',
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => room);
      },
      act: (cubit) => cubit.joinRoomByCode('CODE123'),
      expect: () => [
        const RoomState.loading(),
        const RoomState.created(room: room),
      ],
    );

    blocTest<RoomCubit, RoomState>(
      'emits error on RoomException',
      build: buildCubit,
      setUp: () {
        when(
          () => roomRepository.joinRoomByCode(
            'CODE123',
            password: any(named: 'password'),
          ),
        ).thenThrow(const RoomException('Room full'));
      },
      act: (cubit) => cubit.joinRoomByCode('CODE123'),
      expect: () => [
        const RoomState.loading(),
        const RoomState.error(message: 'Room full'),
      ],
    );
  });

  group('toggleReady', () {
    blocTest<RoomCubit, RoomState>(
      'does nothing when not loaded',
      build: buildCubit,
      act: (cubit) => cubit.toggleReady('r1'),
      expect: () => const <RoomState>[],
    );
  });

  group('sendChatMessage', () {
    blocTest<RoomCubit, RoomState>(
      'does nothing when not loaded',
      build: buildCubit,
      act: (cubit) => cubit.sendChatMessage('r1', 'hello'),
      expect: () => const <RoomState>[],
    );
  });

  group('toggleChat', () {
    blocTest<RoomCubit, RoomState>(
      'toggles chat open flag',
      build: () {
        when(() => roomRepository.watchRoom('r1'))
            .thenAnswer((_) => Stream.value(room));
        when(() => roomRepository.watchChatMessages('r1'))
            .thenAnswer((_) => Stream.value(const []));
        return buildCubit();
      },
      act: (cubit) async {
        cubit.loadRoom('r1');
        await Future<void>.delayed(Duration.zero);
        cubit.toggleChat();
      },
      expect: () => [
        const RoomState.loading(),
        isA<RoomLoaded>().having((s) => s.room.id, 'room id', 'r1'),
        isA<RoomLoaded>().having((s) => s.room.id, 'room id', 'r1'),
        isA<RoomLoaded>().having(
          (s) => s.room.id == 'r1' && s.chatOpen,
          'chat open',
          true,
        ),
      ],
    );
  });

  group('watchPublicRooms', () {
    blocTest<RoomCubit, RoomState>(
      'emits public list loaded',
      build: () {
        when(() => roomRepository.watchPublicRooms())
            .thenAnswer((_) => Stream.value([room]));
        return buildCubit();
      },
      act: (cubit) => cubit.watchPublicRooms(),
      expect: () => [
        const RoomState.loading(),
        const RoomState.publicListLoaded(rooms: [room]),
      ],
    );
  });
}
