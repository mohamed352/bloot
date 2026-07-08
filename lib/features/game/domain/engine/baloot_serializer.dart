import 'package:bloot/features/game/domain/engine/baloot_card.dart';
import 'package:bloot/features/game/domain/engine/baloot_rules.dart';
import 'package:bloot/features/game/domain/engine/baloot_state.dart';

/// Serializes and deserializes [BalootMatch] / [BalootHandState] for
/// Firestore/Cloud Functions compatibility.
class BalootSerializer {
  const BalootSerializer();

  Map<String, dynamic> serializeMatch(BalootMatch match) {
    final state = match.state;
    return {
      'totals': match.totals,
      'dealer': match.dealer,
      'handsPlayed': match.handsPlayed,
      'matchOver': match.matchOver,
      'winnerTeam': match.winnerTeam,
      'safeMode': match.safeMode,
      'autoDeclare': match.autoDeclare,
      'players': match.players.map((p) => {
        'name': p.name,
        'isBot': p.isBot,
        'level': p.level,
      }).toList(),
      'state': state == null ? null : serializeHandState(state),
    };
  }

  BalootMatch deserializeMatch(Map<String, dynamic> json) {
    final players = (json['players'] as List<dynamic>).map((p) => BalootPlayerConfig(
          name: p['name'] as String,
          isBot: p['isBot'] as bool? ?? false,
          level: p['level'] as String? ?? 'amateur',
        )).toList();

    final match = BalootMatch(
      players: players,
      safeMode: json['safeMode'] as bool? ?? false,
      autoDeclare: json['autoDeclare'] as bool? ?? false,
    )
      ..totals[0] = (json['totals'] as List<dynamic>)[0] as int
      ..totals[1] = (json['totals'] as List<dynamic>)[1] as int
      ..dealer = json['dealer'] as int
      ..handsPlayed = json['handsPlayed'] as int
      ..matchOver = json['matchOver'] as bool? ?? false
      ..winnerTeam = json['winnerTeam'] as int?;

    final stateJson = json['state'] as Map<String, dynamic>?;
    if (stateJson != null) {
      match.state = deserializeHandState(stateJson);
    }
    return match;
  }

  Map<String, dynamic> serializeHandState(BalootHandState state) {
    return {
      'phase': state.phase.name,
      'hands': state.hands.map((h) => h.map((c) => c.key).toList()).toList(),
      'topCard': state.topCard.key,
      'rest': state.rest.map((c) => c.key).toList(),
      'firstPlayer': state.firstPlayer,
      'mode': state.mode?.name,
      'trump': state.trump?.symbol,
      'buyer': state.buyer,
      'ashkal': state.ashkal,
      'bidding': {
        'round': state.bidding.round,
        'turn': state.bidding.turn,
        'spoken': state.bidding.spoken,
        'best': state.bidding.best == null
            ? null
            : {
                'type': state.bidding.best!.type.name,
                'seat': state.bidding.best!.seat,
                'suit': state.bidding.best!.suit?.symbol,
              },
      },
      'currentTrick': state.currentTrick.map((t) => {'seat': t.seat, 'card': t.card.key}).toList(),
      'trickHistory': state.trickHistory.map((t) => {
        'plays': t.plays.map((p) => {'seat': p.seat, 'card': p.card.key}).toList(),
        'winner': t.winner,
        'points': t.points,
      }).toList(),
      'leader': state.leader,
      'turn': state.turn,
      'projects': _serializeProjects(state.projects),
      'countedProjects': _serializeProjects(state.countedProjects),
      'droppedProjects': _serializeProjects(state.droppedProjects),
      'pendingAnnounce': _serializeProjects(state.pendingAnnounce),
      'pendingReveal': _serializeProjects(state.pendingReveal),
      'announcedProjects': _serializeProjects(state.announcedProjects),
      'revealedProjects': _serializeProjects(state.revealedProjects),
      'balootTeam': state.balootTeam,
      'balootSeat': state.balootSeat,
      'awaitingDeclare': state.awaitingDeclare,
      'declareSeats': state.declareSeats,
      'declarations': state.declarations.map((k, v) => MapEntry(k.toString(), v.map((e) => e.name).toList())),
      'doubleLevel': state.doubleLevel,
      'doubleTeam': state.doubleTeam,
      'awaitingDouble': state.awaitingDouble,
      'doubling': state.doubling == null
          ? null
          : {
              'turn': state.doubling!.turn,
              'stage': state.doubling!.stage,
              'nextLevel': state.doubling!.nextLevel,
            },
      'violation': state.violation == null
          ? null
          : {
              'seat': state.violation!.seat,
              'card': state.violation!.card.key,
              'trickIndex': state.violation!.trickIndex,
              'type': state.violation!.type.name,
              'escaped': state.violation!.escaped.map((c) => c.key).toList(),
              'confirmed': state.violation!.confirmed,
            },
      'pendingViolations': state.pendingViolations.map((v) => {
        'seat': v.seat,
        'card': v.card.key,
        'trickIndex': v.trickIndex,
        'type': v.type.name,
        'escaped': v.escaped.map((c) => c.key).toList(),
        'confirmed': v.confirmed,
      }).toList(),
      'voids': state.voids.map((s) => s.map((e) => e.symbol).toList()).toList(),
      'playedCards': state.playedCards.map((c) => c.key).toList(),
      'result': state.result == null ? null : _serializeHandResult(state.result!),
    };
  }

  BalootHandState deserializeHandState(Map<String, dynamic> json) {
    final state = BalootHandState()
      ..phase = BalootPhase.values.byName(json['phase'] as String)
      ..hands = (json['hands'] as List<dynamic>)
          .map((h) => (h as List<dynamic>).map((c) => BalootCard.fromString(c as String)).toList())
          .toList()
      ..topCard = BalootCard.fromString(json['topCard'] as String)
      ..rest = (json['rest'] as List<dynamic>).map((c) => BalootCard.fromString(c as String)).toList()
      ..firstPlayer = json['firstPlayer'] as int
      ..mode = json['mode'] == null ? null : BalootMode.values.byName(json['mode'] as String)
      ..trump = json['trump'] == null ? null : BalootSuit.fromSymbol(json['trump'] as String)
      ..buyer = json['buyer'] as int?
      ..ashkal = json['ashkal'] as bool? ?? false
      ..bidding = _deserializeBidding(json['bidding'] as Map<String, dynamic>)
      ..leader = json['leader'] as int
      ..turn = json['turn'] as int
      ..balootTeam = json['balootTeam'] as int?
      ..balootSeat = json['balootSeat'] as int?
      ..awaitingDeclare = json['awaitingDeclare'] as bool? ?? false
      ..declareSeats = (json['declareSeats'] as List<dynamic>? ?? []).cast<int>()
      ..declarations = (json['declarations'] as Map<String, dynamic>? ?? {}).map(
        (k, v) => MapEntry(int.parse(k), (v as List<dynamic>).map((e) => ProjectType.values.byName(e as String)).toList()),
      )
      ..doubleLevel = json['doubleLevel'] as int? ?? 1
      ..doubleTeam = json['doubleTeam'] as int?
      ..awaitingDouble = json['awaitingDouble'] as bool? ?? false
      ..doubling = json['doubling'] == null ? null : _deserializeDoubling(json['doubling'] as Map<String, dynamic>)
      ..result = json['result'] == null ? null : _deserializeHandResult(json['result'] as Map<String, dynamic>);

    state.currentTrick.addAll((json['currentTrick'] as List<dynamic>).map((t) =>
        TrickPlay(seat: t['seat'] as int, card: BalootCard.fromString(t['card'] as String))));

    state.trickHistory.addAll((json['trickHistory'] as List<dynamic>).map((t) => CompletedTrick(
          plays: (t['plays'] as List<dynamic>)
              .map((p) => TrickPlay(seat: p['seat'] as int, card: BalootCard.fromString(p['card'] as String)))
              .toList(),
          winner: t['winner'] as int,
          points: t['points'] as int,
        )));

    state.projects.addAll(_deserializeProjects(json['projects'] as List<dynamic>));
    state.countedProjects.addAll(_deserializeProjects(json['countedProjects'] as List<dynamic>));
    state.droppedProjects.addAll(_deserializeProjects(json['droppedProjects'] as List<dynamic>));
    state.pendingAnnounce.addAll(_deserializeProjects(json['pendingAnnounce'] as List<dynamic>));
    state.pendingReveal.addAll(_deserializeProjects(json['pendingReveal'] as List<dynamic>));
    state.announcedProjects.addAll(_deserializeProjects(json['announcedProjects'] as List<dynamic>));
    state.revealedProjects.addAll(_deserializeProjects(json['revealedProjects'] as List<dynamic>));

    if (json['violation'] != null) {
      state.violation = _deserializeViolation(json['violation'] as Map<String, dynamic>);
    }
    state.pendingViolations.addAll(
      (json['pendingViolations'] as List<dynamic>).map((v) => _deserializeViolation(v as Map<String, dynamic>)),
    );

    state.voids.addAll(
      (json['voids'] as List<dynamic>).map((s) =>
          (s as List<dynamic>).map((e) => BalootSuit.fromSymbol(e as String)).toSet()),
    );
    state.playedCards.addAll((json['playedCards'] as List<dynamic>).map((c) => BalootCard.fromString(c as String)));

    return state;
  }

  List<Map<String, dynamic>> _serializeProjects(List<ProjectClaim> projects) {
    return projects.map((p) => {
      'seat': p.seat,
      'type': p.type.name,
      'cards': p.cards.map((c) => c.key).toList(),
      'revealed': p.revealed,
    }).toList();
  }

  List<ProjectClaim> _deserializeProjects(List<dynamic> json) {
    return json.map((p) => ProjectClaim(
          seat: p['seat'] as int,
          type: ProjectType.values.byName(p['type'] as String),
          cards: (p['cards'] as List<dynamic>).map((c) => BalootCard.fromString(c as String)).toList(),
          revealed: p['revealed'] as bool? ?? false,
        )).toList();
  }

  BiddingState _deserializeBidding(Map<String, dynamic> json) {
    final best = json['best'] as Map<String, dynamic>?;
    return BiddingState(
      round: json['round'] as int,
      turn: json['turn'] as int,
      spoken: json['spoken'] as int,
      best: best == null
          ? null
          : BestBid(
              type: BidActionType.values.byName(best['type'] as String),
              seat: best['seat'] as int,
              suit: best['suit'] == null ? null : BalootSuit.fromSymbol(best['suit'] as String),
            ),
    );
  }

  DoublingState _deserializeDoubling(Map<String, dynamic> json) {
    return DoublingState(
      turn: json['turn'] as int,
      stage: json['stage'] as String,
      nextLevel: json['nextLevel'] as int,
    );
  }

  ViolationRecord _deserializeViolation(Map<String, dynamic> json) {
    return ViolationRecord(
      seat: json['seat'] as int,
      card: BalootCard.fromString(json['card'] as String),
      trickIndex: json['trickIndex'] as int,
      type: ViolationType.values.byName(json['type'] as String),
      escaped: (json['escaped'] as List<dynamic>).map((c) => BalootCard.fromString(c as String)).toList(),
      confirmed: json['confirmed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> _serializeHandResult(HandResult r) {
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
      'qatClaim': r.qatClaim == null
          ? null
          : {
              'type': r.qatClaim!.type.name,
              'typeName': r.qatClaim!.typeName,
              'failed': r.qatClaim!.failed,
              'claimSeat': r.qatClaim!.claimSeat,
              'violSeat': r.qatClaim!.violSeat,
              'winTeam': r.qatClaim!.winTeam,
              'violCard': r.qatClaim!.violCard?.key,
              'trickIndex': r.qatClaim!.trickIndex,
              'provedBy': r.qatClaim!.provedBy?.key,
            },
    };
  }

  HandResult _deserializeHandResult(Map<String, dynamic> json) {
    final qc = json['qatClaim'] as Map<String, dynamic>?;
    return HandResult(
      qaid: (json['qaid'] as List<dynamic>).cast<int>(),
      pts: (json['pts'] as List<dynamic>).cast<int>(),
      trickWins: (json['trickWins'] as List<dynamic>).cast<int>(),
      capotTeam: json['capotTeam'] as int?,
      buyerLost: json['buyerLost'] as bool,
      safeSaved: json['safeSaved'] as bool? ?? false,
      projQaid: (json['projQaid'] as List<dynamic>).cast<int>(),
      balootQaid: (json['balootQaid'] as List<dynamic>).cast<int>(),
      doubleLevel: json['doubleLevel'] as int,
      qatClaim: qc == null
          ? null
          : QatClaimResult(
              type: ViolationType.values.byName(qc['type'] as String),
              typeName: qc['typeName'] as String,
              failed: qc['failed'] as bool,
              claimSeat: qc['claimSeat'] as int,
              violSeat: qc['violSeat'] as int?,
              winTeam: qc['winTeam'] as int?,
              violCard: qc['violCard'] == null ? null : BalootCard.fromString(qc['violCard'] as String),
              trickIndex: qc['trickIndex'] as int?,
              provedBy: qc['provedBy'] == null ? null : BalootCard.fromString(qc['provedBy'] as String),
            ),
    );
  }
}
