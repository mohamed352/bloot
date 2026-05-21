// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tournament_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TournamentState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TournamentState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TournamentState()';
}


}

/// @nodoc
class $TournamentStateCopyWith<$Res>  {
$TournamentStateCopyWith(TournamentState _, $Res Function(TournamentState) __);
}


/// Adds pattern-matching-related methods to [TournamentState].
extension TournamentStatePatterns on TournamentState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( TournamentInitial value)?  initial,TResult Function( TournamentLoading value)?  loading,TResult Function( TournamentLoaded value)?  loaded,TResult Function( TournamentError value)?  error,TResult Function( TournamentJoining value)?  joining,TResult Function( TournamentJoined value)?  joined,TResult Function( TournamentJoinError value)?  joinError,required TResult orElse(),}){
final _that = this;
switch (_that) {
case TournamentInitial() when initial != null:
return initial(_that);case TournamentLoading() when loading != null:
return loading(_that);case TournamentLoaded() when loaded != null:
return loaded(_that);case TournamentError() when error != null:
return error(_that);case TournamentJoining() when joining != null:
return joining(_that);case TournamentJoined() when joined != null:
return joined(_that);case TournamentJoinError() when joinError != null:
return joinError(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( TournamentInitial value)  initial,required TResult Function( TournamentLoading value)  loading,required TResult Function( TournamentLoaded value)  loaded,required TResult Function( TournamentError value)  error,required TResult Function( TournamentJoining value)  joining,required TResult Function( TournamentJoined value)  joined,required TResult Function( TournamentJoinError value)  joinError,}){
final _that = this;
switch (_that) {
case TournamentInitial():
return initial(_that);case TournamentLoading():
return loading(_that);case TournamentLoaded():
return loaded(_that);case TournamentError():
return error(_that);case TournamentJoining():
return joining(_that);case TournamentJoined():
return joined(_that);case TournamentJoinError():
return joinError(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( TournamentInitial value)?  initial,TResult? Function( TournamentLoading value)?  loading,TResult? Function( TournamentLoaded value)?  loaded,TResult? Function( TournamentError value)?  error,TResult? Function( TournamentJoining value)?  joining,TResult? Function( TournamentJoined value)?  joined,TResult? Function( TournamentJoinError value)?  joinError,}){
final _that = this;
switch (_that) {
case TournamentInitial() when initial != null:
return initial(_that);case TournamentLoading() when loading != null:
return loading(_that);case TournamentLoaded() when loaded != null:
return loaded(_that);case TournamentError() when error != null:
return error(_that);case TournamentJoining() when joining != null:
return joining(_that);case TournamentJoined() when joined != null:
return joined(_that);case TournamentJoinError() when joinError != null:
return joinError(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<Tournament> tournaments,  int selectedFilterIndex)?  loaded,TResult Function( String message)?  error,TResult Function()?  joining,TResult Function( String tournamentId)?  joined,TResult Function( String message)?  joinError,required TResult orElse(),}) {final _that = this;
switch (_that) {
case TournamentInitial() when initial != null:
return initial();case TournamentLoading() when loading != null:
return loading();case TournamentLoaded() when loaded != null:
return loaded(_that.tournaments,_that.selectedFilterIndex);case TournamentError() when error != null:
return error(_that.message);case TournamentJoining() when joining != null:
return joining();case TournamentJoined() when joined != null:
return joined(_that.tournamentId);case TournamentJoinError() when joinError != null:
return joinError(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<Tournament> tournaments,  int selectedFilterIndex)  loaded,required TResult Function( String message)  error,required TResult Function()  joining,required TResult Function( String tournamentId)  joined,required TResult Function( String message)  joinError,}) {final _that = this;
switch (_that) {
case TournamentInitial():
return initial();case TournamentLoading():
return loading();case TournamentLoaded():
return loaded(_that.tournaments,_that.selectedFilterIndex);case TournamentError():
return error(_that.message);case TournamentJoining():
return joining();case TournamentJoined():
return joined(_that.tournamentId);case TournamentJoinError():
return joinError(_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<Tournament> tournaments,  int selectedFilterIndex)?  loaded,TResult? Function( String message)?  error,TResult? Function()?  joining,TResult? Function( String tournamentId)?  joined,TResult? Function( String message)?  joinError,}) {final _that = this;
switch (_that) {
case TournamentInitial() when initial != null:
return initial();case TournamentLoading() when loading != null:
return loading();case TournamentLoaded() when loaded != null:
return loaded(_that.tournaments,_that.selectedFilterIndex);case TournamentError() when error != null:
return error(_that.message);case TournamentJoining() when joining != null:
return joining();case TournamentJoined() when joined != null:
return joined(_that.tournamentId);case TournamentJoinError() when joinError != null:
return joinError(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class TournamentInitial implements TournamentState {
  const TournamentInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TournamentInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TournamentState.initial()';
}


}




/// @nodoc


class TournamentLoading implements TournamentState {
  const TournamentLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TournamentLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TournamentState.loading()';
}


}




/// @nodoc


class TournamentLoaded implements TournamentState {
  const TournamentLoaded({required final  List<Tournament> tournaments, this.selectedFilterIndex = 0}): _tournaments = tournaments;
  

 final  List<Tournament> _tournaments;
 List<Tournament> get tournaments {
  if (_tournaments is EqualUnmodifiableListView) return _tournaments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tournaments);
}

@JsonKey() final  int selectedFilterIndex;

/// Create a copy of TournamentState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TournamentLoadedCopyWith<TournamentLoaded> get copyWith => _$TournamentLoadedCopyWithImpl<TournamentLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TournamentLoaded&&const DeepCollectionEquality().equals(other._tournaments, _tournaments)&&(identical(other.selectedFilterIndex, selectedFilterIndex) || other.selectedFilterIndex == selectedFilterIndex));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_tournaments),selectedFilterIndex);

@override
String toString() {
  return 'TournamentState.loaded(tournaments: $tournaments, selectedFilterIndex: $selectedFilterIndex)';
}


}

/// @nodoc
abstract mixin class $TournamentLoadedCopyWith<$Res> implements $TournamentStateCopyWith<$Res> {
  factory $TournamentLoadedCopyWith(TournamentLoaded value, $Res Function(TournamentLoaded) _then) = _$TournamentLoadedCopyWithImpl;
@useResult
$Res call({
 List<Tournament> tournaments, int selectedFilterIndex
});




}
/// @nodoc
class _$TournamentLoadedCopyWithImpl<$Res>
    implements $TournamentLoadedCopyWith<$Res> {
  _$TournamentLoadedCopyWithImpl(this._self, this._then);

  final TournamentLoaded _self;
  final $Res Function(TournamentLoaded) _then;

/// Create a copy of TournamentState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? tournaments = null,Object? selectedFilterIndex = null,}) {
  return _then(TournamentLoaded(
tournaments: null == tournaments ? _self._tournaments : tournaments // ignore: cast_nullable_to_non_nullable
as List<Tournament>,selectedFilterIndex: null == selectedFilterIndex ? _self.selectedFilterIndex : selectedFilterIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class TournamentError implements TournamentState {
  const TournamentError({required this.message});
  

 final  String message;

/// Create a copy of TournamentState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TournamentErrorCopyWith<TournamentError> get copyWith => _$TournamentErrorCopyWithImpl<TournamentError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TournamentError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'TournamentState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $TournamentErrorCopyWith<$Res> implements $TournamentStateCopyWith<$Res> {
  factory $TournamentErrorCopyWith(TournamentError value, $Res Function(TournamentError) _then) = _$TournamentErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$TournamentErrorCopyWithImpl<$Res>
    implements $TournamentErrorCopyWith<$Res> {
  _$TournamentErrorCopyWithImpl(this._self, this._then);

  final TournamentError _self;
  final $Res Function(TournamentError) _then;

/// Create a copy of TournamentState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(TournamentError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class TournamentJoining implements TournamentState {
  const TournamentJoining();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TournamentJoining);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TournamentState.joining()';
}


}




/// @nodoc


class TournamentJoined implements TournamentState {
  const TournamentJoined({required this.tournamentId});
  

 final  String tournamentId;

/// Create a copy of TournamentState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TournamentJoinedCopyWith<TournamentJoined> get copyWith => _$TournamentJoinedCopyWithImpl<TournamentJoined>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TournamentJoined&&(identical(other.tournamentId, tournamentId) || other.tournamentId == tournamentId));
}


@override
int get hashCode => Object.hash(runtimeType,tournamentId);

@override
String toString() {
  return 'TournamentState.joined(tournamentId: $tournamentId)';
}


}

/// @nodoc
abstract mixin class $TournamentJoinedCopyWith<$Res> implements $TournamentStateCopyWith<$Res> {
  factory $TournamentJoinedCopyWith(TournamentJoined value, $Res Function(TournamentJoined) _then) = _$TournamentJoinedCopyWithImpl;
@useResult
$Res call({
 String tournamentId
});




}
/// @nodoc
class _$TournamentJoinedCopyWithImpl<$Res>
    implements $TournamentJoinedCopyWith<$Res> {
  _$TournamentJoinedCopyWithImpl(this._self, this._then);

  final TournamentJoined _self;
  final $Res Function(TournamentJoined) _then;

/// Create a copy of TournamentState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? tournamentId = null,}) {
  return _then(TournamentJoined(
tournamentId: null == tournamentId ? _self.tournamentId : tournamentId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class TournamentJoinError implements TournamentState {
  const TournamentJoinError({required this.message});
  

 final  String message;

/// Create a copy of TournamentState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TournamentJoinErrorCopyWith<TournamentJoinError> get copyWith => _$TournamentJoinErrorCopyWithImpl<TournamentJoinError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TournamentJoinError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'TournamentState.joinError(message: $message)';
}


}

/// @nodoc
abstract mixin class $TournamentJoinErrorCopyWith<$Res> implements $TournamentStateCopyWith<$Res> {
  factory $TournamentJoinErrorCopyWith(TournamentJoinError value, $Res Function(TournamentJoinError) _then) = _$TournamentJoinErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$TournamentJoinErrorCopyWithImpl<$Res>
    implements $TournamentJoinErrorCopyWith<$Res> {
  _$TournamentJoinErrorCopyWithImpl(this._self, this._then);

  final TournamentJoinError _self;
  final $Res Function(TournamentJoinError) _then;

/// Create a copy of TournamentState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(TournamentJoinError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
