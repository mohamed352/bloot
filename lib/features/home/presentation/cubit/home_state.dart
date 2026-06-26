import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:bloot/features/home/domain/entities/home_stream.dart';
import 'package:bloot/features/profile/domain/entities/user_profile.dart';

part 'home_state.freezed.dart';

@freezed
class HomeState with _$HomeState {
  const factory HomeState.initial() = HomeInitial;
  const factory HomeState.loading() = HomeLoading;
  const factory HomeState.loaded({
    required UserProfile? profile,
    required List<HomeStream> streams,
    @Default(0) int unreadNotificationsCount,
  }) = HomeLoaded;
  const factory HomeState.empty({
    UserProfile? profile,
    @Default(0) int unreadNotificationsCount,
  }) = HomeEmpty;
  const factory HomeState.error({required String message}) = HomeError;
}
