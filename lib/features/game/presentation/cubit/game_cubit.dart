import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:bloot/core/logger/app_logger.dart';
import 'package:bloot/core/services/agora_service.dart';
import 'package:bloot/core/services/audio_service.dart';
import 'package:bloot/features/game/domain/entities/game.dart';
import 'package:bloot/features/game/domain/repositories/game_repository.dart';
import 'package:bloot/features/game/presentation/cubit/game_state.dart';
import 'package:bloot/features/room/domain/entities/room.dart';
import 'package:bloot/features/room/domain/repositories/room_repository.dart';

@injectable
class GameCubit extends Cubit<GameState> {
  GameCubit({
    required GameRepository gameRepository,
    required RoomRepository roomRepository,
    required AgoraService agoraService,
    required AudioService audioService,
  }) : _gameRepository = gameRepository,
       _roomRepository = roomRepository,
       _agoraService = agoraService,
       _audioService = audioService,
       super(const GameState.initial());

  final GameRepository _gameRepository;
  final RoomRepository _roomRepository;
  final AgoraService _agoraService;
  final AudioService _audioService;
  StreamSubscription<Game>? _gameSubscription;
  StreamSubscription<List<RoomChatMessage>>? _chatSubscription;
  List<RoomChatMessage> _chatMessages = [];
  bool _chatOpen = false;
  String? _lastRoomId;
  String? _joinedAgoraChannelName;

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
      _startWatching(id, _gameRepository.watchGame(id));

  /// Starts watching the game as a spectator.
  void watchGameAsSpectator(String id) =>
      _startWatching(id, _gameRepository.watchGameAsSpectator(id));

  void _startWatching(String id, Stream<Game> stream) {
    emit(const GameState.loading());
    _gameSubscription?.cancel();
    _chatSubscription?.cancel();
    _chatMessages = [];
    _chatOpen = false;
    _lastRoomId = null;
    _joinedAgoraChannelName = null;

    _gameSubscription = stream.listen(
      (game) => _emitStateForGame(game),
      onError: (Object error) {
        AppLogger.error('Game stream error', error: error);
        emit(const GameState.error(message: 'Failed to load game.'));
      },
    );
  }

  String? _previousStatus;

  void _emitStateForGame(Game game) {
    final current = state;
    final previousStatus = _previousStatus;
    _previousStatus = game.status;

    _joinAgoraIfNeeded(game);
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

    // Start/replace room chat subscription when roomId is available or changes.
    final roomId = game.roomId;
    if (roomId != null && roomId.isNotEmpty && roomId != _lastRoomId) {
      _lastRoomId = roomId;
      _chatSubscription?.cancel();
      _chatSubscription = _roomRepository
          .watchChatMessages(roomId)
          .listen(
            (messages) {
              _chatMessages = messages;
              _reemitWithChat();
            },
            onError: (Object error) {
              AppLogger.error('Chat stream error', error: error);
            },
          );
    }

    switch (game.status) {
      case 'dealing':
        emit(
          GameState.dealing(
            game: game,
            controlsVisible: controlsVisible,
            selectedCardIndex: selectedIndex,
            chatOpen: _chatOpen,
            chatMessages: _chatMessages,
          ),
        );
      case 'bidding':
        emit(
          GameState.bidding(
            game: game,
            controlsVisible: controlsVisible,
            selectedCardIndex: selectedIndex,
            chatOpen: _chatOpen,
            chatMessages: _chatMessages,
          ),
        );
      case 'bonusClaim':
        emit(
          GameState.bonusClaim(
            game: game,
            controlsVisible: controlsVisible,
            selectedCardIndex: selectedIndex,
            chatOpen: _chatOpen,
            chatMessages: _chatMessages,
          ),
        );
      case 'playing':
        emit(
          GameState.playing(
            game: game,
            controlsVisible: controlsVisible,
            selectedCardIndex: selectedIndex,
            chatOpen: _chatOpen,
            chatMessages: _chatMessages,
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
            chatOpen: _chatOpen,
            chatMessages: _chatMessages,
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
            chatOpen: _chatOpen,
            chatMessages: _chatMessages,
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
            chatOpen: _chatOpen,
            chatMessages: _chatMessages,
          ),
        );
      default:
        emit(
          GameState.playing(
            game: game,
            controlsVisible: controlsVisible,
            selectedCardIndex: selectedIndex,
            chatOpen: _chatOpen,
            chatMessages: _chatMessages,
          ),
        );
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

    // playing -> roundEnd: round ended
    if (previousStatus == 'playing' && game.status == 'roundEnd') {
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

  void _reemitWithChat() {
    final current = state;
    current.mapOrNull(
      dealing: (s) => emit(s.copyWith(chatMessages: _chatMessages)),
      bidding: (s) => emit(s.copyWith(chatMessages: _chatMessages)),
      bonusClaim: (s) => emit(s.copyWith(chatMessages: _chatMessages)),
      playing: (s) => emit(s.copyWith(chatMessages: _chatMessages)),
      trickEnd: (s) => emit(s.copyWith(chatMessages: _chatMessages)),
      roundEnd: (s) => emit(s.copyWith(chatMessages: _chatMessages)),
      gameEnd: (s) => emit(s.copyWith(chatMessages: _chatMessages)),
    );
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

  void _emitActionError(String message) {
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
    if (current is! GameBidding) return;
    _bidInProgress = true;
    _emitActionInProgress();
    try {
      await _gameRepository.placeBid(current.game.id, bid);
    } catch (e) {
      AppLogger.error('Failed to place bid', error: e);
      _emitActionError('Failed to place bid. Please try again.');
    } finally {
      _bidInProgress = false;
    }
  }

  Future<void> playCard(String card) async {
    if (_cardInProgress) return;
    final current = state;
    if (current is! GamePlaying) return;
    _cardInProgress = true;
    _emitActionInProgress();
    try {
      await _gameRepository.playCard(current.game.id, card);
    } catch (e) {
      AppLogger.error('Failed to play card', error: e);
      _emitActionError('Failed to play card. Please try again.');
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
      AppLogger.error('Failed to claim bonuses', error: e);
      _emitActionError('Failed to claim bonuses. Please try again.');
    }
  }

  Future<void> dealNextRound() async {
    final current = state;
    if (current is! GameRoundEnd) return;
    _emitActionInProgress();
    try {
      await _gameRepository.dealNextRound(current.game.id);
    } catch (e) {
      AppLogger.error('Failed to deal next round', error: e);
      _emitActionError('Failed to start next round. Please try again.');
    }
  }

  Future<void> rematch() async {
    final roomId = _getCurrentRoomId();
    if (roomId == null || roomId.isEmpty) return;
    _emitActionInProgress();
    try {
      await _gameRepository.rematch(roomId);
    } catch (e) {
      AppLogger.error('Failed to rematch', error: e);
      _emitActionError('Failed to rematch. Please try again.');
    }
  }

  Future<void> leaveGame() async {
    final roomId = _getCurrentRoomId();
    if (roomId == null || roomId.isEmpty) return;
    _emitActionInProgress();
    try {
      await _roomRepository.leaveRoom(roomId);
      await _agoraService.leaveChannel();
      _lastRoomId = null;
      _joinedAgoraChannelName = null;
      emit(const GameState.initial());
    } catch (e) {
      AppLogger.error('Failed to leave game', error: e);
      _emitActionError('Failed to leave game. Please try again.');
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

  void toggleChat() {
    _chatOpen = !_chatOpen;
    _reemitWithChat();
  }

  Future<void> sendChatMessage(String message) async {
    final roomId = _getCurrentRoomId();
    if (roomId == null || roomId.isEmpty) return;
    if (message.trim().isEmpty) return;

    try {
      await _roomRepository.sendChatMessage(roomId, message.trim());
    } catch (e) {
      AppLogger.error('Failed to send chat message', error: e);
      _emitActionError('Failed to send message. Please try again.');
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
    if (_joinedAgoraChannelName == channelName) return;

    _joinedAgoraChannelName = channelName;
    _agoraService.joinChannel(channelName: channelName).catchError((Object e) {
      AppLogger.error('Failed to join Agora from game', error: e);
      _joinedAgoraChannelName = null;
    });
  }

  @override
  Future<void> close() async {
    await _gameSubscription?.cancel();
    await _chatSubscription?.cancel();
    humanTurnSecondsLeft.dispose();

    // Leave the Agora channel if this cubit joined it.
    if (_joinedAgoraChannelName != null) {
      await _agoraService.leaveChannel();
      _joinedAgoraChannelName = null;
    }

    // NOTE: We intentionally do NOT call _roomRepository.leaveRoom() here.
    // Navigating away from the game page should not remove the player from the
    // room; leaving the room must be an explicit user action.

    return super.close();
  }
}
