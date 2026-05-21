import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:bloot/features/tournament/domain/entities/tournament.dart';

part 'tournament_state.freezed.dart';

@freezed
class TournamentState with _$TournamentState {
  const factory TournamentState.initial() = TournamentInitial;
  const factory TournamentState.loading() = TournamentLoading;
  const factory TournamentState.loaded({
    required List<Tournament> tournaments,
    @Default(0) int selectedFilterIndex,
  }) = TournamentLoaded;
  const factory TournamentState.error({required String message}) =
      TournamentError;
  const factory TournamentState.joining() = TournamentJoining;
  const factory TournamentState.joined({required String tournamentId}) =
      TournamentJoined;
  const factory TournamentState.joinError({required String message}) =
      TournamentJoinError;
}
