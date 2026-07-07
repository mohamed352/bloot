// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'room_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RoomState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoomState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RoomState()';
}


}

/// @nodoc
class $RoomStateCopyWith<$Res>  {
$RoomStateCopyWith(RoomState _, $Res Function(RoomState) __);
}


/// Adds pattern-matching-related methods to [RoomState].
extension RoomStatePatterns on RoomState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( RoomInitial value)?  initial,TResult Function( RoomLoading value)?  loading,TResult Function( RoomLoaded value)?  loaded,TResult Function( RoomCreated value)?  created,TResult Function( RoomGameStarted value)?  gameStarted,TResult Function( RoomPublicListLoaded value)?  publicListLoaded,TResult Function( RoomError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case RoomInitial() when initial != null:
return initial(_that);case RoomLoading() when loading != null:
return loading(_that);case RoomLoaded() when loaded != null:
return loaded(_that);case RoomCreated() when created != null:
return created(_that);case RoomGameStarted() when gameStarted != null:
return gameStarted(_that);case RoomPublicListLoaded() when publicListLoaded != null:
return publicListLoaded(_that);case RoomError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( RoomInitial value)  initial,required TResult Function( RoomLoading value)  loading,required TResult Function( RoomLoaded value)  loaded,required TResult Function( RoomCreated value)  created,required TResult Function( RoomGameStarted value)  gameStarted,required TResult Function( RoomPublicListLoaded value)  publicListLoaded,required TResult Function( RoomError value)  error,}){
final _that = this;
switch (_that) {
case RoomInitial():
return initial(_that);case RoomLoading():
return loading(_that);case RoomLoaded():
return loaded(_that);case RoomCreated():
return created(_that);case RoomGameStarted():
return gameStarted(_that);case RoomPublicListLoaded():
return publicListLoaded(_that);case RoomError():
return error(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( RoomInitial value)?  initial,TResult? Function( RoomLoading value)?  loading,TResult? Function( RoomLoaded value)?  loaded,TResult? Function( RoomCreated value)?  created,TResult? Function( RoomGameStarted value)?  gameStarted,TResult? Function( RoomPublicListLoaded value)?  publicListLoaded,TResult? Function( RoomError value)?  error,}){
final _that = this;
switch (_that) {
case RoomInitial() when initial != null:
return initial(_that);case RoomLoading() when loading != null:
return loading(_that);case RoomLoaded() when loaded != null:
return loaded(_that);case RoomCreated() when created != null:
return created(_that);case RoomGameStarted() when gameStarted != null:
return gameStarted(_that);case RoomPublicListLoaded() when publicListLoaded != null:
return publicListLoaded(_that);case RoomError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( Room room)?  loaded,TResult Function( Room room)?  created,TResult Function( String gameId)?  gameStarted,TResult Function( List<Room> rooms)?  publicListLoaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case RoomInitial() when initial != null:
return initial();case RoomLoading() when loading != null:
return loading();case RoomLoaded() when loaded != null:
return loaded(_that.room);case RoomCreated() when created != null:
return created(_that.room);case RoomGameStarted() when gameStarted != null:
return gameStarted(_that.gameId);case RoomPublicListLoaded() when publicListLoaded != null:
return publicListLoaded(_that.rooms);case RoomError() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( Room room)  loaded,required TResult Function( Room room)  created,required TResult Function( String gameId)  gameStarted,required TResult Function( List<Room> rooms)  publicListLoaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case RoomInitial():
return initial();case RoomLoading():
return loading();case RoomLoaded():
return loaded(_that.room);case RoomCreated():
return created(_that.room);case RoomGameStarted():
return gameStarted(_that.gameId);case RoomPublicListLoaded():
return publicListLoaded(_that.rooms);case RoomError():
return error(_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( Room room)?  loaded,TResult? Function( Room room)?  created,TResult? Function( String gameId)?  gameStarted,TResult? Function( List<Room> rooms)?  publicListLoaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case RoomInitial() when initial != null:
return initial();case RoomLoading() when loading != null:
return loading();case RoomLoaded() when loaded != null:
return loaded(_that.room);case RoomCreated() when created != null:
return created(_that.room);case RoomGameStarted() when gameStarted != null:
return gameStarted(_that.gameId);case RoomPublicListLoaded() when publicListLoaded != null:
return publicListLoaded(_that.rooms);case RoomError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class RoomInitial implements RoomState {
  const RoomInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoomInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RoomState.initial()';
}


}




/// @nodoc


class RoomLoading implements RoomState {
  const RoomLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoomLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RoomState.loading()';
}


}




/// @nodoc


class RoomLoaded implements RoomState {
  const RoomLoaded({required this.room});
  

 final  Room room;

/// Create a copy of RoomState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoomLoadedCopyWith<RoomLoaded> get copyWith => _$RoomLoadedCopyWithImpl<RoomLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoomLoaded&&(identical(other.room, room) || other.room == room));
}


@override
int get hashCode => Object.hash(runtimeType,room);

@override
String toString() {
  return 'RoomState.loaded(room: $room)';
}


}

/// @nodoc
abstract mixin class $RoomLoadedCopyWith<$Res> implements $RoomStateCopyWith<$Res> {
  factory $RoomLoadedCopyWith(RoomLoaded value, $Res Function(RoomLoaded) _then) = _$RoomLoadedCopyWithImpl;
@useResult
$Res call({
 Room room
});




}
/// @nodoc
class _$RoomLoadedCopyWithImpl<$Res>
    implements $RoomLoadedCopyWith<$Res> {
  _$RoomLoadedCopyWithImpl(this._self, this._then);

  final RoomLoaded _self;
  final $Res Function(RoomLoaded) _then;

/// Create a copy of RoomState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? room = null,}) {
  return _then(RoomLoaded(
room: null == room ? _self.room : room // ignore: cast_nullable_to_non_nullable
as Room,
  ));
}


}

/// @nodoc


class RoomCreated implements RoomState {
  const RoomCreated({required this.room});
  

 final  Room room;

/// Create a copy of RoomState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoomCreatedCopyWith<RoomCreated> get copyWith => _$RoomCreatedCopyWithImpl<RoomCreated>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoomCreated&&(identical(other.room, room) || other.room == room));
}


@override
int get hashCode => Object.hash(runtimeType,room);

@override
String toString() {
  return 'RoomState.created(room: $room)';
}


}

/// @nodoc
abstract mixin class $RoomCreatedCopyWith<$Res> implements $RoomStateCopyWith<$Res> {
  factory $RoomCreatedCopyWith(RoomCreated value, $Res Function(RoomCreated) _then) = _$RoomCreatedCopyWithImpl;
@useResult
$Res call({
 Room room
});




}
/// @nodoc
class _$RoomCreatedCopyWithImpl<$Res>
    implements $RoomCreatedCopyWith<$Res> {
  _$RoomCreatedCopyWithImpl(this._self, this._then);

  final RoomCreated _self;
  final $Res Function(RoomCreated) _then;

/// Create a copy of RoomState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? room = null,}) {
  return _then(RoomCreated(
room: null == room ? _self.room : room // ignore: cast_nullable_to_non_nullable
as Room,
  ));
}


}

/// @nodoc


class RoomGameStarted implements RoomState {
  const RoomGameStarted({required this.gameId});
  

 final  String gameId;

/// Create a copy of RoomState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoomGameStartedCopyWith<RoomGameStarted> get copyWith => _$RoomGameStartedCopyWithImpl<RoomGameStarted>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoomGameStarted&&(identical(other.gameId, gameId) || other.gameId == gameId));
}


@override
int get hashCode => Object.hash(runtimeType,gameId);

@override
String toString() {
  return 'RoomState.gameStarted(gameId: $gameId)';
}


}

/// @nodoc
abstract mixin class $RoomGameStartedCopyWith<$Res> implements $RoomStateCopyWith<$Res> {
  factory $RoomGameStartedCopyWith(RoomGameStarted value, $Res Function(RoomGameStarted) _then) = _$RoomGameStartedCopyWithImpl;
@useResult
$Res call({
 String gameId
});




}
/// @nodoc
class _$RoomGameStartedCopyWithImpl<$Res>
    implements $RoomGameStartedCopyWith<$Res> {
  _$RoomGameStartedCopyWithImpl(this._self, this._then);

  final RoomGameStarted _self;
  final $Res Function(RoomGameStarted) _then;

/// Create a copy of RoomState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? gameId = null,}) {
  return _then(RoomGameStarted(
gameId: null == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class RoomPublicListLoaded implements RoomState {
  const RoomPublicListLoaded({required final  List<Room> rooms}): _rooms = rooms;
  

 final  List<Room> _rooms;
 List<Room> get rooms {
  if (_rooms is EqualUnmodifiableListView) return _rooms;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rooms);
}


/// Create a copy of RoomState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoomPublicListLoadedCopyWith<RoomPublicListLoaded> get copyWith => _$RoomPublicListLoadedCopyWithImpl<RoomPublicListLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoomPublicListLoaded&&const DeepCollectionEquality().equals(other._rooms, _rooms));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_rooms));

@override
String toString() {
  return 'RoomState.publicListLoaded(rooms: $rooms)';
}


}

/// @nodoc
abstract mixin class $RoomPublicListLoadedCopyWith<$Res> implements $RoomStateCopyWith<$Res> {
  factory $RoomPublicListLoadedCopyWith(RoomPublicListLoaded value, $Res Function(RoomPublicListLoaded) _then) = _$RoomPublicListLoadedCopyWithImpl;
@useResult
$Res call({
 List<Room> rooms
});




}
/// @nodoc
class _$RoomPublicListLoadedCopyWithImpl<$Res>
    implements $RoomPublicListLoadedCopyWith<$Res> {
  _$RoomPublicListLoadedCopyWithImpl(this._self, this._then);

  final RoomPublicListLoaded _self;
  final $Res Function(RoomPublicListLoaded) _then;

/// Create a copy of RoomState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? rooms = null,}) {
  return _then(RoomPublicListLoaded(
rooms: null == rooms ? _self._rooms : rooms // ignore: cast_nullable_to_non_nullable
as List<Room>,
  ));
}


}

/// @nodoc


class RoomError implements RoomState {
  const RoomError({required this.message});
  

 final  String message;

/// Create a copy of RoomState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoomErrorCopyWith<RoomError> get copyWith => _$RoomErrorCopyWithImpl<RoomError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoomError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'RoomState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $RoomErrorCopyWith<$Res> implements $RoomStateCopyWith<$Res> {
  factory $RoomErrorCopyWith(RoomError value, $Res Function(RoomError) _then) = _$RoomErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$RoomErrorCopyWithImpl<$Res>
    implements $RoomErrorCopyWith<$Res> {
  _$RoomErrorCopyWithImpl(this._self, this._then);

  final RoomError _self;
  final $Res Function(RoomError) _then;

/// Create a copy of RoomState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(RoomError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
