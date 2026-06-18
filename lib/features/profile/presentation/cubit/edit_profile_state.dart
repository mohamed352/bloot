import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:bloot/features/profile/domain/entities/user_profile.dart';

part 'edit_profile_state.freezed.dart';

@freezed
class EditProfileState with _$EditProfileState {
  const factory EditProfileState.initial() = EditProfileInitial;
  const factory EditProfileState.loading() = EditProfileLoading;
  const factory EditProfileState.loaded({
    required UserProfile profile,
    required bool hasChanges,
  }) = EditProfileLoaded;
  const factory EditProfileState.saving() = EditProfileSaving;
  const factory EditProfileState.saved() = EditProfileSaved;
  const factory EditProfileState.error({required String message}) =
      EditProfileError;
}
