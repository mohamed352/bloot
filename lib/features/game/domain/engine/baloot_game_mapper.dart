import 'package:bloot/features/game/domain/entities/game.dart';

import 'package:bloot/features/game/domain/engine/baloot_engine.dart';
import 'package:bloot/features/game/domain/engine/baloot_rules.dart';
import 'package:bloot/features/game/domain/engine/baloot_state.dart';

/// Maps the internal Saudi Baloot engine state to the existing [Game] entity
/// used by the Flutter UI. This lets us keep the current GamePlayPage/widgets
/// while swapping the underlying engine.
class BalootGameMapper {
  const BalootGameMapper();

  /// Builds a [Game] entity from the engine state for the player at [humanSeat].
  Game toEntity({
    required BalootMatch match,
    required String gameId,
    required int humanSeat,
    String? roomId,
    String? agoraChannelName,
  }) {
    final state = match.state!;
    final myTeam = BalootEngine.teamOf(humanSeat);
    final isTeamA = myTeam == 0;

    final players = _buildPlayers(match, humanSeat);

    // Current trick cards indexed by absolute seat.
    final playedCards = List<String?>.filled(4, null);
    for (final play in state.currentTrick) {
      playedCards[play.seat] = play.card.key;
    }

    // Completed trick winner if the 4th card was just played.
    int? winnerSeat;
    if (state.phase == BalootPhase.handEnd && state.trickHistory.isNotEmpty) {
      winnerSeat = state.trickHistory.last.winner;
    } else if (state.currentTrick.length == 4) {
      winnerSeat = BalootEngine().trickWinnerIndex(state.currentTrick, state);
    }

    return Game(
      id: gameId,
      players: players,
      myHand: state.hands[humanSeat].map((c) => c.key).toList(),
      mySeatIndex: humanSeat,
      playedCards: playedCards,
      scoreUs: isTeamA ? match.totals[0] : match.totals[1],
      scoreThem: isTeamA ? match.totals[1] : match.totals[0],
      teamAScore: match.totals[0],
      teamBScore: match.totals[1],
      trump: state.trump?.symbol ?? '',
      status: _statusFromPhase(state.phase),
      turnIndex: _effectiveTurn(state),
      currentRound: match.handsPlayed + 1,
      targetScore: BalootRules.targetQaid,
      gameType: state.ashkal ? 'ashkal' : state.mode?.name,
      dealerIndex: match.dealer,
      faceUpCard: state.topCard.key,
      biddingTeam: state.buyer == null ? null : (BalootEngine.teamOf(state.buyer!) == 0 ? 'A' : 'B'),
      fellTeam: state.result?.buyerLost == true
          ? (BalootEngine.teamOf(state.buyer!) == 0 ? 'A' : 'B')
          : null,
      currentTrick: Trick(
        trickNumber: state.trickHistory.length + 1,
        trickLeaderIndex: state.leader,
        leadingSuit: state.currentTrick.isEmpty ? null : state.currentTrick.first.card.suit.symbol,
        cards: _trickCardsMap(state.currentTrick),
        winnerSeat: winnerSeat,
      ),
      projects: _projectsForSeat(state, humanSeat),
      roomId: roomId,
      agoraChannelName: agoraChannelName,
    );
  }

  List<GamePlayer> _buildPlayers(BalootMatch match, int humanSeat) {
    return List.generate(4, (seat) {
      final team = BalootEngine.teamOf(seat) == 0 ? 'A' : 'B';
      return GamePlayer(
        uid: seat == humanSeat ? 'human' : 'bot$seat',
        name: match.players[seat].name,
        avatarUrl: '',
        team: team,
        seatIndex: seat,
        hand: match.state!.hands[seat].map((c) => c.key).toList(),
        takenCards: [],
        tricksWon: _tricksWon(match.state!, seat),
        bid: _bidString(match.state!, seat),
        isActive: seat == _effectiveTurn(match.state!),
        isMuted: true,
        hasCamera: false,
      );
    });
  }

  int _tricksWon(BalootHandState state, int seat) {
    return state.trickHistory.where((t) => t.winner == seat).length;
  }

  String? _bidString(BalootHandState state, int seat) {
    if (state.phase == BalootPhase.bidding) {
      // The current engine doesn't store per-player final bids on state; this
      // can be enhanced later. For now return null during bidding.
      return null;
    }
    if (state.buyer == seat) return state.mode == BalootMode.hokum ? 'hokm' : 'sun';
    return 'pass';
  }

  List<Map<String, dynamic>> _projectsForSeat(BalootHandState state, int seat) {
    return state.projects
        .where((p) => p.seat == seat)
        .map((p) => <String, dynamic>{
              'type': p.type.name,
              'cards': p.cards.map((c) => c.key).toList(),
            })
        .toList();
  }

  Map<String, String?> _trickCardsMap(List<TrickPlay> trick) {
    final map = <String, String?>{};
    for (var i = 0; i < 4; i++) {
      map[i.toString()] = null;
    }
    for (final play in trick) {
      map[play.seat.toString()] = play.card.key;
    }
    return map;
  }

  int _effectiveTurn(BalootHandState state) {
    if (state.phase == BalootPhase.handEnd || state.phase == BalootPhase.matchEnd) return -1;
    return state.turn;
  }

  String _statusFromPhase(BalootPhase phase) {
    return switch (phase) {
      BalootPhase.bidding => 'bidding',
      BalootPhase.playing => 'playing',
      BalootPhase.handEnd => 'roundEnd',
      BalootPhase.matchEnd => 'gameEnd',
    };
  }
}
