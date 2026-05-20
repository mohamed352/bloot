import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:bloot/features/game/domain/entities/game.dart';

part 'game_state.freezed.dart';

@freezed
class GameState with _$GameState {
  const factory GameState.initial() = GameInitial;
  const factory GameState.loading() = GameLoading;
  const factory GameState.loaded({
    required Game game,
    @Default(true) bool controlsVisible,
    int? selectedCardIndex,
  }) = GameLoaded;
  const factory GameState.error({required String message}) = GameError;
}
