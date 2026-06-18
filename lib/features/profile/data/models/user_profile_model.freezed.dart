// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserProfileModel {

 String get uid; String? get displayName; String? get username; String? get avatarUrl; String? get bio; String? get region; String? get favoriteMode; int get level; int get xp; int get xpToNextLevel; int get coins; int get gamesPlayed; int get gamesWon; int get sunGamesPlayed; int get sunGamesWon; int get hokmGamesPlayed; int get hokmGamesWon; int get followersCount; int get followingCount; bool get isOnline;
/// Create a copy of UserProfileModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileModelCopyWith<UserProfileModel> get copyWith => _$UserProfileModelCopyWithImpl<UserProfileModel>(this as UserProfileModel, _$identity);

  /// Serializes this UserProfileModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfileModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.username, username) || other.username == username)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.region, region) || other.region == region)&&(identical(other.favoriteMode, favoriteMode) || other.favoriteMode == favoriteMode)&&(identical(other.level, level) || other.level == level)&&(identical(other.xp, xp) || other.xp == xp)&&(identical(other.xpToNextLevel, xpToNextLevel) || other.xpToNextLevel == xpToNextLevel)&&(identical(other.coins, coins) || other.coins == coins)&&(identical(other.gamesPlayed, gamesPlayed) || other.gamesPlayed == gamesPlayed)&&(identical(other.gamesWon, gamesWon) || other.gamesWon == gamesWon)&&(identical(other.sunGamesPlayed, sunGamesPlayed) || other.sunGamesPlayed == sunGamesPlayed)&&(identical(other.sunGamesWon, sunGamesWon) || other.sunGamesWon == sunGamesWon)&&(identical(other.hokmGamesPlayed, hokmGamesPlayed) || other.hokmGamesPlayed == hokmGamesPlayed)&&(identical(other.hokmGamesWon, hokmGamesWon) || other.hokmGamesWon == hokmGamesWon)&&(identical(other.followersCount, followersCount) || other.followersCount == followersCount)&&(identical(other.followingCount, followingCount) || other.followingCount == followingCount)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,displayName,username,avatarUrl,bio,region,favoriteMode,level,xp,xpToNextLevel,coins,gamesPlayed,gamesWon,sunGamesPlayed,sunGamesWon,hokmGamesPlayed,hokmGamesWon,followersCount,followingCount,isOnline]);

@override
String toString() {
  return 'UserProfileModel(uid: $uid, displayName: $displayName, username: $username, avatarUrl: $avatarUrl, bio: $bio, region: $region, favoriteMode: $favoriteMode, level: $level, xp: $xp, xpToNextLevel: $xpToNextLevel, coins: $coins, gamesPlayed: $gamesPlayed, gamesWon: $gamesWon, sunGamesPlayed: $sunGamesPlayed, sunGamesWon: $sunGamesWon, hokmGamesPlayed: $hokmGamesPlayed, hokmGamesWon: $hokmGamesWon, followersCount: $followersCount, followingCount: $followingCount, isOnline: $isOnline)';
}


}

/// @nodoc
abstract mixin class $UserProfileModelCopyWith<$Res>  {
  factory $UserProfileModelCopyWith(UserProfileModel value, $Res Function(UserProfileModel) _then) = _$UserProfileModelCopyWithImpl;
@useResult
$Res call({
 String uid, String? displayName, String? username, String? avatarUrl, String? bio, String? region, String? favoriteMode, int level, int xp, int xpToNextLevel, int coins, int gamesPlayed, int gamesWon, int sunGamesPlayed, int sunGamesWon, int hokmGamesPlayed, int hokmGamesWon, int followersCount, int followingCount, bool isOnline
});




}
/// @nodoc
class _$UserProfileModelCopyWithImpl<$Res>
    implements $UserProfileModelCopyWith<$Res> {
  _$UserProfileModelCopyWithImpl(this._self, this._then);

  final UserProfileModel _self;
  final $Res Function(UserProfileModel) _then;

/// Create a copy of UserProfileModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? displayName = freezed,Object? username = freezed,Object? avatarUrl = freezed,Object? bio = freezed,Object? region = freezed,Object? favoriteMode = freezed,Object? level = null,Object? xp = null,Object? xpToNextLevel = null,Object? coins = null,Object? gamesPlayed = null,Object? gamesWon = null,Object? sunGamesPlayed = null,Object? sunGamesWon = null,Object? hokmGamesPlayed = null,Object? hokmGamesWon = null,Object? followersCount = null,Object? followingCount = null,Object? isOnline = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,region: freezed == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String?,favoriteMode: freezed == favoriteMode ? _self.favoriteMode : favoriteMode // ignore: cast_nullable_to_non_nullable
as String?,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,xp: null == xp ? _self.xp : xp // ignore: cast_nullable_to_non_nullable
as int,xpToNextLevel: null == xpToNextLevel ? _self.xpToNextLevel : xpToNextLevel // ignore: cast_nullable_to_non_nullable
as int,coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as int,gamesPlayed: null == gamesPlayed ? _self.gamesPlayed : gamesPlayed // ignore: cast_nullable_to_non_nullable
as int,gamesWon: null == gamesWon ? _self.gamesWon : gamesWon // ignore: cast_nullable_to_non_nullable
as int,sunGamesPlayed: null == sunGamesPlayed ? _self.sunGamesPlayed : sunGamesPlayed // ignore: cast_nullable_to_non_nullable
as int,sunGamesWon: null == sunGamesWon ? _self.sunGamesWon : sunGamesWon // ignore: cast_nullable_to_non_nullable
as int,hokmGamesPlayed: null == hokmGamesPlayed ? _self.hokmGamesPlayed : hokmGamesPlayed // ignore: cast_nullable_to_non_nullable
as int,hokmGamesWon: null == hokmGamesWon ? _self.hokmGamesWon : hokmGamesWon // ignore: cast_nullable_to_non_nullable
as int,followersCount: null == followersCount ? _self.followersCount : followersCount // ignore: cast_nullable_to_non_nullable
as int,followingCount: null == followingCount ? _self.followingCount : followingCount // ignore: cast_nullable_to_non_nullable
as int,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [UserProfileModel].
extension UserProfileModelPatterns on UserProfileModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfileModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfileModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfileModel value)  $default,){
final _that = this;
switch (_that) {
case _UserProfileModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfileModel value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfileModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String? displayName,  String? username,  String? avatarUrl,  String? bio,  String? region,  String? favoriteMode,  int level,  int xp,  int xpToNextLevel,  int coins,  int gamesPlayed,  int gamesWon,  int sunGamesPlayed,  int sunGamesWon,  int hokmGamesPlayed,  int hokmGamesWon,  int followersCount,  int followingCount,  bool isOnline)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfileModel() when $default != null:
return $default(_that.uid,_that.displayName,_that.username,_that.avatarUrl,_that.bio,_that.region,_that.favoriteMode,_that.level,_that.xp,_that.xpToNextLevel,_that.coins,_that.gamesPlayed,_that.gamesWon,_that.sunGamesPlayed,_that.sunGamesWon,_that.hokmGamesPlayed,_that.hokmGamesWon,_that.followersCount,_that.followingCount,_that.isOnline);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String? displayName,  String? username,  String? avatarUrl,  String? bio,  String? region,  String? favoriteMode,  int level,  int xp,  int xpToNextLevel,  int coins,  int gamesPlayed,  int gamesWon,  int sunGamesPlayed,  int sunGamesWon,  int hokmGamesPlayed,  int hokmGamesWon,  int followersCount,  int followingCount,  bool isOnline)  $default,) {final _that = this;
switch (_that) {
case _UserProfileModel():
return $default(_that.uid,_that.displayName,_that.username,_that.avatarUrl,_that.bio,_that.region,_that.favoriteMode,_that.level,_that.xp,_that.xpToNextLevel,_that.coins,_that.gamesPlayed,_that.gamesWon,_that.sunGamesPlayed,_that.sunGamesWon,_that.hokmGamesPlayed,_that.hokmGamesWon,_that.followersCount,_that.followingCount,_that.isOnline);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String? displayName,  String? username,  String? avatarUrl,  String? bio,  String? region,  String? favoriteMode,  int level,  int xp,  int xpToNextLevel,  int coins,  int gamesPlayed,  int gamesWon,  int sunGamesPlayed,  int sunGamesWon,  int hokmGamesPlayed,  int hokmGamesWon,  int followersCount,  int followingCount,  bool isOnline)?  $default,) {final _that = this;
switch (_that) {
case _UserProfileModel() when $default != null:
return $default(_that.uid,_that.displayName,_that.username,_that.avatarUrl,_that.bio,_that.region,_that.favoriteMode,_that.level,_that.xp,_that.xpToNextLevel,_that.coins,_that.gamesPlayed,_that.gamesWon,_that.sunGamesPlayed,_that.sunGamesWon,_that.hokmGamesPlayed,_that.hokmGamesWon,_that.followersCount,_that.followingCount,_that.isOnline);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserProfileModel implements UserProfileModel {
  const _UserProfileModel({required this.uid, this.displayName, this.username, this.avatarUrl, this.bio, this.region, this.favoriteMode, this.level = 1, this.xp = 0, this.xpToNextLevel = 100, this.coins = 0, this.gamesPlayed = 0, this.gamesWon = 0, this.sunGamesPlayed = 0, this.sunGamesWon = 0, this.hokmGamesPlayed = 0, this.hokmGamesWon = 0, this.followersCount = 0, this.followingCount = 0, this.isOnline = false});
  factory _UserProfileModel.fromJson(Map<String, dynamic> json) => _$UserProfileModelFromJson(json);

@override final  String uid;
@override final  String? displayName;
@override final  String? username;
@override final  String? avatarUrl;
@override final  String? bio;
@override final  String? region;
@override final  String? favoriteMode;
@override@JsonKey() final  int level;
@override@JsonKey() final  int xp;
@override@JsonKey() final  int xpToNextLevel;
@override@JsonKey() final  int coins;
@override@JsonKey() final  int gamesPlayed;
@override@JsonKey() final  int gamesWon;
@override@JsonKey() final  int sunGamesPlayed;
@override@JsonKey() final  int sunGamesWon;
@override@JsonKey() final  int hokmGamesPlayed;
@override@JsonKey() final  int hokmGamesWon;
@override@JsonKey() final  int followersCount;
@override@JsonKey() final  int followingCount;
@override@JsonKey() final  bool isOnline;

/// Create a copy of UserProfileModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileModelCopyWith<_UserProfileModel> get copyWith => __$UserProfileModelCopyWithImpl<_UserProfileModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserProfileModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfileModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.username, username) || other.username == username)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.region, region) || other.region == region)&&(identical(other.favoriteMode, favoriteMode) || other.favoriteMode == favoriteMode)&&(identical(other.level, level) || other.level == level)&&(identical(other.xp, xp) || other.xp == xp)&&(identical(other.xpToNextLevel, xpToNextLevel) || other.xpToNextLevel == xpToNextLevel)&&(identical(other.coins, coins) || other.coins == coins)&&(identical(other.gamesPlayed, gamesPlayed) || other.gamesPlayed == gamesPlayed)&&(identical(other.gamesWon, gamesWon) || other.gamesWon == gamesWon)&&(identical(other.sunGamesPlayed, sunGamesPlayed) || other.sunGamesPlayed == sunGamesPlayed)&&(identical(other.sunGamesWon, sunGamesWon) || other.sunGamesWon == sunGamesWon)&&(identical(other.hokmGamesPlayed, hokmGamesPlayed) || other.hokmGamesPlayed == hokmGamesPlayed)&&(identical(other.hokmGamesWon, hokmGamesWon) || other.hokmGamesWon == hokmGamesWon)&&(identical(other.followersCount, followersCount) || other.followersCount == followersCount)&&(identical(other.followingCount, followingCount) || other.followingCount == followingCount)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,displayName,username,avatarUrl,bio,region,favoriteMode,level,xp,xpToNextLevel,coins,gamesPlayed,gamesWon,sunGamesPlayed,sunGamesWon,hokmGamesPlayed,hokmGamesWon,followersCount,followingCount,isOnline]);

@override
String toString() {
  return 'UserProfileModel(uid: $uid, displayName: $displayName, username: $username, avatarUrl: $avatarUrl, bio: $bio, region: $region, favoriteMode: $favoriteMode, level: $level, xp: $xp, xpToNextLevel: $xpToNextLevel, coins: $coins, gamesPlayed: $gamesPlayed, gamesWon: $gamesWon, sunGamesPlayed: $sunGamesPlayed, sunGamesWon: $sunGamesWon, hokmGamesPlayed: $hokmGamesPlayed, hokmGamesWon: $hokmGamesWon, followersCount: $followersCount, followingCount: $followingCount, isOnline: $isOnline)';
}


}

/// @nodoc
abstract mixin class _$UserProfileModelCopyWith<$Res> implements $UserProfileModelCopyWith<$Res> {
  factory _$UserProfileModelCopyWith(_UserProfileModel value, $Res Function(_UserProfileModel) _then) = __$UserProfileModelCopyWithImpl;
@override @useResult
$Res call({
 String uid, String? displayName, String? username, String? avatarUrl, String? bio, String? region, String? favoriteMode, int level, int xp, int xpToNextLevel, int coins, int gamesPlayed, int gamesWon, int sunGamesPlayed, int sunGamesWon, int hokmGamesPlayed, int hokmGamesWon, int followersCount, int followingCount, bool isOnline
});




}
/// @nodoc
class __$UserProfileModelCopyWithImpl<$Res>
    implements _$UserProfileModelCopyWith<$Res> {
  __$UserProfileModelCopyWithImpl(this._self, this._then);

  final _UserProfileModel _self;
  final $Res Function(_UserProfileModel) _then;

/// Create a copy of UserProfileModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? displayName = freezed,Object? username = freezed,Object? avatarUrl = freezed,Object? bio = freezed,Object? region = freezed,Object? favoriteMode = freezed,Object? level = null,Object? xp = null,Object? xpToNextLevel = null,Object? coins = null,Object? gamesPlayed = null,Object? gamesWon = null,Object? sunGamesPlayed = null,Object? sunGamesWon = null,Object? hokmGamesPlayed = null,Object? hokmGamesWon = null,Object? followersCount = null,Object? followingCount = null,Object? isOnline = null,}) {
  return _then(_UserProfileModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,region: freezed == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String?,favoriteMode: freezed == favoriteMode ? _self.favoriteMode : favoriteMode // ignore: cast_nullable_to_non_nullable
as String?,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,xp: null == xp ? _self.xp : xp // ignore: cast_nullable_to_non_nullable
as int,xpToNextLevel: null == xpToNextLevel ? _self.xpToNextLevel : xpToNextLevel // ignore: cast_nullable_to_non_nullable
as int,coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as int,gamesPlayed: null == gamesPlayed ? _self.gamesPlayed : gamesPlayed // ignore: cast_nullable_to_non_nullable
as int,gamesWon: null == gamesWon ? _self.gamesWon : gamesWon // ignore: cast_nullable_to_non_nullable
as int,sunGamesPlayed: null == sunGamesPlayed ? _self.sunGamesPlayed : sunGamesPlayed // ignore: cast_nullable_to_non_nullable
as int,sunGamesWon: null == sunGamesWon ? _self.sunGamesWon : sunGamesWon // ignore: cast_nullable_to_non_nullable
as int,hokmGamesPlayed: null == hokmGamesPlayed ? _self.hokmGamesPlayed : hokmGamesPlayed // ignore: cast_nullable_to_non_nullable
as int,hokmGamesWon: null == hokmGamesWon ? _self.hokmGamesWon : hokmGamesWon // ignore: cast_nullable_to_non_nullable
as int,followersCount: null == followersCount ? _self.followersCount : followersCount // ignore: cast_nullable_to_non_nullable
as int,followingCount: null == followingCount ? _self.followingCount : followingCount // ignore: cast_nullable_to_non_nullable
as int,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
