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

 String get id; List<GamePlayerModel> get players; List<String> get myHand; int get mySeatIndex; List<String?> get playedCards; int get scoreUs; int get scoreThem; int get teamAScore; int get teamBScore; String get trump; String get status; int get turnIndex; int get currentRound; int get targetScore; String? get gameType; int get dealerIndex; String? get faceUpCard; String? get biddingTeam; String? get fellTeam; TrickModel? get currentTrick; String? get roomId; String? get agoraChannelName; Map<String, dynamic>? get engineState;
/// Create a copy of GameModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameModelCopyWith<GameModel> get copyWith => _$GameModelCopyWithImpl<GameModel>(this as GameModel, _$identity);

  /// Serializes this GameModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameModel&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.players, players)&&const DeepCollectionEquality().equals(other.myHand, myHand)&&(identical(other.mySeatIndex, mySeatIndex) || other.mySeatIndex == mySeatIndex)&&const DeepCollectionEquality().equals(other.playedCards, playedCards)&&(identical(other.scoreUs, scoreUs) || other.scoreUs == scoreUs)&&(identical(other.scoreThem, scoreThem) || other.scoreThem == scoreThem)&&(identical(other.teamAScore, teamAScore) || other.teamAScore == teamAScore)&&(identical(other.teamBScore, teamBScore) || other.teamBScore == teamBScore)&&(identical(other.trump, trump) || other.trump == trump)&&(identical(other.status, status) || other.status == status)&&(identical(other.turnIndex, turnIndex) || other.turnIndex == turnIndex)&&(identical(other.currentRound, currentRound) || other.currentRound == currentRound)&&(identical(other.targetScore, targetScore) || other.targetScore == targetScore)&&(identical(other.gameType, gameType) || other.gameType == gameType)&&(identical(other.dealerIndex, dealerIndex) || other.dealerIndex == dealerIndex)&&(identical(other.faceUpCard, faceUpCard) || other.faceUpCard == faceUpCard)&&(identical(other.biddingTeam, biddingTeam) || other.biddingTeam == biddingTeam)&&(identical(other.fellTeam, fellTeam) || other.fellTeam == fellTeam)&&(identical(other.currentTrick, currentTrick) || other.currentTrick == currentTrick)&&(identical(other.roomId, roomId) || other.roomId == roomId)&&(identical(other.agoraChannelName, agoraChannelName) || other.agoraChannelName == agoraChannelName)&&const DeepCollectionEquality().equals(other.engineState, engineState));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,const DeepCollectionEquality().hash(players),const DeepCollectionEquality().hash(myHand),mySeatIndex,const DeepCollectionEquality().hash(playedCards),scoreUs,scoreThem,teamAScore,teamBScore,trump,status,turnIndex,currentRound,targetScore,gameType,dealerIndex,faceUpCard,biddingTeam,fellTeam,currentTrick,roomId,agoraChannelName,const DeepCollectionEquality().hash(engineState)]);

@override
String toString() {
  return 'GameModel(id: $id, players: $players, myHand: $myHand, mySeatIndex: $mySeatIndex, playedCards: $playedCards, scoreUs: $scoreUs, scoreThem: $scoreThem, teamAScore: $teamAScore, teamBScore: $teamBScore, trump: $trump, status: $status, turnIndex: $turnIndex, currentRound: $currentRound, targetScore: $targetScore, gameType: $gameType, dealerIndex: $dealerIndex, faceUpCard: $faceUpCard, biddingTeam: $biddingTeam, fellTeam: $fellTeam, currentTrick: $currentTrick, roomId: $roomId, agoraChannelName: $agoraChannelName, engineState: $engineState)';
}


}

/// @nodoc
abstract mixin class $GameModelCopyWith<$Res>  {
  factory $GameModelCopyWith(GameModel value, $Res Function(GameModel) _then) = _$GameModelCopyWithImpl;
@useResult
$Res call({
 String id, List<GamePlayerModel> players, List<String> myHand, int mySeatIndex, List<String?> playedCards, int scoreUs, int scoreThem, int teamAScore, int teamBScore, String trump, String status, int turnIndex, int currentRound, int targetScore, String? gameType, int dealerIndex, String? faceUpCard, String? biddingTeam, String? fellTeam, TrickModel? currentTrick, String? roomId, String? agoraChannelName, Map<String, dynamic>? engineState
});


$TrickModelCopyWith<$Res>? get currentTrick;

}
/// @nodoc
class _$GameModelCopyWithImpl<$Res>
    implements $GameModelCopyWith<$Res> {
  _$GameModelCopyWithImpl(this._self, this._then);

  final GameModel _self;
  final $Res Function(GameModel) _then;

/// Create a copy of GameModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? players = null,Object? myHand = null,Object? mySeatIndex = null,Object? playedCards = null,Object? scoreUs = null,Object? scoreThem = null,Object? teamAScore = null,Object? teamBScore = null,Object? trump = null,Object? status = null,Object? turnIndex = null,Object? currentRound = null,Object? targetScore = null,Object? gameType = freezed,Object? dealerIndex = null,Object? faceUpCard = freezed,Object? biddingTeam = freezed,Object? fellTeam = freezed,Object? currentTrick = freezed,Object? roomId = freezed,Object? agoraChannelName = freezed,Object? engineState = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,players: null == players ? _self.players : players // ignore: cast_nullable_to_non_nullable
as List<GamePlayerModel>,myHand: null == myHand ? _self.myHand : myHand // ignore: cast_nullable_to_non_nullable
as List<String>,mySeatIndex: null == mySeatIndex ? _self.mySeatIndex : mySeatIndex // ignore: cast_nullable_to_non_nullable
as int,playedCards: null == playedCards ? _self.playedCards : playedCards // ignore: cast_nullable_to_non_nullable
as List<String?>,scoreUs: null == scoreUs ? _self.scoreUs : scoreUs // ignore: cast_nullable_to_non_nullable
as int,scoreThem: null == scoreThem ? _self.scoreThem : scoreThem // ignore: cast_nullable_to_non_nullable
as int,teamAScore: null == teamAScore ? _self.teamAScore : teamAScore // ignore: cast_nullable_to_non_nullable
as int,teamBScore: null == teamBScore ? _self.teamBScore : teamBScore // ignore: cast_nullable_to_non_nullable
as int,trump: null == trump ? _self.trump : trump // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,turnIndex: null == turnIndex ? _self.turnIndex : turnIndex // ignore: cast_nullable_to_non_nullable
as int,currentRound: null == currentRound ? _self.currentRound : currentRound // ignore: cast_nullable_to_non_nullable
as int,targetScore: null == targetScore ? _self.targetScore : targetScore // ignore: cast_nullable_to_non_nullable
as int,gameType: freezed == gameType ? _self.gameType : gameType // ignore: cast_nullable_to_non_nullable
as String?,dealerIndex: null == dealerIndex ? _self.dealerIndex : dealerIndex // ignore: cast_nullable_to_non_nullable
as int,faceUpCard: freezed == faceUpCard ? _self.faceUpCard : faceUpCard // ignore: cast_nullable_to_non_nullable
as String?,biddingTeam: freezed == biddingTeam ? _self.biddingTeam : biddingTeam // ignore: cast_nullable_to_non_nullable
as String?,fellTeam: freezed == fellTeam ? _self.fellTeam : fellTeam // ignore: cast_nullable_to_non_nullable
as String?,currentTrick: freezed == currentTrick ? _self.currentTrick : currentTrick // ignore: cast_nullable_to_non_nullable
as TrickModel?,roomId: freezed == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as String?,agoraChannelName: freezed == agoraChannelName ? _self.agoraChannelName : agoraChannelName // ignore: cast_nullable_to_non_nullable
as String?,engineState: freezed == engineState ? _self.engineState : engineState // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}
/// Create a copy of GameModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrickModelCopyWith<$Res>? get currentTrick {
    if (_self.currentTrick == null) {
    return null;
  }

  return $TrickModelCopyWith<$Res>(_self.currentTrick!, (value) {
    return _then(_self.copyWith(currentTrick: value));
  });
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  List<GamePlayerModel> players,  List<String> myHand,  int mySeatIndex,  List<String?> playedCards,  int scoreUs,  int scoreThem,  int teamAScore,  int teamBScore,  String trump,  String status,  int turnIndex,  int currentRound,  int targetScore,  String? gameType,  int dealerIndex,  String? faceUpCard,  String? biddingTeam,  String? fellTeam,  TrickModel? currentTrick,  String? roomId,  String? agoraChannelName,  Map<String, dynamic>? engineState)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GameModel() when $default != null:
return $default(_that.id,_that.players,_that.myHand,_that.mySeatIndex,_that.playedCards,_that.scoreUs,_that.scoreThem,_that.teamAScore,_that.teamBScore,_that.trump,_that.status,_that.turnIndex,_that.currentRound,_that.targetScore,_that.gameType,_that.dealerIndex,_that.faceUpCard,_that.biddingTeam,_that.fellTeam,_that.currentTrick,_that.roomId,_that.agoraChannelName,_that.engineState);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  List<GamePlayerModel> players,  List<String> myHand,  int mySeatIndex,  List<String?> playedCards,  int scoreUs,  int scoreThem,  int teamAScore,  int teamBScore,  String trump,  String status,  int turnIndex,  int currentRound,  int targetScore,  String? gameType,  int dealerIndex,  String? faceUpCard,  String? biddingTeam,  String? fellTeam,  TrickModel? currentTrick,  String? roomId,  String? agoraChannelName,  Map<String, dynamic>? engineState)  $default,) {final _that = this;
switch (_that) {
case _GameModel():
return $default(_that.id,_that.players,_that.myHand,_that.mySeatIndex,_that.playedCards,_that.scoreUs,_that.scoreThem,_that.teamAScore,_that.teamBScore,_that.trump,_that.status,_that.turnIndex,_that.currentRound,_that.targetScore,_that.gameType,_that.dealerIndex,_that.faceUpCard,_that.biddingTeam,_that.fellTeam,_that.currentTrick,_that.roomId,_that.agoraChannelName,_that.engineState);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  List<GamePlayerModel> players,  List<String> myHand,  int mySeatIndex,  List<String?> playedCards,  int scoreUs,  int scoreThem,  int teamAScore,  int teamBScore,  String trump,  String status,  int turnIndex,  int currentRound,  int targetScore,  String? gameType,  int dealerIndex,  String? faceUpCard,  String? biddingTeam,  String? fellTeam,  TrickModel? currentTrick,  String? roomId,  String? agoraChannelName,  Map<String, dynamic>? engineState)?  $default,) {final _that = this;
switch (_that) {
case _GameModel() when $default != null:
return $default(_that.id,_that.players,_that.myHand,_that.mySeatIndex,_that.playedCards,_that.scoreUs,_that.scoreThem,_that.teamAScore,_that.teamBScore,_that.trump,_that.status,_that.turnIndex,_that.currentRound,_that.targetScore,_that.gameType,_that.dealerIndex,_that.faceUpCard,_that.biddingTeam,_that.fellTeam,_that.currentTrick,_that.roomId,_that.agoraChannelName,_that.engineState);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GameModel implements GameModel {
  const _GameModel({required this.id, required final  List<GamePlayerModel> players, required final  List<String> myHand, this.mySeatIndex = 0, required final  List<String?> playedCards, required this.scoreUs, required this.scoreThem, this.teamAScore = 0, this.teamBScore = 0, required this.trump, required this.status, required this.turnIndex, required this.currentRound, required this.targetScore, this.gameType, this.dealerIndex = 0, this.faceUpCard, this.biddingTeam, this.fellTeam, this.currentTrick, this.roomId, this.agoraChannelName, final  Map<String, dynamic>? engineState}): _players = players,_myHand = myHand,_playedCards = playedCards,_engineState = engineState;
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

@override@JsonKey() final  int mySeatIndex;
 final  List<String?> _playedCards;
@override List<String?> get playedCards {
  if (_playedCards is EqualUnmodifiableListView) return _playedCards;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_playedCards);
}

@override final  int scoreUs;
@override final  int scoreThem;
@override@JsonKey() final  int teamAScore;
@override@JsonKey() final  int teamBScore;
@override final  String trump;
@override final  String status;
@override final  int turnIndex;
@override final  int currentRound;
@override final  int targetScore;
@override final  String? gameType;
@override@JsonKey() final  int dealerIndex;
@override final  String? faceUpCard;
@override final  String? biddingTeam;
@override final  String? fellTeam;
@override final  TrickModel? currentTrick;
@override final  String? roomId;
@override final  String? agoraChannelName;
 final  Map<String, dynamic>? _engineState;
@override Map<String, dynamic>? get engineState {
  final value = _engineState;
  if (value == null) return null;
  if (_engineState is EqualUnmodifiableMapView) return _engineState;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameModel&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other._players, _players)&&const DeepCollectionEquality().equals(other._myHand, _myHand)&&(identical(other.mySeatIndex, mySeatIndex) || other.mySeatIndex == mySeatIndex)&&const DeepCollectionEquality().equals(other._playedCards, _playedCards)&&(identical(other.scoreUs, scoreUs) || other.scoreUs == scoreUs)&&(identical(other.scoreThem, scoreThem) || other.scoreThem == scoreThem)&&(identical(other.teamAScore, teamAScore) || other.teamAScore == teamAScore)&&(identical(other.teamBScore, teamBScore) || other.teamBScore == teamBScore)&&(identical(other.trump, trump) || other.trump == trump)&&(identical(other.status, status) || other.status == status)&&(identical(other.turnIndex, turnIndex) || other.turnIndex == turnIndex)&&(identical(other.currentRound, currentRound) || other.currentRound == currentRound)&&(identical(other.targetScore, targetScore) || other.targetScore == targetScore)&&(identical(other.gameType, gameType) || other.gameType == gameType)&&(identical(other.dealerIndex, dealerIndex) || other.dealerIndex == dealerIndex)&&(identical(other.faceUpCard, faceUpCard) || other.faceUpCard == faceUpCard)&&(identical(other.biddingTeam, biddingTeam) || other.biddingTeam == biddingTeam)&&(identical(other.fellTeam, fellTeam) || other.fellTeam == fellTeam)&&(identical(other.currentTrick, currentTrick) || other.currentTrick == currentTrick)&&(identical(other.roomId, roomId) || other.roomId == roomId)&&(identical(other.agoraChannelName, agoraChannelName) || other.agoraChannelName == agoraChannelName)&&const DeepCollectionEquality().equals(other._engineState, _engineState));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,const DeepCollectionEquality().hash(_players),const DeepCollectionEquality().hash(_myHand),mySeatIndex,const DeepCollectionEquality().hash(_playedCards),scoreUs,scoreThem,teamAScore,teamBScore,trump,status,turnIndex,currentRound,targetScore,gameType,dealerIndex,faceUpCard,biddingTeam,fellTeam,currentTrick,roomId,agoraChannelName,const DeepCollectionEquality().hash(_engineState)]);

@override
String toString() {
  return 'GameModel(id: $id, players: $players, myHand: $myHand, mySeatIndex: $mySeatIndex, playedCards: $playedCards, scoreUs: $scoreUs, scoreThem: $scoreThem, teamAScore: $teamAScore, teamBScore: $teamBScore, trump: $trump, status: $status, turnIndex: $turnIndex, currentRound: $currentRound, targetScore: $targetScore, gameType: $gameType, dealerIndex: $dealerIndex, faceUpCard: $faceUpCard, biddingTeam: $biddingTeam, fellTeam: $fellTeam, currentTrick: $currentTrick, roomId: $roomId, agoraChannelName: $agoraChannelName, engineState: $engineState)';
}


}

/// @nodoc
abstract mixin class _$GameModelCopyWith<$Res> implements $GameModelCopyWith<$Res> {
  factory _$GameModelCopyWith(_GameModel value, $Res Function(_GameModel) _then) = __$GameModelCopyWithImpl;
@override @useResult
$Res call({
 String id, List<GamePlayerModel> players, List<String> myHand, int mySeatIndex, List<String?> playedCards, int scoreUs, int scoreThem, int teamAScore, int teamBScore, String trump, String status, int turnIndex, int currentRound, int targetScore, String? gameType, int dealerIndex, String? faceUpCard, String? biddingTeam, String? fellTeam, TrickModel? currentTrick, String? roomId, String? agoraChannelName, Map<String, dynamic>? engineState
});


@override $TrickModelCopyWith<$Res>? get currentTrick;

}
/// @nodoc
class __$GameModelCopyWithImpl<$Res>
    implements _$GameModelCopyWith<$Res> {
  __$GameModelCopyWithImpl(this._self, this._then);

  final _GameModel _self;
  final $Res Function(_GameModel) _then;

/// Create a copy of GameModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? players = null,Object? myHand = null,Object? mySeatIndex = null,Object? playedCards = null,Object? scoreUs = null,Object? scoreThem = null,Object? teamAScore = null,Object? teamBScore = null,Object? trump = null,Object? status = null,Object? turnIndex = null,Object? currentRound = null,Object? targetScore = null,Object? gameType = freezed,Object? dealerIndex = null,Object? faceUpCard = freezed,Object? biddingTeam = freezed,Object? fellTeam = freezed,Object? currentTrick = freezed,Object? roomId = freezed,Object? agoraChannelName = freezed,Object? engineState = freezed,}) {
  return _then(_GameModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,players: null == players ? _self._players : players // ignore: cast_nullable_to_non_nullable
as List<GamePlayerModel>,myHand: null == myHand ? _self._myHand : myHand // ignore: cast_nullable_to_non_nullable
as List<String>,mySeatIndex: null == mySeatIndex ? _self.mySeatIndex : mySeatIndex // ignore: cast_nullable_to_non_nullable
as int,playedCards: null == playedCards ? _self._playedCards : playedCards // ignore: cast_nullable_to_non_nullable
as List<String?>,scoreUs: null == scoreUs ? _self.scoreUs : scoreUs // ignore: cast_nullable_to_non_nullable
as int,scoreThem: null == scoreThem ? _self.scoreThem : scoreThem // ignore: cast_nullable_to_non_nullable
as int,teamAScore: null == teamAScore ? _self.teamAScore : teamAScore // ignore: cast_nullable_to_non_nullable
as int,teamBScore: null == teamBScore ? _self.teamBScore : teamBScore // ignore: cast_nullable_to_non_nullable
as int,trump: null == trump ? _self.trump : trump // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,turnIndex: null == turnIndex ? _self.turnIndex : turnIndex // ignore: cast_nullable_to_non_nullable
as int,currentRound: null == currentRound ? _self.currentRound : currentRound // ignore: cast_nullable_to_non_nullable
as int,targetScore: null == targetScore ? _self.targetScore : targetScore // ignore: cast_nullable_to_non_nullable
as int,gameType: freezed == gameType ? _self.gameType : gameType // ignore: cast_nullable_to_non_nullable
as String?,dealerIndex: null == dealerIndex ? _self.dealerIndex : dealerIndex // ignore: cast_nullable_to_non_nullable
as int,faceUpCard: freezed == faceUpCard ? _self.faceUpCard : faceUpCard // ignore: cast_nullable_to_non_nullable
as String?,biddingTeam: freezed == biddingTeam ? _self.biddingTeam : biddingTeam // ignore: cast_nullable_to_non_nullable
as String?,fellTeam: freezed == fellTeam ? _self.fellTeam : fellTeam // ignore: cast_nullable_to_non_nullable
as String?,currentTrick: freezed == currentTrick ? _self.currentTrick : currentTrick // ignore: cast_nullable_to_non_nullable
as TrickModel?,roomId: freezed == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as String?,agoraChannelName: freezed == agoraChannelName ? _self.agoraChannelName : agoraChannelName // ignore: cast_nullable_to_non_nullable
as String?,engineState: freezed == engineState ? _self._engineState : engineState // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

/// Create a copy of GameModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrickModelCopyWith<$Res>? get currentTrick {
    if (_self.currentTrick == null) {
    return null;
  }

  return $TrickModelCopyWith<$Res>(_self.currentTrick!, (value) {
    return _then(_self.copyWith(currentTrick: value));
  });
}
}


/// @nodoc
mixin _$GamePlayerModel {

 String get uid; String get name; String get avatarUrl; String get team; int get seatIndex; List<String> get hand; List<String> get takenCards; int get tricksWon; String? get bid; bool get isActive; bool get isMuted; bool get hasCamera; bool get isTop; bool get isConnected; int? get agoraUid; bool get isSpeaking;
/// Create a copy of GamePlayerModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GamePlayerModelCopyWith<GamePlayerModel> get copyWith => _$GamePlayerModelCopyWithImpl<GamePlayerModel>(this as GamePlayerModel, _$identity);

  /// Serializes this GamePlayerModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GamePlayerModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.team, team) || other.team == team)&&(identical(other.seatIndex, seatIndex) || other.seatIndex == seatIndex)&&const DeepCollectionEquality().equals(other.hand, hand)&&const DeepCollectionEquality().equals(other.takenCards, takenCards)&&(identical(other.tricksWon, tricksWon) || other.tricksWon == tricksWon)&&(identical(other.bid, bid) || other.bid == bid)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isMuted, isMuted) || other.isMuted == isMuted)&&(identical(other.hasCamera, hasCamera) || other.hasCamera == hasCamera)&&(identical(other.isTop, isTop) || other.isTop == isTop)&&(identical(other.isConnected, isConnected) || other.isConnected == isConnected)&&(identical(other.agoraUid, agoraUid) || other.agoraUid == agoraUid)&&(identical(other.isSpeaking, isSpeaking) || other.isSpeaking == isSpeaking));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,name,avatarUrl,team,seatIndex,const DeepCollectionEquality().hash(hand),const DeepCollectionEquality().hash(takenCards),tricksWon,bid,isActive,isMuted,hasCamera,isTop,isConnected,agoraUid,isSpeaking);

@override
String toString() {
  return 'GamePlayerModel(uid: $uid, name: $name, avatarUrl: $avatarUrl, team: $team, seatIndex: $seatIndex, hand: $hand, takenCards: $takenCards, tricksWon: $tricksWon, bid: $bid, isActive: $isActive, isMuted: $isMuted, hasCamera: $hasCamera, isTop: $isTop, isConnected: $isConnected, agoraUid: $agoraUid, isSpeaking: $isSpeaking)';
}


}

/// @nodoc
abstract mixin class $GamePlayerModelCopyWith<$Res>  {
  factory $GamePlayerModelCopyWith(GamePlayerModel value, $Res Function(GamePlayerModel) _then) = _$GamePlayerModelCopyWithImpl;
@useResult
$Res call({
 String uid, String name, String avatarUrl, String team, int seatIndex, List<String> hand, List<String> takenCards, int tricksWon, String? bid, bool isActive, bool isMuted, bool hasCamera, bool isTop, bool isConnected, int? agoraUid, bool isSpeaking
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
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? name = null,Object? avatarUrl = null,Object? team = null,Object? seatIndex = null,Object? hand = null,Object? takenCards = null,Object? tricksWon = null,Object? bid = freezed,Object? isActive = null,Object? isMuted = null,Object? hasCamera = null,Object? isTop = null,Object? isConnected = null,Object? agoraUid = freezed,Object? isSpeaking = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,team: null == team ? _self.team : team // ignore: cast_nullable_to_non_nullable
as String,seatIndex: null == seatIndex ? _self.seatIndex : seatIndex // ignore: cast_nullable_to_non_nullable
as int,hand: null == hand ? _self.hand : hand // ignore: cast_nullable_to_non_nullable
as List<String>,takenCards: null == takenCards ? _self.takenCards : takenCards // ignore: cast_nullable_to_non_nullable
as List<String>,tricksWon: null == tricksWon ? _self.tricksWon : tricksWon // ignore: cast_nullable_to_non_nullable
as int,bid: freezed == bid ? _self.bid : bid // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isMuted: null == isMuted ? _self.isMuted : isMuted // ignore: cast_nullable_to_non_nullable
as bool,hasCamera: null == hasCamera ? _self.hasCamera : hasCamera // ignore: cast_nullable_to_non_nullable
as bool,isTop: null == isTop ? _self.isTop : isTop // ignore: cast_nullable_to_non_nullable
as bool,isConnected: null == isConnected ? _self.isConnected : isConnected // ignore: cast_nullable_to_non_nullable
as bool,agoraUid: freezed == agoraUid ? _self.agoraUid : agoraUid // ignore: cast_nullable_to_non_nullable
as int?,isSpeaking: null == isSpeaking ? _self.isSpeaking : isSpeaking // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String name,  String avatarUrl,  String team,  int seatIndex,  List<String> hand,  List<String> takenCards,  int tricksWon,  String? bid,  bool isActive,  bool isMuted,  bool hasCamera,  bool isTop,  bool isConnected,  int? agoraUid,  bool isSpeaking)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GamePlayerModel() when $default != null:
return $default(_that.uid,_that.name,_that.avatarUrl,_that.team,_that.seatIndex,_that.hand,_that.takenCards,_that.tricksWon,_that.bid,_that.isActive,_that.isMuted,_that.hasCamera,_that.isTop,_that.isConnected,_that.agoraUid,_that.isSpeaking);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String name,  String avatarUrl,  String team,  int seatIndex,  List<String> hand,  List<String> takenCards,  int tricksWon,  String? bid,  bool isActive,  bool isMuted,  bool hasCamera,  bool isTop,  bool isConnected,  int? agoraUid,  bool isSpeaking)  $default,) {final _that = this;
switch (_that) {
case _GamePlayerModel():
return $default(_that.uid,_that.name,_that.avatarUrl,_that.team,_that.seatIndex,_that.hand,_that.takenCards,_that.tricksWon,_that.bid,_that.isActive,_that.isMuted,_that.hasCamera,_that.isTop,_that.isConnected,_that.agoraUid,_that.isSpeaking);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String name,  String avatarUrl,  String team,  int seatIndex,  List<String> hand,  List<String> takenCards,  int tricksWon,  String? bid,  bool isActive,  bool isMuted,  bool hasCamera,  bool isTop,  bool isConnected,  int? agoraUid,  bool isSpeaking)?  $default,) {final _that = this;
switch (_that) {
case _GamePlayerModel() when $default != null:
return $default(_that.uid,_that.name,_that.avatarUrl,_that.team,_that.seatIndex,_that.hand,_that.takenCards,_that.tricksWon,_that.bid,_that.isActive,_that.isMuted,_that.hasCamera,_that.isTop,_that.isConnected,_that.agoraUid,_that.isSpeaking);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GamePlayerModel implements GamePlayerModel {
  const _GamePlayerModel({required this.uid, required this.name, required this.avatarUrl, required this.team, required this.seatIndex, final  List<String> hand = const <String>[], final  List<String> takenCards = const <String>[], this.tricksWon = 0, this.bid, this.isActive = false, this.isMuted = false, this.hasCamera = true, this.isTop = false, this.isConnected = true, this.agoraUid, this.isSpeaking = false}): _hand = hand,_takenCards = takenCards;
  factory _GamePlayerModel.fromJson(Map<String, dynamic> json) => _$GamePlayerModelFromJson(json);

@override final  String uid;
@override final  String name;
@override final  String avatarUrl;
@override final  String team;
@override final  int seatIndex;
 final  List<String> _hand;
@override@JsonKey() List<String> get hand {
  if (_hand is EqualUnmodifiableListView) return _hand;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hand);
}

 final  List<String> _takenCards;
@override@JsonKey() List<String> get takenCards {
  if (_takenCards is EqualUnmodifiableListView) return _takenCards;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_takenCards);
}

@override@JsonKey() final  int tricksWon;
@override final  String? bid;
@override@JsonKey() final  bool isActive;
@override@JsonKey() final  bool isMuted;
@override@JsonKey() final  bool hasCamera;
@override@JsonKey() final  bool isTop;
@override@JsonKey() final  bool isConnected;
@override final  int? agoraUid;
@override@JsonKey() final  bool isSpeaking;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GamePlayerModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.team, team) || other.team == team)&&(identical(other.seatIndex, seatIndex) || other.seatIndex == seatIndex)&&const DeepCollectionEquality().equals(other._hand, _hand)&&const DeepCollectionEquality().equals(other._takenCards, _takenCards)&&(identical(other.tricksWon, tricksWon) || other.tricksWon == tricksWon)&&(identical(other.bid, bid) || other.bid == bid)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isMuted, isMuted) || other.isMuted == isMuted)&&(identical(other.hasCamera, hasCamera) || other.hasCamera == hasCamera)&&(identical(other.isTop, isTop) || other.isTop == isTop)&&(identical(other.isConnected, isConnected) || other.isConnected == isConnected)&&(identical(other.agoraUid, agoraUid) || other.agoraUid == agoraUid)&&(identical(other.isSpeaking, isSpeaking) || other.isSpeaking == isSpeaking));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,name,avatarUrl,team,seatIndex,const DeepCollectionEquality().hash(_hand),const DeepCollectionEquality().hash(_takenCards),tricksWon,bid,isActive,isMuted,hasCamera,isTop,isConnected,agoraUid,isSpeaking);

@override
String toString() {
  return 'GamePlayerModel(uid: $uid, name: $name, avatarUrl: $avatarUrl, team: $team, seatIndex: $seatIndex, hand: $hand, takenCards: $takenCards, tricksWon: $tricksWon, bid: $bid, isActive: $isActive, isMuted: $isMuted, hasCamera: $hasCamera, isTop: $isTop, isConnected: $isConnected, agoraUid: $agoraUid, isSpeaking: $isSpeaking)';
}


}

/// @nodoc
abstract mixin class _$GamePlayerModelCopyWith<$Res> implements $GamePlayerModelCopyWith<$Res> {
  factory _$GamePlayerModelCopyWith(_GamePlayerModel value, $Res Function(_GamePlayerModel) _then) = __$GamePlayerModelCopyWithImpl;
@override @useResult
$Res call({
 String uid, String name, String avatarUrl, String team, int seatIndex, List<String> hand, List<String> takenCards, int tricksWon, String? bid, bool isActive, bool isMuted, bool hasCamera, bool isTop, bool isConnected, int? agoraUid, bool isSpeaking
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
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? name = null,Object? avatarUrl = null,Object? team = null,Object? seatIndex = null,Object? hand = null,Object? takenCards = null,Object? tricksWon = null,Object? bid = freezed,Object? isActive = null,Object? isMuted = null,Object? hasCamera = null,Object? isTop = null,Object? isConnected = null,Object? agoraUid = freezed,Object? isSpeaking = null,}) {
  return _then(_GamePlayerModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,team: null == team ? _self.team : team // ignore: cast_nullable_to_non_nullable
as String,seatIndex: null == seatIndex ? _self.seatIndex : seatIndex // ignore: cast_nullable_to_non_nullable
as int,hand: null == hand ? _self._hand : hand // ignore: cast_nullable_to_non_nullable
as List<String>,takenCards: null == takenCards ? _self._takenCards : takenCards // ignore: cast_nullable_to_non_nullable
as List<String>,tricksWon: null == tricksWon ? _self.tricksWon : tricksWon // ignore: cast_nullable_to_non_nullable
as int,bid: freezed == bid ? _self.bid : bid // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isMuted: null == isMuted ? _self.isMuted : isMuted // ignore: cast_nullable_to_non_nullable
as bool,hasCamera: null == hasCamera ? _self.hasCamera : hasCamera // ignore: cast_nullable_to_non_nullable
as bool,isTop: null == isTop ? _self.isTop : isTop // ignore: cast_nullable_to_non_nullable
as bool,isConnected: null == isConnected ? _self.isConnected : isConnected // ignore: cast_nullable_to_non_nullable
as bool,agoraUid: freezed == agoraUid ? _self.agoraUid : agoraUid // ignore: cast_nullable_to_non_nullable
as int?,isSpeaking: null == isSpeaking ? _self.isSpeaking : isSpeaking // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$TrickModel {

 int get trickNumber; int get trickLeaderIndex; String? get leadingSuit; Map<String, String?> get cards; int? get winnerSeat;
/// Create a copy of TrickModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrickModelCopyWith<TrickModel> get copyWith => _$TrickModelCopyWithImpl<TrickModel>(this as TrickModel, _$identity);

  /// Serializes this TrickModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrickModel&&(identical(other.trickNumber, trickNumber) || other.trickNumber == trickNumber)&&(identical(other.trickLeaderIndex, trickLeaderIndex) || other.trickLeaderIndex == trickLeaderIndex)&&(identical(other.leadingSuit, leadingSuit) || other.leadingSuit == leadingSuit)&&const DeepCollectionEquality().equals(other.cards, cards)&&(identical(other.winnerSeat, winnerSeat) || other.winnerSeat == winnerSeat));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,trickNumber,trickLeaderIndex,leadingSuit,const DeepCollectionEquality().hash(cards),winnerSeat);

@override
String toString() {
  return 'TrickModel(trickNumber: $trickNumber, trickLeaderIndex: $trickLeaderIndex, leadingSuit: $leadingSuit, cards: $cards, winnerSeat: $winnerSeat)';
}


}

/// @nodoc
abstract mixin class $TrickModelCopyWith<$Res>  {
  factory $TrickModelCopyWith(TrickModel value, $Res Function(TrickModel) _then) = _$TrickModelCopyWithImpl;
@useResult
$Res call({
 int trickNumber, int trickLeaderIndex, String? leadingSuit, Map<String, String?> cards, int? winnerSeat
});




}
/// @nodoc
class _$TrickModelCopyWithImpl<$Res>
    implements $TrickModelCopyWith<$Res> {
  _$TrickModelCopyWithImpl(this._self, this._then);

  final TrickModel _self;
  final $Res Function(TrickModel) _then;

/// Create a copy of TrickModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? trickNumber = null,Object? trickLeaderIndex = null,Object? leadingSuit = freezed,Object? cards = null,Object? winnerSeat = freezed,}) {
  return _then(_self.copyWith(
trickNumber: null == trickNumber ? _self.trickNumber : trickNumber // ignore: cast_nullable_to_non_nullable
as int,trickLeaderIndex: null == trickLeaderIndex ? _self.trickLeaderIndex : trickLeaderIndex // ignore: cast_nullable_to_non_nullable
as int,leadingSuit: freezed == leadingSuit ? _self.leadingSuit : leadingSuit // ignore: cast_nullable_to_non_nullable
as String?,cards: null == cards ? _self.cards : cards // ignore: cast_nullable_to_non_nullable
as Map<String, String?>,winnerSeat: freezed == winnerSeat ? _self.winnerSeat : winnerSeat // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [TrickModel].
extension TrickModelPatterns on TrickModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrickModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrickModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrickModel value)  $default,){
final _that = this;
switch (_that) {
case _TrickModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrickModel value)?  $default,){
final _that = this;
switch (_that) {
case _TrickModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int trickNumber,  int trickLeaderIndex,  String? leadingSuit,  Map<String, String?> cards,  int? winnerSeat)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrickModel() when $default != null:
return $default(_that.trickNumber,_that.trickLeaderIndex,_that.leadingSuit,_that.cards,_that.winnerSeat);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int trickNumber,  int trickLeaderIndex,  String? leadingSuit,  Map<String, String?> cards,  int? winnerSeat)  $default,) {final _that = this;
switch (_that) {
case _TrickModel():
return $default(_that.trickNumber,_that.trickLeaderIndex,_that.leadingSuit,_that.cards,_that.winnerSeat);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int trickNumber,  int trickLeaderIndex,  String? leadingSuit,  Map<String, String?> cards,  int? winnerSeat)?  $default,) {final _that = this;
switch (_that) {
case _TrickModel() when $default != null:
return $default(_that.trickNumber,_that.trickLeaderIndex,_that.leadingSuit,_that.cards,_that.winnerSeat);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrickModel implements TrickModel {
  const _TrickModel({required this.trickNumber, required this.trickLeaderIndex, this.leadingSuit, final  Map<String, String?> cards = const <String, String?>{}, this.winnerSeat}): _cards = cards;
  factory _TrickModel.fromJson(Map<String, dynamic> json) => _$TrickModelFromJson(json);

@override final  int trickNumber;
@override final  int trickLeaderIndex;
@override final  String? leadingSuit;
 final  Map<String, String?> _cards;
@override@JsonKey() Map<String, String?> get cards {
  if (_cards is EqualUnmodifiableMapView) return _cards;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_cards);
}

@override final  int? winnerSeat;

/// Create a copy of TrickModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrickModelCopyWith<_TrickModel> get copyWith => __$TrickModelCopyWithImpl<_TrickModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrickModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrickModel&&(identical(other.trickNumber, trickNumber) || other.trickNumber == trickNumber)&&(identical(other.trickLeaderIndex, trickLeaderIndex) || other.trickLeaderIndex == trickLeaderIndex)&&(identical(other.leadingSuit, leadingSuit) || other.leadingSuit == leadingSuit)&&const DeepCollectionEquality().equals(other._cards, _cards)&&(identical(other.winnerSeat, winnerSeat) || other.winnerSeat == winnerSeat));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,trickNumber,trickLeaderIndex,leadingSuit,const DeepCollectionEquality().hash(_cards),winnerSeat);

@override
String toString() {
  return 'TrickModel(trickNumber: $trickNumber, trickLeaderIndex: $trickLeaderIndex, leadingSuit: $leadingSuit, cards: $cards, winnerSeat: $winnerSeat)';
}


}

/// @nodoc
abstract mixin class _$TrickModelCopyWith<$Res> implements $TrickModelCopyWith<$Res> {
  factory _$TrickModelCopyWith(_TrickModel value, $Res Function(_TrickModel) _then) = __$TrickModelCopyWithImpl;
@override @useResult
$Res call({
 int trickNumber, int trickLeaderIndex, String? leadingSuit, Map<String, String?> cards, int? winnerSeat
});




}
/// @nodoc
class __$TrickModelCopyWithImpl<$Res>
    implements _$TrickModelCopyWith<$Res> {
  __$TrickModelCopyWithImpl(this._self, this._then);

  final _TrickModel _self;
  final $Res Function(_TrickModel) _then;

/// Create a copy of TrickModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? trickNumber = null,Object? trickLeaderIndex = null,Object? leadingSuit = freezed,Object? cards = null,Object? winnerSeat = freezed,}) {
  return _then(_TrickModel(
trickNumber: null == trickNumber ? _self.trickNumber : trickNumber // ignore: cast_nullable_to_non_nullable
as int,trickLeaderIndex: null == trickLeaderIndex ? _self.trickLeaderIndex : trickLeaderIndex // ignore: cast_nullable_to_non_nullable
as int,leadingSuit: freezed == leadingSuit ? _self.leadingSuit : leadingSuit // ignore: cast_nullable_to_non_nullable
as String?,cards: null == cards ? _self._cards : cards // ignore: cast_nullable_to_non_nullable
as Map<String, String?>,winnerSeat: freezed == winnerSeat ? _self.winnerSeat : winnerSeat // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
