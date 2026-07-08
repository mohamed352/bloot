import 'dart:math';

import 'package:bloot/features/game/domain/engine/baloot_card.dart';
import 'package:bloot/features/game/domain/engine/baloot_engine.dart';
import 'package:bloot/features/game/domain/engine/baloot_rules.dart';
import 'package:bloot/features/game/domain/engine/baloot_state.dart';

/// Bot skill levels ported from id7mgh/baloot-game/js/bots.js.
enum BotLevel { beginner, amateur, skilled, pro }

/// AI opponents for local Saudi Baloot.
class BalootBot {
  BalootBot({Random? random}) : _random = random ?? Random();

  final Random _random;

  BidAction decideBid(BalootMatch match, int seat, BotLevel level) {
    final state = match.state!;
    final hand = state.hands[seat];
    final top = state.topCard;
    final round = state.bidding.round;
    final best = state.bidding.best;

    final thresholds = _thresholdsFor(level);
    var adj = 0.0;
    if (round == 2) {
      adj -= 0.4;
      if (state.bidding.spoken == 3 && best == null) adj -= 0.8;
    }
    final hokumThresh = thresholds.hokum + adj;
    final sunThresh = thresholds.sun + adj;

    double noise() => (_random.nextDouble() * 2 - 1) * thresholds.noise;

    final sunScore = _evalSun(hand, top, true) + noise();
    final canSun = best == null || best.type != BidActionType.sun;

    if (round == 1) {
      final hokumScore = _evalHokum(hand, top.suit, top, true) + noise();
      final canHokum = best == null;

      // Ashkal option for dealer or player before dealer.
      final ashkalEligible = seat == match.dealer || seat == (match.dealer + 3) % 4;
      if (ashkalEligible) {
        final ashkalScore = _evalSun(hand, top, false) + noise();
        if (ashkalScore >= sunThresh && ashkalScore >= hokumScore && ashkalScore >= sunScore) {
          return const BidAction.ashkal();
        }
      }

      if (canSun && sunScore >= sunThresh && sunScore >= hokumScore) return const BidAction.sun();
      if (canHokum && hokumScore >= hokumThresh) return const BidAction.hokum(null);
      if (canSun && sunScore >= sunThresh) return const BidAction.sun();
      return const BidAction.pass();
    }

    // Round 2
    BalootSuit? bestSuit;
    var bestScore = -1.0;
    for (final s in BalootSuit.values) {
      if (s == top.suit) continue;
      final sc = _evalHokum(hand, s, top, true);
      if (sc > bestScore) {
        bestScore = sc;
        bestSuit = s;
      }
    }
    bestScore += noise();
    if (canSun && sunScore >= sunThresh && sunScore >= bestScore) return const BidAction.sun();
    if (best == null && bestScore >= hokumThresh) return BidAction.hokum(bestSuit);
    if (canSun && sunScore >= sunThresh) return const BidAction.sun();
    return const BidAction.pass();
  }

  BalootCard decidePlay(BalootMatch match, int seat, BotLevel level) {
    final state = match.state!;
    final legal = BalootEngine().legalMoves(state, seat);
    if (legal.length == 1) return legal.first;

    if (level == BotLevel.beginner) return legal[_random.nextInt(legal.length)];

    final trick = state.currentTrick;
    final partner = (seat + 2) % 4;
    final isLast = trick.length == 3;

    // Leading the trick.
    if (trick.isEmpty) {
      if (level != BotLevel.amateur) {
        final masters = legal.where((c) => _isMaster(c, state)).toList();
        if (masters.isNotEmpty) {
          return masters.reduce((a, b) =>
              BalootRules.cardPoints(b, state.mode!, state.trump) > BalootRules.cardPoints(a, state.mode!, state.trump)
                  ? b
                  : a);
        }
      }

      if (level == BotLevel.pro && state.mode == BalootMode.hokum) {
        final trumpsOut = state.playedCards.where((c) => c.suit == state.trump).length;
        for (final c in legal) {
          if (c.suit != state.trump &&
              state.voids[partner].contains(c.suit) &&
              trumpsOut < 8) {
            final opp1 = (seat + 1) % 4;
            final opp2 = (seat + 3) % 4;
            if (!state.voids[opp1].contains(c.suit) || !state.voids[opp2].contains(c.suit)) return c;
          }
        }
      }

      if (state.mode == BalootMode.hokum && level != BotLevel.amateur) {
        final opp1 = (seat + 1) % 4;
        final opp2 = (seat + 3) % 4;
        final safe = legal
            .where((c) =>
                c.suit == state.trump ||
                (!state.voids[opp1].contains(c.suit) && !state.voids[opp2].contains(c.suit)))
            .toList();
        if (safe.isNotEmpty) return _lowestBy(safe, state);
      }
      return _lowestBy(legal, state);
    }

    // Inside a trick.
    final led = trick.first.card.suit;
    final winSeat = trick[BalootEngine().trickWinnerIndex(trick, state)].seat;
    final partnerWinning = BalootEngine.teamOf(winSeat) == BalootEngine.teamOf(seat);
    final curBest = trick.map((t) => BalootRules.cardStrength(t.card, led, state.mode!, state.trump)).reduce((a, b) => a > b ? a : b);
    final winners = legal.where((c) => BalootRules.cardStrength(c, led, state.mode!, state.trump) > curBest).toList();
    final pts = trick.fold<int>(0, (s, t) => s + BalootRules.cardPoints(t.card, state.mode!, state.trump));

    if (partnerWinning) {
      if (level != BotLevel.amateur) {
        final partnerCard = trick.cast<TrickPlay?>().firstWhere((t) => t?.seat == partner, orElse: () => null);
        final partnerSolid = partnerCard != null && (isLast || _isMaster(partnerCard.card, state));
        if (partnerSolid) {
          final feed = legal.where((c) => BalootRules.cardStrength(c, led, state.mode!, state.trump) <= curBest || c.suit != led).toList();
          if (feed.isNotEmpty) {
            final fat = feed.reduce((a, b) =>
                BalootRules.cardPoints(b, state.mode!, state.trump) > BalootRules.cardPoints(a, state.mode!, state.trump)
                    ? b
                    : a);
            if (BalootRules.cardPoints(fat, state.mode!, state.trump) >= 4) return fat;
            return _lowestBy(feed, state);
          }
        }
      }
      return _lowestBy(legal, state);
    }

    // Opponent winning.
    if (winners.isNotEmpty) {
      final cheapWin = winners.reduce((a, b) =>
          BalootRules.cardStrength(a, led, state.mode!, state.trump) <
                  BalootRules.cardStrength(b, led, state.mode!, state.trump)
              ? a
              : b);
      if (level == BotLevel.amateur) return cheapWin;
      if (isLast) return cheapWin;
      if (pts >= 10 || BalootRules.cardPoints(cheapWin, state.mode!, state.trump) <= 4) return cheapWin;
      final cheap = legal.where((c) => !winners.contains(c)).toList();
      if (cheap.isNotEmpty && _random.nextDouble() < 0.6) return _lowestBy(cheap, state);
      return cheapWin;
    }

    return _lowestBy(legal, state);
  }

  bool decideDouble(BalootMatch match, int seat, BotLevel level) {
    final score = _handStrength(match, seat);
    final base = switch (level) {
      BotLevel.beginner => 0.04,
      BotLevel.amateur => 0.10,
      BotLevel.skilled => 0.18,
      BotLevel.pro => 0.28,
    };
    final isBuyTeam = BalootEngine.teamOf(seat) == BalootEngine.teamOf(match.state!.buyer!);
    final strongThresh = isBuyTeam ? 6.4 : 5.4;
    final chance = score >= strongThresh ? base + 0.35 : base * 0.25;
    return _random.nextDouble() < chance;
  }

  // ═══════════════════════════════════════════════════════════════════
  // Evaluation helpers
  // ═══════════════════════════════════════════════════════════════════

  _BidThresholds _thresholdsFor(BotLevel level) {
    return switch (level) {
      BotLevel.beginner => _BidThresholds(hokum: 6.6, sun: 7.7, noise: 2.0),
      BotLevel.amateur => _BidThresholds(hokum: 6.1, sun: 7.3, noise: 1.0),
      BotLevel.skilled => _BidThresholds(hokum: 5.6, sun: 6.9, noise: 0.5),
      BotLevel.pro => _BidThresholds(hokum: 5.2, sun: 6.6, noise: 0.15),
    };
  }

  double _evalHokum(List<BalootCard> hand, BalootSuit suit, BalootCard topCard, bool takesTop) {
    final cards = takesTop && topCard.suit == suit ? [...hand, topCard] : [...hand];
    final trumps = cards.where((c) => c.suit == suit).toList();
    var score = 0.0;
    for (final c in trumps) {
      score += switch (c.rank.label) {
        'J' => 3.2,
        '9' => 2.2,
        'A' => 1.6,
        '10' => 1.2,
        _ => 0.8,
      };
    }
    for (final c in cards) {
      if (c.suit == suit) continue;
      if (c.rank.label == 'A') score += 1.1;
      if (c.rank.label == '10') score += 0.5;
    }
    if (trumps.length >= 4) score += 1.0;
    return score;
  }

  double _evalSun(List<BalootCard> hand, BalootCard topCard, bool takesTop) {
    final cards = takesTop ? [...hand, topCard] : [...hand];
    var score = 0.0;
    var aces = 0;
    for (final c in cards) {
      score += switch (c.rank.label) {
        'A' => 2.6,
        '10' => 1.4,
        'K' => 0.7,
        'Q' => 0.3,
        _ => 0.0,
      };
      if (c.rank.label == 'A') aces++;
    }
    score += aces * 5.0;
    for (final s in BalootSuit.values) {
      if (cards.where((c) => c.suit == s).length >= 3) score += 0.5;
    }
    return score;
  }

  double _handStrength(BalootMatch match, int seat) {
    final state = match.state!;
    return state.mode == BalootMode.hokum
        ? _evalHokum(state.hands[seat], state.trump!, state.topCard, false)
        : _evalSun(state.hands[seat], state.topCard, false);
  }

  bool _isMaster(BalootCard card, BalootHandState state) {
    final order = state.mode == BalootMode.hokum && card.suit == state.trump
        ? BalootRules.hokumTrumpOrder
        : BalootRules.sunOrder;
    final myPow = order.indexOf(card.rank.label);
    for (final r in BalootRules.naturalOrder) {
      if (order.indexOf(r) <= myPow) continue;
      final played = state.playedCards.any((c) => c.suit == card.suit && c.rank.label == r);
      if (!played) return false;
    }
    return true;
  }

  BalootCard _lowestBy(List<BalootCard> cards, BalootHandState state) {
    return cards.reduce((a, b) {
      final pa = BalootRules.cardPoints(a, state.mode!, state.trump);
      final pb = BalootRules.cardPoints(b, state.mode!, state.trump);
      if (pa != pb) return pa < pb ? a : b;
      return BalootRules.cardStrength(a, a.suit, state.mode!, state.trump) <
              BalootRules.cardStrength(b, b.suit, state.mode!, state.trump)
          ? a
          : b;
    });
  }
}

class _BidThresholds {
  _BidThresholds({required this.hokum, required this.sun, required this.noise});

  final double hokum;
  final double sun;
  final double noise;
}
