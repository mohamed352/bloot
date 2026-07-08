import 'package:bloot/features/game/domain/engine/baloot_card.dart';

/// Game mode in Saudi Baloot.
enum BalootMode { sun, hokum }

/// Bid actions available during the auction.
enum BidActionType { pass, hokum, sun, ashkal }

/// Project (masharee3) types.
enum ProjectType { sira, fifty, hundred, fourAces }

/// Violation types for qaid claims.
enum ViolationType { qatee, makabr, madaq, sawa, rubu }

/// Core rule constants ported from id7mgh/baloot-game engine.js.
abstract class BalootRules {
  BalootRules._();

  static const List<BalootSuit> suits = BalootSuit.values;
  static const List<BalootRank> ranks = BalootRank.values;

  /// Natural order used for sequence detection (7 through A).
  static const List<String> naturalOrder = ['7', '8', '9', '10', 'J', 'Q', 'K', 'A'];

  /// Card strength order in Sun mode and non-trump Hokm suits.
  static const List<String> sunOrder = ['7', '8', '9', 'J', 'Q', 'K', '10', 'A'];

  /// Card strength order in the Hokm trump suit.
  static const List<String> hokumTrumpOrder = ['7', '8', 'Q', 'K', '10', 'A', '9', 'J'];

  /// Point values in Sun mode / non-trump suits.
  static const Map<String, int> sunPoints = {
    'A': 11,
    '10': 10,
    'K': 4,
    'Q': 3,
    'J': 2,
    '9': 0,
    '8': 0,
    '7': 0,
  };

  /// Point values in the Hokm trump suit.
  static const Map<String, int> hokumTrumpPoints = {
    'J': 20,
    '9': 14,
    'A': 11,
    '10': 10,
    'K': 4,
    'Q': 3,
    '8': 0,
    '7': 0,
  };

  /// Point values for non-trump suits in Hokm mode.
  static const Map<String, int> hokumPlainPoints = sunPoints;

  /// Project points in Sun mode (qaid).
  static const Map<ProjectType, int> sunProjectQaid = {
    ProjectType.sira: 4,
    ProjectType.fifty: 10,
    ProjectType.hundred: 20,
    ProjectType.fourAces: 40,
  };

  /// Hokm mode has no projects except Baloot (handled separately).
  static const Map<ProjectType, int> hokumProjectQaid = {};

  /// Human-readable Arabic names for projects.
  static const Map<ProjectType, String> projectNames = {
    ProjectType.sira: 'سرا',
    ProjectType.fifty: 'خمسين',
    ProjectType.hundred: 'مية',
    ProjectType.fourAces: 'أربعمئة',
  };

  /// Qaid value of a Baloot (K+Q of trump in Hokm mode).
  static const int balootQaid = 2;

  /// Target score to win the match.
  static const int targetQaid = 152;

  /// Base round totals used for complementary scoring.
  static const int hokumRoundTotal = 16;
  static const int sunRoundTotal = 26;

  /// Kabout (capot) fixed qaid awards.
  static const int hokumCapotQaid = 25;
  static const int sunCapotQaid = 44;

  static int indexInNaturalOrder(BalootRank rank) => naturalOrder.indexOf(rank.label);

  static int indexInSunOrder(BalootRank rank) => sunOrder.indexOf(rank.label);

  static int indexInHokumTrumpOrder(BalootRank rank) => hokumTrumpOrder.indexOf(rank.label);

  /// Returns the point value of a card given the current mode and trump suit.
  static int cardPoints(BalootCard card, BalootMode mode, BalootSuit? trump) {
    if (mode == BalootMode.hokum && card.suit == trump) {
      return hokumTrumpPoints[card.rank.label] ?? 0;
    }
    return sunPoints[card.rank.label] ?? 0;
  }

  /// Returns the strength index of a card inside a trick.
  /// Higher value = stronger. Non-followers of the led suit get -1.
  static int cardStrength(BalootCard card, BalootSuit ledSuit, BalootMode mode, BalootSuit? trump) {
    if (mode == BalootMode.hokum && card.suit == trump) {
      return 100 + indexInHokumTrumpOrder(card.rank);
    }
    if (card.suit != ledSuit) return -1;
    return indexInSunOrder(card.rank);
  }

  static Map<ProjectType, int> projectQaidFor(BalootMode mode) =>
      mode == BalootMode.sun ? sunProjectQaid : hokumProjectQaid;
}
