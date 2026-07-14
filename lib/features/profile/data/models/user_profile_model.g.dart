// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfileModel _$UserProfileModelFromJson(Map<String, dynamic> json) =>
    _UserProfileModel(
      uid: json['uid'] as String,
      displayName: json['displayName'] as String?,
      username: json['username'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      bio: json['bio'] as String?,
      region: json['region'] as String?,
      favoriteMode: json['favoriteMode'] as String?,
      level: (json['level'] as num?)?.toInt() ?? 1,
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      xpToNextLevel: (json['xpToNextLevel'] as num?)?.toInt() ?? 100,
      gamesPlayed: (json['gamesPlayed'] as num?)?.toInt() ?? 0,
      gamesWon: (json['gamesWon'] as num?)?.toInt() ?? 0,
      sunGamesPlayed: (json['sunGamesPlayed'] as num?)?.toInt() ?? 0,
      sunGamesWon: (json['sunGamesWon'] as num?)?.toInt() ?? 0,
      hokmGamesPlayed: (json['hokmGamesPlayed'] as num?)?.toInt() ?? 0,
      hokmGamesWon: (json['hokmGamesWon'] as num?)?.toInt() ?? 0,
      followersCount: (json['followersCount'] as num?)?.toInt() ?? 0,
      followingCount: (json['followingCount'] as num?)?.toInt() ?? 0,
      isOnline: json['isOnline'] as bool? ?? false,
    );

Map<String, dynamic> _$UserProfileModelToJson(_UserProfileModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'displayName': instance.displayName,
      'username': instance.username,
      'avatarUrl': instance.avatarUrl,
      'bio': instance.bio,
      'region': instance.region,
      'favoriteMode': instance.favoriteMode,
      'level': instance.level,
      'xp': instance.xp,
      'xpToNextLevel': instance.xpToNextLevel,
      'gamesPlayed': instance.gamesPlayed,
      'gamesWon': instance.gamesWon,
      'sunGamesPlayed': instance.sunGamesPlayed,
      'sunGamesWon': instance.sunGamesWon,
      'hokmGamesPlayed': instance.hokmGamesPlayed,
      'hokmGamesWon': instance.hokmGamesWon,
      'followersCount': instance.followersCount,
      'followingCount': instance.followingCount,
      'isOnline': instance.isOnline,
    };
