import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bloot/features/discover/domain/entities/discover_stream.dart';
import 'package:bloot/features/discover/domain/repositories/discover_repository.dart';
import 'package:bloot/features/discover/presentation/cubit/discover_cubit.dart';
import 'package:bloot/features/discover/presentation/cubit/discover_state.dart';

class MockDiscoverRepository extends Mock implements DiscoverRepository {}

void main() {
  late MockDiscoverRepository discoverRepository;

  setUp(() {
    discoverRepository = MockDiscoverRepository();
  });

  const stream = DiscoverStream(
    id: 's1',
    title: 'Live Baloot',
    host: 'Ali',
    viewers: 42,
    avatarUrl: '',
  );

  const chatMessage = StreamChatMessage(
    id: 'cm1',
    senderUid: 'u1',
    senderName: 'Ali',
    text: 'Hello',
  );

  DiscoverCubit buildCubit() => DiscoverCubit(discoverRepository: discoverRepository);

  group('loadStreams', () {
    blocTest<DiscoverCubit, DiscoverState>(
      'emits loaded state with streams',
      build: buildCubit,
      setUp: () {
        when(() => discoverRepository.getStreams())
            .thenAnswer((_) async => [stream]);
      },
      act: (cubit) => cubit.loadStreams(),
      expect: () => [
        const DiscoverState.loading(),
        const DiscoverState.streamsLoaded(streams: [stream]),
      ],
    );

    blocTest<DiscoverCubit, DiscoverState>(
      'emits error when repository fails',
      build: buildCubit,
      setUp: () {
        when(() => discoverRepository.getStreams())
            .thenThrow(Exception('network'));
      },
      act: (cubit) => cubit.loadStreams(),
      expect: () => [
        const DiscoverState.loading(),
        const DiscoverState.error(message: 'Failed to load streams.'),
      ],
    );
  });

  group('selectFilter', () {
    blocTest<DiscoverCubit, DiscoverState>(
      'updates selected filter index',
      build: buildCubit,
      seed: () => const DiscoverState.streamsLoaded(
        streams: [stream],
      ),
      act: (cubit) => cubit.selectFilter(1),
      expect: () => [
        const DiscoverState.streamsLoaded(
          streams: [stream],
          selectedFilterIndex: 1,
        ),
      ],
    );

    blocTest<DiscoverCubit, DiscoverState>(
      'does nothing when not in streams loaded state',
      build: buildCubit,
      act: (cubit) => cubit.selectFilter(1),
      expect: () => const <DiscoverState>[],
    );
  });

  group('loadStream', () {
    blocTest<DiscoverCubit, DiscoverState>(
      'emits stream with empty chat immediately then updates on chat events',
      build: () {
        when(() => discoverRepository.getStreamById('s1'))
            .thenAnswer((_) async => stream);
        when(() => discoverRepository.watchStreamChat('s1')).thenAnswer(
          (_) => Stream.value([chatMessage]),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.loadStream('s1'),
      expect: () => [
        const DiscoverState.loading(),
        const DiscoverState.streamLoaded(stream: stream, messages: []),
        const DiscoverState.streamLoaded(stream: stream, messages: [chatMessage]),
      ],
    );

    blocTest<DiscoverCubit, DiscoverState>(
      'emits error when stream load fails',
      build: () {
        when(() => discoverRepository.getStreamById('s1'))
            .thenThrow(Exception('network'));
        return buildCubit();
      },
      act: (cubit) => cubit.loadStream('s1'),
      expect: () => [
        const DiscoverState.loading(),
        const DiscoverState.error(message: 'Failed to load stream.'),
      ],
    );

    blocTest<DiscoverCubit, DiscoverState>(
      'emits error when chat stream fails',
      build: () {
        when(() => discoverRepository.getStreamById('s1'))
            .thenAnswer((_) async => stream);
        when(() => discoverRepository.watchStreamChat('s1'))
            .thenAnswer((_) => Stream.error(Exception('network')));
        return buildCubit();
      },
      act: (cubit) => cubit.loadStream('s1'),
      expect: () => [
        const DiscoverState.loading(),
        const DiscoverState.streamLoaded(stream: stream, messages: []),
        const DiscoverState.error(message: 'Failed to load stream chat.'),
      ],
    );
  });

  group('sendChatMessage', () {
    blocTest<DiscoverCubit, DiscoverState>(
      'sends message through repository',
      build: buildCubit,
      setUp: () {
        when(() => discoverRepository.sendChatMessage('s1', 'hello'))
            .thenAnswer((_) async {});
      },
      act: (cubit) => cubit.sendChatMessage('s1', 'hello'),
      expect: () => const <DiscoverState>[],
    );
  });
}
