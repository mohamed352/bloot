import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart' show FirebaseException;
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:bloot/core/logger/app_logger.dart';
import 'package:bloot/core/services/agora_service.dart';
import 'package:bloot/core/services/audio_service.dart';
import 'package:bloot/core/services/stream_heartbeat_service.dart';
import 'package:bloot/features/game/domain/entities/game.dart';
import 'package:bloot/features/game/domain/repositories/game_repository.dart';
import 'package:bloot/features/game/presentation/cubit/game_state.dart';
import 'package:bloot/features/room/domain/repositories/room_repository.dart';

@injectable
class GameCubit extends Cubit<GameState> {
  GameCubit({
    required GameRepository gameRepository,
    required RoomRepository roomRepository,
    required AgoraService agoraService,
    required AudioService audioService,
    StreamHeartbeatService? heartbeatService,
    // Retry policy for the 'Game not found' race (see below). Injectable so
    // tests don't wait on real delays.
    Duration notFoundRetryDelay = const Duration(seconds: 2),
    int maxNotFoundRetries = 5,
    Duration trickEndAdvanceDelay = const Duration(milliseconds: 2300),
    Duration turnTimeoutGrace = const Duration(seconds: 3),
  }) : _gameRepository = gameRepository,
       _roomRepository = roomRepository,
       _agoraService = agoraService,
       _audioService = audioService,
       _heartbeatService =
           heartbeatService ??
           StreamHeartbeatService(roomRepository: roomRepository),
       _notFoundRetryDelay = notFoundRetryDelay,
       _maxNotFoundRetries = maxNotFoundRetries,
       _trickEndAdvanceDelay = trickEndAdvanceDelay,
       _turnTimeoutGrace = turnTimeoutGrace,
       super(const GameState.initial());

  final GameRepository _gameRepository;
  final RoomRepository _roomRepository;
  final AgoraService _agoraService;
  final AudioService _audioService;
  final StreamHeartbeatService _heartbeatService;
  StreamSubscription<Game>? _gameSubscription;
  String? _joinedAgoraChannelName;
  Future<void>? _pendingAgoraJoin;
  bool _isClosed = false;
  bool _isSpectator = false;

  /// Countdown seconds left for the current turn. Null when no timer is active
  /// (e.g., non-simulator games). In the local simulator this is updated for
  /// every active seat (human and bots) so the UI can show a turn timer.
  final ValueNotifier<int?> humanTurnSecondsLeft = ValueNotifier<int?>(null);

  /// Timeout duration used for local human-turn feedback and bidding overlays.
  /// Online games default to 30s; simulator subclasses can override this.
  Duration get humanTurnTimeoutDuration => const Duration(seconds: 30);

  /// Alias for [watchGame] to maintain backward compatibility.
  void loadGame(String id) => watchGame(id);

  /// Starts watching the game in real-time.
  void watchGame(String id) =>
      _startWatching(id, () => _gameRepository.watchGame(id));

  /// Starts watching the game as a spectator.
  void watchGameAsSpectator(String id) {
    _isSpectator = true;
    _startWatching(id, () => _gameRepository.watchGameAsSpectator(id));
  }

  /// The room document flips to 'playing' (exposing its gameId) before the
  /// server finishes writing the game document, so a watcher can hit
  /// 'Game not found' on a game that is about to exist. Retry a few times
  /// with a short delay instead of showing a permanent error.
  final int _maxNotFoundRetries;
  final Duration _notFoundRetryDelay;
  int _notFoundRetries = 0;

  void _startWatching(String id, Stream<Game> Function() streamFactory) {
    emit(const GameState.loading());
    _gameSubscription?.cancel();
    _joinedAgoraChannelName = null;
    _notFoundRetries = 0;
    _subscribeToGame(id, streamFactory);
  }

  void _subscribeToGame(String id, Stream<Game> Function() streamFactory) {
    _gameSubscription = streamFactory().listen(
      (game) => _emitStateForGame(game),
      onError: (Object error) {
        if (error.toString().contains('Game not found') &&
            _notFoundRetries < _maxNotFoundRetries) {
          _notFoundRetries++;
          AppLogger.warning(
            'Game doc not ready yet (gameId: $id), retry $_notFoundRetries/$_maxNotFoundRetries',
          );
          Future<void>.delayed(_notFoundRetryDelay, () {
            if (_isClosed) return;
            _subscribeToGame(id, streamFactory);
          });
          return;
        }
        AppLogger.error('Game stream error (gameId: $id)', error: error);
        emit(GameState.error(message: _describeGameLoadError(error)));
      },
    );
  }

  /// Maps low-level stream failures to user-meaningful messages instead of
  /// the previous generic "Failed to load game." for every cause.
  String _describeGameLoadError(Object error) {
    if (error is FirebaseException && error.code == 'permission-denied') {
      return 'game_watch_no_access'.tr();
    }
    final text = error.toString();
    if (text.contains('Game not found') ||
        text.contains('Game data is null') ||
        text.contains('Game has no players')) {
      return 'game_ended'.tr();
    }
    return 'game_load_failed'.tr();
  }

  String? _previousStatus;
  String? _lastEmittedSignature;

  /// Event-driven replacement for the 1-minute autoPlay cron's trickEnd
  /// advance: the next-to-play client's timer calls `advanceTrick` once the
  /// trick-result pause has elapsed.
  Timer? _trickAdvanceTimer;

  /// Signature of the last turn for which a `checkTurnTimeout` call was
  /// fired, so it goes out at most once per turn (per timer start).
  String? _lastTurnTimeoutSignature;

  /// Single-shot timer that fires `checkTurnTimeout` shortly after the
  /// current turn exceeds its time limit, so a stalled turn is enforced even
  /// when no further snapshots arrive.
  Timer? _turnTimeoutTimer;

  final Duration _trickEndAdvanceDelay;
  final Duration _turnTimeoutGrace;

  void _scheduleTrickAdvance(Game game) {
    _trickAdvanceTimer?.cancel();
    _trickAdvanceTimer = null;
    if (_isSpectator || _isClosed || game.status != 'trickEnd') return;
    // Only the next-to-play player's client triggers the advance; the server
    // guards against duplicates and the cron remains a fallback.
    if (game.mySeatIndex != game.turnIndex) return;
    final gameId = game.id;
    _trickAdvanceTimer = Timer(
      _trickEndAdvanceDelay,
      () => _fireAdvanceTrick(gameId, attempt: 0),
    );
  }

  static const int _maxAdvanceAttempts = 3;

  Future<void> _fireAdvanceTrick(String gameId, {required int attempt}) async {
    if (_isClosed) return;
    try {
      final retryAfterMs = await _gameRepository.advanceTrick(gameId);
      // Server says the trick-end pause hasn't fully elapsed (custom
      // trickEndDelayMs longer than the client default): retry once per hint.
      if (retryAfterMs != null &&
          retryAfterMs > 0 &&
          attempt + 1 < _maxAdvanceAttempts &&
          !_isClosed) {
        _trickAdvanceTimer = Timer(
          Duration(milliseconds: retryAfterMs + 200),
          () => _fireAdvanceTrick(gameId, attempt: attempt + 1),
        );
      }
    } catch (e) {
      AppLogger.warning('advanceTrick failed (cron fallback remains): $e');
    }
  }

  /// Event-driven AFK enforcement: when a fresh snapshot shows the current
  /// turn has already exceeded the server's turn time limit, fire ONE
  /// `checkTurnTimeout` call instead of waiting for the 1-minute cron.
  /// Deduped by (status, turnIndex, turnTimerStart) so it fires at most once
  /// per turn; the server re-checks inside a transaction, so races with the
  /// cron or other clients are harmless.
  void _maybeCheckTurnTimeout(Game game) {
    if (_isSpectator || _isClosed) return;
    if (game.status != 'bidding' && game.status != 'playing') return;
    final timerStart = game.turnTimerStart;
    if (timerStart == null) return;
    final limitSeconds = game.turnTimeLimit > 0 ? game.turnTimeLimit : 45;
    final elapsed = DateTime.now().difference(timerStart);
    if (elapsed < Duration(seconds: limitSeconds)) return;
    final signature =
        '${game.id}|${game.status}|${game.turnIndex}|'
        '${timerStart.millisecondsSinceEpoch}';
    if (_lastTurnTimeoutSignature == signature) return;
    _lastTurnTimeoutSignature = signature;
    _fireCheckTurnTimeout(game.id);
  }

  /// Schedules [_fireCheckTurnTimeout] for `turnTimeLimit + grace` measured
  /// from `turnTimerStart`. Cancelled/rescheduled on every new state; if the
  /// state has advanced in the meantime the signature no longer matches and
  /// the fire is skipped. The server re-checks inside a transaction, so a
  /// stale fire is harmless.
  void _scheduleTurnTimeoutCheck(Game game) {
    _turnTimeoutTimer?.cancel();
    _turnTimeoutTimer = null;
    if (_isSpectator || _isClosed) return;
    if (game.status != 'bidding' && game.status != 'playing') return;
    final timerStart = game.turnTimerStart;
    if (timerStart == null) return;
    final limitSeconds = game.turnTimeLimit > 0 ? game.turnTimeLimit : 45;
    final deadline = Duration(seconds: limitSeconds) + _turnTimeoutGrace;
    final elapsed = DateTime.now().difference(timerStart);
    // Already overdue: _maybeCheckTurnTimeout handles it immediately.
    if (elapsed >= deadline) return;
    final signature =
        '${game.id}|${game.status}|${game.turnIndex}|'
        '${timerStart.millisecondsSinceEpoch}';
    if (_lastTurnTimeoutSignature == signature) return;
    final gameId = game.id;
    _turnTimeoutTimer = Timer(deadline - elapsed, () {
      if (_isClosed || _lastTurnTimeoutSignature == signature) return;
      _lastTurnTimeoutSignature = signature;
      _fireCheckTurnTimeout(gameId);
    });
  }

  Future<void> _fireCheckTurnTimeout(String gameId) async {
    if (_isClosed) return;
    try {
      await _gameRepository.checkTurnTimeout(gameId);
    } catch (e) {
      AppLogger.warning('checkTurnTimeout failed (cron fallback remains): $e');
    }
  }

  String _gameSignature(Game game) {
    final trick = game.currentTrick;
    final trickSig = trick == null
        ? ''
        : '${trick.trickNumber}|${trick.winnerSeat}|'
              '${trick.cards.entries.map((e) => '${e.key}:${e.value}').join(',')}';
    // Include bids, media and connection flags, and tricks won: snapshots
    // where only these change used to be silently skipped, leaving the UI
    // stale (e.g. mic/camera toggles or bids never rendering).
    final playersSig = game.players
        .map(
          (p) =>
              '${p.seatIndex}:${p.bid}|${p.isMuted}|${p.hasCamera}|${p.isConnected}|${p.tricksWon}',
        )
        .join(',');
    return '${game.status}|${game.turnIndex}|${game.scoreUs}|${game.scoreThem}|'
        '${game.teamAScore}|${game.teamBScore}|${game.currentRound}|'
        '${game.trump}|${game.dealerIndex}|${game.faceUpCard}|${game.biddingTeam}|'
        '${game.myHand.join(',')}|$trickSig|$playersSig|${game.projects.length}';
  }

  void _emitStateForGame(Game game) {
    final current = state;
    final previousStatus = _previousStatus;
    _previousStatus = game.status;

    // Runs before the signature dedup below: turnTimerStart changes are
    // timer-only updates that must not trigger a re-emit, but a stalled turn
    // should still be reported exactly once.
    _maybeCheckTurnTimeout(game);

    // Skip emitting an identical game state to avoid rebuilding the WebView host
    // and re-encoding the engine state on every Firestore timestamp update.
    final signature = _gameSignature(game);
    if (_lastEmittedSignature == signature) {
      _joinAgoraIfNeeded(game);
      return;
    }
    _lastEmittedSignature = signature;

    _scheduleTrickAdvance(game);
    _scheduleTurnTimeoutCheck(game);
    _joinAgoraIfNeeded(game);
    _syncStreamHeartbeat(game);
    _playSoundsForTransition(previousStatus, game);

    final controlsVisible = current.maybeMap(
      dealing: (s) => s.controlsVisible,
      bidding: (s) => s.controlsVisible,
      bonusClaim: (s) => s.controlsVisible,
      playing: (s) => s.controlsVisible,
      trickEnd: (s) => s.controlsVisible,
      roundEnd: (s) => s.controlsVisible,
      gameEnd: (s) => s.controlsVisible,
      orElse: () => true,
    );
    final selectedIndex = current.maybeMap(
      dealing: (s) => s.selectedCardIndex,
      bidding: (s) => s.selectedCardIndex,
      bonusClaim: (s) => s.selectedCardIndex,
      playing: (s) => s.selectedCardIndex,
      trickEnd: (s) => s.selectedCardIndex,
      roundEnd: (s) => s.selectedCardIndex,
      gameEnd: (s) => s.selectedCardIndex,
      orElse: () => null,
    );

    switch (game.status) {
      case 'dealing':
        emit(
          GameState.dealing(
            game: game,
            controlsVisible: controlsVisible,
            selectedCardIndex: selectedIndex,
          ),
        );
      case 'bidding':
        emit(
          GameState.bidding(
            game: game,
            controlsVisible: controlsVisible,
            selectedCardIndex: selectedIndex,
          ),
        );
      case 'bonusClaim':
        emit(
          GameState.bonusClaim(
            game: game,
            controlsVisible: controlsVisible,
            selectedCardIndex: selectedIndex,
          ),
        );
      case 'playing':
        emit(
          GameState.playing(
            game: game,
            controlsVisible: controlsVisible,
            selectedCardIndex: selectedIndex,
          ),
        );
      case 'trickEnd':
        // Winner is stored on the completed trick once the 4th card is played.
        emit(
          GameState.trickEnd(
            game: game,
            winnerSeat:
                game.currentTrick?.winnerSeat ??
                game.currentTrick?.trickLeaderIndex ??
                0,
            controlsVisible: controlsVisible,
            selectedCardIndex: selectedIndex,
          ),
        );
      case 'roundEnd':
        emit(
          GameState.roundEnd(
            game: game,
            teamAPoints: game.scoreUs,
            teamBPoints: game.scoreThem,
            fellTeam: game.fellTeam,
            controlsVisible: controlsVisible,
            selectedCardIndex: selectedIndex,
          ),
        );
      case 'gameEnd':
        final winner = game.teamAScore >= game.teamBScore ? 'A' : 'B';
        emit(
          GameState.gameEnd(
            game: game,
            winnerTeam: winner,
            controlsVisible: controlsVisible,
            selectedCardIndex: selectedIndex,
          ),
        );
      default:
        emit(
          GameState.playing(
            game: game,
            controlsVisible: controlsVisible,
            selectedCardIndex: selectedIndex,
          ),
        );
    }
  }

  bool _heartbeatSynced = false;

  /// Keeps the host's stream heartbeat alive while on the game page. The
  /// lobby's RoomCubit (which used to own the timer) is closed when the game
  /// starts, so without this the server sweeper would kill healthy live
  /// streams ~5–15 minutes into every game.
  Future<void> _syncStreamHeartbeat(Game game) async {
    if (game.status == 'gameEnd') {
      _heartbeatService.stop();
      return;
    }
    if (_isSpectator || _heartbeatSynced) return;
    _heartbeatSynced = true;
    try {
      final roomId = game.roomId;
      if (roomId == null || roomId.isEmpty) return;
      final room = await _roomRepository.getRoomById(roomId);
      final isHost =
          room.creatorUid != null &&
          room.players.any((p) => p.isMe && p.uid == room.creatorUid);
      final streamId = room.streamId;
      if (room.isStreaming &&
          isHost &&
          streamId != null &&
          streamId.isNotEmpty) {
        _heartbeatService.start(streamId);
      }
    } catch (e) {
      AppLogger.error('Failed to sync stream heartbeat from game', error: e);
    }
  }

  void _playSoundsForTransition(String? previousStatus, Game game) {
    if (previousStatus == null) return;

    final myTeam = game.localTeam;

    // playing -> trickEnd: trick won
    if (previousStatus == 'playing' && game.status == 'trickEnd') {
      final winnerTeam = game.currentTrick?.winnerSeat != null
          ? game.players
                .firstWhere(
                  (p) => p.seatIndex == game.currentTrick!.winnerSeat,
                  orElse: () => game.players.first,
                )
                .team
          : null;
      if (winnerTeam == myTeam) {
        _audioService.playTrickWinSound();
      }
    }

    // playing/trickEnd -> roundEnd: round ended
    if ((previousStatus == 'playing' || previousStatus == 'trickEnd') &&
        game.status == 'roundEnd') {
      _audioService.playRoundEndSound();
    }

    // Any -> gameEnd: game ended
    if (previousStatus != 'gameEnd' && game.status == 'gameEnd') {
      final winner = game.teamAScore >= game.teamBScore ? 'A' : 'B';
      if (winner == myTeam) {
        _audioService.playGameWinSound();
      } else {
        _audioService.playGameLoseSound();
      }
    }
  }

  bool _bidInProgress = false;
  bool _cardInProgress = false;

  void _emitActionInProgress() {
    final current = state;
    current.mapOrNull(
      dealing: (s) =>
          emit(s.copyWith(actionInProgress: true, lastActionError: null)),
      bidding: (s) =>
          emit(s.copyWith(actionInProgress: true, lastActionError: null)),
      bonusClaim: (s) =>
          emit(s.copyWith(actionInProgress: true, lastActionError: null)),
      playing: (s) =>
          emit(s.copyWith(actionInProgress: true, lastActionError: null)),
      trickEnd: (s) =>
          emit(s.copyWith(actionInProgress: true, lastActionError: null)),
      roundEnd: (s) =>
          emit(s.copyWith(actionInProgress: true, lastActionError: null)),
      gameEnd: (s) =>
          emit(s.copyWith(actionInProgress: true, lastActionError: null)),
    );
  }

  void _emitActionError(String? message) {
    final current = state;
    current.mapOrNull(
      dealing: (s) =>
          emit(s.copyWith(actionInProgress: false, lastActionError: message)),
      bidding: (s) =>
          emit(s.copyWith(actionInProgress: false, lastActionError: message)),
      bonusClaim: (s) =>
          emit(s.copyWith(actionInProgress: false, lastActionError: message)),
      playing: (s) =>
          emit(s.copyWith(actionInProgress: false, lastActionError: message)),
      trickEnd: (s) =>
          emit(s.copyWith(actionInProgress: false, lastActionError: message)),
      roundEnd: (s) =>
          emit(s.copyWith(actionInProgress: false, lastActionError: message)),
      gameEnd: (s) =>
          emit(s.copyWith(actionInProgress: false, lastActionError: message)),
    );
  }

  /// True when the server rejected an action because the game already moved
  /// past the phase it targets. The WebView runs on the RTDB fast path which
  /// can be ahead of the Firestore snapshot this Cubit last saw, so this is
  /// an expected race — not something to alarm the user or Crashlytics with.
  bool _isStalePhaseRejection(Object e) =>
      e is FirebaseFunctionsException && e.code == 'failed-precondition';

  /// Exposes action-error emission for subclasses (e.g. local simulator).
  void emitActionError(String message) => _emitActionError(message);

  /// Clears any transient action error shown to the user.
  void clearLastActionError() {
    final current = state;
    current.mapOrNull(
      dealing: (s) => emit(s.copyWith(lastActionError: null)),
      bidding: (s) => emit(s.copyWith(lastActionError: null)),
      bonusClaim: (s) => emit(s.copyWith(lastActionError: null)),
      playing: (s) => emit(s.copyWith(lastActionError: null)),
      trickEnd: (s) => emit(s.copyWith(lastActionError: null)),
      roundEnd: (s) => emit(s.copyWith(lastActionError: null)),
      gameEnd: (s) => emit(s.copyWith(lastActionError: null)),
    );
  }

  String? _getCurrentRoomId() {
    return state.mapOrNull(
      dealing: (s) => s.game.roomId,
      bidding: (s) => s.game.roomId,
      bonusClaim: (s) => s.game.roomId,
      playing: (s) => s.game.roomId,
      trickEnd: (s) => s.game.roomId,
      roundEnd: (s) => s.game.roomId,
      gameEnd: (s) => s.game.roomId,
    );
  }

  Future<void> placeBid(String bid) async {
    if (_bidInProgress) return;
    final current = state;
    // Use the current game entity rather than requiring GameBidding. The WebView
    // receives state via RTDB which can be ahead of the Firestore stream that
    // drives this Cubit, so a strict state check would silently drop valid taps.
    final game = _currentGame(current);
    if (game == null) return;
    _bidInProgress = true;
    _emitActionInProgress();
    try {
      await _gameRepository.placeBid(game.id, bid);
    } catch (e) {
      if (_isStalePhaseRejection(e)) {
        AppLogger.debug('Ignoring stale bid rejection: $e');
        _emitActionError(null);
      } else {
        AppLogger.error('Failed to place bid', error: e);
        _emitActionError('Failed to place bid. Please try again.');
      }
    } finally {
      _bidInProgress = false;
    }
  }

  Future<void> playCard(String card) async {
    if (_cardInProgress) return;
    final current = state;
    // Use the current game entity rather than requiring GamePlaying. The WebView
    // receives state via RTDB which can be ahead of the Firestore stream that
    // drives this Cubit, so a strict state check would silently drop valid taps.
    final game = _currentGame(current);
    if (game == null) return;
    _cardInProgress = true;
    _emitActionInProgress();
    try {
      await _gameRepository.playCard(game.id, card);
    } catch (e) {
      if (_isStalePhaseRejection(e)) {
        AppLogger.debug('Ignoring stale card-play rejection: $e');
        _emitActionError(null);
      } else {
        AppLogger.error('Failed to play card', error: e);
        _emitActionError('Failed to play card. Please try again.');
      }
    } finally {
      _cardInProgress = false;
    }
  }

  Future<void> claimBonuses(List<Map<String, dynamic>> bonuses) async {
    final current = state;
    if (current is! GameBonusClaim) return;
    _emitActionInProgress();
    try {
      await _gameRepository.claimBonuses(current.game.id, bonuses);
    } catch (e) {
      if (_isStalePhaseRejection(e)) {
        AppLogger.debug('Ignoring stale bonus-claim rejection: $e');
        _emitActionError(null);
      } else {
        AppLogger.error('Failed to claim bonuses', error: e);
        _emitActionError('Failed to claim bonuses. Please try again.');
      }
    }
  }

  Future<void> dealNextRound() async {
    final current = state;
    if (current is! GameRoundEnd) return;
    _emitActionInProgress();
    try {
      await _gameRepository.dealNextRound(current.game.id);
    } catch (e) {
      if (_isStalePhaseRejection(e)) {
        AppLogger.debug('Ignoring stale next-round rejection: $e');
        _emitActionError(null);
      } else {
        AppLogger.error('Failed to deal next round', error: e);
        _emitActionError('Failed to start next round. Please try again.');
      }
    }
  }

  Future<void> rematch() async {
    final roomId = _getCurrentRoomId();
    if (roomId == null || roomId.isEmpty) return;
    _emitActionInProgress();
    try {
      await _gameRepository.rematch(roomId);
    } catch (e) {
      if (_isStalePhaseRejection(e)) {
        AppLogger.debug('Ignoring stale rematch rejection: $e');
        _emitActionError(null);
      } else {
        AppLogger.error('Failed to rematch', error: e);
        _emitActionError('Failed to rematch. Please try again.');
      }
    }
  }

  Future<void> declareProject(List<String> types) async {
    final current = state;
    final game = _currentGame(current);
    if (game == null) return;
    _emitActionInProgress();
    try {
      await _gameRepository.declareProject(game.id, types);
    } catch (e) {
      if (_isStalePhaseRejection(e)) {
        AppLogger.debug('Ignoring stale project rejection: $e');
        _emitActionError(null);
      } else {
        AppLogger.error('Failed to declare project', error: e);
        _emitActionError('Failed to declare project. Please try again.');
      }
    }
  }

  Future<void> applyDouble(String action) async {
    final current = state;
    final game = _currentGame(current);
    if (game == null) return;
    _emitActionInProgress();
    try {
      await _gameRepository.applyDouble(game.id, action);
    } catch (e) {
      if (_isStalePhaseRejection(e)) {
        AppLogger.debug('Ignoring stale double rejection: $e');
        _emitActionError(null);
      } else {
        AppLogger.error('Failed to apply double', error: e);
        _emitActionError('Failed to apply double. Please try again.');
      }
    }
  }

  Future<void> claimQaid(String? claimType) async {
    final current = state;
    final game = _currentGame(current);
    if (game == null) return;
    _emitActionInProgress();
    try {
      await _gameRepository.claimQaid(game.id, claimType);
    } catch (e) {
      if (_isStalePhaseRejection(e)) {
        AppLogger.debug('Ignoring stale qaid rejection: $e');
        _emitActionError(null);
      } else {
        AppLogger.error('Failed to claim qaid', error: e);
        _emitActionError('Failed to claim qaid. Please try again.');
      }
    }
  }

  Future<void> claimSawa() async {
    final current = state;
    // Use the current game entity rather than requiring GamePlaying. The WebView
    // receives state via RTDB which can be ahead of the Firestore stream that
    // drives this Cubit, so a strict state check would silently drop valid claims.
    final game = _currentGame(current);
    if (game == null) return;
    _emitActionInProgress();
    try {
      await _gameRepository.claimSawa(game.id);
    } catch (e) {
      if (_isStalePhaseRejection(e)) {
        AppLogger.debug('Ignoring stale sawa rejection: $e');
        _emitActionError(null);
      } else {
        AppLogger.error('Failed to claim sawa', error: e);
        _emitActionError('Failed to claim sawa. Please try again.');
      }
    }
  }

  Game? _currentGame(GameState current) {
    return current.mapOrNull(
      dealing: (s) => s.game,
      bidding: (s) => s.game,
      bonusClaim: (s) => s.game,
      playing: (s) => s.game,
      trickEnd: (s) => s.game,
      roundEnd: (s) => s.game,
      gameEnd: (s) => s.game,
    );
  }

  /// Returns `true` when the leave succeeded on the backend.
  Future<bool> leaveGame() async {
    final roomId = _getCurrentRoomId();
    if (roomId == null || roomId.isEmpty) return false;
    _emitActionInProgress();
    try {
      await _gameSubscription?.cancel();
      _gameSubscription = null;
      await _roomRepository.leaveRoom(roomId);
      _heartbeatService.stop();
      if (_pendingAgoraJoin != null) {
        try {
          await _pendingAgoraJoin!.timeout(const Duration(seconds: 3));
        } catch (_) {
          // Ignore join errors/timeouts during leave.
        }
        _pendingAgoraJoin = null;
      }
      await _agoraService.leaveChannel();
      _joinedAgoraChannelName = null;
      emit(const GameState.initial());
      return true;
    } catch (e) {
      AppLogger.error('Failed to leave game', error: e);
      _emitActionError('Failed to leave game. Please try again.');
      return false;
    }
  }

  Future<void> toggleMic() async {
    final roomId = _getCurrentRoomId();
    if (roomId == null || roomId.isEmpty) return;

    try {
      final isMicOn = await _agoraService.toggleMic();
      await _roomRepository.updatePlayerMediaState(
        roomId,
        isMicOn: isMicOn,
        isCameraOn: _agoraService.isCameraOn,
      );
    } catch (e) {
      AppLogger.error('Failed to toggle mic', error: e);
      _emitActionError('Failed to toggle microphone.');
    }
  }

  Future<void> toggleCamera() async {
    final roomId = _getCurrentRoomId();
    if (roomId == null || roomId.isEmpty) return;

    try {
      final isCameraOn = await _agoraService.toggleCamera();
      await _roomRepository.updatePlayerMediaState(
        roomId,
        isMicOn: _agoraService.isMicOn,
        isCameraOn: isCameraOn,
      );
    } catch (e) {
      AppLogger.error('Failed to toggle camera', error: e);
      _emitActionError('Failed to toggle camera.');
    }
  }

  void toggleControls() {
    final current = state;
    current.mapOrNull(
      dealing: (s) => emit(s.copyWith(controlsVisible: !s.controlsVisible)),
      bidding: (s) => emit(s.copyWith(controlsVisible: !s.controlsVisible)),
      bonusClaim: (s) => emit(s.copyWith(controlsVisible: !s.controlsVisible)),
      playing: (s) => emit(s.copyWith(controlsVisible: !s.controlsVisible)),
      trickEnd: (s) => emit(s.copyWith(controlsVisible: !s.controlsVisible)),
      roundEnd: (s) => emit(s.copyWith(controlsVisible: !s.controlsVisible)),
      gameEnd: (s) => emit(s.copyWith(controlsVisible: !s.controlsVisible)),
    );
  }

  void hideControls() {
    final current = state;
    current.mapOrNull(
      dealing: (s) => emit(s.copyWith(controlsVisible: false)),
      bidding: (s) => emit(s.copyWith(controlsVisible: false)),
      bonusClaim: (s) => emit(s.copyWith(controlsVisible: false)),
      playing: (s) => emit(s.copyWith(controlsVisible: false)),
      trickEnd: (s) => emit(s.copyWith(controlsVisible: false)),
      roundEnd: (s) => emit(s.copyWith(controlsVisible: false)),
      gameEnd: (s) => emit(s.copyWith(controlsVisible: false)),
    );
  }

  void selectCard(int? index) {
    final current = state;
    current.mapOrNull(
      dealing: (s) => emit(s.copyWith(selectedCardIndex: index)),
      bidding: (s) => emit(s.copyWith(selectedCardIndex: index)),
      bonusClaim: (s) => emit(s.copyWith(selectedCardIndex: index)),
      playing: (s) => emit(s.copyWith(selectedCardIndex: index)),
      trickEnd: (s) => emit(s.copyWith(selectedCardIndex: index)),
      roundEnd: (s) => emit(s.copyWith(selectedCardIndex: index)),
      gameEnd: (s) => emit(s.copyWith(selectedCardIndex: index)),
    );
  }

  void _joinAgoraIfNeeded(Game game) {
    final channelName = game.agoraChannelName;
    if (channelName == null || channelName.isEmpty) return;
    // Rooms created without voice/camera (and bot matches) have no media at
    // all, so there is no channel worth joining.
    if (!game.voiceEnabled && !game.cameraEnabled) return;
    if (_joinedAgoraChannelName == channelName) return;
    if (_pendingAgoraJoin != null) return;

    // Use the Agora UID assigned to the local player by the backend when
    // available; otherwise the service will derive a fallback UID.
    final localPlayer = game.players.firstWhere(
      (p) => p.seatIndex == game.mySeatIndex,
      orElse: () => game.players.first,
    );

    // Spectators join as audience (audio only). If already in the channel
    // (e.g. from WatchStreamPage), AgoraService returns early — no conflict.
    // Players join as broadcaster with subscribeVideo disabled (audio only
    // in the game screen to save GPU/CPU).
    //
    // IMPORTANT: spectators must NOT reuse a player's agoraUid — for a
    // spectator `mySeatIndex` resolves to the first player (the host), and
    // joining with the host's UID kicks the host out of the channel,
    // killing their audio/video for everyone. Passing null makes the
    // service derive a UID from the spectator's own Firebase UID instead.
    final pendingJoin = _isSpectator
        // (no agoraUid passed — the service derives one from the spectator's
        // own Firebase UID)
        ? _agoraService.joinAsAudience(
            channelName: channelName,
          )
        : _agoraService.joinChannel(
            channelName: channelName,
            agoraUid: localPlayer.agoraUid,
            subscribeVideo: false,
          );
    _pendingAgoraJoin = pendingJoin;
    pendingJoin
        .then((_) async {
          if (_isClosed) return;
          _joinedAgoraChannelName = channelName;
          // Re-apply the player's mute state after a fresh join (the SDK
          // resets mute/publish state on join).
          if (!_isSpectator) {
            try {
              await _agoraService.setMediaState(
                micOn: !localPlayer.isMuted,
                cameraOn: false,
              );
            } catch (e) {
              AppLogger.error('Failed to sync media state', error: e);
            }
          }
        })
        .catchError((Object e) {
          AppLogger.error('Failed to join Agora from game', error: e);
        })
        .whenComplete(() {
          _pendingAgoraJoin = null;
        });
  }

  @override
  Future<void> close() async {
    if (_isClosed) return super.close();
    _isClosed = true;

    _trickAdvanceTimer?.cancel();
    _turnTimeoutTimer?.cancel();
    await _gameSubscription?.cancel();
    humanTurnSecondsLeft.dispose();

    // Wait for an in-flight Agora join to finish before leaving.
    if (_pendingAgoraJoin != null) {
      try {
        await _pendingAgoraJoin!.timeout(const Duration(seconds: 3));
      } catch (_) {
        // Ignore join errors/timeouts during close.
      }
      _pendingAgoraJoin = null;
    }

    // Spectators never leave the Agora channel on close — the WatchStreamPage
    // owns the channel lifecycle. Leaving here would break audio/video when the
    // spectator navigates back from the game page to the stream page.
    if (!_isSpectator &&
        (_joinedAgoraChannelName != null || _pendingAgoraJoin != null)) {
      await _agoraService.leaveChannel();
      _joinedAgoraChannelName = null;
      _pendingAgoraJoin = null;
    }

    // NOTE: We intentionally do NOT call _roomRepository.leaveRoom() here.
    // Navigating away from the game page should not remove the player from the
    // room; leaving the room must be an explicit user action.

    return super.close();
  }
}
