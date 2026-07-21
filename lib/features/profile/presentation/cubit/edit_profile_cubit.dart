import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

import 'package:bloot/core/logger/app_logger.dart';
import 'package:bloot/features/profile/domain/entities/user_profile.dart';
import 'package:bloot/features/profile/domain/repositories/profile_repository.dart';
import 'package:bloot/features/profile/presentation/cubit/edit_profile_state.dart';

@injectable
class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit({required ProfileRepository profileRepository})
    : _profileRepository = profileRepository,
      super(const EditProfileState.initial());

  final ProfileRepository _profileRepository;

  UserProfile? _currentProfile;

  /// Snapshot of the profile as originally loaded. Used as the diff
  /// baseline in [saveProfile] so that an avatar uploaded during editing
  /// (which updates [_currentProfile] for preview) is still detected as a
  /// change and written to Firestore.
  UserProfile? _originalProfile;

  void loadProfile(UserProfile profile) {
    _currentProfile = profile;
    _originalProfile = profile;
    emit(EditProfileState.loaded(profile: profile, hasChanges: false));
  }

  /// Loads the current authenticated user's profile from the repository.
  /// Used when the edit-profile route is opened directly without `extra`.
  Future<void> loadCurrentUserProfile() async {
    emit(const EditProfileState.loading());
    try {
      final profile = await _profileRepository.getCurrentUserProfile();
      if (profile == null) {
        emit(const EditProfileState.error(message: 'Profile not found.'));
        return;
      }
      _currentProfile = profile;
      _originalProfile = profile;
      emit(EditProfileState.loaded(profile: profile, hasChanges: false));
    } catch (e) {
      AppLogger.error('Failed to load current user profile', error: e);
      emit(const EditProfileState.error(message: 'Failed to load profile.'));
    }
  }

  void markChanged() {
    state.whenOrNull(
      loaded: (profile, _) =>
          emit(EditProfileState.loaded(profile: profile, hasChanges: true)),
    );
  }

  Future<void> saveProfile({
    String? displayName,
    String? username,
    String? bio,
    String? region,
    String? favoriteMode,
    String? avatarUrl,
  }) async {
    if (_currentProfile == null) return;

    emit(const EditProfileState.saving());

    try {
      final data = <String, dynamic>{};

      if (displayName != null && displayName != _currentProfile!.displayName) {
        data['displayName'] = displayName.trim();
      }
      if (username != null && username != _currentProfile!.username) {
        data['username'] = username.trim().toLowerCase();
      }
      if (bio != null && bio != _currentProfile!.bio) {
        data['bio'] = bio.trim();
      }
      if (region != null && region != _currentProfile!.region) {
        data['region'] = region;
      }
      if (favoriteMode != null &&
          favoriteMode != _currentProfile!.favoriteMode) {
        data['favoriteMode'] = favoriteMode;
      }
      if (avatarUrl != null && avatarUrl != _originalProfile!.avatarUrl) {
        data['avatarUrl'] = avatarUrl;
      }

      if (data.isNotEmpty) {
        await _profileRepository.updateProfile(data);
        _originalProfile = _currentProfile;
      }

      emit(const EditProfileState.saved());
    } catch (e) {
      AppLogger.error('Failed to save profile', error: e);
      emit(EditProfileState.error(message: e.toString()));
    }
  }

  /// Applies a successfully uploaded avatar URL to the in-memory profile so
  /// the edit page can preview it. Deliberately does NOT touch
  /// [_originalProfile] — [saveProfile] diffs against that baseline, so the
  /// new URL is still detected as a change and persisted.
  @visibleForTesting
  void applyUploadedAvatar(String url) {
    final current = _currentProfile;
    if (current == null) return;
    final updatedProfile = UserProfile(
      uid: current.uid,
      displayName: current.displayName,
      username: current.username,
      bio: current.bio,
      avatarUrl: url,
      region: current.region,
      favoriteMode: current.favoriteMode,
      level: current.level,
      xp: current.xp,
      xpToNextLevel: current.xpToNextLevel,
      gamesPlayed: current.gamesPlayed,
      gamesWon: current.gamesWon,
      sunGamesPlayed: current.sunGamesPlayed,
      sunGamesWon: current.sunGamesWon,
      hokmGamesPlayed: current.hokmGamesPlayed,
      hokmGamesWon: current.hokmGamesWon,
      followersCount: current.followersCount,
      followingCount: current.followingCount,
      isOnline: current.isOnline,
    );
    _currentProfile = updatedProfile;
    emit(EditProfileState.loaded(profile: updatedProfile, hasChanges: true));
  }

  Future<String?> pickAndUploadAvatar() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (picked == null) return null;

      final url = await _profileRepository.uploadAvatar(File(picked.path));
      applyUploadedAvatar(url);
      return url;
    } catch (e) {
      AppLogger.error('Failed to upload avatar', error: e);
      if (_currentProfile != null) {
        emit(
          EditProfileState.loaded(profile: _currentProfile!, hasChanges: false),
        );
      } else {
        emit(EditProfileState.error(message: e.toString()));
      }
      return null;
    }
  }
}
