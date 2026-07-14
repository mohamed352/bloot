import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:bloot/features/profile/domain/entities/user_profile.dart';

part 'user_profile_model.freezed.dart';
part 'user_profile_model.g.dart';

@freezed
abstract class UserProfileModel with _$UserProfileModel {
  const factory UserProfileModel({
    required String uid,
    String? displayName,
    String? username,
    String? avatarUrl,
    String? bio,
    String? region,
    String? favoriteMode,
    @Default(1) int level,
    @Default(0) int xp,
    @Default(100) int xpToNextLevel,
    @Default(0) int gamesPlayed,
    @Default(0) int gamesWon,
    @Default(0) int sunGamesPlayed,
    @Default(0) int sunGamesWon,
    @Default(0) int hokmGamesPlayed,
    @Default(0) int hokmGamesWon,
    @Default(0) int followersCount,
    @Default(0) int followingCount,
    @Default(false) bool isOnline,
  }) = _UserProfileModel;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      _$UserProfileModelFromJson(json);
}

extension UserProfileModelX on UserProfileModel {
  UserProfile toEntity() => UserProfile(
    uid: uid,
    displayName: displayName,
    username: username,
    avatarUrl: avatarUrl,
    bio: bio,
    region: region,
    favoriteMode: favoriteMode,
    level: level,
    xp: xp,
    xpToNextLevel: xpToNextLevel,
    gamesPlayed: gamesPlayed,
    gamesWon: gamesWon,
    sunGamesPlayed: sunGamesPlayed,
    sunGamesWon: sunGamesWon,
    hokmGamesPlayed: hokmGamesPlayed,
    hokmGamesWon: hokmGamesWon,
    followersCount: followersCount,
    followingCount: followingCount,
    isOnline: isOnline,
  );
}
