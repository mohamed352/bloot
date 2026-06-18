// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_history_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GameHistoryModel {

 String get id; bool get won; String get score; String get type; int? get durationMinutes; DateTime? get playedAt;
/// Create a copy of GameHistoryModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameHistoryModelCopyWith<GameHistoryModel> get copyWith => _$GameHistoryModelCopyWithImpl<GameHistoryModel>(this as GameHistoryModel, _$identity);

  /// Serializes this GameHistoryModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameHistoryModel&&(identical(other.id, id) || other.id == id)&&(identical(other.won, won) || other.won == won)&&(identical(other.score, score) || other.score == score)&&(identical(other.type, type) || other.type == type)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.playedAt, playedAt) || other.playedAt == playedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,won,score,type,durationMinutes,playedAt);

@override
String toString() {
  return 'GameHistoryModel(id: $id, won: $won, score: $score, type: $type, durationMinutes: $durationMinutes, playedAt: $playedAt)';
}


}

/// @nodoc
abstract mixin class $GameHistoryModelCopyWith<$Res>  {
  factory $GameHistoryModelCopyWith(GameHistoryModel value, $Res Function(GameHistoryModel) _then) = _$GameHistoryModelCopyWithImpl;
@useResult
$Res call({
 String id, bool won, String score, String type, int? durationMinutes, DateTime? playedAt
});




}
/// @nodoc
class _$GameHistoryModelCopyWithImpl<$Res>
    implements $GameHistoryModelCopyWith<$Res> {
  _$GameHistoryModelCopyWithImpl(this._self, this._then);

  final GameHistoryModel _self;
  final $Res Function(GameHistoryModel) _then;

/// Create a copy of GameHistoryModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? won = null,Object? score = null,Object? type = null,Object? durationMinutes = freezed,Object? playedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,won: null == won ? _self.won : won // ignore: cast_nullable_to_non_nullable
as bool,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,durationMinutes: freezed == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int?,playedAt: freezed == playedAt ? _self.playedAt : playedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [GameHistoryModel].
extension GameHistoryModelPatterns on GameHistoryModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GameHistoryModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GameHistoryModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GameHistoryModel value)  $default,){
final _that = this;
switch (_that) {
case _GameHistoryModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GameHistoryModel value)?  $default,){
final _that = this;
switch (_that) {
case _GameHistoryModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  bool won,  String score,  String type,  int? durationMinutes,  DateTime? playedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GameHistoryModel() when $default != null:
return $default(_that.id,_that.won,_that.score,_that.type,_that.durationMinutes,_that.playedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  bool won,  String score,  String type,  int? durationMinutes,  DateTime? playedAt)  $default,) {final _that = this;
switch (_that) {
case _GameHistoryModel():
return $default(_that.id,_that.won,_that.score,_that.type,_that.durationMinutes,_that.playedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  bool won,  String score,  String type,  int? durationMinutes,  DateTime? playedAt)?  $default,) {final _that = this;
switch (_that) {
case _GameHistoryModel() when $default != null:
return $default(_that.id,_that.won,_that.score,_that.type,_that.durationMinutes,_that.playedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GameHistoryModel implements GameHistoryModel {
  const _GameHistoryModel({required this.id, required this.won, required this.score, required this.type, this.durationMinutes, this.playedAt});
  factory _GameHistoryModel.fromJson(Map<String, dynamic> json) => _$GameHistoryModelFromJson(json);

@override final  String id;
@override final  bool won;
@override final  String score;
@override final  String type;
@override final  int? durationMinutes;
@override final  DateTime? playedAt;

/// Create a copy of GameHistoryModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameHistoryModelCopyWith<_GameHistoryModel> get copyWith => __$GameHistoryModelCopyWithImpl<_GameHistoryModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GameHistoryModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameHistoryModel&&(identical(other.id, id) || other.id == id)&&(identical(other.won, won) || other.won == won)&&(identical(other.score, score) || other.score == score)&&(identical(other.type, type) || other.type == type)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.playedAt, playedAt) || other.playedAt == playedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,won,score,type,durationMinutes,playedAt);

@override
String toString() {
  return 'GameHistoryModel(id: $id, won: $won, score: $score, type: $type, durationMinutes: $durationMinutes, playedAt: $playedAt)';
}


}

/// @nodoc
abstract mixin class _$GameHistoryModelCopyWith<$Res> implements $GameHistoryModelCopyWith<$Res> {
  factory _$GameHistoryModelCopyWith(_GameHistoryModel value, $Res Function(_GameHistoryModel) _then) = __$GameHistoryModelCopyWithImpl;
@override @useResult
$Res call({
 String id, bool won, String score, String type, int? durationMinutes, DateTime? playedAt
});




}
/// @nodoc
class __$GameHistoryModelCopyWithImpl<$Res>
    implements _$GameHistoryModelCopyWith<$Res> {
  __$GameHistoryModelCopyWithImpl(this._self, this._then);

  final _GameHistoryModel _self;
  final $Res Function(_GameHistoryModel) _then;

/// Create a copy of GameHistoryModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? won = null,Object? score = null,Object? type = null,Object? durationMinutes = freezed,Object? playedAt = freezed,}) {
  return _then(_GameHistoryModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,won: null == won ? _self.won : won // ignore: cast_nullable_to_non_nullable
as bool,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,durationMinutes: freezed == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int?,playedAt: freezed == playedAt ? _self.playedAt : playedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
