import 'dart:math';

import 'package:bloot/features/game/domain/engine/baloot_card.dart';
import 'package:bloot/features/game/domain/engine/baloot_deck.dart';
import 'package:bloot/features/game/domain/engine/baloot_rules.dart';
import 'package:bloot/features/game/domain/engine/baloot_state.dart';

/// Pure game logic for 32-card Saudi Baloot.
///
/// Ported from https://github.com/id7mgh/baloot-game/js/engine.js
class BalootEngine {
  BalootEngine({Random? random}) : _random = random ?? Random();

  final Random _random;

  static int teamOf(int seat) => seat % 2;

  // ═══════════════════════════════════════════════════════════════════
  // Deck & dealing
  // ═══════════════════════════════════════════════════════════════════

  /// Creates a new match with the given player configuration.
  BalootMatch createMatch(List<BalootPlayerConfig> players, {bool safeMode = false, bool autoDeclare = false}) {
    return BalootMatch(
      players: players,
      safeMode: safeMode,
      autoDeclare: autoDeclare,
    )
      ..dealer = _random.nextInt(4)
      ..handsPlayed = 0;
  }

  /// Starts a new hand, deals cards, and returns the hand state.
  BalootHandState startHand(BalootMatch match) {
    final deck = BalootDeck(random: _random);
    final deal = dealBalootHands(deck: deck, dealer: match.dealer);

    final state = BalootHandState()
      ..hands = deal.hands
      ..topCard = deal.topCard
      ..rest = deal.rest
      ..firstPlayer = deal.firstPlayer
      ..phase = BalootPhase.bidding
      ..mode = null
      ..trump = null
      ..buyer = null
      ..ashkal = false
      ..bidding = BiddingState(turn: deal.firstPlayer)
      ..leader = deal.firstPlayer
      ..turn = deal.firstPlayer
      ..doubleLevel = 1
      ..doubleTeam = null
      ..awaitingDouble = false
      ..doubling = null
      ..awaitingDeclare = false
      ..declareSeats = []
      ..declarations = {};

    match.state = state;
    return state;
  }

  // ═══════════════════════════════════════════════════════════════════
  // Bidding
  // ═══════════════════════════════════════════════════════════════════

  /// Applies a bid action for [seat]. Returns events describing what happened.
  List<Map<String, dynamic>> applyBid(BalootMatch match, int seat, BidAction action) {
    final state = match.state!;
    final bidding = state.bidding;
    if (seat != bidding.turn) throw StateError('Not this seat\'s turn to bid');

    final events = <Map<String, dynamic>>[];

    // Sun ends bidding immediately.
    if (action.type == BidActionType.sun) {
      bidding.best = BestBid(type: BidActionType.sun, seat: seat);
      events.add({'type': 'bid', 'seat': seat, 'say': 'صن'});
      _finalizeBid(match, events);
      return events;
    }

    // Ashkal: first round only, dealer or player before dealer.
    if (action.type == BidActionType.ashkal) {
      if (bidding.round != 1) throw StateError('Ashkal only allowed in first bidding round');
      final ashkalEligible = (match.dealer + 3) % 4;
      if (seat != match.dealer && seat != ashkalEligible) {
        throw StateError('Ashkal only allowed for dealer or player before dealer');
      }
      bidding.best = BestBid(type: BidActionType.ashkal, seat: seat);
      events.add({'type': 'bid', 'seat': seat, 'say': 'أشكل'});
      _finalizeBid(match, events);
      return events;
    }

    if (action.type == BidActionType.hokum) {
      final suit = bidding.round == 1 ? state.topCard.suit : action.suit;
      if (bidding.round == 2 && suit == state.topCard.suit) {
        throw StateError('Second-round Hokm must be a different suit');
      }
      bidding.best ??= BestBid(type: BidActionType.hokum, seat: seat, suit: suit);
      events.add({
        'type': 'bid',
        'seat': seat,
        'say': bidding.round == 1 ? 'حكم' : 'حكم ثاني',
      });
    } else {
      events.add({
        'type': 'bid',
        'seat': seat,
        'say': bidding.round == 1 ? 'بس' : 'ولا',
      });
    }

    bidding.spoken++;
    if (bidding.spoken == 4) {
      if (bidding.best != null) {
        _finalizeBid(match, events);
      } else if (bidding.round == 1) {
        bidding.round = 2;
        bidding.spoken = 0;
        bidding.turn = state.firstPlayer;
        bidding.best = null;
        events.add({'type': 'round2'});
      } else {
        // Everyone passed — redeal with next dealer.
        match.dealer = (match.dealer + 1) % 4;
        startHand(match);
        events.add({'type': 'redeal'});
      }
    } else {
      bidding.turn = (bidding.turn + 1) % 4;
    }

    return events;
  }

  void _finalizeBid(BalootMatch match, List<Map<String, dynamic>> events) {
    final state = match.state!;
    final best = state.bidding.best!;

    state.buyer = best.seat;
    state.ashkal = best.type == BidActionType.ashkal;
    state.mode = state.ashkal ? BalootMode.sun : _modeFromBid(best.type);
    state.trump = best.type == BidActionType.hokum ? best.suit : null;

    // Distribute the remaining 11 cards.
    // Ashkal: top card goes to partner; otherwise to buyer.
    final topRecipient = state.ashkal ? (state.buyer! + 2) % 4 : state.buyer!;
    var ri = 0;
    state.hands[topRecipient].add(state.rest[ri++]);
    state.hands[topRecipient].add(state.rest[ri++]);
    for (var p = 0; p < 4; p++) {
      if (p == topRecipient) continue;
      state.hands[p].add(state.rest[ri++]);
      state.hands[p].add(state.rest[ri++]);
      state.hands[p].add(state.rest[ri++]);
    }
    state.hands[topRecipient].add(state.topCard);

    // Detect projects.
    state.projects.clear();
    for (var p = 0; p < 4; p++) {
      for (final pr in _findProjects(state.hands[p], state.mode!, state.trump)) {
        state.projects.add(ProjectClaim(seat: p, type: pr.type, cards: pr.cards));
      }
    }

    state.phase = BalootPhase.playing;
    state.leader = state.firstPlayer;
    state.turn = state.firstPlayer;

    events.add({
      'type': 'bidWon',
      'seat': state.buyer,
      'mode': state.mode!.name,
      'trump': state.trump?.symbol,
      'ashkal': state.ashkal,
    });

    // Open doubling.
    state.doubleLevel = 1;
    state.doubleTeam = null;
    final buyerTeam = teamOf(state.buyer!);
    final oppTeam = 1 - buyerTeam;
    final sunDoubleAllowed = state.mode == BalootMode.hokum ||
        (match.totals[buyerTeam] > 100 && match.totals[oppTeam] <= 100);
    if (sunDoubleAllowed) {
      state.awaitingDouble = true;
      state.doubling = DoublingState(turn: (state.buyer! + 1) % 4, stage: 'offer', nextLevel: 2);
      events.add({'type': 'doubleOpen', 'turn': state.doubling!.turn, 'stage': 'offer'});
    } else {
      state.awaitingDouble = false;
      state.doubling = null;
    }

    // Project declaration.
    state.countedProjects.clear();
    state.droppedProjects.clear();
    final humanSeats = <int>[];
    for (var p = 0; p < 4; p++) {
      if (!match.players[p].isBot && state.projects.any((pr) => pr.seat == p)) {
        humanSeats.add(p);
      }
    }
    if (!match.autoDeclare && humanSeats.isNotEmpty) {
      state.awaitingDeclare = true;
      state.declareSeats = List<int>.from(humanSeats);
      state.declarations = {};
      events.add({'type': 'declareProjects', 'seats': humanSeats});
    } else {
      _finalizeProjects(match, {});
    }
  }

  static BalootMode _modeFromBid(BidActionType type) {
    return type == BidActionType.hokum ? BalootMode.hokum : BalootMode.sun;
  }

  // ═══════════════════════════════════════════════════════════════════
  // Project declaration
  // ═══════════════════════════════════════════════════════════════════

  /// A human seat declares which project types they are claiming.
  void declareProject(BalootMatch match, int seat, List<ProjectType> claimedTypes) {
    final state = match.state!;
    if (!state.awaitingDeclare || !state.declareSeats.contains(seat)) {
      throw StateError('Not time to declare projects');
    }
    state.declarations[seat] = List<ProjectType>.from(claimedTypes);
    state.declareSeats.remove(seat);
    if (state.declareSeats.isEmpty) {
      _finalizeProjects(match, state.declarations);
    }
  }

  void _finalizeProjects(BalootMatch match, Map<int, List<ProjectType>> declarations) {
    final state = match.state!;
    final kept = <ProjectClaim>[];

    for (var p = 0; p < 4; p++) {
      final seatProjs = state.projects.where((pr) => pr.seat == p).toList();
      if (match.players[p].isBot || !declarations.containsKey(p)) {
        kept.addAll(seatProjs);
      } else {
        final claimed = declarations[p] ?? <ProjectType>[];
        kept.addAll(seatProjs.where((pr) => claimed.contains(pr.type)));
      }
    }

    final res = _resolveProjects(kept, state.mode!, state.firstPlayer);
    state.countedProjects
      ..clear()
      ..addAll(res.counted);
    state.droppedProjects
      ..clear()
      ..addAll(res.dropped);

    state.awaitingDeclare = false;
    state.declareSeats = [];
    state.announcedProjects.clear();
    state.revealedProjects.clear();

    state.pendingAnnounce
      ..clear()
      ..addAll(kept.map((p) => ProjectClaim(seat: p.seat, type: p.type, cards: p.cards)));
    state.pendingReveal
      ..clear()
      ..addAll(state.countedProjects.map((p) => ProjectClaim(
            seat: p.seat,
            type: p.type,
            cards: p.cards,
            revealed: true,
          )));
  }

  // ═══════════════════════════════════════════════════════════════════
  // Project detection & resolution
  // ═══════════════════════════════════════════════════════════════════

  List<ProjectClaim> _findProjects(List<BalootCard> hand, BalootMode mode, BalootSuit? trump) {
    final projects = <ProjectClaim>[];

    // Hokum has no projects (Baloot is handled separately during play).
    if (mode != BalootMode.sun) return projects;

    // Four of a kind for A/K/Q/J/10.
    for (final rank in ['A', 'K', 'Q', 'J', '10']) {
      final cards = hand.where((c) => c.rank.label == rank).toList();
      if (cards.length == 4) {
        if (rank == 'A') {
          projects.add(ProjectClaim(seat: 0, type: ProjectType.fourAces, cards: cards));
        } else {
          projects.add(ProjectClaim(seat: 0, type: ProjectType.hundred, cards: cards));
        }
      }
    }

    // Sequences per suit.
    for (final suit in BalootSuit.values) {
      final suitCards = hand.where((c) => c.suit == suit).toList();
      final idxs = suitCards
          .map((c) => BalootRules.naturalOrder.indexOf(c.rank.label))
          .toList()
        ..sort();

      final runs = <List<int>>[];
      var run = <int>[];
      for (var k = 0; k < idxs.length; k++) {
        if (run.isNotEmpty && idxs[k] == run.last + 1) {
          run.add(idxs[k]);
        } else {
          if (run.length >= 3) runs.add(List<int>.from(run));
          run = [idxs[k]];
        }
      }
      if (run.length >= 3) runs.add(run);

      for (final r in runs) {
        ProjectType type;
        int take;
        if (r.length >= 5) {
          take = 5;
          type = ProjectType.hundred;
        } else if (r.length == 4) {
          take = 4;
          type = ProjectType.fifty;
        } else {
          take = 3;
          type = ProjectType.sira;
        }
        final cards = r.sublist(r.length - take).map((i) => BalootCard(suit: suit, rank: BalootRank.fromLabel(BalootRules.naturalOrder[i]))).toList();
        projects.add(ProjectClaim(seat: 0, type: type, cards: cards));
      }
    }

    return projects;
  }

  ({List<ProjectClaim> counted, List<ProjectClaim> dropped}) _resolveProjects(
    List<ProjectClaim> projects,
    BalootMode mode,
    int firstPlayer,
  ) {
    if (projects.isEmpty) return (counted: <ProjectClaim>[], dropped: <ProjectClaim>[]);

    int power(ProjectClaim p) {
      final q = BalootRules.projectQaidFor(mode)[p.type] ?? 0;
      final top = p.cards.map((c) => BalootRules.naturalOrder.indexOf(c.rank.label)).reduce((a, b) => a > b ? a : b);
      final orderBonus = (4 + p.seat - firstPlayer) % 4;
      return q * 10000 + top * 100 + (3 - orderBonus);
    }

    var best = projects.first;
    for (final p in projects) {
      if (power(p) > power(best)) best = p;
    }
    final winTeam = teamOf(best.seat);
    final counted = projects.where((p) => teamOf(p.seat) == winTeam).toList();
    final dropped = projects.where((p) => teamOf(p.seat) != winTeam).toList();
    return (counted: counted, dropped: dropped);
  }

  // ═══════════════════════════════════════════════════════════════════
  // Doubling
  // ═══════════════════════════════════════════════════════════════════

  List<Map<String, dynamic>> applyDouble(BalootMatch match, int seat, DoubleAction action) {
    final state = match.state!;
    if (!state.awaitingDouble || state.doubling == null) throw StateError('Not time to double');
    final d = state.doubling!;
    if (seat != d.turn) throw StateError('Not this seat\'s turn to double');

    final events = <Map<String, dynamic>>[];
    if (action == DoubleAction.double) {
      final level = d.nextLevel;
      state.doubleLevel = level;
      state.doubleTeam = teamOf(seat);
      events.add({'type': 'doubled', 'seat': seat, 'level': level});

      if (level >= 4 || state.mode == BalootMode.sun) {
        state.awaitingDouble = false;
        state.doubling = null;
        events.add({'type': 'doublingClosed', 'level': level});
      } else {
        d.turn = teamOf(seat) == teamOf(state.buyer!) ? (state.buyer! + 1) % 4 : state.buyer!;
        d.stage = level == 2 ? 'redouble' : 'recoat';
        d.nextLevel = level + 1;
        events.add({'type': 'doubleOpen', 'turn': d.turn, 'stage': d.stage});
      }
    } else {
      state.awaitingDouble = false;
      state.doubling = null;
      events.add({'type': 'doublingClosed', 'level': state.doubleLevel});
    }
    return events;
  }

  // ═══════════════════════════════════════════════════════════════════
  // Card play
  // ═══════════════════════════════════════════════════════════════════

  /// Returns the legal cards a seat may play right now.
  List<BalootCard> legalMoves(BalootHandState state, int seat, {bool strict = false}) {
    final hand = state.hands[seat];
    final trick = state.currentTrick;

    if (trick.isEmpty) return List<BalootCard>.from(hand);

    final led = trick.first.card.suit;
    final follow = hand.where((c) => c.suit == led).toList();

    if (state.mode == BalootMode.sun) return follow.isNotEmpty ? follow : List<BalootCard>.from(hand);

    // Hokum
    if (follow.isNotEmpty) {
      if (led == state.trump) {
        final bestTrump = trick
            .where((t) => t.card.suit == state.trump)
            .map((t) => BalootRules.indexInHokumTrumpOrder(t.card.rank))
            .reduce((a, b) => a > b ? a : b);
        final higher = follow.where((c) => BalootRules.indexInHokumTrumpOrder(c.rank) > bestTrump).toList();
        return higher.isNotEmpty ? higher : follow;
      }
      return follow;
    }

    // Void in led suit
    final winIdx = trickWinnerIndex(trick, state);
    final winnerSeat = trick[winIdx].seat;
    if (!strict && teamOf(winnerSeat) == teamOf(seat)) return List<BalootCard>.from(hand);

    final trumps = hand.where((c) => c.suit == state.trump).toList();
    if (trumps.isEmpty) return List<BalootCard>.from(hand);

    final trumpedInTrick = trick.where((t) => t.card.suit == state.trump).toList();
    if (trumpedInTrick.isNotEmpty) {
      final bestTrump = trumpedInTrick
          .map((t) => BalootRules.indexInHokumTrumpOrder(t.card.rank))
          .reduce((a, b) => a > b ? a : b);
      final higher = trumps.where((c) => BalootRules.indexInHokumTrumpOrder(c.rank) > bestTrump).toList();
      return higher.isNotEmpty ? List<BalootCard>.from(hand) : trumps;
    }
    return trumps;
  }

  /// Plays a card from [seat]. Returns events.
  List<Map<String, dynamic>> playCard(BalootMatch match, int seat, BalootCard card) {
    final state = match.state!;
    if (state.phase != BalootPhase.playing || state.turn != seat) {
      throw StateError('Not this seat\'s turn');
    }

    final hand = state.hands[seat];
    final idx = hand.indexWhere((c) => c == card);
    if (idx == -1) throw StateError('Card not in hand');

    final strict = state.doubleLevel >= 2;
    final legal = legalMoves(state, seat, strict: strict);
    final isLegal = legal.any((c) => c == card);

    if (!isLegal) {
      if (match.safeMode) throw StateError('Illegal move');
      state.pendingViolations.add(ViolationRecord(
        seat: seat,
        card: card,
        trickIndex: state.trickHistory.length,
        type: _classifyViolation(hand, state.currentTrick, state, card, seat),
        escaped: List<BalootCard>.from(legal),
      ));
    }

    if (state.currentTrick.isNotEmpty) {
      final led = state.currentTrick.first.card.suit;
      if (card.suit != led) state.voids[seat].add(led);
    }

    hand.removeAt(idx);
    state.currentTrick.add(TrickPlay(seat: seat, card: card));
    state.playedCards.add(card);

    final events = <Map<String, dynamic>>[
      {'type': 'played', 'seat': seat, 'card': card.key, 'lead': state.currentTrick.length == 1},
    ];

    // Baloot detection in Hokm.
    if (state.mode == BalootMode.hokum && card.suit == state.trump && (card.rank.label == 'K' || card.rank.label == 'Q')) {
      final bs = state.balootState;
      final curTrick = state.trickHistory.length;
      if (bs != null &&
          bs.seat == seat &&
          bs.rank != card.rank &&
          curTrick == bs.trickIndex + 1 &&
          state.balootTeam == null) {
        state.balootTeam = teamOf(seat);
        state.balootSeat = seat;
        state.balootState = null;
        events.add({'type': 'baloot', 'seat': seat});
      } else {
        state.balootState = (seat: seat, rank: card.rank, trickIndex: curTrick);
      }
    }

    // Reveal hidden violations.
    for (final pv in state.pendingViolations) {
      if (pv.confirmed || pv.seat != seat) continue;
      if (pv.escaped.any((e) => e == card)) {
        pv.confirmed = true;
        pv.provedBy = card;
        state.violation = pv;
        events.add({
          'type': 'violationRevealed',
          'seat': pv.seat,
          'card': pv.card.key,
          'trickIndex': pv.trickIndex,
          'provedBy': card.key,
        });
      }
    }

    // Project announcements on first trick.
    if (state.trickHistory.isEmpty && state.pendingAnnounce.isNotEmpty) {
      final mine = state.pendingAnnounce.where((p) => p.seat == seat).toList();
      if (mine.isNotEmpty) {
        state.pendingAnnounce.removeWhere((p) => p.seat == seat);
        state.announcedProjects.addAll(mine);
        events.add({'type': 'projectAnnounce', 'seat': seat, 'names': mine.map((m) => BalootRules.projectNames[m.type]).toList()});
      }
    }

    // Project reveals on second trick.
    if (state.trickHistory.length == 1 && state.pendingReveal.isNotEmpty) {
      final mine = state.pendingReveal.where((p) => p.seat == seat).toList();
      if (mine.isNotEmpty) {
        state.pendingReveal.removeWhere((p) => p.seat == seat);
        state.revealedProjects.addAll(mine);
        for (final p in mine) {
          events.add({
            'type': 'projectReveal',
            'seat': p.seat,
            'name': BalootRules.projectNames[p.type],
            'qaid': p.qaid,
            'cards': p.cards.map((c) => c.key).toList(),
          });
        }
      }
    }

    if (state.currentTrick.length == 4) {
      final winner = trickWinnerIndex(state.currentTrick, state);
      final winnerSeat = state.currentTrick[winner].seat;
      final trickPts = state.currentTrick.fold<int>(0, (s, t) => s + BalootRules.cardPoints(t.card, state.mode!, state.trump));

      state.trickHistory.add(CompletedTrick(
        plays: List<TrickPlay>.from(state.currentTrick),
        winner: winnerSeat,
        points: trickPts,
      ));

      state.currentTrick.clear();
      state.leader = winnerSeat;
      state.turn = winnerSeat;
      state.violation = null;

      events.add({'type': 'trickEnd', 'winner': winnerSeat, 'pts': trickPts});

      if (state.trickHistory.length == 8) {
        final result = scoreHand(state);
        match.totals[0] += result.qaid[0];
        match.totals[1] += result.qaid[1];
        match.handResults.add({
          'mode': state.mode!.name,
          'trump': state.trump?.symbol,
          'buyer': state.buyer,
          'qaid': result.qaid,
          'buyerLost': result.buyerLost,
          'capotTeam': result.capotTeam,
        });
        match.handsPlayed++;
        state.phase = BalootPhase.handEnd;
        state.result = result;
        events.add({'type': 'handEnd', 'result': _resultToJson(result)});

        _checkMatchEnd(match, events);
      }
    } else {
      state.turn = (state.turn + 1) % 4;
    }

    return events;
  }

  int trickWinnerIndex(List<TrickPlay> trick, BalootHandState state) {
    final led = trick.first.card.suit;
    var best = 0;
    for (var i = 1; i < trick.length; i++) {
      if (BalootRules.cardStrength(trick[i].card, led, state.mode!, state.trump) >
          BalootRules.cardStrength(trick[best].card, led, state.mode!, state.trump)) {
        best = i;
      }
    }
    return best;
  }

  ViolationType _classifyViolation(
    List<BalootCard> hand,
    List<TrickPlay> trick,
    BalootHandState state,
    BalootCard card,
    int seat,
  ) {
    final led = trick.isEmpty ? null : trick.first.card.suit;
    if (led == null) return ViolationType.qatee;

    final hasLed = hand.any((c) => c.suit == led);
    if (hasLed && card.suit != led) return ViolationType.qatee;

    if (state.mode == BalootMode.hokum) {
      if (!hasLed && state.doubleLevel >= 2) {
        final winIdx = trickWinnerIndex(trick, state);
        final winnerSeat = trick[winIdx].seat;
        if (teamOf(winnerSeat) == teamOf(seat)) return ViolationType.rubu;
      }
      if (card.suit == state.trump) return ViolationType.makabr;
      if (!hasLed && hand.any((c) => c.suit == state.trump)) return ViolationType.madaq;
    }
    return ViolationType.qatee;
  }

  // ═══════════════════════════════════════════════════════════════════
  // Scoring
  // ═══════════════════════════════════════════════════════════════════

  /// Scores a completed hand.
  HandResult scoreHand(BalootHandState state) {
    final mode = state.mode!;
    final buyTeam = teamOf(state.buyer!);
    final pts = [0, 0];
    var capotTeam = -1;

    final trickWins = [0, 0];
    for (final t in state.trickHistory) {
      trickWins[teamOf(t.winner)]++;
      for (final play in t.plays) {
        pts[teamOf(t.winner)] += BalootRules.cardPoints(play.card, mode, state.trump);
      }
    }
    final lastWinner = state.trickHistory.last.winner;
    pts[teamOf(lastWinner)] += 10; // Ground bonus

    if (trickWins[0] == 8) capotTeam = 0;
    if (trickWins[1] == 8) capotTeam = 1;

    final projQaid = [0, 0];
    for (final p in state.countedProjects) {
      projQaid[teamOf(p.seat)] += p.qaid;
    }

    final balootQaid = [0, 0];
    if (state.balootTeam != null) balootQaid[state.balootTeam!] = BalootRules.balootQaid;

    final mult = state.doubleLevel;
    final qaid = [0, 0];

    if (capotTeam != -1) {
      qaid[capotTeam] = ((mode == BalootMode.hokum ? BalootRules.hokumCapotQaid : BalootRules.sunCapotQaid) + projQaid[capotTeam]) * mult + balootQaid[capotTeam];
      qaid[1 - capotTeam] = balootQaid[1 - capotTeam];
    } else {
      final div = mode == BalootMode.hokum ? 10 : 5;
      final baseTotal = mode == BalootMode.hokum ? BalootRules.hokumRoundTotal : BalootRules.sunRoundTotal;
      final nonBuy = 1 - buyTeam;
      final nonBuyQaid = (pts[nonBuy] / div).round();
      final buyQaid = baseTotal - nonBuyQaid;
      qaid[nonBuy] = (nonBuyQaid + projQaid[nonBuy]) * mult + balootQaid[nonBuy];
      qaid[buyTeam] = (buyQaid + projQaid[buyTeam]) * mult + balootQaid[buyTeam];
    }

    var buyerLost = false;
    if (capotTeam == -1 && qaid[buyTeam] <= qaid[1 - buyTeam]) buyerLost = true;
    if (capotTeam != -1 && capotTeam != buyTeam) buyerLost = true;

    var safeSaved = false;
    if (buyerLost && capotTeam == -1 && state.result?.safeSaved == true && buyTeam == 0) {
      buyerLost = false;
      safeSaved = true;
    }

    if (buyerLost && capotTeam == -1) {
      final total = qaid[0] + qaid[1] - balootQaid[buyTeam];
      qaid[1 - buyTeam] = total;
      qaid[buyTeam] = balootQaid[buyTeam];
    }

    return HandResult(
      qaid: qaid,
      pts: pts,
      trickWins: trickWins,
      capotTeam: capotTeam == -1 ? null : capotTeam,
      buyerLost: buyerLost,
      safeSaved: safeSaved,
      projQaid: projQaid,
      balootQaid: balootQaid,
      doubleLevel: mult,
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Qaid / Sawa claims
  // ═══════════════════════════════════════════════════════════════════

  List<Map<String, dynamic>> claimQaid(BalootMatch match, int claimingSeat, {ViolationType? claimType}) {
    final state = match.state!;
    if (state.phase != BalootPhase.playing) throw StateError('Not time to claim qaid');

    final claimTeam = teamOf(claimingSeat);
    final v = state.violation;
    final correct = v != null && teamOf(v.seat) != claimTeam && (claimType == null || claimType == v.type);

    final events = <Map<String, dynamic>>[];
    if (correct) {
      _finishClaimedHand(match, events,
          winTeam: claimTeam,
          loseTeam: teamOf(v.seat),
          qatClaim: QatClaimResult(
            type: v.type,
            typeName: _violationName(v.type),
            failed: false,
            claimSeat: claimingSeat,
            violSeat: v.seat,
            winTeam: claimTeam,
            violCard: v.card,
            trickIndex: v.trickIndex,
            provedBy: v.provedBy,
          ));
    } else {
      _finishClaimedHand(match, events,
          winTeam: 1 - claimTeam,
          loseTeam: claimTeam,
          qatClaim: QatClaimResult(
            type: claimType ?? ViolationType.qatee,
            typeName: _violationName(claimType ?? ViolationType.qatee),
            failed: true,
            claimSeat: claimingSeat,
            violSeat: claimingSeat,
            winTeam: 1 - claimTeam,
          ));
    }

    final qc = state.result!.qatClaim!;
    events.insert(0, {
      'type': 'qatClaimed',
      'seat': claimingSeat,
      'violSeat': qc.violSeat,
      'failed': qc.failed,
      'typeName': qc.typeName,
    });
    _checkMatchEnd(match, events);
    return events;
  }

  static String _violationName(ViolationType type) {
    return switch (type) {
      ViolationType.qatee => 'قيد قاطع',
      ViolationType.makabr => 'ما كبر بحكم',
      ViolationType.madaq => 'ما دق بحكم',
      ViolationType.sawa => 'سوا خاطئ',
      ViolationType.rubu => 'ربع في الدبل',
    };
  }

  void _finishClaimedHand(
    BalootMatch match,
    List<Map<String, dynamic>> events, {
    required int winTeam,
    required int loseTeam,
    required QatClaimResult qatClaim,
  }) {
    final state = match.state!;
    final balootQaid = [0, 0];
    if (state.balootTeam != null) balootQaid[state.balootTeam!] = BalootRules.balootQaid;
    final mult = state.doubleLevel;
    final qaid = [0, 0];
    qaid[winTeam] = (state.mode == BalootMode.hokum ? BalootRules.hokumCapotQaid : BalootRules.sunCapotQaid) * mult + balootQaid[winTeam];
    qaid[loseTeam] = balootQaid[loseTeam];

    match.totals[0] += qaid[0];
    match.totals[1] += qaid[1];
    match.handResults.add({
      'mode': state.mode!.name,
      'trump': state.trump?.symbol,
      'buyer': state.buyer,
      'qaid': qaid,
      'buyerLost': true,
      'capotTeam': null,
      'qatClaim': true,
    });
    match.handsPlayed++;

    final result = HandResult(
      qaid: qaid,
      pts: [0, 0],
      trickWins: [0, 0],
      buyerLost: true,
      projQaid: [0, 0],
      balootQaid: balootQaid,
      doubleLevel: mult,
      qatClaim: qatClaim,
    );
    state.phase = BalootPhase.handEnd;
    state.result = result;
    state.violation = null;
    events.add({'type': 'handEnd', 'result': _resultToJson(result)});
  }

  // ═══════════════════════════════════════════════════════════════════
  // Helpers
  // ═══════════════════════════════════════════════════════════════════

  void _checkMatchEnd(BalootMatch match, List<Map<String, dynamic>> events) {
    if (match.totals[0] >= BalootRules.targetQaid || match.totals[1] >= BalootRules.targetQaid) {
      if (match.totals[0] != match.totals[1]) {
        match.matchOver = true;
        match.winnerTeam = match.totals[0] > match.totals[1] ? 0 : 1;
        match.state!.phase = BalootPhase.matchEnd;
        events.add({'type': 'matchEnd', 'winnerTeam': match.winnerTeam});
      }
    }
  }

  Map<String, dynamic> _resultToJson(HandResult r) {
    return {
      'qaid': r.qaid,
      'pts': r.pts,
      'trickWins': r.trickWins,
      'capotTeam': r.capotTeam,
      'buyerLost': r.buyerLost,
      'safeSaved': r.safeSaved,
      'projQaid': r.projQaid,
      'balootQaid': r.balootQaid,
      'doubleLevel': r.doubleLevel,
      'qatClaim': r.qatClaim != null
          ? {
              'type': r.qatClaim!.type.name,
              'typeName': r.qatClaim!.typeName,
              'failed': r.qatClaim!.failed,
              'claimSeat': r.qatClaim!.claimSeat,
            }
          : null,
    };
  }
}

/// Action a player can take during bidding.
class BidAction {
  const BidAction.pass() : type = BidActionType.pass, suit = null;
  const BidAction.sun() : type = BidActionType.sun, suit = null;
  const BidAction.hokum(this.suit) : type = BidActionType.hokum;
  const BidAction.ashkal() : type = BidActionType.ashkal, suit = null;

  final BidActionType type;
  final BalootSuit? suit;
}

enum DoubleAction { pass, double }
