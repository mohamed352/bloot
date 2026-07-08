import 'dart:math';

import 'package:bloot/features/game/domain/engine/baloot_card.dart';
import 'package:bloot/features/game/domain/engine/baloot_engine.dart';
import 'package:bloot/features/game/domain/engine/baloot_rules.dart';
import 'package:bloot/features/game/domain/engine/baloot_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BalootEngine', () {
    late BalootEngine engine;

    setUp(() {
      engine = BalootEngine(random: Random(42));
    });

    test('deals 32 cards into four 8-card hands after bidding', () {
      final match = engine.createMatch([
        const BalootPlayerConfig(name: 'P0'),
        const BalootPlayerConfig(name: 'P1', isBot: true),
        const BalootPlayerConfig(name: 'P2', isBot: true),
        const BalootPlayerConfig(name: 'P3', isBot: true),
      ]);
      engine.startHand(match);
      engine.applyBid(match, match.state!.firstPlayer, const BidAction.sun());
      final state = match.state!;

      expect(state.hands.length, 4);
      for (final hand in state.hands) {
        expect(hand.length, 8);
      }
      expect(state.hands.expand((h) => h).toSet().length, 32);
    });

    test('bidding: sun wins immediately', () {
      final match = engine.createMatch([
        const BalootPlayerConfig(name: 'P0'),
        const BalootPlayerConfig(name: 'P1', isBot: true),
        const BalootPlayerConfig(name: 'P2', isBot: true),
        const BalootPlayerConfig(name: 'P3', isBot: true),
      ]);
      engine.startHand(match);
      final first = match.state!.firstPlayer;
      final events = engine.applyBid(match, first, const BidAction.sun());

      expect(events.any((e) => e['type'] == 'bidWon'), isTrue);
      expect(match.state!.mode, BalootMode.sun);
    });

    test('legal moves: must follow suit in sun', () {
      final match = engine.createMatch(List.generate(4, (i) => BalootPlayerConfig(name: 'P$i')));
      engine.startHand(match);
      engine.applyBid(match, match.state!.firstPlayer, const BidAction.sun());

      final state = match.state!;
      final leader = state.turn;
      final leaderHand = state.hands[leader];
      final ledCard = leaderHand.first;
      engine.playCard(match, leader, ledCard);

      final next = state.turn;
      final nextHand = state.hands[next];
      final legal = engine.legalMoves(state, next);
      final hasLedSuit = nextHand.any((c) => c.suit == ledCard.suit);

      if (hasLedSuit) {
        expect(legal.every((c) => c.suit == ledCard.suit), isTrue);
      } else {
        expect(legal.length, nextHand.length);
      }
    });

    test('a full hand reaches 8 tricks and produces a score', () {
      final match = engine.createMatch(List.generate(4, (i) => BalootPlayerConfig(name: 'P$i')));
      engine.startHand(match);
      engine.applyBid(match, match.state!.firstPlayer, const BidAction.sun());

      while (match.state!.phase != BalootPhase.handEnd) {
        final turn = match.state!.turn;
        final legal = engine.legalMoves(match.state!, turn);
        engine.playCard(match, turn, legal.first);
      }

      expect(match.state!.trickHistory.length, 8);
      expect(match.state!.result, isNotNull);
      expect(match.state!.result!.qaid[0] + match.state!.result!.qaid[1], 26); // sun round total
    });

    test('card points match sun table', () {
      expect(BalootRules.cardPoints(const BalootCard(suit: BalootSuit.spades, rank: BalootRank.ace), BalootMode.sun, null), 11);
      expect(BalootRules.cardPoints(const BalootCard(suit: BalootSuit.hearts, rank: BalootRank.ten), BalootMode.sun, null), 10);
      expect(BalootRules.cardPoints(const BalootCard(suit: BalootSuit.diamonds, rank: BalootRank.jack), BalootMode.hokum, BalootSuit.diamonds), 20);
      expect(BalootRules.cardPoints(const BalootCard(suit: BalootSuit.clubs, rank: BalootRank.nine), BalootMode.hokum, BalootSuit.diamonds), 0);
    });
  });
}
