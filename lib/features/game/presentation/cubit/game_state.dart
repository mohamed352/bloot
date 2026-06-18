import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:bloot/features/game/domain/entities/game.dart';
import 'package:bloot/features/room/domain/entities/room.dart';

part 'game_state.freezed.dart';

@freezed
class GameState with _$GameState {
  const factory GameState.initial() = GameInitial;
  const factory GameState.loading() = GameLoading;

  /// Active game states — one per phase.
  const factory GameState.dealing({
    required Game game,
    @Default(true) bool controlsVisible,
    int? selectedCardIndex,
    @Default(false) bool chatOpen,
    @Default(<RoomChatMessage>[]) List<RoomChatMessage> chatMessages,
    @Default(false) bool actionInProgress,
    String? lastActionError,
  }) = GameDealing;

  const factory GameState.bidding({
    required Game game,
    @Default(true) bool controlsVisible,
    int? selectedCardIndex,
    @Default(false) bool chatOpen,
    @Default(<RoomChatMessage>[]) List<RoomChatMessage> chatMessages,
    @Default(false) bool actionInProgress,
    String? lastActionError,
  }) = GameBidding;

  const factory GameState.bonusClaim({
    required Game game,
    @Default(true) bool controlsVisible,
    int? selectedCardIndex,
    @Default(false) bool chatOpen,
    @Default(<RoomChatMessage>[]) List<RoomChatMessage> chatMessages,
    @Default(false) bool actionInProgress,
    String? lastActionError,
  }) = GameBonusClaim;

  const factory GameState.playing({
    required Game game,
    @Default(true) bool controlsVisible,
    int? selectedCardIndex,
    @Default(false) bool chatOpen,
    @Default(<RoomChatMessage>[]) List<RoomChatMessage> chatMessages,
    @Default(false) bool actionInProgress,
    String? lastActionError,
  }) = GamePlaying;

  const factory GameState.trickEnd({
    required Game game,
    required int winnerSeat,
    @Default(true) bool controlsVisible,
    int? selectedCardIndex,
    @Default(false) bool chatOpen,
    @Default(<RoomChatMessage>[]) List<RoomChatMessage> chatMessages,
    @Default(false) bool actionInProgress,
    String? lastActionError,
  }) = GameTrickEnd;

  const factory GameState.roundEnd({
    required Game game,
    required int teamAPoints,
    required int teamBPoints,
    String? fellTeam,
    @Default(true) bool controlsVisible,
    int? selectedCardIndex,
    @Default(false) bool chatOpen,
    @Default(<RoomChatMessage>[]) List<RoomChatMessage> chatMessages,
    @Default(false) bool actionInProgress,
    String? lastActionError,
  }) = GameRoundEnd;

  const factory GameState.gameEnd({
    required Game game,
    required String winnerTeam,
    @Default(true) bool controlsVisible,
    int? selectedCardIndex,
    @Default(false) bool chatOpen,
    @Default(<RoomChatMessage>[]) List<RoomChatMessage> chatMessages,
    @Default(false) bool actionInProgress,
    String? lastActionError,
  }) = GameGameEnd;

  const factory GameState.error({required String message}) = GameError;
}
