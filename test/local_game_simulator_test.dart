import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bloot/core/services/agora_service.dart';
import 'package:bloot/core/services/audio_service.dart';
import 'package:bloot/features/game/domain/entities/game.dart';
import 'package:bloot/features/game/presentation/cubit/game_state.dart';
import 'package:bloot/features/game/presentation/cubit/local_game_simulator.dart';
import 'package:bloot/features/room/domain/repositories/room_repository.dart';
import 'package:bloot/generated/locale_keys.g.dart';

class MockRoomRepository extends Mock implements RoomRepository {}

class MockAgoraService extends Mock implements AgoraService {}

class MockAudioService extends Mock implements AudioService {}

/// Returns the most recent game-bearing state (playing, trickEnd or roundEnd).
Game? _latestGame(List<GameState> states) {
  for (var i = states.length - 1; i >= 0; i--) {
    final game = states[i].mapOrNull(
      playing: (s) => s.game,
      trickEnd: (s) => s.game,
      roundEnd: (s) => s.game,
    );
    if (game != null) return game;
  }
  return null;
}

/// Waits until the local player has a turn in the playing phase.
bool _waitForHumanTurn(
  FakeAsync async,
  List<GameState> states, {
  int maxIterations = 300,
}) {
  for (var i = 0; i < maxIterations; i++) {
    async.elapse(const Duration(milliseconds: 100));
    final game = _latestGame(states);
    if (game != null && game.isMyTurn && game.status == 'playing') {
      return true;
    }
  }
  return false;
}

/// Waits up to [maxSeconds] for a state whose hand size is different from
/// [previousSize]. Returns the new size or null if it never changes.
int? _waitForHandChange(
  FakeAsync async,
  List<GameState> states,
  int previousSize, {
  int maxSeconds = 10,
}) {
  final deadline = async.elapsed + Duration(seconds: maxSeconds);
  while (async.elapsed < deadline) {
    async.elapse(const Duration(milliseconds: 100));
    final game = _latestGame(states);
    if (game != null && game.myHand.length != previousSize) {
      return game.myHand.length;
    }
  }
  return null;
}

void main() {
  group('LocalGameSimulator cubit', () {
    setUp(() {
      final getIt = GetIt.instance;
      getIt.registerSingleton<RoomRepository>(MockRoomRepository());
      getIt.registerSingleton<AgoraService>(MockAgoraService());
      getIt.registerSingleton<AudioService>(MockAudioService());
    });

    tearDown(() async {
      await GetIt.instance.reset();
    });

    test('watchGame emits loading then dealing', () async {
      final simulator = LocalGameSimulator();
      final states = <GameState>[];
      final subscription = simulator.stream.listen(states.add);

      simulator.watchGame('sim_1');

      // Wait for the microtask that starts the game.
      await Future<void>.delayed(Duration.zero);

      expect(states.length, greaterThanOrEqualTo(2));
      expect(states.first, isA<GameLoading>());
      expect(states.last, isA<GameDealing>());

      await subscription.cancel();
      await simulator.close();
    });

    test('exposes players with camera off and mic muted', () async {
      final simulator = LocalGameSimulator();
      final states = <GameState>[];
      final subscription = simulator.stream.listen(states.add);

      simulator.watchGame('sim_1');

      // Wait for the dealing state to be emitted.
      await Future<void>.delayed(Duration.zero);

      final dealing = states.whereType<GameDealing>().firstOrNull;
      expect(dealing, isNotNull);
      for (final player in dealing!.game.players) {
        expect(
          player.hasCamera,
          isFalse,
          reason: 'simulator players should not render camera feeds',
        );
        expect(
          player.isMuted,
          isTrue,
          reason: 'simulator players should appear muted',
        );
      }

      await subscription.cancel();
      await simulator.close();
    });

    test('auto-plays a card when human turn times out', () {
      fakeAsync((async) {
        final simulator = LocalGameSimulator(
          humanTurnTimeout: const Duration(milliseconds: 200),
        );
        final states = <GameState>[];
        final subscription = simulator.stream.listen(states.add);

        simulator.watchGame('sim_1');
        async.flushMicrotasks();

        expect(
          _waitForHumanTurn(async, states),
          isTrue,
          reason: 'human should eventually get a turn',
        );

        final before = _latestGame(states)!;
        final handSizeBefore = before.myHand.length;

        // Wait for the auto-play to actually remove a card from the hand.
        final newSize = _waitForHandChange(async, states, handSizeBefore);
        expect(
          newSize,
          isNotNull,
          reason: 'auto-play should remove a card from hand',
        );
        expect(newSize, lessThan(handSizeBefore));

        subscription.cancel();
        simulator.close();
      });
    });

    test('scores update after a full round', () {
      fakeAsync((async) {
        final simulator = LocalGameSimulator(
          humanTurnTimeout: const Duration(milliseconds: 100),
        );
        final states = <GameState>[];
        final subscription = simulator.stream.listen(states.add);

        simulator.watchGame('sim_1');
        async.flushMicrotasks();

        // Advance enough fake time for a full round to complete.
        async.elapse(const Duration(seconds: 240));

        // Score should have changed from 0-0 at least once (in any state).
        final hasNonZeroScore = states.any((s) {
          final game = s.mapOrNull(
            dealing: (x) => x.game,
            bidding: (x) => x.game,
            bonusClaim: (x) => x.game,
            playing: (x) => x.game,
            trickEnd: (x) => x.game,
            roundEnd: (x) => x.game,
            gameEnd: (x) => x.game,
          );
          return game != null && (game.scoreUs != 0 || game.scoreThem != 0);
        });
        expect(
          hasNonZeroScore,
          isTrue,
          reason: 'score should update after a round completes',
        );

        subscription.cancel();
        simulator.close();
      });
    });

    test('humanTurnTimeoutDuration reflects configured timeout', () {
      final simulator = LocalGameSimulator(
        humanTurnTimeout: const Duration(seconds: 7),
      );
      expect(simulator.humanTurnTimeoutDuration, const Duration(seconds: 7));
      simulator.close();
    });

    test('emits error when playing card out of turn', () {
      fakeAsync((async) {
        final simulator = LocalGameSimulator(
          humanTurnTimeout: const Duration(days: 1),
        );
        final states = <GameState>[];
        final subscription = simulator.stream.listen(states.add);

        simulator.watchGame('sim_1');
        async.flushMicrotasks();

        // During dealing it is not the human's turn to play a card.
        simulator.playCard('A♠');
        async.flushMicrotasks();

        final lastState = states.last;
        final error = lastState.mapOrNull(
          dealing: (s) => s.lastActionError,
        );
        expect(error, isNotNull);
        expect(error, LocaleKeys.not_your_turn_card);

        subscription.cancel();
        simulator.close();
      });
    });

    test('emits error when playing an illegal card on human turn', () {
      fakeAsync((async) {
        final simulator = LocalGameSimulator(
          humanTurnTimeout: const Duration(milliseconds: 200),
          humanCardTimeout: const Duration(days: 1),
        );
        final states = <GameState>[];
        final subscription = simulator.stream.listen(states.add);

        simulator.watchGame('sim_1');
        async.flushMicrotasks();

        expect(
          _waitForHumanTurn(async, states),
          isTrue,
          reason: 'human should eventually get a turn',
        );

        // Playing a card that is not in the hand is illegal.
        simulator.playCard('ZZ');
        async.flushMicrotasks();

        final lastState = states.last;
        final error = lastState.mapOrNull(
          playing: (s) => s.lastActionError,
        );
        expect(error, isNotNull);
        expect(error, LocaleKeys.card_not_allowed);

        subscription.cancel();
        simulator.close();
      });
    });

    test('human played card appears on the table before trick ends', () {
      fakeAsync((async) {
        final simulator = LocalGameSimulator(
          humanTurnTimeout: const Duration(milliseconds: 200),
          humanCardTimeout: const Duration(days: 1),
        );
        final states = <GameState>[];
        final subscription = simulator.stream.listen(states.add);

        simulator.watchGame('sim_1');
        async.flushMicrotasks();

        expect(
          _waitForHumanTurn(async, states),
          isTrue,
          reason: 'human should eventually get a turn',
        );

        final before = _latestGame(states)!;
        final handSizeBefore = before.myHand.length;

        // Play the first legal card from the hand.
        String? playedCard;
        for (final card in before.myHand) {
          simulator.playCard(card);
          async.flushMicrotasks();
          final newSize = _waitForHandChange(async, states, handSizeBefore, maxSeconds: 3);
          if (newSize != null && newSize == handSizeBefore - 1) {
            playedCard = card;
            break;
          }
        }

        expect(playedCard, isNotNull);
        // The card should either be visible on the table in a GamePlaying state
        // or, if the human played the 4th card, the hand size should have
        // decreased and the trick should have ended.
        final onTable = states.any((s) {
          final g = s.mapOrNull(playing: (x) => x.game);
          return g != null &&
              g.myHand.length == handSizeBefore - 1 &&
              g.playedCards[g.mySeatIndex] == playedCard;
        });
        final after = _latestGame(states)!;
        expect(
          onTable || after.myHand.length == handSizeBefore - 1,
          isTrue,
          reason: 'played card should be removed from hand and visible when not the 4th card',
        );

        subscription.cancel();
        simulator.close();
      });
    });

    test('playCard removes a legal card from hand on human turn', () {
      fakeAsync((async) {
        final simulator = LocalGameSimulator(
          humanTurnTimeout: const Duration(milliseconds: 200),
          humanCardTimeout: const Duration(days: 1),
        );
        final states = <GameState>[];
        final subscription = simulator.stream.listen(states.add);

        simulator.watchGame('sim_1');
        async.flushMicrotasks();

        expect(
          _waitForHumanTurn(async, states),
          isTrue,
          reason: 'human should eventually get a turn',
        );

        final before = _latestGame(states)!;
        final handSizeBefore = before.myHand.length;

        // Play the first legal card from the hand.
        String? playedCard;
        for (final card in before.myHand) {
          simulator.playCard(card);
          async.flushMicrotasks();
          final newSize = _waitForHandChange(async, states, handSizeBefore, maxSeconds: 3);
          if (newSize != null && newSize == handSizeBefore - 1) {
            playedCard = card;
            break;
          }
        }

        expect(playedCard, isNotNull);
        final after = _latestGame(states)!;
        expect(after.myHand.length, handSizeBefore - 1);
        expect(after.myHand, isNot(contains(playedCard)));

        subscription.cancel();
        simulator.close();
      });
    });

    test('dealNextRound advances immediately from round end', () {
      fakeAsync((async) {
        final simulator = LocalGameSimulator(
          humanTurnTimeout: const Duration(milliseconds: 100),
        );
        final states = <GameState>[];
        final subscription = simulator.stream.listen(states.add);

        simulator.watchGame('sim_1');
        async.flushMicrotasks();

        // Wait until we reach a round-end state.
        final deadline = async.elapsed + const Duration(seconds: 240);
        while (async.elapsed < deadline && states.whereType<GameRoundEnd>().isEmpty) {
          async.elapse(const Duration(milliseconds: 100));
        }
        expect(states.whereType<GameRoundEnd>(), isNotEmpty);

        // Calling dealNextRound should move to loading/dealing without waiting
        // for the auto-advance timer.
        simulator.dealNextRound();
        async.flushMicrotasks();
        async.elapse(Duration.zero);

        expect(
          states.lastWhere((s) => s is GameLoading || s is GameDealing),
          isA<GameDealing>(),
        );

        subscription.cancel();
        simulator.close();
      });
    });

    test('rematch starts a new game from game end', () {
      fakeAsync((async) {
        final simulator = LocalGameSimulator(
          humanTurnTimeout: const Duration(milliseconds: 100),
        );
        final states = <GameState>[];
        final subscription = simulator.stream.listen(states.add);

        simulator.watchGame('sim_1');
        async.flushMicrotasks();

        // Advance enough to potentially reach game end, or at least round end.
        async.elapse(const Duration(seconds: 300));

        // Rematch should always restart the game.
        simulator.rematch();
        async.flushMicrotasks();
        async.elapse(Duration.zero);

        expect(
          states.whereType<GameLoading>().length,
          greaterThanOrEqualTo(2),
          reason: 'rematch should emit loading again',
        );
        expect(states.last, isA<GameDealing>());

        subscription.cancel();
        simulator.close();
      });
    });
  });

  group('Game legalCards', () {
    Game makeGame({
      required List<String> hand,
      required int turnIndex,
      required String status,
      String? leadingSuit,
    }) {
      return Game(
        id: 'test',
        players: const [],
        myHand: hand,
        mySeatIndex: 0,
        playedCards: const [null, null, null, null],
        scoreUs: 0,
        scoreThem: 0,
        teamAScore: 0,
        teamBScore: 0,
        trump: '♥',
        status: status,
        turnIndex: turnIndex,
        currentRound: 1,
        targetScore: 152,
        currentTrick: leadingSuit == null
            ? null
            : Trick(
                trickNumber: 1,
                trickLeaderIndex: 1,
                leadingSuit: leadingSuit,
              ),
      );
    }

    test('returns empty list when it is not the local player turn', () {
      final game = makeGame(
        hand: const ['A♠', 'K♠'],
        turnIndex: 1,
        status: 'playing',
      );
      expect(game.legalCards, isEmpty);
    });

    test('returns empty list outside playing phase', () {
      final game = makeGame(
        hand: const ['A♠', 'K♠'],
        turnIndex: 0,
        status: 'bidding',
      );
      expect(game.legalCards, isEmpty);
    });

    test('returns whole hand when player leads the trick', () {
      final game = makeGame(
        hand: const ['A♠', 'K♥', '10♦'],
        turnIndex: 0,
        status: 'playing',
      );
      expect(game.legalCards, equals(const ['A♠', 'K♥', '10♦']));
    });

    test('must follow the leading suit when possible', () {
      final game = makeGame(
        hand: const ['A♠', 'K♠', '10♥', 'J♦'],
        turnIndex: 0,
        status: 'playing',
        leadingSuit: '♠',
      );
      expect(game.legalCards, equals(const ['A♠', 'K♠']));
    });

    test('allows any card when unable to follow suit', () {
      final game = makeGame(
        hand: const ['A♥', 'K♥', '10♥'],
        turnIndex: 0,
        status: 'playing',
        leadingSuit: '♠',
      );
      expect(game.legalCards, equals(const ['A♥', 'K♥', '10♥']));
    });
  });
}
