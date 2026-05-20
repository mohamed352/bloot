import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:bloot/core/logger/app_logger.dart';
import 'package:bloot/features/tournament/domain/repositories/tournament_repository.dart';
import 'package:bloot/features/tournament/presentation/cubit/tournament_state.dart';

@injectable
class TournamentCubit extends Cubit<TournamentState> {
  TournamentCubit({required TournamentRepository tournamentRepository})
    : _tournamentRepository = tournamentRepository,
      super(const TournamentState.initial());

  final TournamentRepository _tournamentRepository;

  Future<void> loadTournaments() async {
    emit(const TournamentState.loading());
    try {
      final tournaments = await _tournamentRepository.getTournaments();
      emit(TournamentState.loaded(tournaments: tournaments));
    } catch (e) {
      AppLogger.error('Failed to load tournaments', error: e);
      emit(const TournamentState.error(message: 'Failed to load tournaments.'));
    }
  }

  void selectFilter(int index) {
    final currentState = state;
    if (currentState is! TournamentLoaded) return;
    emit(currentState.copyWith(selectedFilterIndex: index));
  }
}
