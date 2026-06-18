import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:bloot/core/logger/app_logger.dart';
import 'package:bloot/core/services/remote_config_service.dart';
import 'package:bloot/features/home/domain/entities/home_stream.dart';
import 'package:bloot/features/home/domain/repositories/home_repository.dart';
import 'package:bloot/features/home/presentation/cubit/home_state.dart';
import 'package:bloot/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:bloot/features/profile/domain/entities/user_profile.dart';
import 'package:bloot/features/profile/domain/repositories/profile_repository.dart';
import 'package:bloot/features/tournament/domain/entities/tournament.dart';
import 'package:bloot/features/tournament/domain/repositories/tournament_repository.dart';

@injectable
class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required HomeRepository homeRepository,
    required ProfileRepository profileRepository,
    required TournamentRepository tournamentRepository,
    required NotificationsRepository notificationsRepository,
    required RemoteConfigService remoteConfigService,
  }) : _homeRepository = homeRepository,
       _profileRepository = profileRepository,
       _tournamentRepository = tournamentRepository,
       _notificationsRepository = notificationsRepository,
       _remoteConfigService = remoteConfigService,
       super(const HomeState.initial());

  final HomeRepository _homeRepository;
  final ProfileRepository _profileRepository;
  final TournamentRepository _tournamentRepository;
  final NotificationsRepository _notificationsRepository;
  final RemoteConfigService _remoteConfigService;
  StreamSubscription<List<HomeStream>>? _streamsSubscription;
  StreamSubscription<UserProfile?>? _profileSubscription;

  UserProfile? _currentProfile;
  List<HomeStream> _currentStreams = [];
  List<Tournament> _currentTournaments = [];
  int _unreadNotificationsCount = 0;

  void loadHomeData() {
    emit(const HomeState.loading());
    _cancelSubscriptions();

    _loadTournaments().then((_) => _emitCombinedState());
    _loadUnreadNotifications().then((_) => _emitCombinedState());

    _profileSubscription = _profileRepository.watchCurrentUserProfile().listen(
      (profile) {
        _currentProfile = profile;
        _emitCombinedState();
      },
      onError: (Object error) {
        AppLogger.error('Home profile stream error', error: error);
      },
    );

    _streamsSubscription = _homeRepository.watchLiveStreams().listen(
      (streams) {
        _currentStreams = streams;
        _emitCombinedState();
      },
      onError: (Object error) {
        AppLogger.error('Home streams stream error', error: error);
        emit(HomeState.error(message: error.toString()));
      },
    );
  }

  Future<void> refresh() async {
    try {
      final streams = await _homeRepository.getLiveStreams();
      _currentStreams = streams;
      await _loadTournaments();
      await _loadUnreadNotifications();
      _emitCombinedState();
    } catch (e) {
      AppLogger.error('Failed to refresh home data', error: e);
      emit(HomeState.error(message: e.toString()));
    }
  }

  Future<void> _loadTournaments() async {
    if (!_remoteConfigService.enableTournaments) {
      _currentTournaments = [];
      return;
    }

    try {
      final tournaments = await _tournamentRepository.getTournaments();
      _currentTournaments = tournaments
          .where((t) => t.status.toLowerCase() == 'upcoming')
          .take(3)
          .toList();
    } catch (e) {
      AppLogger.error('Failed to load tournaments for home', error: e);
      _currentTournaments = [];
    }
  }

  Future<void> _loadUnreadNotifications() async {
    try {
      final notifications =
          await _notificationsRepository.getUnreadNotifications();
      _unreadNotificationsCount = notifications.length;
    } catch (e) {
      AppLogger.error('Failed to load unread notifications', error: e);
      _unreadNotificationsCount = 0;
    }
  }

  void _emitCombinedState() {
    if (_currentStreams.isEmpty) {
      emit(
        HomeState.empty(
          profile: _currentProfile,
          tournaments: _currentTournaments,
          unreadNotificationsCount: _unreadNotificationsCount,
        ),
      );
    } else {
      emit(
        HomeState.loaded(
          profile: _currentProfile,
          streams: _currentStreams,
          tournaments: _currentTournaments,
          unreadNotificationsCount: _unreadNotificationsCount,
        ),
      );
    }
  }

  void _cancelSubscriptions() {
    _streamsSubscription?.cancel();
    _streamsSubscription = null;
    _profileSubscription?.cancel();
    _profileSubscription = null;
  }

  @override
  Future<void> close() {
    _cancelSubscriptions();
    return super.close();
  }
}
