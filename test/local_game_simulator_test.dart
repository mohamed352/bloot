import 'dart:math';

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

void main() {
  group('LocalGameSimulator engine', () {
    test('deals 13 cards to each player using 5+4+4 pattern', () {
      final game = SimGame(id: 't1', random: Random(42));
      game.deal();

      for (final p in game.players) {
        expect(p.hand.length, 13);
      }
      expect(game.faceUpCard, isNotNull);
    });

    test('trump Jack beats trump 9 and non-trump Ace', () {
      final game = SimGame(id: 't1', random: Random(42));
      game.deal();
      game.gameType = 'hokm';
      game.faceUpCard = 'AH'; // hearts trump

      expect(SimGame.cardBeats('JH', '9H', 'H', 'H'), isTrue);
      expect(SimGame.cardBeats('9H', 'AH', 'H', 'H'), isTrue);
      expect(SimGame.cardBeats('AH', 'AS', 'H', 'H'), isTrue);
    });

    test('trump card beats non-trump leading suit', () {
      final game = SimGame(id: 't1', random: Random(42));
      game.deal();
      game.gameType = 'hokm';
      game.faceUpCard = 'AH'; // hearts trump

      expect(SimGame.cardBeats('2H', 'AS', 'S', 'H'), isTrue);
      expect(SimGame.cardBeats('AS', 'KH', 'S', 'H'), isFalse);
    });

    test('leading suit wins when no trump played', () {
      final game = SimGame(id: 't1', random: Random(42));
      game.deal();

      expect(SimGame.cardBeats('KS', 'QS', 'S', null), isTrue);
      expect(SimGame.cardBeats('QS', 'KS', 'S', null), isFalse);
      expect(SimGame.cardBeats('KH', 'QS', 'S', null), isFalse);
    });

    test('trump Jack is worth 20 points', () {
      expect(SimGame.cardPoints('JH', 'H'), 20);
      expect(SimGame.cardPoints('JH', 'S'), 2);
      expect(SimGame.cardPoints('9H', 'H'), 14);
    });

    test('Sun fall gives opponents 120', () {
      final game = SimGame(id: 't1', random: Random(42));
      game.deal();
      game.gameType = 'sun';
      game.biddingTeam = 'A';
      // Give team A 50 points, team B 70 points (bidder fails)
      game.players[0].takenCards = ['AH', 'KH', 'QH', 'JH', '10H'];
      game.players[2].takenCards = [];
      game.players[1].takenCards = [
        'AS',
        'KS',
        'QS',
        'JS',
        '10S',
        '9S',
        '8S',
        '7S',
        '6S',
        '5S',
        '4S',
        '3S',
        '2S',
      ];
      game.players[3].takenCards = [];

      final (teamA, teamB) = game.scoreRound();
      expect(teamA, 0);
      expect(teamB, 120);
    });

    test('Hokm fall gives opponents 152 plus bonuses', () {
      final game = SimGame(id: 't1', random: Random(42));
      game.deal();
      game.gameType = 'hokm';
      game.faceUpCard = 'AH';
      game.biddingTeam = 'B';
      // Team B bidder fails: A gets more points.
      game.players[0].takenCards = [
        'AH',
        'KH',
        'QH',
        'JH',
        '10H',
        '9H',
        '8H',
        '7H',
        '6H',
        '5H',
        '4H',
        '3H',
        '2H',
      ];
      game.players[2].takenCards = [];
      game.players[1].takenCards = [];
      game.players[3].takenCards = [];
      game.players[0].claimedBonuses = [];
      game.players[1].claimedBonuses = [];
      game.players[2].claimedBonuses = [];
      game.players[3].claimedBonuses = [];

      final (teamA, teamB) = game.scoreRound();
      expect(teamA, 152);
      expect(teamB, 0);
    });
  });

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

        // Advance until the human gets a turn in the playing phase.
        var foundHumanTurn = false;
        for (var i = 0; i < 200 && !foundHumanTurn; i++) {
          async.elapse(const Duration(milliseconds: 100));
          final playingStates = states.whereType<GamePlaying>().toList();
          if (playingStates.isNotEmpty && playingStates.last.game.isMyTurn) {
            foundHumanTurn = true;
          }
        }
        expect(
          foundHumanTurn,
          isTrue,
          reason: 'human should eventually get a turn',
        );

        final before = states.whereType<GamePlaying>().last;
        final handSizeBefore = before.game.myHand.length;

        // Advance past the human turn timeout.
        async.elapse(const Duration(milliseconds: 300));

        final after = states.whereType<GamePlaying>().last;
        expect(
          after.game.myHand.length,
          lessThan(handSizeBefore),
          reason: 'auto-play should remove a card from hand',
        );

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
        async.elapse(const Duration(seconds: 120));

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
        simulator.playCard('AH');
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

        // Advance until the human gets a turn in the playing phase.
        var foundHumanTurn = false;
        for (var i = 0; i < 200 && !foundHumanTurn; i++) {
          async.elapse(const Duration(milliseconds: 100));
          final playingStates = states.whereType<GamePlaying>().toList();
          if (playingStates.isNotEmpty && playingStates.last.game.isMyTurn) {
            foundHumanTurn = true;
          }
        }
        expect(foundHumanTurn, isTrue);

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

        // Advance until the human gets a turn in the playing phase.
        var foundHumanTurn = false;
        for (var i = 0; i < 200 && !foundHumanTurn; i++) {
          async.elapse(const Duration(milliseconds: 100));
          final playingStates = states.whereType<GamePlaying>().toList();
          if (playingStates.isNotEmpty && playingStates.last.game.isMyTurn) {
            foundHumanTurn = true;
          }
        }
        expect(foundHumanTurn, isTrue);

        final before = states.whereType<GamePlaying>().last;
        final handSizeBefore = before.game.myHand.length;

        // Play the first legal card from the hand.
        String? playedCard;
        for (final card in before.game.myHand) {
          simulator.playCard(card);
          async.flushMicrotasks();
          final after = states.whereType<GamePlaying>().last;
          if (after.game.myHand.length == handSizeBefore - 1) {
            playedCard = card;
            break;
          }
        }

        expect(playedCard, isNotNull);
        final after = states.whereType<GamePlaying>().last;
        expect(after.game.myHand.length, handSizeBefore - 1);
        expect(after.game.myHand, isNot(contains(playedCard)));

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
        async.elapse(const Duration(seconds: 120));
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
        async.elapse(const Duration(seconds: 240));

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
        trump: 'H',
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
