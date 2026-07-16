import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bloot/features/discover/domain/entities/discover_stream.dart';
import 'package:bloot/features/discover/presentation/cubit/discover_cubit.dart';
import 'package:bloot/features/discover/presentation/pages/watch_stream_page.dart';

import 'helpers/test_helpers.dart';

void main() {
  late MockDiscoverRepository discoverRepository;
  late MockAgoraService agoraService;
  late DiscoverCubit cubit;

  setUpAll(setupWidgetTests);

  setUp(() {
    discoverRepository = MockDiscoverRepository();
    agoraService = MockAgoraService();
    stubAgoraServiceDefaults(agoraService);

    cubit = DiscoverCubit(discoverRepository: discoverRepository);
  });

  tearDown(() async {
    await cubit.close();
  });

  group('WatchStreamPage', () {
    Future<void> pumpWatchStreamPage(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        buildTestableWidget(
          const WatchStreamPage(id: 's1'),
          discoverCubit: cubit,
          agoraService: agoraService,
        ),
      );
      await tester.pump();
    }

    testWidgets('renders stream title and host', (tester) async {
      await runWithFakeHttp(() async {
        when(
          () => discoverRepository.getStreamById('s1'),
        ).thenAnswer((_) async => testStream());
        when(
          () => discoverRepository.watchStream('s1'),
        ).thenAnswer((_) => const Stream.empty());
        when(
          () => discoverRepository.watchStreamChat('s1'),
        ).thenAnswer((_) => const Stream.empty());

        await pumpWatchStreamPage(tester);
        await cubit.loadStream('s1');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Live Baloot'), findsOneWidget);
        // The host name may also appear as the avatar fallback initials.
        expect(find.text('Ali'), findsWidgets);
      });
    });

    testWidgets('joins Agora as audience when stream loaded', (tester) async {
      await runWithFakeHttp(() async {
        when(
          () => discoverRepository.getStreamById('s1'),
        ).thenAnswer((_) async => testStream());
        when(
          () => discoverRepository.watchStream('s1'),
        ).thenAnswer((_) => const Stream.empty());
        when(
          () => discoverRepository.watchStreamChat('s1'),
        ).thenAnswer((_) => const Stream.empty());

        await pumpWatchStreamPage(tester);
        await cubit.loadStream('s1');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        verify(
          () => agoraService.joinAsAudience(channelName: 'stream_s1'),
        ).called(1);
      });
    });

    testWidgets('renders video grid with four player squares', (tester) async {
      await runWithFakeHttp(() async {
        when(
          () => discoverRepository.getStreamById('s1'),
        ).thenAnswer((_) async => testStream());
        when(
          () => discoverRepository.watchStream('s1'),
        ).thenAnswer((_) => const Stream.empty());
        when(
          () => discoverRepository.watchStreamChat('s1'),
        ).thenAnswer((_) => const Stream.empty());

        await pumpWatchStreamPage(tester);
        await cubit.loadStream('s1');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Ali'), findsWidgets);
        expect(find.text('Faisal'), findsOneWidget);
        expect(find.text('Omar'), findsOneWidget);
        expect(find.text('Khalid'), findsOneWidget);
      });
    });

    testWidgets('renders chat messages', (tester) async {
      await runWithFakeHttp(() async {
        when(
          () => discoverRepository.getStreamById('s1'),
        ).thenAnswer((_) async => testStream());
        when(
          () => discoverRepository.watchStream('s1'),
        ).thenAnswer((_) => const Stream.empty());
        when(() => discoverRepository.watchStreamChat('s1')).thenAnswer(
          (_) => Stream.value([
            const StreamChatMessage(
              id: 'm1',
              senderUid: 'u2',
              senderName: 'Faisal',
              text: 'Nice play!',
            ),
          ]),
        );

        await pumpWatchStreamPage(tester);
        await cubit.loadStream('s1');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Nice play!'), findsOneWidget);
        expect(find.text('Faisal'), findsWidgets);
      });
    });

    testWidgets('sends chat message on submit', (tester) async {
      await runWithFakeHttp(() async {
        when(
          () => discoverRepository.getStreamById('s1'),
        ).thenAnswer((_) async => testStream());
        when(
          () => discoverRepository.watchStream('s1'),
        ).thenAnswer((_) => const Stream.empty());
        when(
          () => discoverRepository.watchStreamChat('s1'),
        ).thenAnswer((_) => const Stream.empty());
        when(
          () => discoverRepository.sendChatMessage('s1', 'Hello stream'),
        ).thenAnswer((_) async {});

        await pumpWatchStreamPage(tester);
        await cubit.loadStream('s1');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        final input = find.byType(TextField);
        await tester.enterText(input, 'Hello stream');
        await tester.pump();

        await tester.tap(find.byIcon(Icons.send_rounded));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        verify(
          () => discoverRepository.sendChatMessage('s1', 'Hello stream'),
        ).called(1);
      });
    });

    testWidgets('shows viewer count from stream document', (tester) async {
      await runWithFakeHttp(() async {
        when(
          () => discoverRepository.getStreamById('s1'),
        ).thenAnswer((_) async => testStream(viewers: 10));
        when(
          () => discoverRepository.watchStream('s1'),
        ).thenAnswer((_) => const Stream.empty());
        when(
          () => discoverRepository.watchStreamChat('s1'),
        ).thenAnswer((_) => const Stream.empty());

        await pumpWatchStreamPage(tester);
        await cubit.loadStream('s1');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('10'), findsOneWidget);
      });
    });
  });
}
