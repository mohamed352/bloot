import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bloot/features/discover/domain/entities/discover_stream.dart';
import 'package:bloot/features/discover/presentation/cubit/discover_cubit.dart';
import 'package:bloot/features/discover/presentation/cubit/discover_state.dart';

import 'helpers/test_helpers.dart';

void main() {
  setUpAll(setupWidgetTests);

  late MockDiscoverRepository discoverRepository;

  setUp(() {
    discoverRepository = MockDiscoverRepository();
  });

  DiscoverCubit buildCubit() =>
      DiscoverCubit(discoverRepository: discoverRepository);

  final stream = testStream();
  const chatMessage = StreamChatMessage(
    id: 'cm1',
    senderUid: 'u2',
    senderName: 'Faisal',
    text: 'Nice play!',
  );
  const chatMessage2 = StreamChatMessage(
    id: 'cm2',
    senderUid: 'u3',
    senderName: 'Omar',
    text: 'Great game',
  );

  group('watchStream real-time updates', () {
    StreamController<DiscoverStream>? streamController;
    StreamController<List<StreamChatMessage>>? chatController;

    blocTest<DiscoverCubit, DiscoverState>(
      'emits updated stream when stream doc updates via watchStream',
      build: () {
        when(
          () => discoverRepository.getStreamById('s1'),
        ).thenAnswer((_) async => stream);
        when(
          () => discoverRepository.watchStream('s1'),
        ).thenAnswer((_) => Stream.value(stream.copyWith(viewers: 100)));
        when(
          () => discoverRepository.watchStreamChat('s1'),
        ).thenAnswer((_) => const Stream.empty());
        return buildCubit();
      },
      act: (cubit) => cubit.loadStream('s1'),
      expect: () => [
        const DiscoverState.loading(),
        DiscoverState.streamLoaded(stream: stream, messages: const []),
        DiscoverState.streamLoaded(
          stream: stream.copyWith(viewers: 100),
          messages: const [],
        ),
      ],
    );

    blocTest<DiscoverCubit, DiscoverState>(
      'interleaved stream and chat updates preserve latest from each',
      build: () {
        streamController = StreamController<DiscoverStream>();
        chatController = StreamController<List<StreamChatMessage>>();
        addTearDown(() async {
          await streamController!.close();
          await chatController!.close();
        });
        when(
          () => discoverRepository.getStreamById('s1'),
        ).thenAnswer((_) async => stream);
        when(
          () => discoverRepository.watchStream('s1'),
        ).thenAnswer((_) => streamController!.stream);
        when(
          () => discoverRepository.watchStreamChat('s1'),
        ).thenAnswer((_) => chatController!.stream);
        return buildCubit();
      },
      act: (cubit) async {
        cubit.loadStream('s1');
        await Future<void>.delayed(Duration.zero);
        // Chat update arrives first
        chatController!.add([chatMessage]);
        await Future<void>.delayed(Duration.zero);
        // Stream doc update arrives with viewer count change
        streamController!.add(stream.copyWith(viewers: 200));
        await Future<void>.delayed(Duration.zero);
        // Another chat update with more messages
        chatController!.add([chatMessage, chatMessage2]);
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => [
        const DiscoverState.loading(),
        DiscoverState.streamLoaded(stream: stream, messages: const []),
        DiscoverState.streamLoaded(stream: stream, messages: [chatMessage]),
        DiscoverState.streamLoaded(
          stream: stream.copyWith(viewers: 200),
          messages: [chatMessage],
        ),
        DiscoverState.streamLoaded(
          stream: stream.copyWith(viewers: 200),
          messages: [chatMessage, chatMessage2],
        ),
      ],
    );
  });

  group('sendChatMessage return value', () {
    test('returns true on success', () async {
      when(
        () => discoverRepository.sendChatMessage('s1', 'hello'),
      ).thenAnswer((_) async {});
      final cubit = buildCubit();
      final result = await cubit.sendChatMessage('s1', 'hello');
      expect(result, isTrue);
    });

    test('returns false on failure', () async {
      when(
        () => discoverRepository.sendChatMessage('s1', 'hello'),
      ).thenThrow(Exception('network'));
      final cubit = buildCubit();
      final result = await cubit.sendChatMessage('s1', 'hello');
      expect(result, isFalse);
    });
  });

  group('findStreamByCode', () {
    test('delegates to repository and returns result', () async {
      when(
        () => discoverRepository.findStreamIdByCode('ABC123'),
      ).thenAnswer((_) async => 's1');
      final cubit = buildCubit();
      final result = await cubit.findStreamByCode('ABC123');
      expect(result, 's1');
    });

    test('returns null when no stream matches', () async {
      when(
        () => discoverRepository.findStreamIdByCode('NOPE'),
      ).thenAnswer((_) async => null);
      final cubit = buildCubit();
      final result = await cubit.findStreamByCode('NOPE');
      expect(result, isNull);
    });
  });

  group('close cleanup', () {
    blocTest<DiscoverCubit, DiscoverState>(
      'close cancels both stream and chat subscriptions',
      build: () {
        when(
          () => discoverRepository.getStreamById('s1'),
        ).thenAnswer((_) async => stream);
        when(
          () => discoverRepository.watchStream('s1'),
        ).thenAnswer((_) => const Stream.empty());
        when(
          () => discoverRepository.watchStreamChat('s1'),
        ).thenAnswer((_) => const Stream.empty());
        return buildCubit();
      },
      act: (cubit) async {
        cubit.loadStream('s1');
        await Future<void>.delayed(Duration.zero);
        await cubit.close();
      },
      // No errors should be thrown after close
    );
  });

  group('loadStream re-entrancy', () {
    blocTest<DiscoverCubit, DiscoverState>(
      'calling loadStream twice cancels previous subscriptions',
      build: () {
        when(
          () => discoverRepository.getStreamById('s1'),
        ).thenAnswer((_) async => stream);
        when(
          () => discoverRepository.getStreamById('s2'),
        ).thenAnswer((_) async => testStream(id: 's2', title: 'Other'));
        when(
          () => discoverRepository.watchStream('s1'),
        ).thenAnswer((_) => const Stream.empty());
        when(
          () => discoverRepository.watchStream('s2'),
        ).thenAnswer((_) => const Stream.empty());
        when(
          () => discoverRepository.watchStreamChat('s1'),
        ).thenAnswer((_) => const Stream.empty());
        when(
          () => discoverRepository.watchStreamChat('s2'),
        ).thenAnswer((_) => const Stream.empty());
        return buildCubit();
      },
      act: (cubit) async {
        cubit.loadStream('s1');
        await Future<void>.delayed(Duration.zero);
        cubit.loadStream('s2');
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => [
        const DiscoverState.loading(),
        DiscoverState.streamLoaded(stream: stream, messages: const []),
        const DiscoverState.loading(),
        DiscoverState.streamLoaded(
          stream: testStream(id: 's2', title: 'Other'),
          messages: const [],
        ),
      ],
    );
  });

  group('selectFilter does nothing in streamLoaded state', () {
    blocTest<DiscoverCubit, DiscoverState>(
      'does nothing when in streamLoaded (not streamsLoaded) state',
      build: buildCubit,
      seed: () =>
          DiscoverState.streamLoaded(stream: stream, messages: const []),
      act: (cubit) => cubit.selectFilter(1),
      expect: () => const <DiscoverState>[],
    );
  });

  group('watchStream error', () {
    blocTest<DiscoverCubit, DiscoverState>(
      'watchStream onError does not crash cubit',
      build: () {
        when(
          () => discoverRepository.getStreamById('s1'),
        ).thenAnswer((_) async => stream);
        when(
          () => discoverRepository.watchStream('s1'),
        ).thenAnswer((_) => Stream.error(Exception('stream error')));
        when(
          () => discoverRepository.watchStreamChat('s1'),
        ).thenAnswer((_) => const Stream.empty());
        return buildCubit();
      },
      act: (cubit) => cubit.loadStream('s1'),
      expect: () => [
        const DiscoverState.loading(),
        DiscoverState.streamLoaded(stream: stream, messages: const []),
      ],
    );
  });

  group('loadStreams with empty list', () {
    blocTest<DiscoverCubit, DiscoverState>(
      'emits empty streams loaded',
      build: () {
        when(
          () => discoverRepository.watchStreams(),
        ).thenAnswer((_) => Stream.value([]));
        return buildCubit();
      },
      act: (cubit) => cubit.loadStreams(),
      expect: () => [
        const DiscoverState.loading(),
        const DiscoverState.streamsLoaded(streams: []),
      ],
    );
  });
}
