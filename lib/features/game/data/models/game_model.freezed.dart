// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GameModel {

 String get id; List<GamePlayerModel> get players; List<String> get myHand; List<String> get playedCards; int get scoreUs; int get scoreThem; String get trump;
/// Create a copy of GameModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameModelCopyWith<GameModel> get copyWith => _$GameModelCopyWithImpl<GameModel>(this as GameModel, _$identity);

  /// Serializes this GameModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameModel&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.players, players)&&const DeepCollectionEquality().equals(other.myHand, myHand)&&const DeepCollectionEquality().equals(other.playedCards, playedCards)&&(identical(other.scoreUs, scoreUs) || other.scoreUs == scoreUs)&&(identical(other.scoreThem, scoreThem) || other.scoreThem == scoreThem)&&(identical(other.trump, trump) || other.trump == trump));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(players),const DeepCollectionEquality().hash(myHand),const DeepCollectionEquality().hash(playedCards),scoreUs,scoreThem,trump);

@override
String toString() {
  return 'GameModel(id: $id, players: $players, myHand: $myHand, playedCards: $playedCards, scoreUs: $scoreUs, scoreThem: $scoreThem, trump: $trump)';
}


}

/// @nodoc
abstract mixin class $GameModelCopyWith<$Res>  {
  factory $GameModelCopyWith(GameModel value, $Res Function(GameModel) _then) = _$GameModelCopyWithImpl;
@useResult
$Res call({
 String id, List<GamePlayerModel> players, List<String> myHand, List<String> playedCards, int scoreUs, int scoreThem, String trump
});




}
/// @nodoc
class _$GameModelCopyWithImpl<$Res>
    implements $GameModelCopyWith<$Res> {
  _$GameModelCopyWithImpl(this._self, this._then);

  final GameModel _self;
  final $Res Function(GameModel) _then;

/// Create a copy of GameModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? players = null,Object? myHand = null,Object? playedCards = null,Object? scoreUs = null,Object? scoreThem = null,Object? trump = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,players: null == players ? _self.players : players // ignore: cast_nullable_to_non_nullable
as List<GamePlayerModel>,myHand: null == myHand ? _self.myHand : myHand // ignore: cast_nullable_to_non_nullable
as List<String>,playedCards: null == playedCards ? _self.playedCards : playedCards // ignore: cast_nullable_to_non_nullable
as List<String>,scoreUs: null == scoreUs ? _self.scoreUs : scoreUs // ignore: cast_nullable_to_non_nullable
as int,scoreThem: null == scoreThem ? _self.scoreThem : scoreThem // ignore: cast_nullable_to_non_nullable
as int,trump: null == trump ? _self.trump : trump // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GameModel].
extension GameModelPatterns on GameModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GameModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GameModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GameModel value)  $default,){
final _that = this;
switch (_that) {
case _GameModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GameModel value)?  $default,){
final _that = this;
switch (_that) {
case _GameModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  List<GamePlayerModel> players,  List<String> myHand,  List<String> playedCards,  int scoreUs,  int scoreThem,  String trump)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GameModel() when $default != null:
return $default(_that.id,_that.players,_that.myHand,_that.playedCards,_that.scoreUs,_that.scoreThem,_that.trump);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  List<GamePlayerModel> players,  List<String> myHand,  List<String> playedCards,  int scoreUs,  int scoreThem,  String trump)  $default,) {final _that = this;
switch (_that) {
case _GameModel():
return $default(_that.id,_that.players,_that.myHand,_that.playedCards,_that.scoreUs,_that.scoreThem,_that.trump);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  List<GamePlayerModel> players,  List<String> myHand,  List<String> playedCards,  int scoreUs,  int scoreThem,  String trump)?  $default,) {final _that = this;
switch (_that) {
case _GameModel() when $default != null:
return $default(_that.id,_that.players,_that.myHand,_that.playedCards,_that.scoreUs,_that.scoreThem,_that.trump);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GameModel implements GameModel {
  const _GameModel({required this.id, required final  List<GamePlayerModel> players, required final  List<String> myHand, required final  List<String> playedCards, required this.scoreUs, required this.scoreThem, required this.trump}): _players = players,_myHand = myHand,_playedCards = playedCards;
  factory _GameModel.fromJson(Map<String, dynamic> json) => _$GameModelFromJson(json);

@override final  String id;
 final  List<GamePlayerModel> _players;
@override List<GamePlayerModel> get players {
  if (_players is EqualUnmodifiableListView) return _players;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_players);
}

 final  List<String> _myHand;
@override List<String> get myHand {
  if (_myHand is EqualUnmodifiableListView) return _myHand;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_myHand);
}

 final  List<String> _playedCards;
@override List<String> get playedCards {
  if (_playedCards is EqualUnmodifiableListView) return _playedCards;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_playedCards);
}

@override final  int scoreUs;
@override final  int scoreThem;
@override final  String trump;

/// Create a copy of GameModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameModelCopyWith<_GameModel> get copyWith => __$GameModelCopyWithImpl<_GameModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GameModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameModel&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other._players, _players)&&const DeepCollectionEquality().equals(other._myHand, _myHand)&&const DeepCollectionEquality().equals(other._playedCards, _playedCards)&&(identical(other.scoreUs, scoreUs) || other.scoreUs == scoreUs)&&(identical(other.scoreThem, scoreThem) || other.scoreThem == scoreThem)&&(identical(other.trump, trump) || other.trump == trump));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(_players),const DeepCollectionEquality().hash(_myHand),const DeepCollectionEquality().hash(_playedCards),scoreUs,scoreThem,trump);

@override
String toString() {
  return 'GameModel(id: $id, players: $players, myHand: $myHand, playedCards: $playedCards, scoreUs: $scoreUs, scoreThem: $scoreThem, trump: $trump)';
}


}

/// @nodoc
abstract mixin class _$GameModelCopyWith<$Res> implements $GameModelCopyWith<$Res> {
  factory _$GameModelCopyWith(_GameModel value, $Res Function(_GameModel) _then) = __$GameModelCopyWithImpl;
@override @useResult
$Res call({
 String id, List<GamePlayerModel> players, List<String> myHand, List<String> playedCards, int scoreUs, int scoreThem, String trump
});




}
/// @nodoc
class __$GameModelCopyWithImpl<$Res>
    implements _$GameModelCopyWith<$Res> {
  __$GameModelCopyWithImpl(this._self, this._then);

  final _GameModel _self;
  final $Res Function(_GameModel) _then;

/// Create a copy of GameModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? players = null,Object? myHand = null,Object? playedCards = null,Object? scoreUs = null,Object? scoreThem = null,Object? trump = null,}) {
  return _then(_GameModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,players: null == players ? _self._players : players // ignore: cast_nullable_to_non_nullable
as List<GamePlayerModel>,myHand: null == myHand ? _self._myHand : myHand // ignore: cast_nullable_to_non_nullable
as List<String>,playedCards: null == playedCards ? _self._playedCards : playedCards // ignore: cast_nullable_to_non_nullable
as List<String>,scoreUs: null == scoreUs ? _self.scoreUs : scoreUs // ignore: cast_nullable_to_non_nullable
as int,scoreThem: null == scoreThem ? _self.scoreThem : scoreThem // ignore: cast_nullable_to_non_nullable
as int,trump: null == trump ? _self.trump : trump // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$GamePlayerModel {

 String get name; String get avatarUrl; String get team; bool get isActive; bool get isMuted; bool get hasCamera; bool get isTop;
/// Create a copy of GamePlayerModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GamePlayerModelCopyWith<GamePlayerModel> get copyWith => _$GamePlayerModelCopyWithImpl<GamePlayerModel>(this as GamePlayerModel, _$identity);

  /// Serializes this GamePlayerModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GamePlayerModel&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.team, team) || other.team == team)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isMuted, isMuted) || other.isMuted == isMuted)&&(identical(other.hasCamera, hasCamera) || other.hasCamera == hasCamera)&&(identical(other.isTop, isTop) || other.isTop == isTop));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,avatarUrl,team,isActive,isMuted,hasCamera,isTop);

@override
String toString() {
  return 'GamePlayerModel(name: $name, avatarUrl: $avatarUrl, team: $team, isActive: $isActive, isMuted: $isMuted, hasCamera: $hasCamera, isTop: $isTop)';
}


}

/// @nodoc
abstract mixin class $GamePlayerModelCopyWith<$Res>  {
  factory $GamePlayerModelCopyWith(GamePlayerModel value, $Res Function(GamePlayerModel) _then) = _$GamePlayerModelCopyWithImpl;
@useResult
$Res call({
 String name, String avatarUrl, String team, bool isActive, bool isMuted, bool hasCamera, bool isTop
});




}
/// @nodoc
class _$GamePlayerModelCopyWithImpl<$Res>
    implements $GamePlayerModelCopyWith<$Res> {
  _$GamePlayerModelCopyWithImpl(this._self, this._then);

  final GamePlayerModel _self;
  final $Res Function(GamePlayerModel) _then;

/// Create a copy of GamePlayerModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? avatarUrl = null,Object? team = null,Object? isActive = null,Object? isMuted = null,Object? hasCamera = null,Object? isTop = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,team: null == team ? _self.team : team // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isMuted: null == isMuted ? _self.isMuted : isMuted // ignore: cast_nullable_to_non_nullable
as bool,hasCamera: null == hasCamera ? _self.hasCamera : hasCamera // ignore: cast_nullable_to_non_nullable
as bool,isTop: null == isTop ? _self.isTop : isTop // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [GamePlayerModel].
extension GamePlayerModelPatterns on GamePlayerModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GamePlayerModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GamePlayerModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GamePlayerModel value)  $default,){
final _that = this;
switch (_that) {
case _GamePlayerModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GamePlayerModel value)?  $default,){
final _that = this;
switch (_that) {
case _GamePlayerModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String avatarUrl,  String team,  bool isActive,  bool isMuted,  bool hasCamera,  bool isTop)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GamePlayerModel() when $default != null:
return $default(_that.name,_that.avatarUrl,_that.team,_that.isActive,_that.isMuted,_that.hasCamera,_that.isTop);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String avatarUrl,  String team,  bool isActive,  bool isMuted,  bool hasCamera,  bool isTop)  $default,) {final _that = this;
switch (_that) {
case _GamePlayerModel():
return $default(_that.name,_that.avatarUrl,_that.team,_that.isActive,_that.isMuted,_that.hasCamera,_that.isTop);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String avatarUrl,  String team,  bool isActive,  bool isMuted,  bool hasCamera,  bool isTop)?  $default,) {final _that = this;
switch (_that) {
case _GamePlayerModel() when $default != null:
return $default(_that.name,_that.avatarUrl,_that.team,_that.isActive,_that.isMuted,_that.hasCamera,_that.isTop);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GamePlayerModel implements GamePlayerModel {
  const _GamePlayerModel({required this.name, required this.avatarUrl, required this.team, this.isActive = false, this.isMuted = false, this.hasCamera = true, this.isTop = false});
  factory _GamePlayerModel.fromJson(Map<String, dynamic> json) => _$GamePlayerModelFromJson(json);

@override final  String name;
@override final  String avatarUrl;
@override final  String team;
@override@JsonKey() final  bool isActive;
@override@JsonKey() final  bool isMuted;
@override@JsonKey() final  bool hasCamera;
@override@JsonKey() final  bool isTop;

/// Create a copy of GamePlayerModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GamePlayerModelCopyWith<_GamePlayerModel> get copyWith => __$GamePlayerModelCopyWithImpl<_GamePlayerModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GamePlayerModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GamePlayerModel&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.team, team) || other.team == team)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isMuted, isMuted) || other.isMuted == isMuted)&&(identical(other.hasCamera, hasCamera) || other.hasCamera == hasCamera)&&(identical(other.isTop, isTop) || other.isTop == isTop));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,avatarUrl,team,isActive,isMuted,hasCamera,isTop);

@override
String toString() {
  return 'GamePlayerModel(name: $name, avatarUrl: $avatarUrl, team: $team, isActive: $isActive, isMuted: $isMuted, hasCamera: $hasCamera, isTop: $isTop)';
}


}

/// @nodoc
abstract mixin class _$GamePlayerModelCopyWith<$Res> implements $GamePlayerModelCopyWith<$Res> {
  factory _$GamePlayerModelCopyWith(_GamePlayerModel value, $Res Function(_GamePlayerModel) _then) = __$GamePlayerModelCopyWithImpl;
@override @useResult
$Res call({
 String name, String avatarUrl, String team, bool isActive, bool isMuted, bool hasCamera, bool isTop
});




}
/// @nodoc
class __$GamePlayerModelCopyWithImpl<$Res>
    implements _$GamePlayerModelCopyWith<$Res> {
  __$GamePlayerModelCopyWithImpl(this._self, this._then);

  final _GamePlayerModel _self;
  final $Res Function(_GamePlayerModel) _then;

/// Create a copy of GamePlayerModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? avatarUrl = null,Object? team = null,Object? isActive = null,Object? isMuted = null,Object? hasCamera = null,Object? isTop = null,}) {
  return _then(_GamePlayerModel(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,team: null == team ? _self.team : team // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isMuted: null == isMuted ? _self.isMuted : isMuted // ignore: cast_nullable_to_non_nullable
as bool,hasCamera: null == hasCamera ? _self.hasCamera : hasCamera // ignore: cast_nullable_to_non_nullable
as bool,isTop: null == isTop ? _self.isTop : isTop // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
