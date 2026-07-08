import 'dart:async';
import 'dart:math';

import 'package:get_it/get_it.dart';

import 'package:bloot/core/services/agora_service.dart';
import 'package:bloot/core/services/audio_service.dart';
import 'package:bloot/features/game/domain/engine/baloot_engine_module.dart';
import 'package:bloot/features/game/domain/entities/game.dart';
import 'package:bloot/features/game/domain/repositories/game_repository.dart';
import 'package:bloot/features/game/presentation/cubit/game_cubit.dart';
import 'package:bloot/features/game/presentation/cubit/game_state.dart';
import 'package:bloot/features/room/domain/repositories/room_repository.dart';
import 'package:bloot/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

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
  Future<void> claimBonuses(String gameId, List<Map<String, dynamic>> bonuses) async {}

  @override
  Future<void> dealNextRound(String gameId) async {}

  @override
  Future<void> rematch(String roomId) async {}

  @override
  Stream<Game> watchGameAsSpectator(String id) => const Stream.empty();
}

/// Local Saudi Baloot simulator using the new 32-card engine.
///
/// The human player is always seat 0. Three bots (seats 1-3) play
/// automatically with realistic delays.
class LocalGameSimulator extends GameCubit {
  LocalGameSimulator({
    Duration humanTurnTimeout = _defaultHumanTurnTimeout,
    Duration? humanCardTimeout,
  })  : _humanTurnTimeout = humanTurnTimeout,
        _humanCardTimeout = humanCardTimeout ?? humanTurnTimeout,
        super(
          gameRepository: _FakeGameRepository(),
          roomRepository: GetIt.I<RoomRepository>(),
          agoraService: GetIt.I<AgoraService>(),
          audioService: GetIt.I<AudioService>(),
        );

  static const _defaultHumanTurnTimeout = Duration(seconds: 15);
  final Duration _humanTurnTimeout;
  final Duration _humanCardTimeout;

  final Random _random = Random();
  final BalootEngine _engine = BalootEngine();
  final BalootBot _bot = BalootBot();
  final BalootGameMapper _mapper = const BalootGameMapper();

  Timer? _botTimer;
  Timer? _humanTurnCountdownTimer;

  late BalootMatch _match;
  final int _humanSeat = 0;
  bool _humanBidPending = false;
  bool _humanCardPending = false;
  bool _humanProjectPending = false;

  @override
  void watchGame(String id) {
    emit(const GameState.loading());
    Future.microtask(() => _startNewGame(id));
  }

  @override
  void loadGame(String id) => watchGame(id);

  void _startNewGame(String id) {
    _botTimer?.cancel();
    _stopTurnCountdown();
    _humanBidPending = false;
    _humanCardPending = false;
    _humanProjectPending = false;

    _match = _engine.createMatch([
      const BalootPlayerConfig(name: 'You'),
      const BalootPlayerConfig(name: 'Faisal', isBot: true),
      const BalootPlayerConfig(name: 'Omar', isBot: true),
      const BalootPlayerConfig(name: 'Khalid', isBot: true),
    ]);
    _engine.startHand(_match);
    _emitState('dealing');

    _botTimer = Timer(const Duration(milliseconds: 1200), _startBidding);
  }

  void _startBidding() {
    _botTimer?.cancel();
    _emitState('bidding');
    _advanceBidTurn();
  }

  void _advanceBidTurn() {
    _botTimer?.cancel();
    if (_match.state!.bidding.spoken == 4 && _match.state!.bidding.best == null) {
      // Everyone passed — redeal.
      _handleRedeal();
      return;
    }

    if (_match.state!.phase == BalootPhase.playing) {
      _startProjectDeclaration();
      return;
    }

    final turn = _match.state!.bidding.turn;
    if (turn == _humanSeat) {
      _humanBidPending = true;
      _startTurnCountdown(_humanTurnTimeout);
      _botTimer = Timer(_humanTurnTimeout, () {
        if (!_humanBidPending) return;
        placeBid('pass');
      });
      return;
    }

    final delay = Duration(milliseconds: 600 + _random.nextInt(1200));
    _startTurnCountdown(delay);
    _botTimer = Timer(delay, () {
      if (_match.state!.phase != BalootPhase.bidding) return;
      if (_match.state!.bidding.turn != turn) return;
      final action = _bot.decideBid(_match, turn, _botLevel(turn));
      _engine.applyBid(_match, turn, action);
      _advanceBidTurn();
    });
  }

  void _handleRedeal() {
    final savedDealer = _match.dealer;
    final savedTotals = List<int>.from(_match.totals);
    final savedHandsPlayed = _match.handsPlayed;
    _startNewGame(_match.state.hashCode.toString());
    _match.dealer = savedDealer;
    _match.totals[0] = savedTotals[0];
    _match.totals[1] = savedTotals[1];
    _match.handsPlayed = savedHandsPlayed;
  }

  void _startProjectDeclaration() {
    _botTimer?.cancel();
    final state = _match.state!;
    if (!state.awaitingDeclare || state.declareSeats.isEmpty) {
      _startDoubling();
      return;
    }

    // In local simulator only the human player needs to declare projects.
    // Bot projects are auto-kept by the engine, so skip any bot seats.
    if (!state.declareSeats.contains(_humanSeat)) {
      // No human declaration required; finalize by declaring nothing for the
      // first pending seat and let the engine move on.
      final seat = state.declareSeats.first;
      _engine.declareProject(_match, seat, []);
      _startProjectDeclaration();
      return;
    }

    state.turn = _humanSeat;
    _humanProjectPending = true;
    _emitState('bonusClaim');
    _startTurnCountdown(_humanTurnTimeout);
    _botTimer = Timer(_humanTurnTimeout, () {
      if (!_humanProjectPending) return;
      claimBonuses([]);
    });
  }

  void _startDoubling() {
    _botTimer?.cancel();
    final state = _match.state!;
    if (!state.awaitingDouble || state.doubling == null) {
      _startTrickPlay();
      return;
    }

    final turn = state.doubling!.turn;
    if (turn == _humanSeat) {
      // Human auto-passes doubling for now; UI can be added later.
      _engine.applyDouble(_match, turn, DoubleAction.pass);
      _startDoubling();
      return;
    }

    final delay = Duration(milliseconds: 500 + _random.nextInt(800));
    _startTurnCountdown(delay);
    _botTimer = Timer(delay, () {
      final current = _match.state!;
      if (!current.awaitingDouble || current.doubling == null) {
        _startTrickPlay();
        return;
      }
      if (current.doubling!.turn != turn) {
        _startDoubling();
        return;
      }
      final action = _bot.decideDouble(_match, turn, _botLevel(turn))
          ? DoubleAction.double
          : DoubleAction.pass;
      _engine.applyDouble(_match, turn, action);
      _startDoubling();
    });
  }

  void _startTrickPlay() {
    _botTimer?.cancel();
    _match.state!.turn = _match.state!.buyer!;
    _emitState('playing');
    _advanceCardTurn();
  }

  void _advanceCardTurn({bool emitTrickEndIfNeeded = true}) {
    _botTimer?.cancel();
    final state = _match.state!;

    // The engine resolves tricks and scores hands inside playCard, so we react
    // to the resulting state rather than resolving ourselves.
    if (state.phase == BalootPhase.handEnd || state.phase == BalootPhase.matchEnd) {
      _endRound();
      return;
    }

    if (emitTrickEndIfNeeded && state.currentTrick.isEmpty && state.trickHistory.isNotEmpty) {
      // A trick was just completed by the engine; pause, then lead the winner.
      final winnerSeat = state.turn;
      _emitTrickEndState(winnerSeat);
      _botTimer = Timer(const Duration(milliseconds: 1500), () {
        _advanceCardTurn(emitTrickEndIfNeeded: false);
      });
      return;
    }

    final turn = state.turn;
    if (turn == _humanSeat) {
      _humanCardPending = true;
      _startTurnCountdown(_humanTurnTimeout);
      _botTimer = Timer(_humanCardTimeout, () {
        if (!_humanCardPending) return;
        final legal = _engine.legalMoves(state, _humanSeat);
        if (legal.isNotEmpty) playCard(legal.first.key);
      });
      _emitState('playing');
      return;
    }

    final delay = Duration(milliseconds: 800 + _random.nextInt(1500));
    _startTurnCountdown(delay);
    _botTimer = Timer(delay, () {
      final current = _match.state!;
      if (current.phase == BalootPhase.handEnd || current.phase == BalootPhase.matchEnd) {
        _endRound();
        return;
      }
      if (current.turn != turn) {
        _advanceCardTurn();
        return;
      }
      final legal = _engine.legalMoves(current, turn);
      if (legal.isEmpty) {
        _advanceCardTurn();
        return;
      }
      final card = _bot.decidePlay(_match, turn, _botLevel(turn));
      _engine.playCard(_match, turn, card);
      _advanceCardTurn();
    });
  }

  void _endRound() {
    final state = _match.state!;
    final result = state.result ?? _engine.scoreHand(state);
    _match.totals[0] += result.qaid[0];
    _match.totals[1] += result.qaid[1];
    _match.handsPlayed++;
    _match.state!.result = result;
    _emitRoundEndState(result.qaid[0], result.qaid[1]);

    _botTimer = Timer(const Duration(milliseconds: 2500), _proceedAfterRoundEnd);
  }

  void _proceedAfterRoundEnd() {
    if (_match.totals[0] >= BalootRules.targetQaid || _match.totals[1] >= BalootRules.targetQaid) {
      if (_match.totals[0] != _match.totals[1]) {
        _match.matchOver = true;
        _match.winnerTeam = _match.totals[0] > _match.totals[1] ? 0 : 1;
        _match.state!.phase = BalootPhase.matchEnd;
        _emitGameEndState(_match.winnerTeam!);
        return;
      }
    }

    _match.dealer = (_match.dealer + 1) % 4;
    _engine.startHand(_match);
    _emitState('dealing');
    _botTimer = Timer(const Duration(milliseconds: 1200), _startBidding);
  }

  BotLevel _botLevel(int seat) {
    final key = _match.players[seat].level;
    return BotLevel.values.firstWhere(
      (l) => l.name == key,
      orElse: () => BotLevel.amateur,
    );
  }

  // ——— Human actions ———

  @override
  Duration get humanTurnTimeoutDuration => _humanTurnTimeout;

  @override
  Future<void> placeBid(String bid) async {
    if (!_humanBidPending) {
      emitActionError(LocaleKeys.not_your_turn_bid.tr());
      return;
    }

    BidAction action;
    switch (bid) {
      case 'sun':
        action = const BidAction.sun();
      case 'hokm':
        action = const BidAction.hokum(null);
      case 'ashkal':
        action = const BidAction.ashkal();
      default:
        action = const BidAction.pass();
    }

    try {
      _engine.applyBid(_match, _humanSeat, action);
    } catch (e) {
      emitActionError(LocaleKeys.bid_not_allowed.tr());
      return;
    }

    _botTimer?.cancel();
    _stopTurnCountdown();
    _humanBidPending = false;
    _advanceBidTurn();
  }

  @override
  Future<void> playCard(String card) async {
    if (!_humanCardPending) {
      emitActionError(LocaleKeys.not_your_turn_card.tr());
      return;
    }

    final BalootCard balootCard;
    try {
      balootCard = BalootCard.fromString(card);
    } catch (_) {
      emitActionError(LocaleKeys.card_not_allowed.tr());
      return;
    }
    if (!_engine.legalMoves(_match.state!, _humanSeat).contains(balootCard)) {
      emitActionError(LocaleKeys.card_not_allowed.tr());
      return;
    }

    _botTimer?.cancel();
    _stopTurnCountdown();
    _humanCardPending = false;
    _engine.playCard(_match, _humanSeat, balootCard);
    _advanceCardTurn();
  }

  @override
  Future<void> claimBonuses(List<Map<String, dynamic>> bonuses) async {
    if (!_humanProjectPending) {
      emitActionError(LocaleKeys.not_your_turn_bonus.tr());
      return;
    }

    final claimed = bonuses
        .map((b) => ProjectType.values.byName(b['type'] as String? ?? ''))
        .toList();

    _botTimer?.cancel();
    _stopTurnCountdown();
    _humanProjectPending = false;
    try {
      _engine.declareProject(_match, _humanSeat, claimed);
    } catch (_) {
      // Declaration window closed (e.g., auto-timeout raced with user action).
    }
    _startProjectDeclaration();
  }

  @override
  Future<void> dealNextRound() async {
    if (_match.state!.phase == BalootPhase.handEnd) {
      _botTimer?.cancel();
      _proceedAfterRoundEnd();
    }
  }

  @override
  Future<void> rematch() async {
    _botTimer?.cancel();
    _stopTurnCountdown();
    emit(const GameState.loading());
    Future.microtask(() => _startNewGame(_match.state.hashCode.toString()));
  }

  @override
  Future<void> close() async {
    _botTimer?.cancel();
    _humanTurnCountdownTimer?.cancel();
    return super.close();
  }

  @override
  Future<void> toggleMic() async => emitActionError(LocaleKeys.simulator_mic_unavailable.tr());

  @override
  Future<void> toggleCamera() async => emitActionError(LocaleKeys.simulator_camera_unavailable.tr());

  // ——— State emission ———

  void _emitState(String status) {
    final game = _mapper.toEntity(
      match: _match,
      gameId: _match.state.hashCode.toString(),
      humanSeat: _humanSeat,
    ).copyWith(status: status);
    _emitStateFromGame(game);
  }

  void _emitTrickEndState(int winnerSeat) {
    final game = _mapper.toEntity(
      match: _match,
      gameId: _match.state.hashCode.toString(),
      humanSeat: _humanSeat,
    );
    emit(GameState.trickEnd(game: game, winnerSeat: winnerSeat));
  }

  void _emitRoundEndState(int teamAQaid, int teamBQaid) {
    final game = _mapper.toEntity(
      match: _match,
      gameId: _match.state.hashCode.toString(),
      humanSeat: _humanSeat,
    );
    final usPoints = BalootEngine.teamOf(_humanSeat) == 0 ? teamAQaid : teamBQaid;
    final themPoints = BalootEngine.teamOf(_humanSeat) == 0 ? teamBQaid : teamAQaid;
    emit(GameState.roundEnd(
      game: game,
      teamAPoints: usPoints,
      teamBPoints: themPoints,
      fellTeam: game.fellTeam,
    ));
  }

  void _emitGameEndState(int winnerTeam) {
    final game = _mapper.toEntity(
      match: _match,
      gameId: _match.state.hashCode.toString(),
      humanSeat: _humanSeat,
    );
    final myTeam = BalootEngine.teamOf(_humanSeat);
    emit(GameState.gameEnd(
      game: game,
      winnerTeam: winnerTeam == myTeam ? 'A' : 'B',
    ));
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
        emit(GameState.trickEnd(
          game: game,
          winnerSeat: game.currentTrick?.winnerSeat ?? 0,
        ));
      case 'roundEnd':
        emit(GameState.roundEnd(
          game: game,
          teamAPoints: game.scoreUs,
          teamBPoints: game.scoreThem,
          fellTeam: game.fellTeam,
        ));
      case 'gameEnd':
        emit(GameState.gameEnd(
          game: game,
          winnerTeam: game.teamAScore >= game.teamBScore ? 'A' : 'B',
        ));
      default:
        emit(GameState.playing(game: game));
    }
  }

  // ——— Timer ———

  void _startTurnCountdown(Duration duration) {
    _stopTurnCountdown();
    final totalSeconds = duration.inSeconds < 1 ? 1 : duration.inSeconds;
    humanTurnSecondsLeft.value = totalSeconds;
    var secondsLeft = totalSeconds;
    _humanTurnCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timer != _humanTurnCountdownTimer) return;
      secondsLeft--;
      humanTurnSecondsLeft.value = secondsLeft > 0 ? secondsLeft : null;
      if (secondsLeft <= 0) timer.cancel();
    });
  }

  void _stopTurnCountdown() {
    _humanTurnCountdownTimer?.cancel();
    _humanTurnCountdownTimer = null;
    humanTurnSecondsLeft.value = null;
  }
}
