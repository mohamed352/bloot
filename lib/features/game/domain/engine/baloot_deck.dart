import 'dart:math';

import 'package:bloot/features/game/domain/engine/baloot_card.dart';

/// Represents the 32-card Baloot deck and dealing operations.
class BalootDeck {
  BalootDeck({Random? random}) : _random = random ?? Random();

  final Random _random;

  /// Creates a fresh ordered 32-card deck.
  static List<BalootCard> makeDeck() {
    final deck = <BalootCard>[];
    for (final suit in BalootSuit.values) {
      for (final rank in BalootRank.values) {
        deck.add(BalootCard(suit: suit, rank: rank));
      }
    }
    return deck;
  }

  /// Fisher-Yates shuffle.
  List<BalootCard> shuffle(List<BalootCard> cards) {
    final result = List<BalootCard>.from(cards);
    for (var i = result.length - 1; i > 0; i--) {
      final j = _random.nextInt(i + 1);
      final tmp = result[i];
      result[i] = result[j];
      result[j] = tmp;
    }
    return result;
  }

  /// Returns a shuffled 32-card deck.
  List<BalootCard> shuffledDeck() => shuffle(makeDeck());
}

/// Result of a Baloot deal.
class BalootDealResult {
  const BalootDealResult({
    required this.hands,
    required this.topCard,
    required this.rest,
    required this.firstPlayer,
  });

  /// Four hands of 8 cards each after the full deal.
  final List<List<BalootCard>> hands;

  /// The face-up card that determines the proposed trump / first-round Hokm.
  final BalootCard topCard;

  /// The remaining 11 cards dealt in phase 2 (used internally by the engine).
  final List<BalootCard> rest;

  /// Seat index of the first player to bid / play.
  final int firstPlayer;
}

/// Performs the Saudi Baloot 2-phase deal.
///
/// Phase 1: 5 cards to each player.
/// Face-up card is revealed.
/// Phase 2: remaining 11 cards distributed so each player ends with 8.
BalootDealResult dealBalootHands({
  required BalootDeck deck,
  required int dealer,
}) {
  final d = deck.shuffledDeck();
  final hands = List.generate(4, (_) => <BalootCard>[]);
  final firstPlayer = (dealer + 1) % 4;

  // Phase 1: 5 cards each.
  var di = 0;
  for (var round = 0; round < 5; round++) {
    for (var p = 0; p < 4; p++) {
      hands[(firstPlayer + p) % 4].add(d[di++]);
    }
  }

  final topCard = d[di++];
  final rest = d.sublist(di); // 11 cards

  return BalootDealResult(
    hands: hands,
    topCard: topCard,
    rest: rest,
    firstPlayer: firstPlayer,
  );
}
