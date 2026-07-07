import 'dart:async';
import 'dart:math';

import 'package:get_it/get_it.dart';

import 'package:bloot/core/services/agora_service.dart';
import 'package:bloot/core/services/audio_service.dart';
import 'package:bloot/features/game/domain/entities/game.dart';
import 'package:bloot/features/game/domain/repositories/game_repository.dart';
import 'package:bloot/features/game/presentation/cubit/game_cubit.dart';
import 'package:bloot/features/game/presentation/cubit/game_state.dart';
import 'package:bloot/features/room/domain/repositories/room_repository.dart';
import 'package:bloot/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

String _botAvatarUrl(String name) {
  return 'https://api.dicebear.com/7.x/bottts/png?seed=$name&backgroundColor=b6e3f4';
}

/// A fake repository that does nothing — the simulator manages all state locally.
class _FakeGameRepository implements GameRepository {
  @override
  Stream<Game> watchGame(String id) => const Stream.empty();

  @override
  Future<Game> getGameById(String id) async => throw UnimplementedError();

  @override
  Future<void> placeBid(String gameId, String bid) async {}

  @override
  Future<void> playCard(String gameId, String card) async {}

  @override
  Future<void> claimBonuses(
    String gameId,
    List<Map<String, dynamic>> bonuses,
  ) async {}

  @override
  Future<void> dealNextRound(String gameId) async {}

  @override
  Future<void> rematch(String roomId) async {}

  @override
  Stream<Game> watchGameAsSpectator(String id) => const Stream.empty();
}

/// Local Baloot simulator that runs a full 4-player game on one device.
///
/// The human player is always seat 0. Three bots (seats 1-3) play
/// automatically with realistic delays so the user can observe and
/// interact with the full game flow on a single device.
///
/// The engine follows the rules in `docs/game_rules.md`:
/// - Dealing: 5 + 4 + 4 with a face-up card determining proposed trump.
/// - Bidding: Pass < Sun < Hokm. First Hokm wins, last Sun wins.
/// - Hokm trump suit is the face-up card's suit.
/// - Trick play with correct trump rank/points.
/// - Fall scoring (120 Sun / 152 Hokm) and last-trick +10 bonus.
class LocalGameSimulator extends GameCubit {
  LocalGameSimulator({
    Duration humanTurnTimeout = _defaultHumanTurnTimeout,
    Duration? humanCardTimeout,
  }) : _humanTurnTimeout = humanTurnTimeout,
       _humanCardTimeout = humanCardTimeout ?? humanTurnTimeout,
       super(
        gameRepository: _FakeGameRepository(),
        roomRepository: GetIt.I<RoomRepository>(),
        agoraService: GetIt.I<AgoraService>(),
        audioService: GetIt.I<AudioService>(),
      );

  final Random _random = Random();
  Timer? _botTimer;
  Timer? _humanTurnCountdownTimer;

  /// Default timeout for human auto-play. Can be overridden in tests.
  static const _defaultHumanTurnTimeout = Duration(seconds: 15);
  final Duration _humanTurnTimeout;
  final Duration _humanCardTimeout;

  // Internal mutable game state
  late SimGame _game;
  final int _humanSeat = 0;
  bool _humanBidPending = false;
  bool _humanCardPending = false;
  bool _humanBonusPending = false;
  int _bidWinnerSeat = 0;

  // Bot names and avatars for realism
  static const _botNames = ['Faisal', 'Omar', 'Khalid'];
  static const _botTeams = ['B', 'A', 'B'];

  @override
  void watchGame(String id) {
    emit(const GameState.loading());
    // Defer dealing setup so the Bloc listener is attached before the state
    // changes — prevents the transition from being swallowed during create.
    Future.microtask(() => _startNewGame(id));
  }

  @override
  void loadGame(String id) => watchGame(id);

  void _startNewGame(String id) {
    _botTimer?.cancel();
    _stopTurnCountdown();
    _humanBidPending = false;
    _humanCardPending = false;
    _humanBonusPending = false;

    _game = SimGame(id: id, random: _random);
    _game.deal();
    _emitGameState('dealing');

    // Brief dealing delay then start bidding
    _botTimer = Timer(const Duration(milliseconds: 1200), () {
      _startBidding();
    });
  }

  void _startTurnCountdown(Duration duration) {
    _stopTurnCountdown();
    final totalSeconds = max(1, duration.inSeconds);
    humanTurnSecondsLeft.value = totalSeconds;
    var secondsLeft = totalSeconds;
    _humanTurnCountdownTimer = Timer.periodic(const Duration(seconds: 1), (
      timer,
    ) {
      // Ignore ticks from a stale timer that was replaced before it fired.
      if (timer != _humanTurnCountdownTimer) return;
      secondsLeft--;
      humanTurnSecondsLeft.value = secondsLeft > 0 ? secondsLeft : null;
      if (secondsLeft <= 0) {
        timer.cancel();
      }
    });
  }

  void _stopTurnCountdown() {
    _humanTurnCountdownTimer?.cancel();
    _humanTurnCountdownTimer = null;
    humanTurnSecondsLeft.value = null;
  }

  void _startBidding() {
    _game.status = 'bidding';
    // Bidding starts with the player to the dealer's right.
    _game.turnIndex = (_game.dealerIndex + 1) % 4;
    _advanceBidTurn();
  }

  void _advanceBidTurn() {
    _emitGameState('bidding');

    if (_game.allBidsComplete) {
      _finalizeBidding();
      return;
    }

    final turn = _game.turnIndex;

    // If human's turn, wait for UI input (with an auto-pass fallback).
    if (turn == _humanSeat) {
      _humanBidPending = true;
      _startTurnCountdown(_humanTurnTimeout);
      _botTimer = Timer(_humanTurnTimeout, () {
        if (!_humanBidPending) return;
        placeBid('pass');
      });
      return;
    }

    // Bot bid with a realistic delay
    final delay = Duration(milliseconds: 600 + _random.nextInt(1200));
    _startTurnCountdown(delay);
    _botTimer = Timer(delay, () {
      _botBid(turn);
      _game.nextTurn();
      _advanceBidTurn();
    });
  }

  void _botBid(int seat) {
    final canBidHokm = _game.isValidBid(seat, 'hokm');
    final canBidSun = _game.isValidBid(seat, 'sun');

    // Simple bot strategy:
    // - Bid Hokm ~30% if eligible.
    // - Otherwise bid Sun ~30%.
    // - Otherwise pass.
    final roll = _random.nextDouble();
    if (canBidHokm && roll < 0.3) {
      _game.placeBid(seat, 'hokm');
    } else if (canBidSun && roll < 0.6) {
      _game.placeBid(seat, 'sun');
    } else {
      _game.placeBid(seat, 'pass');
    }
  }

  void _finalizeBidding() {
    final winner = _game.winningBidder;
    if (winner == null) {
      // Everyone passed — redeal by same dealer (per Baloot rules).
      // Preserve cumulative scores and round number.
      final currentDealer = _game.dealerIndex;
      final savedTeamAScore = _game.teamAScore;
      final savedTeamBScore = _game.teamBScore;
      final savedCurrentRound = _game.currentRound;
      final savedTargetScore = _game.targetScore;
      _startNewGame(_game.id);
      _game.dealerIndex = currentDealer;
      _game.teamAScore = savedTeamAScore;
      _game.teamBScore = savedTeamBScore;
      _game.currentRound = savedCurrentRound;
      _game.targetScore = savedTargetScore;
      return;
    }

    _game.biddingTeam = _game.players[winner].team;
    _game.gameType = _game.winningBidType;
    _game.trump = _game.winningTrumpSuit;
    _game.turnIndex = winner;
    _bidWinnerSeat = winner;

    // Move straight into the next phase so the UI doesn't linger on bidding.
    if (_game.gameType == 'hokm') {
      _startBonusClaim();
    } else {
      _startTrickPlay();
    }
  }

  void _startBonusClaim() {
    _game.status = 'bonusClaim';
    _advanceBonusClaimTurn();
  }

  void _advanceBonusClaimTurn() {
    _emitGameState('bonusClaim');

    if (_game.allBonusesClaimed) {
      // Don't keep the player waiting on the bonus overlay.
      _startTrickPlay();
      return;
    }

    final turn = _game.turnIndex;

    if (turn == _humanSeat) {
      _humanBonusPending = true;
      _startTurnCountdown(_humanTurnTimeout);
      _botTimer = Timer(_humanTurnTimeout, () {
        if (!_humanBonusPending) return;
        claimBonuses(_game.autoDetectBonuses(_humanSeat));
      });
      return;
    }

    final delay = Duration(milliseconds: 500 + _random.nextInt(1000));
    _startTurnCountdown(delay);
    _botTimer = Timer(delay, () {
      final bonuses = _game.autoDetectBonuses(turn);
      _game.claimBonuses(turn, bonuses);
      _game.nextTurn();
      _advanceBonusClaimTurn();
    });
  }

  void _startTrickPlay() {
    // Trick play always starts with the bid winner, regardless of where the
    // bonus-claim rotation ended.
    _game.turnIndex = _bidWinnerSeat;
    _game.startNewTrick();
    _emitGameState('playing');
    _advanceCardTurn();
  }

  void _advanceCardTurn() {
    // Check if trick is complete
    if (_game.currentTrickCards.length == 4) {
      _resolveTrick();
      return;
    }

    final turn = _game.turnIndex;

    // If human's turn, wait for UI input (with an auto-play fallback).
    if (turn == _humanSeat) {
      _humanCardPending = true;
      _emitGameState('playing');
      _startTurnCountdown(_humanTurnTimeout);
      _botTimer = Timer(_humanCardTimeout, () {
        if (!_humanCardPending) return;
        final legal = _game.legalCards(_humanSeat);
        if (legal.isNotEmpty) playCard(legal.first);
      });
      return;
    }

    // Bot plays with realistic delay
    final delay = Duration(milliseconds: 800 + _random.nextInt(1500));
    _startTurnCountdown(delay);
    _botTimer = Timer(delay, () {
      _botPlayCard(turn);
      _game.nextTurn();
      _advanceCardTurn();
    });
  }

  void _botPlayCard(int seat) {
    final legal = _game.legalCards(seat);
    if (legal.isEmpty) return;
    // Sort by rank — bots prefer middle cards, occasionally high
    legal.sort(_game.compareCards);
    final idx = _random.nextInt(legal.length);
    _game.playCard(seat, legal[idx]);
  }

  void _resolveTrick() {
    final winner = _game.resolveTrick();
    _game.lastTrickWinner = winner;
    _game.status = 'trickEnd';
    _emitTrickEndState(winner);

    _botTimer = Timer(const Duration(milliseconds: 1500), () {
      _game.players[winner].tricksWon++;
      _game.collectTrickCards(winner);

      // Check if round is over (all 13 tricks played)
      if (_game.tricksPlayed >= 13) {
        _endRound();
      } else {
        _game.turnIndex = winner;
        _game.status = 'playing';
        _game.startNewTrick();
        _emitGameState('playing');
        _advanceCardTurn();
      }
    });
  }

  void _endRound() {
    final (teamAPoints, teamBPoints) = _game.scoreRound();
    _game.teamAScore += teamAPoints;
    _game.teamBScore += teamBPoints;
    _game.status = 'roundEnd';
    _emitRoundEndState(teamAPoints, teamBPoints);

    _botTimer = Timer(
      const Duration(milliseconds: 2500),
      _proceedAfterRoundEnd,
    );
  }

  void _proceedAfterRoundEnd() {
    // Check game end
    final usScore = _humanTeam == 'A' ? _game.teamAScore : _game.teamBScore;
    final themScore = _humanTeam == 'A' ? _game.teamBScore : _game.teamAScore;
    final target = _game.targetScore;

    if (usScore >= target || themScore >= target) {
      _game.status = 'gameEnd';
      _emitGameEndState(
        usScore >= themScore ? _humanTeam : (_humanTeam == 'A' ? 'B' : 'A'),
      );
    } else {
      // Next round
      _game.currentRound++;
      _game.dealerIndex = (_game.dealerIndex + 1) % 4;
      _game.resetForNewRound();
      _game.deal();
      _emitGameState('dealing');
      _botTimer = Timer(const Duration(milliseconds: 1200), () {
        _startBidding();
      });
    }
  }

  String get _humanTeam => _game.players[_humanSeat].team;

  // ——— Human actions ———

  @override
  Duration get humanTurnTimeoutDuration => _humanTurnTimeout;

  @override
  Future<void> placeBid(String bid) async {
    if (!_humanBidPending) {
      emitActionError(LocaleKeys.not_your_turn_bid.tr());
      return;
    }
    if (!_game.isValidBid(_humanSeat, bid)) {
      if (bid == 'hokm') {
        final trumpSuit = _game.faceUpSuit;
        if (trumpSuit == null ||
            !_game.players[_humanSeat].hand.any(
              (c) => c.substring(c.length - 1) == trumpSuit,
            )) {
          emitActionError(LocaleKeys.hokm_requires_trump_suit.tr());
        } else {
          emitActionError(LocaleKeys.hokm_after_hokm.tr());
        }
      } else if (bid == 'sun') {
        final existingBids = _game.players
            .map((p) => p.bid)
            .whereType<String>()
            .toList();
        if (existingBids.contains('sun')) {
          emitActionError(LocaleKeys.sun_after_sun.tr());
        } else if (existingBids.contains('hokm')) {
          emitActionError(LocaleKeys.hokm_after_hokm.tr());
        } else {
          emitActionError(LocaleKeys.bid_not_allowed.tr());
        }
      } else {
        emitActionError(LocaleKeys.bid_not_allowed.tr());
      }
      return;
    }
    _botTimer?.cancel();
    _stopTurnCountdown();
    _humanBidPending = false;
    _game.placeBid(_humanSeat, bid);
    _game.nextTurn();
    _advanceBidTurn();
  }

  @override
  Future<void> playCard(String card) async {
    if (!_humanCardPending) {
      emitActionError(LocaleKeys.not_your_turn_card.tr());
      return;
    }
    if (!_game.legalCards(_humanSeat).contains(card)) {
      emitActionError(LocaleKeys.card_not_allowed.tr());
      return;
    }

    _botTimer?.cancel();
    _stopTurnCountdown();
    _humanCardPending = false;
    _game.playCard(_humanSeat, card);
    _game.nextTurn();
    _advanceCardTurn();
  }

  @override
  Future<void> claimBonuses(List<Map<String, dynamic>> bonuses) async {
    if (!_humanBonusPending) {
      emitActionError(LocaleKeys.not_your_turn_bonus.tr());
      return;
    }
    _botTimer?.cancel();
    _stopTurnCountdown();
    _humanBonusPending = false;
    _game.claimBonuses(_humanSeat, bonuses);
    _game.nextTurn();
    _advanceBonusClaimTurn();
  }

  @override
  Future<void> dealNextRound() async {
    // In the simulator we auto-advance, but if the user taps the overlay
    // button before the timer fires, proceed immediately.
    if (state is GameRoundEnd) {
      _botTimer?.cancel();
      _proceedAfterRoundEnd();
    }
  }

  @override
  Future<void> rematch() async {
    // Simulator has no room; just start a fresh game with the same id.
    _botTimer?.cancel();
    _stopTurnCountdown();
    emit(const GameState.loading());
    Future.microtask(() => _startNewGame(_game.id));
  }

  @override
  Future<void> close() async {
    _botTimer?.cancel();
    _humanTurnCountdownTimer?.cancel();
    return super.close();
  }

  @override
  Future<void> toggleMic() async {
    emitActionError(LocaleKeys.simulator_mic_unavailable.tr());
  }

  @override
  Future<void> toggleCamera() async {
    emitActionError(LocaleKeys.simulator_camera_unavailable.tr());
  }

  // ——— State emission ———

  void _emitGameState(String status) {
    _game.status = status;
    final g = _game.toEntity(_humanSeat);
    _emitStateFromGame(g);
  }

  void _emitTrickEndState(int winnerSeat) {
    final g = _game.toEntity(_humanSeat);
    emit(GameState.trickEnd(game: g, winnerSeat: winnerSeat));
  }

  void _emitRoundEndState(int teamAPoints, int teamBPoints) {
    final g = _game.toEntity(_humanSeat);
    // RoundScoreOverlay labels teamA/teamB as Us/Them, so emit local perspective.
    final usPoints = _humanTeam == 'A' ? teamAPoints : teamBPoints;
    final themPoints = _humanTeam == 'A' ? teamBPoints : teamAPoints;
    emit(
      GameState.roundEnd(
        game: g,
        teamAPoints: usPoints,
        teamBPoints: themPoints,
      ),
    );
  }

  void _emitGameEndState(String winnerTeam) {
    final g = _game.toEntity(_humanSeat);
    emit(GameState.gameEnd(game: g, winnerTeam: winnerTeam));
  }

  void _emitStateFromGame(Game game) {
    switch (game.status) {
      case 'dealing':
        emit(GameState.dealing(game: game));
      case 'bidding':
        emit(GameState.bidding(game: game));
      case 'bonusClaim':
        emit(GameState.bonusClaim(game: game));
      case 'playing':
        emit(GameState.playing(game: game));
      case 'trickEnd':
        emit(
          GameState.trickEnd(
            game: game,
            winnerSeat:
                game.currentTrick?.winnerSeat ??
                game.currentTrick?.trickLeaderIndex ??
                0,
          ),
        );
      case 'roundEnd':
        emit(
          GameState.roundEnd(
            game: game,
            teamAPoints: game.scoreUs,
            teamBPoints: game.scoreThem,
            fellTeam: game.fellTeam,
          ),
        );
      case 'gameEnd':
        emit(
          GameState.gameEnd(
            game: game,
            winnerTeam: game.teamAScore >= game.teamBScore ? 'A' : 'B',
          ),
        );
      default:
        emit(GameState.playing(game: game));
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
// Internal simulator engine
// ═══════════════════════════════════════════════════════════════════

class SimPlayer {
  SimPlayer({
    required this.uid,
    required this.name,
    required this.team,
    required this.seatIndex,
  });

  final String uid;
  final String name;
  final String team;
  final int seatIndex;
  List<String> hand = [];
  List<String> takenCards = [];
  int tricksWon = 0;
  String? bid;
  List<Map<String, dynamic>> claimedBonuses = [];
  bool hasClaimedBonus = false;
}

class SimGame {
  SimGame({required this.id, required Random random}) : _random = random;

  final String id;
  final Random _random;

  late List<SimPlayer> players;
  String status = 'dealing';
  int turnIndex = 0;
  int dealerIndex = 0;
  int currentRound = 1;
  int targetScore = 152;
  String? gameType;
  String? trump;
  String? biddingTeam;
  int teamAScore = 0;
  int teamBScore = 0;
  String? faceUpCard;
  int? lastTrickWinner;

  // Trick state
  final Map<int, String> currentTrickCards = {};
  int trickLeaderIndex = 0;
  int tricksPlayed = 0;

  bool get allBidsComplete {
    if (players.every((p) => p.bid != null)) return true;
    if (_allPassed()) return true;
    // If someone has bid Hokm and everyone else has had a chance, bidding ends.
    // Simplification: bidding proceeds until everyone has bid once.
    return false;
  }

  bool _allPassed() => players.every((p) => p.bid == 'pass');

  String? get winningBidType {
    final bidders = players
        .where((p) => p.bid != null && p.bid != 'pass')
        .toList();
    if (bidders.isEmpty) return null;
    final anyHokm = bidders.any((p) => p.bid == 'hokm');
    return anyHokm ? 'hokm' : 'sun';
  }

  String? get winningTrumpSuit {
    if (winningBidType != 'hokm') return null;
    return faceUpSuit;
  }

  String? get faceUpSuit => faceUpCard == null ? null : _suitOf(faceUpCard!);

  List<int> get _biddingOrder =>
      [1, 2, 3, 4].map((o) => (dealerIndex + o) % 4).toList();

  int? get winningBidder {
    final bidders = players
        .where((p) => p.bid != null && p.bid != 'pass')
        .toList();
    if (bidders.isEmpty) return null;

    final order = _biddingOrder;
    bidders.sort(
      (a, b) =>
          order.indexOf(a.seatIndex).compareTo(order.indexOf(b.seatIndex)),
    );

    final bidType = winningBidType;
    if (bidType == 'hokm') {
      // First Hokm bidder in clockwise bidding order wins.
      return bidders.firstWhere((p) => p.bid == 'hokm').seatIndex;
    }

    // Sun: last Sun bidder in clockwise bidding order wins.
    SimPlayer? lastSun;
    for (final p in bidders) {
      if (p.bid == 'sun') lastSun = p;
    }
    return lastSun?.seatIndex;
  }

  void deal() {
    players = [
      SimPlayer(uid: 'human', name: 'You', team: 'A', seatIndex: 0),
      SimPlayer(
        uid: 'bot1',
        name: LocalGameSimulator._botNames[0],
        team: LocalGameSimulator._botTeams[0],
        seatIndex: 1,
      ),
      SimPlayer(
        uid: 'bot2',
        name: LocalGameSimulator._botNames[1],
        team: LocalGameSimulator._botTeams[1],
        seatIndex: 2,
      ),
      SimPlayer(
        uid: 'bot3',
        name: LocalGameSimulator._botNames[2],
        team: LocalGameSimulator._botTeams[2],
        seatIndex: 3,
      ),
    ];

    final deck = _createDeck()..shuffle(_random);

    // Deal counter-clockwise in rounds: 5 + 4 + 4.
    // Dealer is the last to receive in each round, so the face-up card
    // is the last card dealt to the dealer.
    for (var i = 0; i < 4; i++) {
      players[i].hand = [];
      players[i].bid = null;
      players[i].tricksWon = 0;
      players[i].takenCards = [];
      players[i].claimedBonuses = [];
    }

    var deckIndex = 0;
    String? lastCardDealt;
    void dealRound(int count) {
      for (var r = 0; r < 4; r++) {
        final seat = (dealerIndex + 1 + r) % 4;
        final cards = deck.sublist(deckIndex, deckIndex + count);
        players[seat].hand.addAll(cards);
        lastCardDealt = cards.last;
        deckIndex += count;
      }
    }

    dealRound(5);
    dealRound(4);
    dealRound(4);

    // The last card dealt (to the dealer) is placed face-up.
    faceUpCard = lastCardDealt;

    currentTrickCards.clear();
    trickLeaderIndex = 0;
    tricksPlayed = 0;
    gameType = null;
    trump = null;
    biddingTeam = null;
    lastTrickWinner = null;
  }

  void nextTurn() {
    turnIndex = (turnIndex + 1) % 4;
  }

  void placeBid(int seat, String bid) {
    players[seat].bid = bid;
  }

  bool isValidBid(int seat, String bid) {
    if (bid == 'pass') return true;

    final existingBids = players.map((p) => p.bid).whereType<String>().toList();
    final hasHokm = existingBids.contains('hokm');
    final hasSun = existingBids.contains('sun');

    if (bid == 'sun') {
      return !hasHokm && !hasSun;
    }

    if (bid == 'hokm') {
      if (hasHokm) return false;
      final trumpProposalSuit = faceUpSuit;
      if (trumpProposalSuit == null) return false;
      return players[seat].hand.any((c) => _suitOf(c) == trumpProposalSuit);
    }

    return false;
  }

  void startNewTrick() {
    currentTrickCards.clear();
    trickLeaderIndex = turnIndex;
  }

  List<String> legalCards(int seat) {
    final hand = players[seat].hand;
    if (currentTrickCards.isEmpty) return List.from(hand);

    final leading = _suitOf(currentTrickCards.values.first);
    final follow = hand.where((c) => _suitOf(c) == leading).toList();
    return follow.isNotEmpty ? follow : List.from(hand);
  }

  void playCard(int seat, String card) {
    players[seat].hand.remove(card);
    currentTrickCards[seat] = card;
  }

  int resolveTrick() {
    final entries = currentTrickCards.entries.toList();
    if (entries.isEmpty) return trickLeaderIndex;

    final leadingSuit = _suitOf(entries.first.value);
    final trumpSuit = gameType == 'hokm' ? faceUpSuit : null;

    var winner = entries.first;
    for (var i = 1; i < entries.length; i++) {
      final current = entries[i];
      if (cardBeats(current.value, winner.value, leadingSuit, trumpSuit)) {
        winner = current;
      }
    }
    return winner.key;
  }

  void collectTrickCards(int winnerSeat) {
    players[winnerSeat].takenCards.addAll(currentTrickCards.values);
    tricksPlayed++;
  }

  (int, int) scoreRound() {
    int teamAPoints = 0;
    int teamBPoints = 0;

    // Base card points
    for (final p in players) {
      final points = p.takenCards.fold(
        0,
        (sum, card) =>
            sum + cardPoints(card, gameType == 'hokm' ? faceUpSuit : null),
      );
      if (p.team == 'A') teamAPoints += points;
      if (p.team == 'B') teamBPoints += points;
    }

    // Bonuses (only in Hokm)
    var teamABonus = 0;
    var teamBBonus = 0;
    if (gameType == 'hokm') {
      final a = _teamBestBonuses('A');
      final b = _teamBestBonuses('B');

      final winner = _compareBonuses(
        teamAMosal: a.mosal,
        teamABnaga: a.bnaga,
        teamABnagaCards: a.bnagaCards,
        teamBMosal: b.mosal,
        teamBBnaga: b.bnaga,
        teamBBnagaCards: b.bnagaCards,
      );

      if (winner == 'A') {
        teamABonus = a.mosal + a.bnaga;
      } else if (winner == 'B') {
        teamBBonus = b.mosal + b.bnaga;
      } else {
        // Tie: both teams keep their own bonuses (Cloud Functions gives both).
        teamABonus = a.mosal + a.bnaga;
        teamBBonus = b.mosal + b.bnaga;
      }
    }

    // Apply fall rules
    final biddingTeamWon = biddingTeam == 'A'
        ? teamAPoints > teamBPoints
        : teamBPoints > teamAPoints;
    final totalPoints = gameType == 'hokm' ? 152 : 120;

    if (!biddingTeamWon) {
      // Fall: bidding team gets 0, opponents get total + all bonuses (both teams)
      if (biddingTeam == 'A') {
        return (0, totalPoints + teamABonus + teamBBonus);
      } else {
        return (totalPoints + teamABonus + teamBBonus, 0);
      }
    }

    // No fall: each team keeps earned points + their valid bonuses
    return (teamAPoints + teamABonus, teamBPoints + teamBBonus);
  }

  ({int mosal, int bnaga, List<String> bnagaCards}) _teamBestBonuses(
    String team,
  ) {
    var bestMosal = 0;
    var bestBnaga = 0;
    List<String> bestBnagaCards = [];
    for (final p in players.where((p) => p.team == team)) {
      for (final bonus in p.claimedBonuses) {
        final points = (bonus['points'] as num?)?.toInt() ?? 0;
        final type = bonus['type'] as String? ?? '';
        final cards =
            (bonus['cards'] as List<dynamic>?)?.cast<String>().toList() ??
            <String>[];
        if (type == 'mosal' && points > bestMosal) {
          bestMosal = points;
        }
        if (type == 'bnaga') {
          if (points > bestBnaga) {
            bestBnaga = points;
            bestBnagaCards = cards;
          } else if (points == bestBnaga && points > 0) {
            // Same-length sequences tie: keep the higher-ranking one.
            final candidateHigh = _highestSequenceCard(cards);
            final currentHigh = _highestSequenceCard(bestBnagaCards);
            if (candidateHigh > currentHigh) {
              bestBnagaCards = cards;
            }
          }
        }
      }
    }
    return (mosal: bestMosal, bnaga: bestBnaga, bnagaCards: bestBnagaCards);
  }

  String _compareBonuses({
    required int teamAMosal,
    required int teamABnaga,
    required List<String> teamABnagaCards,
    required int teamBMosal,
    required int teamBBnaga,
    required List<String> teamBBnagaCards,
  }) {
    // 1. Compare mosal first.
    if (teamAMosal > teamBMosal) return 'A';
    if (teamBMosal > teamAMosal) return 'B';

    // 2. No mosal or tied mosal: compare longest bnaga by points.
    if (teamABnaga > teamBBnaga) return 'A';
    if (teamBBnaga > teamABnaga) return 'B';

    // 3. Equal length sequences: compare highest card in sequence.
    if (teamABnagaCards.isNotEmpty && teamBBnagaCards.isNotEmpty) {
      final aHigh = _highestSequenceCard(teamABnagaCards);
      final bHigh = _highestSequenceCard(teamBBnagaCards);
      if (aHigh > bHigh) return 'A';
      if (bHigh > aHigh) return 'B';
    }

    // True tie: both teams keep bonuses.
    return 'tie';
  }

  int _highestSequenceCard(List<String> cards) {
    // Sequence high-card ranking: A > K > Q > J > 10 > 9 > ... > 2
    const rankOrder = {
      '2': 0,
      '3': 1,
      '4': 2,
      '5': 3,
      '6': 4,
      '7': 5,
      '8': 6,
      '9': 7,
      '10': 8,
      'J': 9,
      'Q': 10,
      'K': 11,
      'A': 12,
    };
    return cards
        .map((c) => rankOrder[_rankOf(c)] ?? 0)
        .reduce((a, b) => a > b ? a : b);
  }

  void resetForNewRound() {
    for (final p in players) {
      p.hand = [];
      p.takenCards = [];
      p.tricksWon = 0;
      p.bid = null;
      p.claimedBonuses = [];
      p.hasClaimedBonus = false;
    }
    currentTrickCards.clear();
    tricksPlayed = 0;
    gameType = null;
    trump = null;
    biddingTeam = null;
    faceUpCard = null;
    lastTrickWinner = null;
  }

  // ——— Bonus claim ———

  bool get allBonusesClaimed => players.every((p) => p.hasClaimedBonus);

  void claimBonuses(int seat, List<Map<String, dynamic>> bonuses) {
    players[seat].claimedBonuses = bonuses;
    players[seat].hasClaimedBonus = true;
  }

  List<Map<String, dynamic>> autoDetectBonuses(int seat) {
    final hand = players[seat].hand;
    final bonuses = <Map<String, dynamic>>[];

    // Detect sequences (Bnaga)
    final suits = {'S', 'H', 'D', 'C'};
    for (final suit in suits) {
      final suitCards = hand.where((c) => _suitOf(c) == suit).toList();
      if (suitCards.length < 3) continue;

      final sorted = suitCards.toList()
        ..sort(
          (a, b) =>
              _sequenceRank(_rankOf(b)).compareTo(_sequenceRank(_rankOf(a))),
        );

      List<String> currentSeq = [sorted.first];
      List<String>? bestSeq;

      for (var i = 1; i < sorted.length; i++) {
        final prevRank = _sequenceRank(_rankOf(currentSeq.last));
        final currRank = _sequenceRank(_rankOf(sorted[i]));
        if (prevRank - currRank == 1) {
          currentSeq.add(sorted[i]);
        } else {
          if (currentSeq.length >= 3 &&
              (bestSeq == null || currentSeq.length > bestSeq.length)) {
            bestSeq = currentSeq.toList();
          }
          currentSeq = [sorted[i]];
        }
      }
      if (currentSeq.length >= 3 &&
          (bestSeq == null || currentSeq.length > bestSeq.length)) {
        bestSeq = currentSeq.toList();
      }

      if (bestSeq != null) {
        final length = bestSeq.length;
        final points = length == 3
            ? 20
            : length == 4
            ? 50
            : 100;
        bonuses.add({
          'type': 'bnaga',
          'points': points,
          'cards': bestSeq,
          'length': length,
        });
      }
    }

    // If multiple same-length sequences exist, keep only the highest-ranking one.
    final bnagas = bonuses.where((b) => b['type'] == 'bnaga').toList();
    if (bnagas.length > 1) {
      final best = bnagas.reduce((a, b) {
        final lenA = (a['length'] as num?)?.toInt() ?? 0;
        final lenB = (b['length'] as num?)?.toInt() ?? 0;
        if (lenA != lenB) return lenA > lenB ? a : b;
        final cardsA =
            (a['cards'] as List<dynamic>?)?.cast<String>().toList() ??
            <String>[];
        final cardsB =
            (b['cards'] as List<dynamic>?)?.cast<String>().toList() ??
            <String>[];
        return _highestSequenceCard(cardsA) >= _highestSequenceCard(cardsB)
            ? a
            : b;
      });
      bonuses.removeWhere((b) => b['type'] == 'bnaga');
      bonuses.add(best);
    }

    // Detect mosal (four of a kind)
    final rankGroups = <String, List<String>>{};
    for (final card in hand) {
      rankGroups.putIfAbsent(_rankOf(card), () => []).add(card);
    }
    for (final entry in rankGroups.entries) {
      if (entry.value.length == 4) {
        final points = switch (entry.key) {
          'J' => 200,
          '9' => 150,
          'A' || '10' || 'K' || 'Q' => 100,
          _ => 0,
        };
        if (points > 0) {
          bonuses.add({
            'type': 'mosal',
            'rank': entry.key,
            'points': points,
            'cards': entry.value,
          });
        }
      }
    }

    return bonuses;
  }

  Game toEntity(int humanSeat) {
    final gamePlayers = players.map((p) {
      return GamePlayer(
        uid: p.uid,
        name: p.name,
        avatarUrl: p.seatIndex == humanSeat ? '' : _botAvatarUrl(p.name),
        team: p.team,
        seatIndex: p.seatIndex,
        hand: p.hand,
        takenCards: p.takenCards,
        tricksWon: p.tricksWon,
        bid: p.bid,
        isActive: p.seatIndex == turnIndex,
        hasCamera: false,
        isMuted: true,
      );
    }).toList();

    final myHand = players[humanSeat].hand;
    final played = <String?>[null, null, null, null];
    for (final entry in currentTrickCards.entries) {
      played[entry.key] = entry.value;
    }

    return Game(
      id: id,
      players: gamePlayers,
      myHand: myHand,
      mySeatIndex: humanSeat,
      playedCards: played,
      scoreUs: humanSeatTeam(humanSeat) == 'A' ? teamAScore : teamBScore,
      scoreThem: humanSeatTeam(humanSeat) == 'A' ? teamBScore : teamAScore,
      teamAScore: teamAScore,
      teamBScore: teamBScore,
      trump: trump ?? '',
      status: status,
      turnIndex: turnIndex,
      currentRound: currentRound,
      targetScore: targetScore,
      gameType: gameType,
      dealerIndex: dealerIndex,
      faceUpCard: faceUpCard,
      biddingTeam: biddingTeam,
      currentTrick: currentTrickCards.isEmpty
          ? null
          : Trick(
              trickNumber: tricksPlayed + 1,
              trickLeaderIndex: trickLeaderIndex,
              leadingSuit: currentTrickCards.isEmpty
                  ? null
                  : _suitOf(currentTrickCards.values.first),
              cards: currentTrickCards.map((k, v) => MapEntry(k.toString(), v)),
              winnerSeat: lastTrickWinner,
            ),
    );
  }

  String humanSeatTeam(int humanSeat) => players[humanSeat].team;

  // ——— Card utilities ———

  static List<String> _createDeck() {
    final suits = ['S', 'H', 'D', 'C'];
    final ranks = [
      'A',
      'K',
      'Q',
      'J',
      '10',
      '9',
      '8',
      '7',
      '6',
      '5',
      '4',
      '3',
      '2',
    ];
    return [
      for (final s in suits)
        for (final r in ranks) '$r$s',
    ];
  }

  static String _suitOf(String card) => card.substring(card.length - 1);
  static String _rankOf(String card) => card.substring(0, card.length - 1);

  static int _rankOrder(String rank, {bool isTrump = false}) {
    if (isTrump) {
      return switch (rank) {
        'J' => 8,
        '9' => 7,
        'A' => 6,
        '10' => 5,
        'K' => 4,
        'Q' => 3,
        '8' => 2,
        '7' => 1,
        _ => 0,
      };
    }
    return switch (rank) {
      'A' => 14,
      '10' => 10,
      'K' => 13,
      'Q' => 12,
      'J' => 11,
      '9' => 9,
      '8' => 8,
      '7' => 7,
      '6' => 6,
      '5' => 5,
      '4' => 4,
      '3' => 3,
      '2' => 2,
      _ => 0,
    };
  }

  static int _sequenceRank(String rank) {
    return switch (rank) {
      'A' => 14,
      'K' => 13,
      'Q' => 12,
      'J' => 11,
      '10' => 10,
      '9' => 9,
      '8' => 8,
      '7' => 7,
      '6' => 6,
      '5' => 5,
      '4' => 4,
      '3' => 3,
      '2' => 2,
      _ => 0,
    };
  }

  int compareCards(String a, String b) {
    return _rankOrder(_rankOf(a)).compareTo(_rankOrder(_rankOf(b)));
  }

  static bool cardBeats(
    String candidate,
    String current,
    String leadingSuit,
    String? trumpSuit,
  ) {
    final candSuit = _suitOf(candidate);
    final currSuit = _suitOf(current);
    final candRank = _rankOf(candidate);
    final currRank = _rankOf(current);
    final isTrump = trumpSuit != null;

    // Trump beats non-trump
    if (isTrump) {
      if (candSuit == trumpSuit && currSuit != trumpSuit) return true;
      if (candSuit != trumpSuit && currSuit == trumpSuit) return false;
    }

    // Leading suit beats non-leading (when neither is trump)
    if (candSuit == leadingSuit && currSuit != leadingSuit) return true;
    if (candSuit != leadingSuit && currSuit == leadingSuit) return false;

    // Same suit — higher rank wins
    final candPower = _rankOrder(
      candRank,
      isTrump: isTrump && candSuit == trumpSuit,
    );
    final currPower = _rankOrder(
      currRank,
      isTrump: isTrump && currSuit == trumpSuit,
    );
    return candPower > currPower;
  }

  static int cardPoints(String card, String? trumpSuit) {
    final rank = _rankOf(card);
    final isTrump = trumpSuit != null && _suitOf(card) == trumpSuit;

    if (isTrump) {
      return switch (rank) {
        'J' => 20,
        '9' => 14,
        'A' => 11,
        '10' => 10,
        'K' => 4,
        'Q' => 3,
        _ => 0,
      };
    }

    return switch (rank) {
      'A' => 11,
      '10' => 10,
      'K' => 4,
      'Q' => 3,
      'J' => 2,
      _ => 0,
    };
  }
}
