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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( GameInitial value)?  initial,TResult Function( GameLoading value)?  loading,TResult Function( GameDealing value)?  dealing,TResult Function( GameBidding value)?  bidding,TResult Function( GameBonusClaim value)?  bonusClaim,TResult Function( GamePlaying value)?  playing,TResult Function( GameTrickEnd value)?  trickEnd,TResult Function( GameRoundEnd value)?  roundEnd,TResult Function( GameGameEnd value)?  gameEnd,TResult Function( GameError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case GameInitial() when initial != null:
return initial(_that);case GameLoading() when loading != null:
return loading(_that);case GameDealing() when dealing != null:
return dealing(_that);case GameBidding() when bidding != null:
return bidding(_that);case GameBonusClaim() when bonusClaim != null:
return bonusClaim(_that);case GamePlaying() when playing != null:
return playing(_that);case GameTrickEnd() when trickEnd != null:
return trickEnd(_that);case GameRoundEnd() when roundEnd != null:
return roundEnd(_that);case GameGameEnd() when gameEnd != null:
return gameEnd(_that);case GameError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( GameInitial value)  initial,required TResult Function( GameLoading value)  loading,required TResult Function( GameDealing value)  dealing,required TResult Function( GameBidding value)  bidding,required TResult Function( GameBonusClaim value)  bonusClaim,required TResult Function( GamePlaying value)  playing,required TResult Function( GameTrickEnd value)  trickEnd,required TResult Function( GameRoundEnd value)  roundEnd,required TResult Function( GameGameEnd value)  gameEnd,required TResult Function( GameError value)  error,}){
final _that = this;
switch (_that) {
case GameInitial():
return initial(_that);case GameLoading():
return loading(_that);case GameDealing():
return dealing(_that);case GameBidding():
return bidding(_that);case GameBonusClaim():
return bonusClaim(_that);case GamePlaying():
return playing(_that);case GameTrickEnd():
return trickEnd(_that);case GameRoundEnd():
return roundEnd(_that);case GameGameEnd():
return gameEnd(_that);case GameError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( GameInitial value)?  initial,TResult? Function( GameLoading value)?  loading,TResult? Function( GameDealing value)?  dealing,TResult? Function( GameBidding value)?  bidding,TResult? Function( GameBonusClaim value)?  bonusClaim,TResult? Function( GamePlaying value)?  playing,TResult? Function( GameTrickEnd value)?  trickEnd,TResult? Function( GameRoundEnd value)?  roundEnd,TResult? Function( GameGameEnd value)?  gameEnd,TResult? Function( GameError value)?  error,}){
final _that = this;
switch (_that) {
case GameInitial() when initial != null:
return initial(_that);case GameLoading() when loading != null:
return loading(_that);case GameDealing() when dealing != null:
return dealing(_that);case GameBidding() when bidding != null:
return bidding(_that);case GameBonusClaim() when bonusClaim != null:
return bonusClaim(_that);case GamePlaying() when playing != null:
return playing(_that);case GameTrickEnd() when trickEnd != null:
return trickEnd(_that);case GameRoundEnd() when roundEnd != null:
return roundEnd(_that);case GameGameEnd() when gameEnd != null:
return gameEnd(_that);case GameError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( Game game,  bool controlsVisible,  int? selectedCardIndex,  bool actionInProgress,  String? lastActionError)?  dealing,TResult Function( Game game,  bool controlsVisible,  int? selectedCardIndex,  bool actionInProgress,  String? lastActionError)?  bidding,TResult Function( Game game,  bool controlsVisible,  int? selectedCardIndex,  bool actionInProgress,  String? lastActionError)?  bonusClaim,TResult Function( Game game,  bool controlsVisible,  int? selectedCardIndex,  bool actionInProgress,  String? lastActionError)?  playing,TResult Function( Game game,  int winnerSeat,  bool controlsVisible,  int? selectedCardIndex,  bool actionInProgress,  String? lastActionError)?  trickEnd,TResult Function( Game game,  int teamAPoints,  int teamBPoints,  String? fellTeam,  bool controlsVisible,  int? selectedCardIndex,  bool actionInProgress,  String? lastActionError)?  roundEnd,TResult Function( Game game,  String winnerTeam,  bool controlsVisible,  int? selectedCardIndex,  bool actionInProgress,  String? lastActionError)?  gameEnd,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case GameInitial() when initial != null:
return initial();case GameLoading() when loading != null:
return loading();case GameDealing() when dealing != null:
return dealing(_that.game,_that.controlsVisible,_that.selectedCardIndex,_that.actionInProgress,_that.lastActionError);case GameBidding() when bidding != null:
return bidding(_that.game,_that.controlsVisible,_that.selectedCardIndex,_that.actionInProgress,_that.lastActionError);case GameBonusClaim() when bonusClaim != null:
return bonusClaim(_that.game,_that.controlsVisible,_that.selectedCardIndex,_that.actionInProgress,_that.lastActionError);case GamePlaying() when playing != null:
return playing(_that.game,_that.controlsVisible,_that.selectedCardIndex,_that.actionInProgress,_that.lastActionError);case GameTrickEnd() when trickEnd != null:
return trickEnd(_that.game,_that.winnerSeat,_that.controlsVisible,_that.selectedCardIndex,_that.actionInProgress,_that.lastActionError);case GameRoundEnd() when roundEnd != null:
return roundEnd(_that.game,_that.teamAPoints,_that.teamBPoints,_that.fellTeam,_that.controlsVisible,_that.selectedCardIndex,_that.actionInProgress,_that.lastActionError);case GameGameEnd() when gameEnd != null:
return gameEnd(_that.game,_that.winnerTeam,_that.controlsVisible,_that.selectedCardIndex,_that.actionInProgress,_that.lastActionError);case GameError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( Game game,  bool controlsVisible,  int? selectedCardIndex,  bool actionInProgress,  String? lastActionError)  dealing,required TResult Function( Game game,  bool controlsVisible,  int? selectedCardIndex,  bool actionInProgress,  String? lastActionError)  bidding,required TResult Function( Game game,  bool controlsVisible,  int? selectedCardIndex,  bool actionInProgress,  String? lastActionError)  bonusClaim,required TResult Function( Game game,  bool controlsVisible,  int? selectedCardIndex,  bool actionInProgress,  String? lastActionError)  playing,required TResult Function( Game game,  int winnerSeat,  bool controlsVisible,  int? selectedCardIndex,  bool actionInProgress,  String? lastActionError)  trickEnd,required TResult Function( Game game,  int teamAPoints,  int teamBPoints,  String? fellTeam,  bool controlsVisible,  int? selectedCardIndex,  bool actionInProgress,  String? lastActionError)  roundEnd,required TResult Function( Game game,  String winnerTeam,  bool controlsVisible,  int? selectedCardIndex,  bool actionInProgress,  String? lastActionError)  gameEnd,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case GameInitial():
return initial();case GameLoading():
return loading();case GameDealing():
return dealing(_that.game,_that.controlsVisible,_that.selectedCardIndex,_that.actionInProgress,_that.lastActionError);case GameBidding():
return bidding(_that.game,_that.controlsVisible,_that.selectedCardIndex,_that.actionInProgress,_that.lastActionError);case GameBonusClaim():
return bonusClaim(_that.game,_that.controlsVisible,_that.selectedCardIndex,_that.actionInProgress,_that.lastActionError);case GamePlaying():
return playing(_that.game,_that.controlsVisible,_that.selectedCardIndex,_that.actionInProgress,_that.lastActionError);case GameTrickEnd():
return trickEnd(_that.game,_that.winnerSeat,_that.controlsVisible,_that.selectedCardIndex,_that.actionInProgress,_that.lastActionError);case GameRoundEnd():
return roundEnd(_that.game,_that.teamAPoints,_that.teamBPoints,_that.fellTeam,_that.controlsVisible,_that.selectedCardIndex,_that.actionInProgress,_that.lastActionError);case GameGameEnd():
return gameEnd(_that.game,_that.winnerTeam,_that.controlsVisible,_that.selectedCardIndex,_that.actionInProgress,_that.lastActionError);case GameError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( Game game,  bool controlsVisible,  int? selectedCardIndex,  bool actionInProgress,  String? lastActionError)?  dealing,TResult? Function( Game game,  bool controlsVisible,  int? selectedCardIndex,  bool actionInProgress,  String? lastActionError)?  bidding,TResult? Function( Game game,  bool controlsVisible,  int? selectedCardIndex,  bool actionInProgress,  String? lastActionError)?  bonusClaim,TResult? Function( Game game,  bool controlsVisible,  int? selectedCardIndex,  bool actionInProgress,  String? lastActionError)?  playing,TResult? Function( Game game,  int winnerSeat,  bool controlsVisible,  int? selectedCardIndex,  bool actionInProgress,  String? lastActionError)?  trickEnd,TResult? Function( Game game,  int teamAPoints,  int teamBPoints,  String? fellTeam,  bool controlsVisible,  int? selectedCardIndex,  bool actionInProgress,  String? lastActionError)?  roundEnd,TResult? Function( Game game,  String winnerTeam,  bool controlsVisible,  int? selectedCardIndex,  bool actionInProgress,  String? lastActionError)?  gameEnd,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case GameInitial() when initial != null:
return initial();case GameLoading() when loading != null:
return loading();case GameDealing() when dealing != null:
return dealing(_that.game,_that.controlsVisible,_that.selectedCardIndex,_that.actionInProgress,_that.lastActionError);case GameBidding() when bidding != null:
return bidding(_that.game,_that.controlsVisible,_that.selectedCardIndex,_that.actionInProgress,_that.lastActionError);case GameBonusClaim() when bonusClaim != null:
return bonusClaim(_that.game,_that.controlsVisible,_that.selectedCardIndex,_that.actionInProgress,_that.lastActionError);case GamePlaying() when playing != null:
return playing(_that.game,_that.controlsVisible,_that.selectedCardIndex,_that.actionInProgress,_that.lastActionError);case GameTrickEnd() when trickEnd != null:
return trickEnd(_that.game,_that.winnerSeat,_that.controlsVisible,_that.selectedCardIndex,_that.actionInProgress,_that.lastActionError);case GameRoundEnd() when roundEnd != null:
return roundEnd(_that.game,_that.teamAPoints,_that.teamBPoints,_that.fellTeam,_that.controlsVisible,_that.selectedCardIndex,_that.actionInProgress,_that.lastActionError);case GameGameEnd() when gameEnd != null:
return gameEnd(_that.game,_that.winnerTeam,_that.controlsVisible,_that.selectedCardIndex,_that.actionInProgress,_that.lastActionError);case GameError() when error != null:
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


class GameDealing implements GameState {
  const GameDealing({required this.game, this.controlsVisible = true, this.selectedCardIndex, this.actionInProgress = false, this.lastActionError});
  

 final  Game game;
@JsonKey() final  bool controlsVisible;
 final  int? selectedCardIndex;
@JsonKey() final  bool actionInProgress;
 final  String? lastActionError;

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameDealingCopyWith<GameDealing> get copyWith => _$GameDealingCopyWithImpl<GameDealing>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameDealing&&(identical(other.game, game) || other.game == game)&&(identical(other.controlsVisible, controlsVisible) || other.controlsVisible == controlsVisible)&&(identical(other.selectedCardIndex, selectedCardIndex) || other.selectedCardIndex == selectedCardIndex)&&(identical(other.actionInProgress, actionInProgress) || other.actionInProgress == actionInProgress)&&(identical(other.lastActionError, lastActionError) || other.lastActionError == lastActionError));
}


@override
int get hashCode => Object.hash(runtimeType,game,controlsVisible,selectedCardIndex,actionInProgress,lastActionError);

@override
String toString() {
  return 'GameState.dealing(game: $game, controlsVisible: $controlsVisible, selectedCardIndex: $selectedCardIndex, actionInProgress: $actionInProgress, lastActionError: $lastActionError)';
}


}

/// @nodoc
abstract mixin class $GameDealingCopyWith<$Res> implements $GameStateCopyWith<$Res> {
  factory $GameDealingCopyWith(GameDealing value, $Res Function(GameDealing) _then) = _$GameDealingCopyWithImpl;
@useResult
$Res call({
 Game game, bool controlsVisible, int? selectedCardIndex, bool actionInProgress, String? lastActionError
});




}
/// @nodoc
class _$GameDealingCopyWithImpl<$Res>
    implements $GameDealingCopyWith<$Res> {
  _$GameDealingCopyWithImpl(this._self, this._then);

  final GameDealing _self;
  final $Res Function(GameDealing) _then;

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? game = null,Object? controlsVisible = null,Object? selectedCardIndex = freezed,Object? actionInProgress = null,Object? lastActionError = freezed,}) {
  return _then(GameDealing(
game: null == game ? _self.game : game // ignore: cast_nullable_to_non_nullable
as Game,controlsVisible: null == controlsVisible ? _self.controlsVisible : controlsVisible // ignore: cast_nullable_to_non_nullable
as bool,selectedCardIndex: freezed == selectedCardIndex ? _self.selectedCardIndex : selectedCardIndex // ignore: cast_nullable_to_non_nullable
as int?,actionInProgress: null == actionInProgress ? _self.actionInProgress : actionInProgress // ignore: cast_nullable_to_non_nullable
as bool,lastActionError: freezed == lastActionError ? _self.lastActionError : lastActionError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class GameBidding implements GameState {
  const GameBidding({required this.game, this.controlsVisible = true, this.selectedCardIndex, this.actionInProgress = false, this.lastActionError});
  

 final  Game game;
@JsonKey() final  bool controlsVisible;
 final  int? selectedCardIndex;
@JsonKey() final  bool actionInProgress;
 final  String? lastActionError;

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameBiddingCopyWith<GameBidding> get copyWith => _$GameBiddingCopyWithImpl<GameBidding>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameBidding&&(identical(other.game, game) || other.game == game)&&(identical(other.controlsVisible, controlsVisible) || other.controlsVisible == controlsVisible)&&(identical(other.selectedCardIndex, selectedCardIndex) || other.selectedCardIndex == selectedCardIndex)&&(identical(other.actionInProgress, actionInProgress) || other.actionInProgress == actionInProgress)&&(identical(other.lastActionError, lastActionError) || other.lastActionError == lastActionError));
}


@override
int get hashCode => Object.hash(runtimeType,game,controlsVisible,selectedCardIndex,actionInProgress,lastActionError);

@override
String toString() {
  return 'GameState.bidding(game: $game, controlsVisible: $controlsVisible, selectedCardIndex: $selectedCardIndex, actionInProgress: $actionInProgress, lastActionError: $lastActionError)';
}


}

/// @nodoc
abstract mixin class $GameBiddingCopyWith<$Res> implements $GameStateCopyWith<$Res> {
  factory $GameBiddingCopyWith(GameBidding value, $Res Function(GameBidding) _then) = _$GameBiddingCopyWithImpl;
@useResult
$Res call({
 Game game, bool controlsVisible, int? selectedCardIndex, bool actionInProgress, String? lastActionError
});




}
/// @nodoc
class _$GameBiddingCopyWithImpl<$Res>
    implements $GameBiddingCopyWith<$Res> {
  _$GameBiddingCopyWithImpl(this._self, this._then);

  final GameBidding _self;
  final $Res Function(GameBidding) _then;

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? game = null,Object? controlsVisible = null,Object? selectedCardIndex = freezed,Object? actionInProgress = null,Object? lastActionError = freezed,}) {
  return _then(GameBidding(
game: null == game ? _self.game : game // ignore: cast_nullable_to_non_nullable
as Game,controlsVisible: null == controlsVisible ? _self.controlsVisible : controlsVisible // ignore: cast_nullable_to_non_nullable
as bool,selectedCardIndex: freezed == selectedCardIndex ? _self.selectedCardIndex : selectedCardIndex // ignore: cast_nullable_to_non_nullable
as int?,actionInProgress: null == actionInProgress ? _self.actionInProgress : actionInProgress // ignore: cast_nullable_to_non_nullable
as bool,lastActionError: freezed == lastActionError ? _self.lastActionError : lastActionError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class GameBonusClaim implements GameState {
  const GameBonusClaim({required this.game, this.controlsVisible = true, this.selectedCardIndex, this.actionInProgress = false, this.lastActionError});
  

 final  Game game;
@JsonKey() final  bool controlsVisible;
 final  int? selectedCardIndex;
@JsonKey() final  bool actionInProgress;
 final  String? lastActionError;

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameBonusClaimCopyWith<GameBonusClaim> get copyWith => _$GameBonusClaimCopyWithImpl<GameBonusClaim>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameBonusClaim&&(identical(other.game, game) || other.game == game)&&(identical(other.controlsVisible, controlsVisible) || other.controlsVisible == controlsVisible)&&(identical(other.selectedCardIndex, selectedCardIndex) || other.selectedCardIndex == selectedCardIndex)&&(identical(other.actionInProgress, actionInProgress) || other.actionInProgress == actionInProgress)&&(identical(other.lastActionError, lastActionError) || other.lastActionError == lastActionError));
}


@override
int get hashCode => Object.hash(runtimeType,game,controlsVisible,selectedCardIndex,actionInProgress,lastActionError);

@override
String toString() {
  return 'GameState.bonusClaim(game: $game, controlsVisible: $controlsVisible, selectedCardIndex: $selectedCardIndex, actionInProgress: $actionInProgress, lastActionError: $lastActionError)';
}


}

/// @nodoc
abstract mixin class $GameBonusClaimCopyWith<$Res> implements $GameStateCopyWith<$Res> {
  factory $GameBonusClaimCopyWith(GameBonusClaim value, $Res Function(GameBonusClaim) _then) = _$GameBonusClaimCopyWithImpl;
@useResult
$Res call({
 Game game, bool controlsVisible, int? selectedCardIndex, bool actionInProgress, String? lastActionError
});




}
/// @nodoc
class _$GameBonusClaimCopyWithImpl<$Res>
    implements $GameBonusClaimCopyWith<$Res> {
  _$GameBonusClaimCopyWithImpl(this._self, this._then);

  final GameBonusClaim _self;
  final $Res Function(GameBonusClaim) _then;

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? game = null,Object? controlsVisible = null,Object? selectedCardIndex = freezed,Object? actionInProgress = null,Object? lastActionError = freezed,}) {
  return _then(GameBonusClaim(
game: null == game ? _self.game : game // ignore: cast_nullable_to_non_nullable
as Game,controlsVisible: null == controlsVisible ? _self.controlsVisible : controlsVisible // ignore: cast_nullable_to_non_nullable
as bool,selectedCardIndex: freezed == selectedCardIndex ? _self.selectedCardIndex : selectedCardIndex // ignore: cast_nullable_to_non_nullable
as int?,actionInProgress: null == actionInProgress ? _self.actionInProgress : actionInProgress // ignore: cast_nullable_to_non_nullable
as bool,lastActionError: freezed == lastActionError ? _self.lastActionError : lastActionError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class GamePlaying implements GameState {
  const GamePlaying({required this.game, this.controlsVisible = true, this.selectedCardIndex, this.actionInProgress = false, this.lastActionError});
  

 final  Game game;
@JsonKey() final  bool controlsVisible;
 final  int? selectedCardIndex;
@JsonKey() final  bool actionInProgress;
 final  String? lastActionError;

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GamePlayingCopyWith<GamePlaying> get copyWith => _$GamePlayingCopyWithImpl<GamePlaying>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GamePlaying&&(identical(other.game, game) || other.game == game)&&(identical(other.controlsVisible, controlsVisible) || other.controlsVisible == controlsVisible)&&(identical(other.selectedCardIndex, selectedCardIndex) || other.selectedCardIndex == selectedCardIndex)&&(identical(other.actionInProgress, actionInProgress) || other.actionInProgress == actionInProgress)&&(identical(other.lastActionError, lastActionError) || other.lastActionError == lastActionError));
}


@override
int get hashCode => Object.hash(runtimeType,game,controlsVisible,selectedCardIndex,actionInProgress,lastActionError);

@override
String toString() {
  return 'GameState.playing(game: $game, controlsVisible: $controlsVisible, selectedCardIndex: $selectedCardIndex, actionInProgress: $actionInProgress, lastActionError: $lastActionError)';
}


}

/// @nodoc
abstract mixin class $GamePlayingCopyWith<$Res> implements $GameStateCopyWith<$Res> {
  factory $GamePlayingCopyWith(GamePlaying value, $Res Function(GamePlaying) _then) = _$GamePlayingCopyWithImpl;
@useResult
$Res call({
 Game game, bool controlsVisible, int? selectedCardIndex, bool actionInProgress, String? lastActionError
});




}
/// @nodoc
class _$GamePlayingCopyWithImpl<$Res>
    implements $GamePlayingCopyWith<$Res> {
  _$GamePlayingCopyWithImpl(this._self, this._then);

  final GamePlaying _self;
  final $Res Function(GamePlaying) _then;

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? game = null,Object? controlsVisible = null,Object? selectedCardIndex = freezed,Object? actionInProgress = null,Object? lastActionError = freezed,}) {
  return _then(GamePlaying(
game: null == game ? _self.game : game // ignore: cast_nullable_to_non_nullable
as Game,controlsVisible: null == controlsVisible ? _self.controlsVisible : controlsVisible // ignore: cast_nullable_to_non_nullable
as bool,selectedCardIndex: freezed == selectedCardIndex ? _self.selectedCardIndex : selectedCardIndex // ignore: cast_nullable_to_non_nullable
as int?,actionInProgress: null == actionInProgress ? _self.actionInProgress : actionInProgress // ignore: cast_nullable_to_non_nullable
as bool,lastActionError: freezed == lastActionError ? _self.lastActionError : lastActionError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class GameTrickEnd implements GameState {
  const GameTrickEnd({required this.game, required this.winnerSeat, this.controlsVisible = true, this.selectedCardIndex, this.actionInProgress = false, this.lastActionError});
  

 final  Game game;
 final  int winnerSeat;
@JsonKey() final  bool controlsVisible;
 final  int? selectedCardIndex;
@JsonKey() final  bool actionInProgress;
 final  String? lastActionError;

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameTrickEndCopyWith<GameTrickEnd> get copyWith => _$GameTrickEndCopyWithImpl<GameTrickEnd>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameTrickEnd&&(identical(other.game, game) || other.game == game)&&(identical(other.winnerSeat, winnerSeat) || other.winnerSeat == winnerSeat)&&(identical(other.controlsVisible, controlsVisible) || other.controlsVisible == controlsVisible)&&(identical(other.selectedCardIndex, selectedCardIndex) || other.selectedCardIndex == selectedCardIndex)&&(identical(other.actionInProgress, actionInProgress) || other.actionInProgress == actionInProgress)&&(identical(other.lastActionError, lastActionError) || other.lastActionError == lastActionError));
}


@override
int get hashCode => Object.hash(runtimeType,game,winnerSeat,controlsVisible,selectedCardIndex,actionInProgress,lastActionError);

@override
String toString() {
  return 'GameState.trickEnd(game: $game, winnerSeat: $winnerSeat, controlsVisible: $controlsVisible, selectedCardIndex: $selectedCardIndex, actionInProgress: $actionInProgress, lastActionError: $lastActionError)';
}


}

/// @nodoc
abstract mixin class $GameTrickEndCopyWith<$Res> implements $GameStateCopyWith<$Res> {
  factory $GameTrickEndCopyWith(GameTrickEnd value, $Res Function(GameTrickEnd) _then) = _$GameTrickEndCopyWithImpl;
@useResult
$Res call({
 Game game, int winnerSeat, bool controlsVisible, int? selectedCardIndex, bool actionInProgress, String? lastActionError
});




}
/// @nodoc
class _$GameTrickEndCopyWithImpl<$Res>
    implements $GameTrickEndCopyWith<$Res> {
  _$GameTrickEndCopyWithImpl(this._self, this._then);

  final GameTrickEnd _self;
  final $Res Function(GameTrickEnd) _then;

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? game = null,Object? winnerSeat = null,Object? controlsVisible = null,Object? selectedCardIndex = freezed,Object? actionInProgress = null,Object? lastActionError = freezed,}) {
  return _then(GameTrickEnd(
game: null == game ? _self.game : game // ignore: cast_nullable_to_non_nullable
as Game,winnerSeat: null == winnerSeat ? _self.winnerSeat : winnerSeat // ignore: cast_nullable_to_non_nullable
as int,controlsVisible: null == controlsVisible ? _self.controlsVisible : controlsVisible // ignore: cast_nullable_to_non_nullable
as bool,selectedCardIndex: freezed == selectedCardIndex ? _self.selectedCardIndex : selectedCardIndex // ignore: cast_nullable_to_non_nullable
as int?,actionInProgress: null == actionInProgress ? _self.actionInProgress : actionInProgress // ignore: cast_nullable_to_non_nullable
as bool,lastActionError: freezed == lastActionError ? _self.lastActionError : lastActionError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class GameRoundEnd implements GameState {
  const GameRoundEnd({required this.game, required this.teamAPoints, required this.teamBPoints, this.fellTeam, this.controlsVisible = true, this.selectedCardIndex, this.actionInProgress = false, this.lastActionError});
  

 final  Game game;
 final  int teamAPoints;
 final  int teamBPoints;
 final  String? fellTeam;
@JsonKey() final  bool controlsVisible;
 final  int? selectedCardIndex;
@JsonKey() final  bool actionInProgress;
 final  String? lastActionError;

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameRoundEndCopyWith<GameRoundEnd> get copyWith => _$GameRoundEndCopyWithImpl<GameRoundEnd>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameRoundEnd&&(identical(other.game, game) || other.game == game)&&(identical(other.teamAPoints, teamAPoints) || other.teamAPoints == teamAPoints)&&(identical(other.teamBPoints, teamBPoints) || other.teamBPoints == teamBPoints)&&(identical(other.fellTeam, fellTeam) || other.fellTeam == fellTeam)&&(identical(other.controlsVisible, controlsVisible) || other.controlsVisible == controlsVisible)&&(identical(other.selectedCardIndex, selectedCardIndex) || other.selectedCardIndex == selectedCardIndex)&&(identical(other.actionInProgress, actionInProgress) || other.actionInProgress == actionInProgress)&&(identical(other.lastActionError, lastActionError) || other.lastActionError == lastActionError));
}


@override
int get hashCode => Object.hash(runtimeType,game,teamAPoints,teamBPoints,fellTeam,controlsVisible,selectedCardIndex,actionInProgress,lastActionError);

@override
String toString() {
  return 'GameState.roundEnd(game: $game, teamAPoints: $teamAPoints, teamBPoints: $teamBPoints, fellTeam: $fellTeam, controlsVisible: $controlsVisible, selectedCardIndex: $selectedCardIndex, actionInProgress: $actionInProgress, lastActionError: $lastActionError)';
}


}

/// @nodoc
abstract mixin class $GameRoundEndCopyWith<$Res> implements $GameStateCopyWith<$Res> {
  factory $GameRoundEndCopyWith(GameRoundEnd value, $Res Function(GameRoundEnd) _then) = _$GameRoundEndCopyWithImpl;
@useResult
$Res call({
 Game game, int teamAPoints, int teamBPoints, String? fellTeam, bool controlsVisible, int? selectedCardIndex, bool actionInProgress, String? lastActionError
});




}
/// @nodoc
class _$GameRoundEndCopyWithImpl<$Res>
    implements $GameRoundEndCopyWith<$Res> {
  _$GameRoundEndCopyWithImpl(this._self, this._then);

  final GameRoundEnd _self;
  final $Res Function(GameRoundEnd) _then;

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? game = null,Object? teamAPoints = null,Object? teamBPoints = null,Object? fellTeam = freezed,Object? controlsVisible = null,Object? selectedCardIndex = freezed,Object? actionInProgress = null,Object? lastActionError = freezed,}) {
  return _then(GameRoundEnd(
game: null == game ? _self.game : game // ignore: cast_nullable_to_non_nullable
as Game,teamAPoints: null == teamAPoints ? _self.teamAPoints : teamAPoints // ignore: cast_nullable_to_non_nullable
as int,teamBPoints: null == teamBPoints ? _self.teamBPoints : teamBPoints // ignore: cast_nullable_to_non_nullable
as int,fellTeam: freezed == fellTeam ? _self.fellTeam : fellTeam // ignore: cast_nullable_to_non_nullable
as String?,controlsVisible: null == controlsVisible ? _self.controlsVisible : controlsVisible // ignore: cast_nullable_to_non_nullable
as bool,selectedCardIndex: freezed == selectedCardIndex ? _self.selectedCardIndex : selectedCardIndex // ignore: cast_nullable_to_non_nullable
as int?,actionInProgress: null == actionInProgress ? _self.actionInProgress : actionInProgress // ignore: cast_nullable_to_non_nullable
as bool,lastActionError: freezed == lastActionError ? _self.lastActionError : lastActionError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class GameGameEnd implements GameState {
  const GameGameEnd({required this.game, required this.winnerTeam, this.controlsVisible = true, this.selectedCardIndex, this.actionInProgress = false, this.lastActionError});
  

 final  Game game;
 final  String winnerTeam;
@JsonKey() final  bool controlsVisible;
 final  int? selectedCardIndex;
@JsonKey() final  bool actionInProgress;
 final  String? lastActionError;

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameGameEndCopyWith<GameGameEnd> get copyWith => _$GameGameEndCopyWithImpl<GameGameEnd>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameGameEnd&&(identical(other.game, game) || other.game == game)&&(identical(other.winnerTeam, winnerTeam) || other.winnerTeam == winnerTeam)&&(identical(other.controlsVisible, controlsVisible) || other.controlsVisible == controlsVisible)&&(identical(other.selectedCardIndex, selectedCardIndex) || other.selectedCardIndex == selectedCardIndex)&&(identical(other.actionInProgress, actionInProgress) || other.actionInProgress == actionInProgress)&&(identical(other.lastActionError, lastActionError) || other.lastActionError == lastActionError));
}


@override
int get hashCode => Object.hash(runtimeType,game,winnerTeam,controlsVisible,selectedCardIndex,actionInProgress,lastActionError);

@override
String toString() {
  return 'GameState.gameEnd(game: $game, winnerTeam: $winnerTeam, controlsVisible: $controlsVisible, selectedCardIndex: $selectedCardIndex, actionInProgress: $actionInProgress, lastActionError: $lastActionError)';
}


}

/// @nodoc
abstract mixin class $GameGameEndCopyWith<$Res> implements $GameStateCopyWith<$Res> {
  factory $GameGameEndCopyWith(GameGameEnd value, $Res Function(GameGameEnd) _then) = _$GameGameEndCopyWithImpl;
@useResult
$Res call({
 Game game, String winnerTeam, bool controlsVisible, int? selectedCardIndex, bool actionInProgress, String? lastActionError
});




}
/// @nodoc
class _$GameGameEndCopyWithImpl<$Res>
    implements $GameGameEndCopyWith<$Res> {
  _$GameGameEndCopyWithImpl(this._self, this._then);

  final GameGameEnd _self;
  final $Res Function(GameGameEnd) _then;

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? game = null,Object? winnerTeam = null,Object? controlsVisible = null,Object? selectedCardIndex = freezed,Object? actionInProgress = null,Object? lastActionError = freezed,}) {
  return _then(GameGameEnd(
game: null == game ? _self.game : game // ignore: cast_nullable_to_non_nullable
as Game,winnerTeam: null == winnerTeam ? _self.winnerTeam : winnerTeam // ignore: cast_nullable_to_non_nullable
as String,controlsVisible: null == controlsVisible ? _self.controlsVisible : controlsVisible // ignore: cast_nullable_to_non_nullable
as bool,selectedCardIndex: freezed == selectedCardIndex ? _self.selectedCardIndex : selectedCardIndex // ignore: cast_nullable_to_non_nullable
as int?,actionInProgress: null == actionInProgress ? _self.actionInProgress : actionInProgress // ignore: cast_nullable_to_non_nullable
as bool,lastActionError: freezed == lastActionError ? _self.lastActionError : lastActionError // ignore: cast_nullable_to_non_nullable
as String?,
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
