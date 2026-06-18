// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tournament_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TournamentPrizeModel {

 String get place; String get amount;
/// Create a copy of TournamentPrizeModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TournamentPrizeModelCopyWith<TournamentPrizeModel> get copyWith => _$TournamentPrizeModelCopyWithImpl<TournamentPrizeModel>(this as TournamentPrizeModel, _$identity);

  /// Serializes this TournamentPrizeModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TournamentPrizeModel&&(identical(other.place, place) || other.place == place)&&(identical(other.amount, amount) || other.amount == amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,place,amount);

@override
String toString() {
  return 'TournamentPrizeModel(place: $place, amount: $amount)';
}


}

/// @nodoc
abstract mixin class $TournamentPrizeModelCopyWith<$Res>  {
  factory $TournamentPrizeModelCopyWith(TournamentPrizeModel value, $Res Function(TournamentPrizeModel) _then) = _$TournamentPrizeModelCopyWithImpl;
@useResult
$Res call({
 String place, String amount
});




}
/// @nodoc
class _$TournamentPrizeModelCopyWithImpl<$Res>
    implements $TournamentPrizeModelCopyWith<$Res> {
  _$TournamentPrizeModelCopyWithImpl(this._self, this._then);

  final TournamentPrizeModel _self;
  final $Res Function(TournamentPrizeModel) _then;

/// Create a copy of TournamentPrizeModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? place = null,Object? amount = null,}) {
  return _then(_self.copyWith(
place: null == place ? _self.place : place // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TournamentPrizeModel].
extension TournamentPrizeModelPatterns on TournamentPrizeModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TournamentPrizeModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TournamentPrizeModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TournamentPrizeModel value)  $default,){
final _that = this;
switch (_that) {
case _TournamentPrizeModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TournamentPrizeModel value)?  $default,){
final _that = this;
switch (_that) {
case _TournamentPrizeModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String place,  String amount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TournamentPrizeModel() when $default != null:
return $default(_that.place,_that.amount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String place,  String amount)  $default,) {final _that = this;
switch (_that) {
case _TournamentPrizeModel():
return $default(_that.place,_that.amount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String place,  String amount)?  $default,) {final _that = this;
switch (_that) {
case _TournamentPrizeModel() when $default != null:
return $default(_that.place,_that.amount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TournamentPrizeModel implements TournamentPrizeModel {
  const _TournamentPrizeModel({required this.place, required this.amount});
  factory _TournamentPrizeModel.fromJson(Map<String, dynamic> json) => _$TournamentPrizeModelFromJson(json);

@override final  String place;
@override final  String amount;

/// Create a copy of TournamentPrizeModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TournamentPrizeModelCopyWith<_TournamentPrizeModel> get copyWith => __$TournamentPrizeModelCopyWithImpl<_TournamentPrizeModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TournamentPrizeModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TournamentPrizeModel&&(identical(other.place, place) || other.place == place)&&(identical(other.amount, amount) || other.amount == amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,place,amount);

@override
String toString() {
  return 'TournamentPrizeModel(place: $place, amount: $amount)';
}


}

/// @nodoc
abstract mixin class _$TournamentPrizeModelCopyWith<$Res> implements $TournamentPrizeModelCopyWith<$Res> {
  factory _$TournamentPrizeModelCopyWith(_TournamentPrizeModel value, $Res Function(_TournamentPrizeModel) _then) = __$TournamentPrizeModelCopyWithImpl;
@override @useResult
$Res call({
 String place, String amount
});




}
/// @nodoc
class __$TournamentPrizeModelCopyWithImpl<$Res>
    implements _$TournamentPrizeModelCopyWith<$Res> {
  __$TournamentPrizeModelCopyWithImpl(this._self, this._then);

  final _TournamentPrizeModel _self;
  final $Res Function(_TournamentPrizeModel) _then;

/// Create a copy of TournamentPrizeModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? place = null,Object? amount = null,}) {
  return _then(_TournamentPrizeModel(
place: null == place ? _self.place : place // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$TournamentMatchModel {

 String get matchId; String get playerAName; String get playerBName; String? get playerAUid; String? get playerBUid; String? get winnerUid; String? get roomId; String? get gameId; String? get nextMatchId; int get roundIndex; int get matchIndex; int? get playerAScore; int? get playerBScore; String get status; bool get isUserMatch; String? get playerAAvatarUrl; String? get playerBAvatarUrl; List<String> get teamAPlayerIds; List<String> get teamBPlayerIds;
/// Create a copy of TournamentMatchModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TournamentMatchModelCopyWith<TournamentMatchModel> get copyWith => _$TournamentMatchModelCopyWithImpl<TournamentMatchModel>(this as TournamentMatchModel, _$identity);

  /// Serializes this TournamentMatchModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TournamentMatchModel&&(identical(other.matchId, matchId) || other.matchId == matchId)&&(identical(other.playerAName, playerAName) || other.playerAName == playerAName)&&(identical(other.playerBName, playerBName) || other.playerBName == playerBName)&&(identical(other.playerAUid, playerAUid) || other.playerAUid == playerAUid)&&(identical(other.playerBUid, playerBUid) || other.playerBUid == playerBUid)&&(identical(other.winnerUid, winnerUid) || other.winnerUid == winnerUid)&&(identical(other.roomId, roomId) || other.roomId == roomId)&&(identical(other.gameId, gameId) || other.gameId == gameId)&&(identical(other.nextMatchId, nextMatchId) || other.nextMatchId == nextMatchId)&&(identical(other.roundIndex, roundIndex) || other.roundIndex == roundIndex)&&(identical(other.matchIndex, matchIndex) || other.matchIndex == matchIndex)&&(identical(other.playerAScore, playerAScore) || other.playerAScore == playerAScore)&&(identical(other.playerBScore, playerBScore) || other.playerBScore == playerBScore)&&(identical(other.status, status) || other.status == status)&&(identical(other.isUserMatch, isUserMatch) || other.isUserMatch == isUserMatch)&&(identical(other.playerAAvatarUrl, playerAAvatarUrl) || other.playerAAvatarUrl == playerAAvatarUrl)&&(identical(other.playerBAvatarUrl, playerBAvatarUrl) || other.playerBAvatarUrl == playerBAvatarUrl)&&const DeepCollectionEquality().equals(other.teamAPlayerIds, teamAPlayerIds)&&const DeepCollectionEquality().equals(other.teamBPlayerIds, teamBPlayerIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,matchId,playerAName,playerBName,playerAUid,playerBUid,winnerUid,roomId,gameId,nextMatchId,roundIndex,matchIndex,playerAScore,playerBScore,status,isUserMatch,playerAAvatarUrl,playerBAvatarUrl,const DeepCollectionEquality().hash(teamAPlayerIds),const DeepCollectionEquality().hash(teamBPlayerIds)]);

@override
String toString() {
  return 'TournamentMatchModel(matchId: $matchId, playerAName: $playerAName, playerBName: $playerBName, playerAUid: $playerAUid, playerBUid: $playerBUid, winnerUid: $winnerUid, roomId: $roomId, gameId: $gameId, nextMatchId: $nextMatchId, roundIndex: $roundIndex, matchIndex: $matchIndex, playerAScore: $playerAScore, playerBScore: $playerBScore, status: $status, isUserMatch: $isUserMatch, playerAAvatarUrl: $playerAAvatarUrl, playerBAvatarUrl: $playerBAvatarUrl, teamAPlayerIds: $teamAPlayerIds, teamBPlayerIds: $teamBPlayerIds)';
}


}

/// @nodoc
abstract mixin class $TournamentMatchModelCopyWith<$Res>  {
  factory $TournamentMatchModelCopyWith(TournamentMatchModel value, $Res Function(TournamentMatchModel) _then) = _$TournamentMatchModelCopyWithImpl;
@useResult
$Res call({
 String matchId, String playerAName, String playerBName, String? playerAUid, String? playerBUid, String? winnerUid, String? roomId, String? gameId, String? nextMatchId, int roundIndex, int matchIndex, int? playerAScore, int? playerBScore, String status, bool isUserMatch, String? playerAAvatarUrl, String? playerBAvatarUrl, List<String> teamAPlayerIds, List<String> teamBPlayerIds
});




}
/// @nodoc
class _$TournamentMatchModelCopyWithImpl<$Res>
    implements $TournamentMatchModelCopyWith<$Res> {
  _$TournamentMatchModelCopyWithImpl(this._self, this._then);

  final TournamentMatchModel _self;
  final $Res Function(TournamentMatchModel) _then;

/// Create a copy of TournamentMatchModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? matchId = null,Object? playerAName = null,Object? playerBName = null,Object? playerAUid = freezed,Object? playerBUid = freezed,Object? winnerUid = freezed,Object? roomId = freezed,Object? gameId = freezed,Object? nextMatchId = freezed,Object? roundIndex = null,Object? matchIndex = null,Object? playerAScore = freezed,Object? playerBScore = freezed,Object? status = null,Object? isUserMatch = null,Object? playerAAvatarUrl = freezed,Object? playerBAvatarUrl = freezed,Object? teamAPlayerIds = null,Object? teamBPlayerIds = null,}) {
  return _then(_self.copyWith(
matchId: null == matchId ? _self.matchId : matchId // ignore: cast_nullable_to_non_nullable
as String,playerAName: null == playerAName ? _self.playerAName : playerAName // ignore: cast_nullable_to_non_nullable
as String,playerBName: null == playerBName ? _self.playerBName : playerBName // ignore: cast_nullable_to_non_nullable
as String,playerAUid: freezed == playerAUid ? _self.playerAUid : playerAUid // ignore: cast_nullable_to_non_nullable
as String?,playerBUid: freezed == playerBUid ? _self.playerBUid : playerBUid // ignore: cast_nullable_to_non_nullable
as String?,winnerUid: freezed == winnerUid ? _self.winnerUid : winnerUid // ignore: cast_nullable_to_non_nullable
as String?,roomId: freezed == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as String?,gameId: freezed == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as String?,nextMatchId: freezed == nextMatchId ? _self.nextMatchId : nextMatchId // ignore: cast_nullable_to_non_nullable
as String?,roundIndex: null == roundIndex ? _self.roundIndex : roundIndex // ignore: cast_nullable_to_non_nullable
as int,matchIndex: null == matchIndex ? _self.matchIndex : matchIndex // ignore: cast_nullable_to_non_nullable
as int,playerAScore: freezed == playerAScore ? _self.playerAScore : playerAScore // ignore: cast_nullable_to_non_nullable
as int?,playerBScore: freezed == playerBScore ? _self.playerBScore : playerBScore // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,isUserMatch: null == isUserMatch ? _self.isUserMatch : isUserMatch // ignore: cast_nullable_to_non_nullable
as bool,playerAAvatarUrl: freezed == playerAAvatarUrl ? _self.playerAAvatarUrl : playerAAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,playerBAvatarUrl: freezed == playerBAvatarUrl ? _self.playerBAvatarUrl : playerBAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,teamAPlayerIds: null == teamAPlayerIds ? _self.teamAPlayerIds : teamAPlayerIds // ignore: cast_nullable_to_non_nullable
as List<String>,teamBPlayerIds: null == teamBPlayerIds ? _self.teamBPlayerIds : teamBPlayerIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [TournamentMatchModel].
extension TournamentMatchModelPatterns on TournamentMatchModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TournamentMatchModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TournamentMatchModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TournamentMatchModel value)  $default,){
final _that = this;
switch (_that) {
case _TournamentMatchModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TournamentMatchModel value)?  $default,){
final _that = this;
switch (_that) {
case _TournamentMatchModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String matchId,  String playerAName,  String playerBName,  String? playerAUid,  String? playerBUid,  String? winnerUid,  String? roomId,  String? gameId,  String? nextMatchId,  int roundIndex,  int matchIndex,  int? playerAScore,  int? playerBScore,  String status,  bool isUserMatch,  String? playerAAvatarUrl,  String? playerBAvatarUrl,  List<String> teamAPlayerIds,  List<String> teamBPlayerIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TournamentMatchModel() when $default != null:
return $default(_that.matchId,_that.playerAName,_that.playerBName,_that.playerAUid,_that.playerBUid,_that.winnerUid,_that.roomId,_that.gameId,_that.nextMatchId,_that.roundIndex,_that.matchIndex,_that.playerAScore,_that.playerBScore,_that.status,_that.isUserMatch,_that.playerAAvatarUrl,_that.playerBAvatarUrl,_that.teamAPlayerIds,_that.teamBPlayerIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String matchId,  String playerAName,  String playerBName,  String? playerAUid,  String? playerBUid,  String? winnerUid,  String? roomId,  String? gameId,  String? nextMatchId,  int roundIndex,  int matchIndex,  int? playerAScore,  int? playerBScore,  String status,  bool isUserMatch,  String? playerAAvatarUrl,  String? playerBAvatarUrl,  List<String> teamAPlayerIds,  List<String> teamBPlayerIds)  $default,) {final _that = this;
switch (_that) {
case _TournamentMatchModel():
return $default(_that.matchId,_that.playerAName,_that.playerBName,_that.playerAUid,_that.playerBUid,_that.winnerUid,_that.roomId,_that.gameId,_that.nextMatchId,_that.roundIndex,_that.matchIndex,_that.playerAScore,_that.playerBScore,_that.status,_that.isUserMatch,_that.playerAAvatarUrl,_that.playerBAvatarUrl,_that.teamAPlayerIds,_that.teamBPlayerIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String matchId,  String playerAName,  String playerBName,  String? playerAUid,  String? playerBUid,  String? winnerUid,  String? roomId,  String? gameId,  String? nextMatchId,  int roundIndex,  int matchIndex,  int? playerAScore,  int? playerBScore,  String status,  bool isUserMatch,  String? playerAAvatarUrl,  String? playerBAvatarUrl,  List<String> teamAPlayerIds,  List<String> teamBPlayerIds)?  $default,) {final _that = this;
switch (_that) {
case _TournamentMatchModel() when $default != null:
return $default(_that.matchId,_that.playerAName,_that.playerBName,_that.playerAUid,_that.playerBUid,_that.winnerUid,_that.roomId,_that.gameId,_that.nextMatchId,_that.roundIndex,_that.matchIndex,_that.playerAScore,_that.playerBScore,_that.status,_that.isUserMatch,_that.playerAAvatarUrl,_that.playerBAvatarUrl,_that.teamAPlayerIds,_that.teamBPlayerIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TournamentMatchModel implements TournamentMatchModel {
  const _TournamentMatchModel({required this.matchId, required this.playerAName, required this.playerBName, this.playerAUid, this.playerBUid, this.winnerUid, this.roomId, this.gameId, this.nextMatchId, this.roundIndex = 0, this.matchIndex = 0, this.playerAScore, this.playerBScore, this.status = 'upcoming', this.isUserMatch = false, this.playerAAvatarUrl, this.playerBAvatarUrl, final  List<String> teamAPlayerIds = const [], final  List<String> teamBPlayerIds = const []}): _teamAPlayerIds = teamAPlayerIds,_teamBPlayerIds = teamBPlayerIds;
  factory _TournamentMatchModel.fromJson(Map<String, dynamic> json) => _$TournamentMatchModelFromJson(json);

@override final  String matchId;
@override final  String playerAName;
@override final  String playerBName;
@override final  String? playerAUid;
@override final  String? playerBUid;
@override final  String? winnerUid;
@override final  String? roomId;
@override final  String? gameId;
@override final  String? nextMatchId;
@override@JsonKey() final  int roundIndex;
@override@JsonKey() final  int matchIndex;
@override final  int? playerAScore;
@override final  int? playerBScore;
@override@JsonKey() final  String status;
@override@JsonKey() final  bool isUserMatch;
@override final  String? playerAAvatarUrl;
@override final  String? playerBAvatarUrl;
 final  List<String> _teamAPlayerIds;
@override@JsonKey() List<String> get teamAPlayerIds {
  if (_teamAPlayerIds is EqualUnmodifiableListView) return _teamAPlayerIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_teamAPlayerIds);
}

 final  List<String> _teamBPlayerIds;
@override@JsonKey() List<String> get teamBPlayerIds {
  if (_teamBPlayerIds is EqualUnmodifiableListView) return _teamBPlayerIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_teamBPlayerIds);
}


/// Create a copy of TournamentMatchModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TournamentMatchModelCopyWith<_TournamentMatchModel> get copyWith => __$TournamentMatchModelCopyWithImpl<_TournamentMatchModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TournamentMatchModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TournamentMatchModel&&(identical(other.matchId, matchId) || other.matchId == matchId)&&(identical(other.playerAName, playerAName) || other.playerAName == playerAName)&&(identical(other.playerBName, playerBName) || other.playerBName == playerBName)&&(identical(other.playerAUid, playerAUid) || other.playerAUid == playerAUid)&&(identical(other.playerBUid, playerBUid) || other.playerBUid == playerBUid)&&(identical(other.winnerUid, winnerUid) || other.winnerUid == winnerUid)&&(identical(other.roomId, roomId) || other.roomId == roomId)&&(identical(other.gameId, gameId) || other.gameId == gameId)&&(identical(other.nextMatchId, nextMatchId) || other.nextMatchId == nextMatchId)&&(identical(other.roundIndex, roundIndex) || other.roundIndex == roundIndex)&&(identical(other.matchIndex, matchIndex) || other.matchIndex == matchIndex)&&(identical(other.playerAScore, playerAScore) || other.playerAScore == playerAScore)&&(identical(other.playerBScore, playerBScore) || other.playerBScore == playerBScore)&&(identical(other.status, status) || other.status == status)&&(identical(other.isUserMatch, isUserMatch) || other.isUserMatch == isUserMatch)&&(identical(other.playerAAvatarUrl, playerAAvatarUrl) || other.playerAAvatarUrl == playerAAvatarUrl)&&(identical(other.playerBAvatarUrl, playerBAvatarUrl) || other.playerBAvatarUrl == playerBAvatarUrl)&&const DeepCollectionEquality().equals(other._teamAPlayerIds, _teamAPlayerIds)&&const DeepCollectionEquality().equals(other._teamBPlayerIds, _teamBPlayerIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,matchId,playerAName,playerBName,playerAUid,playerBUid,winnerUid,roomId,gameId,nextMatchId,roundIndex,matchIndex,playerAScore,playerBScore,status,isUserMatch,playerAAvatarUrl,playerBAvatarUrl,const DeepCollectionEquality().hash(_teamAPlayerIds),const DeepCollectionEquality().hash(_teamBPlayerIds)]);

@override
String toString() {
  return 'TournamentMatchModel(matchId: $matchId, playerAName: $playerAName, playerBName: $playerBName, playerAUid: $playerAUid, playerBUid: $playerBUid, winnerUid: $winnerUid, roomId: $roomId, gameId: $gameId, nextMatchId: $nextMatchId, roundIndex: $roundIndex, matchIndex: $matchIndex, playerAScore: $playerAScore, playerBScore: $playerBScore, status: $status, isUserMatch: $isUserMatch, playerAAvatarUrl: $playerAAvatarUrl, playerBAvatarUrl: $playerBAvatarUrl, teamAPlayerIds: $teamAPlayerIds, teamBPlayerIds: $teamBPlayerIds)';
}


}

/// @nodoc
abstract mixin class _$TournamentMatchModelCopyWith<$Res> implements $TournamentMatchModelCopyWith<$Res> {
  factory _$TournamentMatchModelCopyWith(_TournamentMatchModel value, $Res Function(_TournamentMatchModel) _then) = __$TournamentMatchModelCopyWithImpl;
@override @useResult
$Res call({
 String matchId, String playerAName, String playerBName, String? playerAUid, String? playerBUid, String? winnerUid, String? roomId, String? gameId, String? nextMatchId, int roundIndex, int matchIndex, int? playerAScore, int? playerBScore, String status, bool isUserMatch, String? playerAAvatarUrl, String? playerBAvatarUrl, List<String> teamAPlayerIds, List<String> teamBPlayerIds
});




}
/// @nodoc
class __$TournamentMatchModelCopyWithImpl<$Res>
    implements _$TournamentMatchModelCopyWith<$Res> {
  __$TournamentMatchModelCopyWithImpl(this._self, this._then);

  final _TournamentMatchModel _self;
  final $Res Function(_TournamentMatchModel) _then;

/// Create a copy of TournamentMatchModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? matchId = null,Object? playerAName = null,Object? playerBName = null,Object? playerAUid = freezed,Object? playerBUid = freezed,Object? winnerUid = freezed,Object? roomId = freezed,Object? gameId = freezed,Object? nextMatchId = freezed,Object? roundIndex = null,Object? matchIndex = null,Object? playerAScore = freezed,Object? playerBScore = freezed,Object? status = null,Object? isUserMatch = null,Object? playerAAvatarUrl = freezed,Object? playerBAvatarUrl = freezed,Object? teamAPlayerIds = null,Object? teamBPlayerIds = null,}) {
  return _then(_TournamentMatchModel(
matchId: null == matchId ? _self.matchId : matchId // ignore: cast_nullable_to_non_nullable
as String,playerAName: null == playerAName ? _self.playerAName : playerAName // ignore: cast_nullable_to_non_nullable
as String,playerBName: null == playerBName ? _self.playerBName : playerBName // ignore: cast_nullable_to_non_nullable
as String,playerAUid: freezed == playerAUid ? _self.playerAUid : playerAUid // ignore: cast_nullable_to_non_nullable
as String?,playerBUid: freezed == playerBUid ? _self.playerBUid : playerBUid // ignore: cast_nullable_to_non_nullable
as String?,winnerUid: freezed == winnerUid ? _self.winnerUid : winnerUid // ignore: cast_nullable_to_non_nullable
as String?,roomId: freezed == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as String?,gameId: freezed == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as String?,nextMatchId: freezed == nextMatchId ? _self.nextMatchId : nextMatchId // ignore: cast_nullable_to_non_nullable
as String?,roundIndex: null == roundIndex ? _self.roundIndex : roundIndex // ignore: cast_nullable_to_non_nullable
as int,matchIndex: null == matchIndex ? _self.matchIndex : matchIndex // ignore: cast_nullable_to_non_nullable
as int,playerAScore: freezed == playerAScore ? _self.playerAScore : playerAScore // ignore: cast_nullable_to_non_nullable
as int?,playerBScore: freezed == playerBScore ? _self.playerBScore : playerBScore // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,isUserMatch: null == isUserMatch ? _self.isUserMatch : isUserMatch // ignore: cast_nullable_to_non_nullable
as bool,playerAAvatarUrl: freezed == playerAAvatarUrl ? _self.playerAAvatarUrl : playerAAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,playerBAvatarUrl: freezed == playerBAvatarUrl ? _self.playerBAvatarUrl : playerBAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,teamAPlayerIds: null == teamAPlayerIds ? _self._teamAPlayerIds : teamAPlayerIds // ignore: cast_nullable_to_non_nullable
as List<String>,teamBPlayerIds: null == teamBPlayerIds ? _self._teamBPlayerIds : teamBPlayerIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$TournamentModel {

 String get id; String get name; String get prize; String get participants; String get status; String get date; bool get isPremium; bool get isJoined; List<TournamentPrizeModel> get prizes; List<TournamentMatchModel> get bracket; String get entryFee; List<String> get participantIds; int get maxParticipants; int get currentRound; DateTime? get startedAt; DateTime? get endedAt; String? get creatorUid; String get format;
/// Create a copy of TournamentModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TournamentModelCopyWith<TournamentModel> get copyWith => _$TournamentModelCopyWithImpl<TournamentModel>(this as TournamentModel, _$identity);

  /// Serializes this TournamentModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TournamentModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.prize, prize) || other.prize == prize)&&(identical(other.participants, participants) || other.participants == participants)&&(identical(other.status, status) || other.status == status)&&(identical(other.date, date) || other.date == date)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&(identical(other.isJoined, isJoined) || other.isJoined == isJoined)&&const DeepCollectionEquality().equals(other.prizes, prizes)&&const DeepCollectionEquality().equals(other.bracket, bracket)&&(identical(other.entryFee, entryFee) || other.entryFee == entryFee)&&const DeepCollectionEquality().equals(other.participantIds, participantIds)&&(identical(other.maxParticipants, maxParticipants) || other.maxParticipants == maxParticipants)&&(identical(other.currentRound, currentRound) || other.currentRound == currentRound)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.creatorUid, creatorUid) || other.creatorUid == creatorUid)&&(identical(other.format, format) || other.format == format));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,prize,participants,status,date,isPremium,isJoined,const DeepCollectionEquality().hash(prizes),const DeepCollectionEquality().hash(bracket),entryFee,const DeepCollectionEquality().hash(participantIds),maxParticipants,currentRound,startedAt,endedAt,creatorUid,format);

@override
String toString() {
  return 'TournamentModel(id: $id, name: $name, prize: $prize, participants: $participants, status: $status, date: $date, isPremium: $isPremium, isJoined: $isJoined, prizes: $prizes, bracket: $bracket, entryFee: $entryFee, participantIds: $participantIds, maxParticipants: $maxParticipants, currentRound: $currentRound, startedAt: $startedAt, endedAt: $endedAt, creatorUid: $creatorUid, format: $format)';
}


}

/// @nodoc
abstract mixin class $TournamentModelCopyWith<$Res>  {
  factory $TournamentModelCopyWith(TournamentModel value, $Res Function(TournamentModel) _then) = _$TournamentModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String prize, String participants, String status, String date, bool isPremium, bool isJoined, List<TournamentPrizeModel> prizes, List<TournamentMatchModel> bracket, String entryFee, List<String> participantIds, int maxParticipants, int currentRound, DateTime? startedAt, DateTime? endedAt, String? creatorUid, String format
});




}
/// @nodoc
class _$TournamentModelCopyWithImpl<$Res>
    implements $TournamentModelCopyWith<$Res> {
  _$TournamentModelCopyWithImpl(this._self, this._then);

  final TournamentModel _self;
  final $Res Function(TournamentModel) _then;

/// Create a copy of TournamentModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? prize = null,Object? participants = null,Object? status = null,Object? date = null,Object? isPremium = null,Object? isJoined = null,Object? prizes = null,Object? bracket = null,Object? entryFee = null,Object? participantIds = null,Object? maxParticipants = null,Object? currentRound = null,Object? startedAt = freezed,Object? endedAt = freezed,Object? creatorUid = freezed,Object? format = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,prize: null == prize ? _self.prize : prize // ignore: cast_nullable_to_non_nullable
as String,participants: null == participants ? _self.participants : participants // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,isJoined: null == isJoined ? _self.isJoined : isJoined // ignore: cast_nullable_to_non_nullable
as bool,prizes: null == prizes ? _self.prizes : prizes // ignore: cast_nullable_to_non_nullable
as List<TournamentPrizeModel>,bracket: null == bracket ? _self.bracket : bracket // ignore: cast_nullable_to_non_nullable
as List<TournamentMatchModel>,entryFee: null == entryFee ? _self.entryFee : entryFee // ignore: cast_nullable_to_non_nullable
as String,participantIds: null == participantIds ? _self.participantIds : participantIds // ignore: cast_nullable_to_non_nullable
as List<String>,maxParticipants: null == maxParticipants ? _self.maxParticipants : maxParticipants // ignore: cast_nullable_to_non_nullable
as int,currentRound: null == currentRound ? _self.currentRound : currentRound // ignore: cast_nullable_to_non_nullable
as int,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,creatorUid: freezed == creatorUid ? _self.creatorUid : creatorUid // ignore: cast_nullable_to_non_nullable
as String?,format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TournamentModel].
extension TournamentModelPatterns on TournamentModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TournamentModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TournamentModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TournamentModel value)  $default,){
final _that = this;
switch (_that) {
case _TournamentModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TournamentModel value)?  $default,){
final _that = this;
switch (_that) {
case _TournamentModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String prize,  String participants,  String status,  String date,  bool isPremium,  bool isJoined,  List<TournamentPrizeModel> prizes,  List<TournamentMatchModel> bracket,  String entryFee,  List<String> participantIds,  int maxParticipants,  int currentRound,  DateTime? startedAt,  DateTime? endedAt,  String? creatorUid,  String format)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TournamentModel() when $default != null:
return $default(_that.id,_that.name,_that.prize,_that.participants,_that.status,_that.date,_that.isPremium,_that.isJoined,_that.prizes,_that.bracket,_that.entryFee,_that.participantIds,_that.maxParticipants,_that.currentRound,_that.startedAt,_that.endedAt,_that.creatorUid,_that.format);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String prize,  String participants,  String status,  String date,  bool isPremium,  bool isJoined,  List<TournamentPrizeModel> prizes,  List<TournamentMatchModel> bracket,  String entryFee,  List<String> participantIds,  int maxParticipants,  int currentRound,  DateTime? startedAt,  DateTime? endedAt,  String? creatorUid,  String format)  $default,) {final _that = this;
switch (_that) {
case _TournamentModel():
return $default(_that.id,_that.name,_that.prize,_that.participants,_that.status,_that.date,_that.isPremium,_that.isJoined,_that.prizes,_that.bracket,_that.entryFee,_that.participantIds,_that.maxParticipants,_that.currentRound,_that.startedAt,_that.endedAt,_that.creatorUid,_that.format);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String prize,  String participants,  String status,  String date,  bool isPremium,  bool isJoined,  List<TournamentPrizeModel> prizes,  List<TournamentMatchModel> bracket,  String entryFee,  List<String> participantIds,  int maxParticipants,  int currentRound,  DateTime? startedAt,  DateTime? endedAt,  String? creatorUid,  String format)?  $default,) {final _that = this;
switch (_that) {
case _TournamentModel() when $default != null:
return $default(_that.id,_that.name,_that.prize,_that.participants,_that.status,_that.date,_that.isPremium,_that.isJoined,_that.prizes,_that.bracket,_that.entryFee,_that.participantIds,_that.maxParticipants,_that.currentRound,_that.startedAt,_that.endedAt,_that.creatorUid,_that.format);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TournamentModel implements TournamentModel {
  const _TournamentModel({required this.id, required this.name, required this.prize, required this.participants, required this.status, required this.date, this.isPremium = false, this.isJoined = false, final  List<TournamentPrizeModel> prizes = const [], final  List<TournamentMatchModel> bracket = const [], this.entryFee = '', final  List<String> participantIds = const [], this.maxParticipants = 64, this.currentRound = 0, this.startedAt, this.endedAt, this.creatorUid, this.format = 'single_elimination'}): _prizes = prizes,_bracket = bracket,_participantIds = participantIds;
  factory _TournamentModel.fromJson(Map<String, dynamic> json) => _$TournamentModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  String prize;
@override final  String participants;
@override final  String status;
@override final  String date;
@override@JsonKey() final  bool isPremium;
@override@JsonKey() final  bool isJoined;
 final  List<TournamentPrizeModel> _prizes;
@override@JsonKey() List<TournamentPrizeModel> get prizes {
  if (_prizes is EqualUnmodifiableListView) return _prizes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_prizes);
}

 final  List<TournamentMatchModel> _bracket;
@override@JsonKey() List<TournamentMatchModel> get bracket {
  if (_bracket is EqualUnmodifiableListView) return _bracket;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bracket);
}

@override@JsonKey() final  String entryFee;
 final  List<String> _participantIds;
@override@JsonKey() List<String> get participantIds {
  if (_participantIds is EqualUnmodifiableListView) return _participantIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_participantIds);
}

@override@JsonKey() final  int maxParticipants;
@override@JsonKey() final  int currentRound;
@override final  DateTime? startedAt;
@override final  DateTime? endedAt;
@override final  String? creatorUid;
@override@JsonKey() final  String format;

/// Create a copy of TournamentModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TournamentModelCopyWith<_TournamentModel> get copyWith => __$TournamentModelCopyWithImpl<_TournamentModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TournamentModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TournamentModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.prize, prize) || other.prize == prize)&&(identical(other.participants, participants) || other.participants == participants)&&(identical(other.status, status) || other.status == status)&&(identical(other.date, date) || other.date == date)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&(identical(other.isJoined, isJoined) || other.isJoined == isJoined)&&const DeepCollectionEquality().equals(other._prizes, _prizes)&&const DeepCollectionEquality().equals(other._bracket, _bracket)&&(identical(other.entryFee, entryFee) || other.entryFee == entryFee)&&const DeepCollectionEquality().equals(other._participantIds, _participantIds)&&(identical(other.maxParticipants, maxParticipants) || other.maxParticipants == maxParticipants)&&(identical(other.currentRound, currentRound) || other.currentRound == currentRound)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.creatorUid, creatorUid) || other.creatorUid == creatorUid)&&(identical(other.format, format) || other.format == format));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,prize,participants,status,date,isPremium,isJoined,const DeepCollectionEquality().hash(_prizes),const DeepCollectionEquality().hash(_bracket),entryFee,const DeepCollectionEquality().hash(_participantIds),maxParticipants,currentRound,startedAt,endedAt,creatorUid,format);

@override
String toString() {
  return 'TournamentModel(id: $id, name: $name, prize: $prize, participants: $participants, status: $status, date: $date, isPremium: $isPremium, isJoined: $isJoined, prizes: $prizes, bracket: $bracket, entryFee: $entryFee, participantIds: $participantIds, maxParticipants: $maxParticipants, currentRound: $currentRound, startedAt: $startedAt, endedAt: $endedAt, creatorUid: $creatorUid, format: $format)';
}


}

/// @nodoc
abstract mixin class _$TournamentModelCopyWith<$Res> implements $TournamentModelCopyWith<$Res> {
  factory _$TournamentModelCopyWith(_TournamentModel value, $Res Function(_TournamentModel) _then) = __$TournamentModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String prize, String participants, String status, String date, bool isPremium, bool isJoined, List<TournamentPrizeModel> prizes, List<TournamentMatchModel> bracket, String entryFee, List<String> participantIds, int maxParticipants, int currentRound, DateTime? startedAt, DateTime? endedAt, String? creatorUid, String format
});




}
/// @nodoc
class __$TournamentModelCopyWithImpl<$Res>
    implements _$TournamentModelCopyWith<$Res> {
  __$TournamentModelCopyWithImpl(this._self, this._then);

  final _TournamentModel _self;
  final $Res Function(_TournamentModel) _then;

/// Create a copy of TournamentModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? prize = null,Object? participants = null,Object? status = null,Object? date = null,Object? isPremium = null,Object? isJoined = null,Object? prizes = null,Object? bracket = null,Object? entryFee = null,Object? participantIds = null,Object? maxParticipants = null,Object? currentRound = null,Object? startedAt = freezed,Object? endedAt = freezed,Object? creatorUid = freezed,Object? format = null,}) {
  return _then(_TournamentModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,prize: null == prize ? _self.prize : prize // ignore: cast_nullable_to_non_nullable
as String,participants: null == participants ? _self.participants : participants // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,isJoined: null == isJoined ? _self.isJoined : isJoined // ignore: cast_nullable_to_non_nullable
as bool,prizes: null == prizes ? _self._prizes : prizes // ignore: cast_nullable_to_non_nullable
as List<TournamentPrizeModel>,bracket: null == bracket ? _self._bracket : bracket // ignore: cast_nullable_to_non_nullable
as List<TournamentMatchModel>,entryFee: null == entryFee ? _self.entryFee : entryFee // ignore: cast_nullable_to_non_nullable
as String,participantIds: null == participantIds ? _self._participantIds : participantIds // ignore: cast_nullable_to_non_nullable
as List<String>,maxParticipants: null == maxParticipants ? _self.maxParticipants : maxParticipants // ignore: cast_nullable_to_non_nullable
as int,currentRound: null == currentRound ? _self.currentRound : currentRound // ignore: cast_nullable_to_non_nullable
as int,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,creatorUid: freezed == creatorUid ? _self.creatorUid : creatorUid // ignore: cast_nullable_to_non_nullable
as String?,format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
