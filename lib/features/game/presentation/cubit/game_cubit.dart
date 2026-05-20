import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:bloot/core/logger/app_logger.dart';
import 'package:bloot/features/game/domain/repositories/game_repository.dart';
import 'package:bloot/features/game/presentation/cubit/game_state.dart';

@injectable
class GameCubit extends Cubit<GameState> {
  GameCubit({required GameRepository gameRepository})
    : _gameRepository = gameRepository,
      super(const GameState.initial());

  final GameRepository _gameRepository;

  Future<void> loadGame(String id) async {
    emit(const GameState.loading());
    try {
      final game = await _gameRepository.getGameById(id);
      emit(GameState.loaded(game: game));
    } catch (e) {
      AppLogger.error('Failed to load game', error: e);
      emit(const GameState.error(message: 'Failed to load game.'));
    }
  }

  void toggleControls() {
    final currentState = state;
    if (currentState is! GameLoaded) return;
    emit(currentState.copyWith(controlsVisible: !currentState.controlsVisible));
  }

  void hideControls() {
    final currentState = state;
    if (currentState is! GameLoaded) return;
    emit(currentState.copyWith(controlsVisible: false));
  }

  void selectCard(int? index) {
    final currentState = state;
    if (currentState is! GameLoaded) return;
    emit(currentState.copyWith(selectedCardIndex: index));
  }
}
