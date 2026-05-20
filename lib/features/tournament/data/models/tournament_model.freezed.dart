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
mixin _$TournamentModel {

 String get id; String get name; String get prize; String get participants; String get status; String get date; bool get isPremium; bool get isJoined;
/// Create a copy of TournamentModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TournamentModelCopyWith<TournamentModel> get copyWith => _$TournamentModelCopyWithImpl<TournamentModel>(this as TournamentModel, _$identity);

  /// Serializes this TournamentModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TournamentModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.prize, prize) || other.prize == prize)&&(identical(other.participants, participants) || other.participants == participants)&&(identical(other.status, status) || other.status == status)&&(identical(other.date, date) || other.date == date)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&(identical(other.isJoined, isJoined) || other.isJoined == isJoined));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,prize,participants,status,date,isPremium,isJoined);

@override
String toString() {
  return 'TournamentModel(id: $id, name: $name, prize: $prize, participants: $participants, status: $status, date: $date, isPremium: $isPremium, isJoined: $isJoined)';
}


}

/// @nodoc
abstract mixin class $TournamentModelCopyWith<$Res>  {
  factory $TournamentModelCopyWith(TournamentModel value, $Res Function(TournamentModel) _then) = _$TournamentModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String prize, String participants, String status, String date, bool isPremium, bool isJoined
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? prize = null,Object? participants = null,Object? status = null,Object? date = null,Object? isPremium = null,Object? isJoined = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,prize: null == prize ? _self.prize : prize // ignore: cast_nullable_to_non_nullable
as String,participants: null == participants ? _self.participants : participants // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,isJoined: null == isJoined ? _self.isJoined : isJoined // ignore: cast_nullable_to_non_nullable
as bool,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String prize,  String participants,  String status,  String date,  bool isPremium,  bool isJoined)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TournamentModel() when $default != null:
return $default(_that.id,_that.name,_that.prize,_that.participants,_that.status,_that.date,_that.isPremium,_that.isJoined);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String prize,  String participants,  String status,  String date,  bool isPremium,  bool isJoined)  $default,) {final _that = this;
switch (_that) {
case _TournamentModel():
return $default(_that.id,_that.name,_that.prize,_that.participants,_that.status,_that.date,_that.isPremium,_that.isJoined);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String prize,  String participants,  String status,  String date,  bool isPremium,  bool isJoined)?  $default,) {final _that = this;
switch (_that) {
case _TournamentModel() when $default != null:
return $default(_that.id,_that.name,_that.prize,_that.participants,_that.status,_that.date,_that.isPremium,_that.isJoined);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TournamentModel implements TournamentModel {
  const _TournamentModel({required this.id, required this.name, required this.prize, required this.participants, required this.status, required this.date, this.isPremium = false, this.isJoined = false});
  factory _TournamentModel.fromJson(Map<String, dynamic> json) => _$TournamentModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  String prize;
@override final  String participants;
@override final  String status;
@override final  String date;
@override@JsonKey() final  bool isPremium;
@override@JsonKey() final  bool isJoined;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TournamentModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.prize, prize) || other.prize == prize)&&(identical(other.participants, participants) || other.participants == participants)&&(identical(other.status, status) || other.status == status)&&(identical(other.date, date) || other.date == date)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&(identical(other.isJoined, isJoined) || other.isJoined == isJoined));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,prize,participants,status,date,isPremium,isJoined);

@override
String toString() {
  return 'TournamentModel(id: $id, name: $name, prize: $prize, participants: $participants, status: $status, date: $date, isPremium: $isPremium, isJoined: $isJoined)';
}


}

/// @nodoc
abstract mixin class _$TournamentModelCopyWith<$Res> implements $TournamentModelCopyWith<$Res> {
  factory _$TournamentModelCopyWith(_TournamentModel value, $Res Function(_TournamentModel) _then) = __$TournamentModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String prize, String participants, String status, String date, bool isPremium, bool isJoined
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? prize = null,Object? participants = null,Object? status = null,Object? date = null,Object? isPremium = null,Object? isJoined = null,}) {
  return _then(_TournamentModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,prize: null == prize ? _self.prize : prize // ignore: cast_nullable_to_non_nullable
as String,participants: null == participants ? _self.participants : participants // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,isJoined: null == isJoined ? _self.isJoined : isJoined // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
