import 'package:flutter/foundation.dart';

import 'package:bloot/features/game/presentation/widgets/playing_card/playing_card_model.dart';

/// The four suits used in 32-card Saudi Baloot.
enum BalootSuit {
  spades(symbol: '♠', code: 'S'),
  hearts(symbol: '♥', code: 'H'),
  diamonds(symbol: '♦', code: 'D'),
  clubs(symbol: '♣', code: 'C');

  const BalootSuit({required this.symbol, required this.code});

  final String symbol;
  final String code;

  bool get isRed => this == hearts || this == diamonds;

  static BalootSuit fromCode(String code) =>
      values.firstWhere((s) => s.code == code.toUpperCase(), orElse: () => fromSymbol(code));

  static BalootSuit fromSymbol(String symbol) =>
      values.firstWhere((s) => s.symbol == symbol, orElse: () => throw FormatException('Invalid suit: $symbol'));

  CardSuit toCardSuit() => CardSuit.fromSymbol(symbol);
}

/// The eight ranks used in 32-card Saudi Baloot.
enum BalootRank {
  seven(label: '7'),
  eight(label: '8'),
  nine(label: '9'),
  ten(label: '10'),
  jack(label: 'J'),
  queen(label: 'Q'),
  king(label: 'K'),
  ace(label: 'A');

  const BalootRank({required this.label});

  final String label;

  static BalootRank fromLabel(String label) =>
      values.firstWhere((r) => r.label == label, orElse: () => throw FormatException('Invalid rank: $label'));

  CardRank toCardRank() => CardRank.fromLabel(label);
}

/// Immutable value object representing a single 32-card Baloot card.
@immutable
class BalootCard {
  const BalootCard({required this.suit, required this.rank});

  factory BalootCard.fromString(String card) {
    if (card.length < 2) throw FormatException('Invalid card string: $card');
    final suitSymbol = card.substring(card.length - 1);
    final rankLabel = card.substring(0, card.length - 1);
    return BalootCard(
      suit: BalootSuit.fromSymbol(suitSymbol),
      rank: BalootRank.fromLabel(rankLabel),
    );
  }

  factory BalootCard.fromJson(Object json) {
    final s = json as String;
    return BalootCard.fromString(s);
  }

  final BalootSuit suit;
  final BalootRank rank;

  String get key => '${rank.label}${suit.symbol}';

  bool get isRed => suit.isRed;

  PlayingCard toPlayingCard() => PlayingCard(rank: rank.toCardRank(), suit: suit.toCardSuit());

  static BalootCard fromPlayingCard(PlayingCard card) => BalootCard(
        rank: BalootRank.fromLabel(card.rank.label),
        suit: BalootSuit.fromSymbol(card.suit.symbol),
      );

  Object toJson() => key;

  @override
  String toString() => key;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is BalootCard && suit == other.suit && rank == other.rank;

  @override
  int get hashCode => suit.hashCode ^ rank.hashCode;
}
