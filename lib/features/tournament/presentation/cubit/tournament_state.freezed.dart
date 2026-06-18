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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( TournamentInitial value)?  initial,TResult Function( TournamentLoading value)?  loading,TResult Function( TournamentLoaded value)?  loaded,TResult Function( TournamentError value)?  error,TResult Function( TournamentDetailLoading value)?  detailLoading,TResult Function( TournamentDetailLoaded value)?  detailLoaded,TResult Function( TournamentDetailError value)?  detailError,TResult Function( TournamentJoining value)?  joining,TResult Function( TournamentJoined value)?  joined,TResult Function( TournamentJoinError value)?  joinError,TResult Function( TournamentMatchReady value)?  matchReady,required TResult orElse(),}){
final _that = this;
switch (_that) {
case TournamentInitial() when initial != null:
return initial(_that);case TournamentLoading() when loading != null:
return loading(_that);case TournamentLoaded() when loaded != null:
return loaded(_that);case TournamentError() when error != null:
return error(_that);case TournamentDetailLoading() when detailLoading != null:
return detailLoading(_that);case TournamentDetailLoaded() when detailLoaded != null:
return detailLoaded(_that);case TournamentDetailError() when detailError != null:
return detailError(_that);case TournamentJoining() when joining != null:
return joining(_that);case TournamentJoined() when joined != null:
return joined(_that);case TournamentJoinError() when joinError != null:
return joinError(_that);case TournamentMatchReady() when matchReady != null:
return matchReady(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( TournamentInitial value)  initial,required TResult Function( TournamentLoading value)  loading,required TResult Function( TournamentLoaded value)  loaded,required TResult Function( TournamentError value)  error,required TResult Function( TournamentDetailLoading value)  detailLoading,required TResult Function( TournamentDetailLoaded value)  detailLoaded,required TResult Function( TournamentDetailError value)  detailError,required TResult Function( TournamentJoining value)  joining,required TResult Function( TournamentJoined value)  joined,required TResult Function( TournamentJoinError value)  joinError,required TResult Function( TournamentMatchReady value)  matchReady,}){
final _that = this;
switch (_that) {
case TournamentInitial():
return initial(_that);case TournamentLoading():
return loading(_that);case TournamentLoaded():
return loaded(_that);case TournamentError():
return error(_that);case TournamentDetailLoading():
return detailLoading(_that);case TournamentDetailLoaded():
return detailLoaded(_that);case TournamentDetailError():
return detailError(_that);case TournamentJoining():
return joining(_that);case TournamentJoined():
return joined(_that);case TournamentJoinError():
return joinError(_that);case TournamentMatchReady():
return matchReady(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( TournamentInitial value)?  initial,TResult? Function( TournamentLoading value)?  loading,TResult? Function( TournamentLoaded value)?  loaded,TResult? Function( TournamentError value)?  error,TResult? Function( TournamentDetailLoading value)?  detailLoading,TResult? Function( TournamentDetailLoaded value)?  detailLoaded,TResult? Function( TournamentDetailError value)?  detailError,TResult? Function( TournamentJoining value)?  joining,TResult? Function( TournamentJoined value)?  joined,TResult? Function( TournamentJoinError value)?  joinError,TResult? Function( TournamentMatchReady value)?  matchReady,}){
final _that = this;
switch (_that) {
case TournamentInitial() when initial != null:
return initial(_that);case TournamentLoading() when loading != null:
return loading(_that);case TournamentLoaded() when loaded != null:
return loaded(_that);case TournamentError() when error != null:
return error(_that);case TournamentDetailLoading() when detailLoading != null:
return detailLoading(_that);case TournamentDetailLoaded() when detailLoaded != null:
return detailLoaded(_that);case TournamentDetailError() when detailError != null:
return detailError(_that);case TournamentJoining() when joining != null:
return joining(_that);case TournamentJoined() when joined != null:
return joined(_that);case TournamentJoinError() when joinError != null:
return joinError(_that);case TournamentMatchReady() when matchReady != null:
return matchReady(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<Tournament> tournaments,  int selectedFilterIndex)?  loaded,TResult Function( String message)?  error,TResult Function()?  detailLoading,TResult Function( Tournament tournament)?  detailLoaded,TResult Function( String message)?  detailError,TResult Function()?  joining,TResult Function( String tournamentId)?  joined,TResult Function( String message)?  joinError,TResult Function( String tournamentId,  String roomId,  String matchId)?  matchReady,required TResult orElse(),}) {final _that = this;
switch (_that) {
case TournamentInitial() when initial != null:
return initial();case TournamentLoading() when loading != null:
return loading();case TournamentLoaded() when loaded != null:
return loaded(_that.tournaments,_that.selectedFilterIndex);case TournamentError() when error != null:
return error(_that.message);case TournamentDetailLoading() when detailLoading != null:
return detailLoading();case TournamentDetailLoaded() when detailLoaded != null:
return detailLoaded(_that.tournament);case TournamentDetailError() when detailError != null:
return detailError(_that.message);case TournamentJoining() when joining != null:
return joining();case TournamentJoined() when joined != null:
return joined(_that.tournamentId);case TournamentJoinError() when joinError != null:
return joinError(_that.message);case TournamentMatchReady() when matchReady != null:
return matchReady(_that.tournamentId,_that.roomId,_that.matchId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<Tournament> tournaments,  int selectedFilterIndex)  loaded,required TResult Function( String message)  error,required TResult Function()  detailLoading,required TResult Function( Tournament tournament)  detailLoaded,required TResult Function( String message)  detailError,required TResult Function()  joining,required TResult Function( String tournamentId)  joined,required TResult Function( String message)  joinError,required TResult Function( String tournamentId,  String roomId,  String matchId)  matchReady,}) {final _that = this;
switch (_that) {
case TournamentInitial():
return initial();case TournamentLoading():
return loading();case TournamentLoaded():
return loaded(_that.tournaments,_that.selectedFilterIndex);case TournamentError():
return error(_that.message);case TournamentDetailLoading():
return detailLoading();case TournamentDetailLoaded():
return detailLoaded(_that.tournament);case TournamentDetailError():
return detailError(_that.message);case TournamentJoining():
return joining();case TournamentJoined():
return joined(_that.tournamentId);case TournamentJoinError():
return joinError(_that.message);case TournamentMatchReady():
return matchReady(_that.tournamentId,_that.roomId,_that.matchId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<Tournament> tournaments,  int selectedFilterIndex)?  loaded,TResult? Function( String message)?  error,TResult? Function()?  detailLoading,TResult? Function( Tournament tournament)?  detailLoaded,TResult? Function( String message)?  detailError,TResult? Function()?  joining,TResult? Function( String tournamentId)?  joined,TResult? Function( String message)?  joinError,TResult? Function( String tournamentId,  String roomId,  String matchId)?  matchReady,}) {final _that = this;
switch (_that) {
case TournamentInitial() when initial != null:
return initial();case TournamentLoading() when loading != null:
return loading();case TournamentLoaded() when loaded != null:
return loaded(_that.tournaments,_that.selectedFilterIndex);case TournamentError() when error != null:
return error(_that.message);case TournamentDetailLoading() when detailLoading != null:
return detailLoading();case TournamentDetailLoaded() when detailLoaded != null:
return detailLoaded(_that.tournament);case TournamentDetailError() when detailError != null:
return detailError(_that.message);case TournamentJoining() when joining != null:
return joining();case TournamentJoined() when joined != null:
return joined(_that.tournamentId);case TournamentJoinError() when joinError != null:
return joinError(_that.message);case TournamentMatchReady() when matchReady != null:
return matchReady(_that.tournamentId,_that.roomId,_that.matchId);case _:
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


class TournamentDetailLoading implements TournamentState {
  const TournamentDetailLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TournamentDetailLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TournamentState.detailLoading()';
}


}




/// @nodoc


class TournamentDetailLoaded implements TournamentState {
  const TournamentDetailLoaded({required this.tournament});
  

 final  Tournament tournament;

/// Create a copy of TournamentState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TournamentDetailLoadedCopyWith<TournamentDetailLoaded> get copyWith => _$TournamentDetailLoadedCopyWithImpl<TournamentDetailLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TournamentDetailLoaded&&(identical(other.tournament, tournament) || other.tournament == tournament));
}


@override
int get hashCode => Object.hash(runtimeType,tournament);

@override
String toString() {
  return 'TournamentState.detailLoaded(tournament: $tournament)';
}


}

/// @nodoc
abstract mixin class $TournamentDetailLoadedCopyWith<$Res> implements $TournamentStateCopyWith<$Res> {
  factory $TournamentDetailLoadedCopyWith(TournamentDetailLoaded value, $Res Function(TournamentDetailLoaded) _then) = _$TournamentDetailLoadedCopyWithImpl;
@useResult
$Res call({
 Tournament tournament
});




}
/// @nodoc
class _$TournamentDetailLoadedCopyWithImpl<$Res>
    implements $TournamentDetailLoadedCopyWith<$Res> {
  _$TournamentDetailLoadedCopyWithImpl(this._self, this._then);

  final TournamentDetailLoaded _self;
  final $Res Function(TournamentDetailLoaded) _then;

/// Create a copy of TournamentState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? tournament = null,}) {
  return _then(TournamentDetailLoaded(
tournament: null == tournament ? _self.tournament : tournament // ignore: cast_nullable_to_non_nullable
as Tournament,
  ));
}


}

/// @nodoc


class TournamentDetailError implements TournamentState {
  const TournamentDetailError({required this.message});
  

 final  String message;

/// Create a copy of TournamentState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TournamentDetailErrorCopyWith<TournamentDetailError> get copyWith => _$TournamentDetailErrorCopyWithImpl<TournamentDetailError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TournamentDetailError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'TournamentState.detailError(message: $message)';
}


}

/// @nodoc
abstract mixin class $TournamentDetailErrorCopyWith<$Res> implements $TournamentStateCopyWith<$Res> {
  factory $TournamentDetailErrorCopyWith(TournamentDetailError value, $Res Function(TournamentDetailError) _then) = _$TournamentDetailErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$TournamentDetailErrorCopyWithImpl<$Res>
    implements $TournamentDetailErrorCopyWith<$Res> {
  _$TournamentDetailErrorCopyWithImpl(this._self, this._then);

  final TournamentDetailError _self;
  final $Res Function(TournamentDetailError) _then;

/// Create a copy of TournamentState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(TournamentDetailError(
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

/// @nodoc


class TournamentMatchReady implements TournamentState {
  const TournamentMatchReady({required this.tournamentId, required this.roomId, required this.matchId});
  

 final  String tournamentId;
 final  String roomId;
 final  String matchId;

/// Create a copy of TournamentState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TournamentMatchReadyCopyWith<TournamentMatchReady> get copyWith => _$TournamentMatchReadyCopyWithImpl<TournamentMatchReady>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TournamentMatchReady&&(identical(other.tournamentId, tournamentId) || other.tournamentId == tournamentId)&&(identical(other.roomId, roomId) || other.roomId == roomId)&&(identical(other.matchId, matchId) || other.matchId == matchId));
}


@override
int get hashCode => Object.hash(runtimeType,tournamentId,roomId,matchId);

@override
String toString() {
  return 'TournamentState.matchReady(tournamentId: $tournamentId, roomId: $roomId, matchId: $matchId)';
}


}

/// @nodoc
abstract mixin class $TournamentMatchReadyCopyWith<$Res> implements $TournamentStateCopyWith<$Res> {
  factory $TournamentMatchReadyCopyWith(TournamentMatchReady value, $Res Function(TournamentMatchReady) _then) = _$TournamentMatchReadyCopyWithImpl;
@useResult
$Res call({
 String tournamentId, String roomId, String matchId
});




}
/// @nodoc
class _$TournamentMatchReadyCopyWithImpl<$Res>
    implements $TournamentMatchReadyCopyWith<$Res> {
  _$TournamentMatchReadyCopyWithImpl(this._self, this._then);

  final TournamentMatchReady _self;
  final $Res Function(TournamentMatchReady) _then;

/// Create a copy of TournamentState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? tournamentId = null,Object? roomId = null,Object? matchId = null,}) {
  return _then(TournamentMatchReady(
tournamentId: null == tournamentId ? _self.tournamentId : tournamentId // ignore: cast_nullable_to_non_nullable
as String,roomId: null == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as String,matchId: null == matchId ? _self.matchId : matchId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
