import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:bloot/core/logger/app_logger.dart';
import 'package:bloot/features/profile/domain/repositories/profile_repository.dart';
import 'package:bloot/features/profile/presentation/cubit/profile_state.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({required ProfileRepository profileRepository})
    : _profileRepository = profileRepository,
      super(const ProfileState.initial());

  final ProfileRepository _profileRepository;
  StreamSubscription<dynamic>? _profileSubscription;

  /// Loads a user profile.
  ///
  /// If [userId] is `'me'`, watches the current authenticated user's profile
  /// in real-time. Otherwise fetches the specified user's profile once.
  void loadProfile(String userId) {
    emit(const ProfileState.loading());
    _cancelSubscription();

    if (userId == 'me') {
      _profileSubscription = _profileRepository
          .watchCurrentUserProfile()
          .listen(
            (profile) async {
              if (profile != null) {
                final gameHistory =
                    await _profileRepository.getGameHistory(profile.uid);
                final achievements =
                    await _profileRepository.getAchievements(profile.uid);
                emit(
                  ProfileState.loaded(
                    profile: profile,
                    gameHistory: gameHistory,
                    achievements: achievements,
                  ),
                );
              } else {
                emit(
                  const ProfileState.error(
                    message: 'Profile not found. Please complete your profile.',
                  ),
                );
              }
            },
            onError: (Object error) {
              AppLogger.error('Profile stream error', error: error);
              emit(
                ProfileState.error(
                  message: 'Failed to load profile: $error',
                ),
              );
            },
          );
    } else {
      _loadOtherUserProfile(userId);
    }
  }

  Future<void> _loadOtherUserProfile(String userId) async {
    try {
      final profile = await _profileRepository.getUserProfile(userId);
      if (profile != null) {
        final gameHistory =
            await _profileRepository.getGameHistory(userId);
        final achievements =
            await _profileRepository.getAchievements(userId);
        emit(
          ProfileState.loaded(
            profile: profile,
            gameHistory: gameHistory,
            achievements: achievements,
          ),
        );
      } else {
        emit(const ProfileState.error(message: 'User not found.'));
      }
    } catch (e) {
      AppLogger.error('Failed to load user profile', error: e);
      emit(const ProfileState.error(message: 'Failed to load profile.'));
    }
  }

  void _cancelSubscription() {
    _profileSubscription?.cancel();
    _profileSubscription = null;
  }

  @override
  Future<void> close() {
    _cancelSubscription();
    return super.close();
  }
}
