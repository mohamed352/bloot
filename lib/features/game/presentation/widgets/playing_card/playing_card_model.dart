import 'package:flutter/material.dart';

/// Represents the four standard playing card suits.
enum CardSuit {
  spades(symbol: '♠', color: Color(0xFF000000)),
  hearts(symbol: '♥', color: Color(0xFFD32F2F)),
  diamonds(symbol: '♦', color: Color(0xFFD32F2F)),
  clubs(symbol: '♣', color: Color(0xFF000000));

  const CardSuit({required this.symbol, required this.color});

  /// Unicode suit symbol (♠ ♥ ♦ ♣).
  final String symbol;

  /// Traditional color for this suit.
  final Color color;

  /// Returns true for red suits (hearts & diamonds).
  bool get isRed => this == hearts || this == diamonds;

  /// Parses a suit from its Unicode symbol or ASCII code.
  static CardSuit fromSymbol(String symbol) {
    return switch (symbol) {
      '♠' || 'S' || 's' => CardSuit.spades,
      '♥' || 'H' || 'h' => CardSuit.hearts,
      '♦' || 'D' || 'd' => CardSuit.diamonds,
      '♣' || 'C' || 'c' => CardSuit.clubs,
      _ => throw FormatException('Invalid suit symbol: $symbol'),
    };
  }
}

/// Represents the thirteen standard playing card ranks.
enum CardRank {
  ace('A'),
  two('2'),
  three('3'),
  four('4'),
  five('5'),
  six('6'),
  seven('7'),
  eight('8'),
  nine('9'),
  ten('10'),
  jack('J'),
  queen('Q'),
  king('K');

  const CardRank(this.label);

  /// Display label (A, 2, 3 … 10, J, Q, K).
  final String label;

  /// Parses a rank from its label.
  static CardRank fromLabel(String label) {
    return CardRank.values.firstWhere(
      (r) => r.label == label,
      orElse: () => throw FormatException('Invalid rank label: $label'),
    );
  }
}

/// Immutable value object representing a single playing card.
@immutable
class PlayingCard {
  const PlayingCard({required this.rank, required this.suit});

  /// Parses a card from a string like `'A♠'` or `'10♥'`.
  factory PlayingCard.fromString(String card) {
    if (card.length < 2) {
      throw FormatException('Card string must be at least 2 chars: $card');
    }
    final suitSymbol = card.substring(card.length - 1);
    final rankLabel = card.substring(0, card.length - 1);
    return PlayingCard(
      rank: CardRank.fromLabel(rankLabel),
      suit: CardSuit.fromSymbol(suitSymbol),
    );
  }

  final CardRank rank;
  final CardSuit suit;

  /// True for red suits (hearts & diamonds).
  bool get isRed => suit.isRed;

  @override
  String toString() => '${rank.label}${suit.symbol}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayingCard &&
          runtimeType == other.runtimeType &&
          rank == other.rank &&
          suit == other.suit;

  @override
  int get hashCode => rank.hashCode ^ suit.hashCode;
}
