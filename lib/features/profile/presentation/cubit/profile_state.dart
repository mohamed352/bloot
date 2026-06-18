import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:bloot/features/profile/domain/entities/achievement.dart';
import 'package:bloot/features/profile/domain/entities/game_history.dart';
import 'package:bloot/features/profile/domain/entities/user_profile.dart';

part 'profile_state.freezed.dart';

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState.initial() = ProfileInitial;
  const factory ProfileState.loading() = ProfileLoading;
  const factory ProfileState.loaded({
    required UserProfile profile,
    @Default([]) List<GameHistory> gameHistory,
    @Default([]) List<Achievement> achievements,
  }) = ProfileLoaded;
  const factory ProfileState.error({required String message}) = ProfileError;
}
