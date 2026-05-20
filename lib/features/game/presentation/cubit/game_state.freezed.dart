// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GameState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GameState()';
}


}

/// @nodoc
class $GameStateCopyWith<$Res>  {
$GameStateCopyWith(GameState _, $Res Function(GameState) __);
}


/// Adds pattern-matching-related methods to [GameState].
extension GameStatePatterns on GameState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( GameInitial value)?  initial,TResult Function( GameLoading value)?  loading,TResult Function( GameLoaded value)?  loaded,TResult Function( GameError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case GameInitial() when initial != null:
return initial(_that);case GameLoading() when loading != null:
return loading(_that);case GameLoaded() when loaded != null:
return loaded(_that);case GameError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( GameInitial value)  initial,required TResult Function( GameLoading value)  loading,required TResult Function( GameLoaded value)  loaded,required TResult Function( GameError value)  error,}){
final _that = this;
switch (_that) {
case GameInitial():
return initial(_that);case GameLoading():
return loading(_that);case GameLoaded():
return loaded(_that);case GameError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( GameInitial value)?  initial,TResult? Function( GameLoading value)?  loading,TResult? Function( GameLoaded value)?  loaded,TResult? Function( GameError value)?  error,}){
final _that = this;
switch (_that) {
case GameInitial() when initial != null:
return initial(_that);case GameLoading() when loading != null:
return loading(_that);case GameLoaded() when loaded != null:
return loaded(_that);case GameError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( Game game,  bool controlsVisible,  int? selectedCardIndex)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case GameInitial() when initial != null:
return initial();case GameLoading() when loading != null:
return loading();case GameLoaded() when loaded != null:
return loaded(_that.game,_that.controlsVisible,_that.selectedCardIndex);case GameError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( Game game,  bool controlsVisible,  int? selectedCardIndex)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case GameInitial():
return initial();case GameLoading():
return loading();case GameLoaded():
return loaded(_that.game,_that.controlsVisible,_that.selectedCardIndex);case GameError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( Game game,  bool controlsVisible,  int? selectedCardIndex)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case GameInitial() when initial != null:
return initial();case GameLoading() when loading != null:
return loading();case GameLoaded() when loaded != null:
return loaded(_that.game,_that.controlsVisible,_that.selectedCardIndex);case GameError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class GameInitial implements GameState {
  const GameInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GameState.initial()';
}


}




/// @nodoc


class GameLoading implements GameState {
  const GameLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GameState.loading()';
}


}




/// @nodoc


class GameLoaded implements GameState {
  const GameLoaded({required this.game, this.controlsVisible = true, this.selectedCardIndex});
  

 final  Game game;
@JsonKey() final  bool controlsVisible;
 final  int? selectedCardIndex;

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameLoadedCopyWith<GameLoaded> get copyWith => _$GameLoadedCopyWithImpl<GameLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameLoaded&&(identical(other.game, game) || other.game == game)&&(identical(other.controlsVisible, controlsVisible) || other.controlsVisible == controlsVisible)&&(identical(other.selectedCardIndex, selectedCardIndex) || other.selectedCardIndex == selectedCardIndex));
}


@override
int get hashCode => Object.hash(runtimeType,game,controlsVisible,selectedCardIndex);

@override
String toString() {
  return 'GameState.loaded(game: $game, controlsVisible: $controlsVisible, selectedCardIndex: $selectedCardIndex)';
}


}

/// @nodoc
abstract mixin class $GameLoadedCopyWith<$Res> implements $GameStateCopyWith<$Res> {
  factory $GameLoadedCopyWith(GameLoaded value, $Res Function(GameLoaded) _then) = _$GameLoadedCopyWithImpl;
@useResult
$Res call({
 Game game, bool controlsVisible, int? selectedCardIndex
});




}
/// @nodoc
class _$GameLoadedCopyWithImpl<$Res>
    implements $GameLoadedCopyWith<$Res> {
  _$GameLoadedCopyWithImpl(this._self, this._then);

  final GameLoaded _self;
  final $Res Function(GameLoaded) _then;

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? game = null,Object? controlsVisible = null,Object? selectedCardIndex = freezed,}) {
  return _then(GameLoaded(
game: null == game ? _self.game : game // ignore: cast_nullable_to_non_nullable
as Game,controlsVisible: null == controlsVisible ? _self.controlsVisible : controlsVisible // ignore: cast_nullable_to_non_nullable
as bool,selectedCardIndex: freezed == selectedCardIndex ? _self.selectedCardIndex : selectedCardIndex // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc


class GameError implements GameState {
  const GameError({required this.message});
  

 final  String message;

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameErrorCopyWith<GameError> get copyWith => _$GameErrorCopyWithImpl<GameError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'GameState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $GameErrorCopyWith<$Res> implements $GameStateCopyWith<$Res> {
  factory $GameErrorCopyWith(GameError value, $Res Function(GameError) _then) = _$GameErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$GameErrorCopyWithImpl<$Res>
    implements $GameErrorCopyWith<$Res> {
  _$GameErrorCopyWithImpl(this._self, this._then);

  final GameError _self;
  final $Res Function(GameError) _then;

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(GameError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
