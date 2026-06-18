import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:bloot/core/logger/app_logger.dart';
import 'package:bloot/features/profile/domain/entities/user_profile.dart';
import 'package:bloot/features/profile/domain/repositories/profile_repository.dart';
import 'package:bloot/features/tournament/domain/entities/tournament.dart';
import 'package:bloot/features/tournament/domain/repositories/tournament_repository.dart';
import 'package:bloot/features/tournament/presentation/cubit/tournament_state.dart';

@injectable
class TournamentCubit extends Cubit<TournamentState> {
  TournamentCubit({
    required TournamentRepository tournamentRepository,
    required ProfileRepository profileRepository,
  })  : _tournamentRepository = tournamentRepository,
        _profileRepository = profileRepository,
        super(const TournamentState.initial());

  final TournamentRepository _tournamentRepository;
  final ProfileRepository _profileRepository;

  StreamSubscription<Tournament>? _tournamentSubscription;
  List<UserProfile> _participantProfiles = [];
  UserProfile? _currentUserProfile;

  /// Participant profiles for the currently loaded tournament.
  List<UserProfile> get participantProfiles => _participantProfiles;

  /// Current user profile (used for coin balance, etc.).
  UserProfile? get currentUserProfile => _currentUserProfile;

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

  void watchTournament(String id) {
    emit(const TournamentState.detailLoading());
    _participantProfiles = [];
    _tournamentSubscription?.cancel();

    _tournamentSubscription = _tournamentRepository.watchTournament(id).listen(
      (tournament) async {
        await Future.wait([
          _loadParticipantProfiles(tournament.participantIds),
          _loadCurrentUserProfile(),
        ]);

        emit(TournamentState.detailLoaded(tournament: tournament));

        // Check if current user has a ready match
        _checkForActiveMatch(tournament);
      },
      onError: (Object error) {
        AppLogger.error('Failed to watch tournament $id', error: error);
        emit(const TournamentState.detailError(message: 'Failed to load tournament.'));
      },
    );
  }

  /// One-time fetch fallback (used by pages that don't need real-time).
  Future<void> loadTournament(String id) async {
    emit(const TournamentState.detailLoading());
    _participantProfiles = [];
    try {
      final tournament = await _tournamentRepository.getTournamentById(id);
      if (tournament == null) {
        emit(const TournamentState.detailError(message: 'Tournament not found.'));
        return;
      }

      await Future.wait([
        _loadParticipantProfiles(tournament.participantIds),
        _loadCurrentUserProfile(),
      ]);

      emit(TournamentState.detailLoaded(tournament: tournament));
    } catch (e) {
      AppLogger.error('Failed to load tournament $id', error: e);
      emit(const TournamentState.detailError(message: 'Failed to load tournament.'));
    }
  }

  void _checkForActiveMatch(Tournament tournament) {
    final uid = _currentUserProfile?.uid;
    if (uid == null) return;

    for (final match in tournament.bracket) {
      if (match.status == 'live' && match.roomId != null && match.roomId!.isNotEmpty) {
        final isParticipant = match.playerAUid == uid ||
            match.playerBUid == uid ||
            match.teamAPlayerIds.contains(uid) ||
            match.teamBPlayerIds.contains(uid);
        if (isParticipant) {
          emit(TournamentState.matchReady(
            tournamentId: tournament.id,
            roomId: match.roomId!,
            matchId: match.matchId,
          ));
          return;
        }
      }
    }
  }

  Future<void> _loadParticipantProfiles(List<String> participantIds) async {
    if (participantIds.isEmpty) {
      _participantProfiles = [];
      return;
    }
    try {
      _participantProfiles =
          await _profileRepository.getUserProfiles(participantIds);
    } catch (e) {
      AppLogger.error('Failed to load participant profiles', error: e);
      _participantProfiles = [];
    }
  }

  Future<void> _loadCurrentUserProfile() async {
    try {
      _currentUserProfile =
          await _profileRepository.getCurrentUserProfile();
    } catch (e) {
      AppLogger.error('Failed to load current user profile', error: e);
      _currentUserProfile = null;
    }
  }

  void selectFilter(int index) {
    final currentState = state;
    if (currentState is! TournamentLoaded) return;
    emit(currentState.copyWith(selectedFilterIndex: index));
  }

  Future<void> joinTournament(String tournamentId) async {
    emit(const TournamentState.joining());
    try {
      final tournament = await _tournamentRepository.joinTournament(tournamentId);

      // Reload participant profiles after joining
      await _loadParticipantProfiles(tournament.participantIds);

      emit(TournamentState.detailLoaded(tournament: tournament));
      emit(TournamentState.joined(tournamentId: tournamentId));
    } catch (e) {
      AppLogger.error('Failed to join tournament $tournamentId', error: e);
      emit(TournamentState.joinError(message: e.toString()));
    }
  }

  @override
  Future<void> close() async {
    _tournamentSubscription?.cancel();
    return super.close();
  }
}
