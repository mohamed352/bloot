import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:bloot/core/logger/app_logger.dart';
import 'package:bloot/features/home/domain/entities/home_stream.dart';
import 'package:bloot/features/home/domain/repositories/home_repository.dart';
import 'package:bloot/features/home/presentation/cubit/home_state.dart';
import 'package:bloot/features/notifications/domain/entities/notification_item.dart';
import 'package:bloot/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:bloot/features/profile/domain/entities/user_profile.dart';
import 'package:bloot/features/profile/domain/repositories/profile_repository.dart';

@injectable
class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required HomeRepository homeRepository,
    required ProfileRepository profileRepository,
    required NotificationsRepository notificationsRepository,
  }) : _homeRepository = homeRepository,
       _profileRepository = profileRepository,
       _notificationsRepository = notificationsRepository,
       super(const HomeState.initial());

  final HomeRepository _homeRepository;
  final ProfileRepository _profileRepository;
  final NotificationsRepository _notificationsRepository;
  StreamSubscription<List<HomeStream>>? _streamsSubscription;
  StreamSubscription<UserProfile?>? _profileSubscription;
  StreamSubscription<List<NotificationItem>>? _unreadSubscription;

  UserProfile? _currentProfile;
  List<HomeStream> _currentStreams = [];
  int _unreadNotificationsCount = 0;

  void loadHomeData() {
    emit(const HomeState.loading());
    _cancelSubscriptions();

    _unreadSubscription = _notificationsRepository
        .watchUnreadNotifications()
        .listen(
          (notifications) {
            _unreadNotificationsCount = notifications.length;
            _emitCombinedState();
          },
          onError: (Object error) {
            AppLogger.error(
              'Failed to watch unread notifications',
              error: error,
            );
          },
        );

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
      await _loadUnreadNotifications();
      _emitCombinedState();
    } catch (e) {
      AppLogger.error('Failed to refresh home data', error: e);
      emit(HomeState.error(message: e.toString()));
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
          unreadNotificationsCount: _unreadNotificationsCount,
        ),
      );
    } else {
      emit(
        HomeState.loaded(
          profile: _currentProfile,
          streams: _currentStreams,
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
    _unreadSubscription?.cancel();
    _unreadSubscription = null;
  }

  @override
  Future<void> close() {
    _cancelSubscriptions();
    return super.close();
  }
}
