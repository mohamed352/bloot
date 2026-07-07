// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'room_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RoomModel {

 String get id; String get name; String get type; bool get voiceEnabled; bool get cameraEnabled; bool get allowSpectators; String get gameSpeed; String? get password; String? get creatorUid; String? get inviteCode; String? get agoraChannelName; List<RoomPlayerModel> get players; String get status; String? get gameId; bool get isStreaming; String? get streamId;
/// Create a copy of RoomModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoomModelCopyWith<RoomModel> get copyWith => _$RoomModelCopyWithImpl<RoomModel>(this as RoomModel, _$identity);

  /// Serializes this RoomModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoomModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.voiceEnabled, voiceEnabled) || other.voiceEnabled == voiceEnabled)&&(identical(other.cameraEnabled, cameraEnabled) || other.cameraEnabled == cameraEnabled)&&(identical(other.allowSpectators, allowSpectators) || other.allowSpectators == allowSpectators)&&(identical(other.gameSpeed, gameSpeed) || other.gameSpeed == gameSpeed)&&(identical(other.password, password) || other.password == password)&&(identical(other.creatorUid, creatorUid) || other.creatorUid == creatorUid)&&(identical(other.inviteCode, inviteCode) || other.inviteCode == inviteCode)&&(identical(other.agoraChannelName, agoraChannelName) || other.agoraChannelName == agoraChannelName)&&const DeepCollectionEquality().equals(other.players, players)&&(identical(other.status, status) || other.status == status)&&(identical(other.gameId, gameId) || other.gameId == gameId)&&(identical(other.isStreaming, isStreaming) || other.isStreaming == isStreaming)&&(identical(other.streamId, streamId) || other.streamId == streamId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,voiceEnabled,cameraEnabled,allowSpectators,gameSpeed,password,creatorUid,inviteCode,agoraChannelName,const DeepCollectionEquality().hash(players),status,gameId,isStreaming,streamId);

@override
String toString() {
  return 'RoomModel(id: $id, name: $name, type: $type, voiceEnabled: $voiceEnabled, cameraEnabled: $cameraEnabled, allowSpectators: $allowSpectators, gameSpeed: $gameSpeed, password: $password, creatorUid: $creatorUid, inviteCode: $inviteCode, agoraChannelName: $agoraChannelName, players: $players, status: $status, gameId: $gameId, isStreaming: $isStreaming, streamId: $streamId)';
}


}

/// @nodoc
abstract mixin class $RoomModelCopyWith<$Res>  {
  factory $RoomModelCopyWith(RoomModel value, $Res Function(RoomModel) _then) = _$RoomModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String type, bool voiceEnabled, bool cameraEnabled, bool allowSpectators, String gameSpeed, String? password, String? creatorUid, String? inviteCode, String? agoraChannelName, List<RoomPlayerModel> players, String status, String? gameId, bool isStreaming, String? streamId
});




}
/// @nodoc
class _$RoomModelCopyWithImpl<$Res>
    implements $RoomModelCopyWith<$Res> {
  _$RoomModelCopyWithImpl(this._self, this._then);

  final RoomModel _self;
  final $Res Function(RoomModel) _then;

/// Create a copy of RoomModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = null,Object? voiceEnabled = null,Object? cameraEnabled = null,Object? allowSpectators = null,Object? gameSpeed = null,Object? password = freezed,Object? creatorUid = freezed,Object? inviteCode = freezed,Object? agoraChannelName = freezed,Object? players = null,Object? status = null,Object? gameId = freezed,Object? isStreaming = null,Object? streamId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,voiceEnabled: null == voiceEnabled ? _self.voiceEnabled : voiceEnabled // ignore: cast_nullable_to_non_nullable
as bool,cameraEnabled: null == cameraEnabled ? _self.cameraEnabled : cameraEnabled // ignore: cast_nullable_to_non_nullable
as bool,allowSpectators: null == allowSpectators ? _self.allowSpectators : allowSpectators // ignore: cast_nullable_to_non_nullable
as bool,gameSpeed: null == gameSpeed ? _self.gameSpeed : gameSpeed // ignore: cast_nullable_to_non_nullable
as String,password: freezed == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String?,creatorUid: freezed == creatorUid ? _self.creatorUid : creatorUid // ignore: cast_nullable_to_non_nullable
as String?,inviteCode: freezed == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String?,agoraChannelName: freezed == agoraChannelName ? _self.agoraChannelName : agoraChannelName // ignore: cast_nullable_to_non_nullable
as String?,players: null == players ? _self.players : players // ignore: cast_nullable_to_non_nullable
as List<RoomPlayerModel>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,gameId: freezed == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as String?,isStreaming: null == isStreaming ? _self.isStreaming : isStreaming // ignore: cast_nullable_to_non_nullable
as bool,streamId: freezed == streamId ? _self.streamId : streamId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RoomModel].
extension RoomModelPatterns on RoomModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoomModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoomModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoomModel value)  $default,){
final _that = this;
switch (_that) {
case _RoomModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoomModel value)?  $default,){
final _that = this;
switch (_that) {
case _RoomModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String type,  bool voiceEnabled,  bool cameraEnabled,  bool allowSpectators,  String gameSpeed,  String? password,  String? creatorUid,  String? inviteCode,  String? agoraChannelName,  List<RoomPlayerModel> players,  String status,  String? gameId,  bool isStreaming,  String? streamId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoomModel() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.voiceEnabled,_that.cameraEnabled,_that.allowSpectators,_that.gameSpeed,_that.password,_that.creatorUid,_that.inviteCode,_that.agoraChannelName,_that.players,_that.status,_that.gameId,_that.isStreaming,_that.streamId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String type,  bool voiceEnabled,  bool cameraEnabled,  bool allowSpectators,  String gameSpeed,  String? password,  String? creatorUid,  String? inviteCode,  String? agoraChannelName,  List<RoomPlayerModel> players,  String status,  String? gameId,  bool isStreaming,  String? streamId)  $default,) {final _that = this;
switch (_that) {
case _RoomModel():
return $default(_that.id,_that.name,_that.type,_that.voiceEnabled,_that.cameraEnabled,_that.allowSpectators,_that.gameSpeed,_that.password,_that.creatorUid,_that.inviteCode,_that.agoraChannelName,_that.players,_that.status,_that.gameId,_that.isStreaming,_that.streamId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String type,  bool voiceEnabled,  bool cameraEnabled,  bool allowSpectators,  String gameSpeed,  String? password,  String? creatorUid,  String? inviteCode,  String? agoraChannelName,  List<RoomPlayerModel> players,  String status,  String? gameId,  bool isStreaming,  String? streamId)?  $default,) {final _that = this;
switch (_that) {
case _RoomModel() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.voiceEnabled,_that.cameraEnabled,_that.allowSpectators,_that.gameSpeed,_that.password,_that.creatorUid,_that.inviteCode,_that.agoraChannelName,_that.players,_that.status,_that.gameId,_that.isStreaming,_that.streamId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RoomModel implements RoomModel {
  const _RoomModel({required this.id, required this.name, required this.type, this.voiceEnabled = true, this.cameraEnabled = false, this.allowSpectators = true, this.gameSpeed = 'normal', this.password, this.creatorUid, this.inviteCode, this.agoraChannelName, final  List<RoomPlayerModel> players = const <RoomPlayerModel>[], this.status = 'waiting', this.gameId, this.isStreaming = false, this.streamId}): _players = players;
  factory _RoomModel.fromJson(Map<String, dynamic> json) => _$RoomModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  String type;
@override@JsonKey() final  bool voiceEnabled;
@override@JsonKey() final  bool cameraEnabled;
@override@JsonKey() final  bool allowSpectators;
@override@JsonKey() final  String gameSpeed;
@override final  String? password;
@override final  String? creatorUid;
@override final  String? inviteCode;
@override final  String? agoraChannelName;
 final  List<RoomPlayerModel> _players;
@override@JsonKey() List<RoomPlayerModel> get players {
  if (_players is EqualUnmodifiableListView) return _players;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_players);
}

@override@JsonKey() final  String status;
@override final  String? gameId;
@override@JsonKey() final  bool isStreaming;
@override final  String? streamId;

/// Create a copy of RoomModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoomModelCopyWith<_RoomModel> get copyWith => __$RoomModelCopyWithImpl<_RoomModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoomModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoomModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.voiceEnabled, voiceEnabled) || other.voiceEnabled == voiceEnabled)&&(identical(other.cameraEnabled, cameraEnabled) || other.cameraEnabled == cameraEnabled)&&(identical(other.allowSpectators, allowSpectators) || other.allowSpectators == allowSpectators)&&(identical(other.gameSpeed, gameSpeed) || other.gameSpeed == gameSpeed)&&(identical(other.password, password) || other.password == password)&&(identical(other.creatorUid, creatorUid) || other.creatorUid == creatorUid)&&(identical(other.inviteCode, inviteCode) || other.inviteCode == inviteCode)&&(identical(other.agoraChannelName, agoraChannelName) || other.agoraChannelName == agoraChannelName)&&const DeepCollectionEquality().equals(other._players, _players)&&(identical(other.status, status) || other.status == status)&&(identical(other.gameId, gameId) || other.gameId == gameId)&&(identical(other.isStreaming, isStreaming) || other.isStreaming == isStreaming)&&(identical(other.streamId, streamId) || other.streamId == streamId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,voiceEnabled,cameraEnabled,allowSpectators,gameSpeed,password,creatorUid,inviteCode,agoraChannelName,const DeepCollectionEquality().hash(_players),status,gameId,isStreaming,streamId);

@override
String toString() {
  return 'RoomModel(id: $id, name: $name, type: $type, voiceEnabled: $voiceEnabled, cameraEnabled: $cameraEnabled, allowSpectators: $allowSpectators, gameSpeed: $gameSpeed, password: $password, creatorUid: $creatorUid, inviteCode: $inviteCode, agoraChannelName: $agoraChannelName, players: $players, status: $status, gameId: $gameId, isStreaming: $isStreaming, streamId: $streamId)';
}


}

/// @nodoc
abstract mixin class _$RoomModelCopyWith<$Res> implements $RoomModelCopyWith<$Res> {
  factory _$RoomModelCopyWith(_RoomModel value, $Res Function(_RoomModel) _then) = __$RoomModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String type, bool voiceEnabled, bool cameraEnabled, bool allowSpectators, String gameSpeed, String? password, String? creatorUid, String? inviteCode, String? agoraChannelName, List<RoomPlayerModel> players, String status, String? gameId, bool isStreaming, String? streamId
});




}
/// @nodoc
class __$RoomModelCopyWithImpl<$Res>
    implements _$RoomModelCopyWith<$Res> {
  __$RoomModelCopyWithImpl(this._self, this._then);

  final _RoomModel _self;
  final $Res Function(_RoomModel) _then;

/// Create a copy of RoomModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,Object? voiceEnabled = null,Object? cameraEnabled = null,Object? allowSpectators = null,Object? gameSpeed = null,Object? password = freezed,Object? creatorUid = freezed,Object? inviteCode = freezed,Object? agoraChannelName = freezed,Object? players = null,Object? status = null,Object? gameId = freezed,Object? isStreaming = null,Object? streamId = freezed,}) {
  return _then(_RoomModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,voiceEnabled: null == voiceEnabled ? _self.voiceEnabled : voiceEnabled // ignore: cast_nullable_to_non_nullable
as bool,cameraEnabled: null == cameraEnabled ? _self.cameraEnabled : cameraEnabled // ignore: cast_nullable_to_non_nullable
as bool,allowSpectators: null == allowSpectators ? _self.allowSpectators : allowSpectators // ignore: cast_nullable_to_non_nullable
as bool,gameSpeed: null == gameSpeed ? _self.gameSpeed : gameSpeed // ignore: cast_nullable_to_non_nullable
as String,password: freezed == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String?,creatorUid: freezed == creatorUid ? _self.creatorUid : creatorUid // ignore: cast_nullable_to_non_nullable
as String?,inviteCode: freezed == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String?,agoraChannelName: freezed == agoraChannelName ? _self.agoraChannelName : agoraChannelName // ignore: cast_nullable_to_non_nullable
as String?,players: null == players ? _self._players : players // ignore: cast_nullable_to_non_nullable
as List<RoomPlayerModel>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,gameId: freezed == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as String?,isStreaming: null == isStreaming ? _self.isStreaming : isStreaming // ignore: cast_nullable_to_non_nullable
as bool,streamId: freezed == streamId ? _self.streamId : streamId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$RoomPlayerModel {

 String get uid; String get name; String? get avatarUrl; bool get isReady; bool get isMe; String get team; int? get level; bool get isMicOn; bool get isCameraOn; int? get agoraUid; bool get isSpeaking;
/// Create a copy of RoomPlayerModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoomPlayerModelCopyWith<RoomPlayerModel> get copyWith => _$RoomPlayerModelCopyWithImpl<RoomPlayerModel>(this as RoomPlayerModel, _$identity);

  /// Serializes this RoomPlayerModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoomPlayerModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.isReady, isReady) || other.isReady == isReady)&&(identical(other.isMe, isMe) || other.isMe == isMe)&&(identical(other.team, team) || other.team == team)&&(identical(other.level, level) || other.level == level)&&(identical(other.isMicOn, isMicOn) || other.isMicOn == isMicOn)&&(identical(other.isCameraOn, isCameraOn) || other.isCameraOn == isCameraOn)&&(identical(other.agoraUid, agoraUid) || other.agoraUid == agoraUid)&&(identical(other.isSpeaking, isSpeaking) || other.isSpeaking == isSpeaking));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,name,avatarUrl,isReady,isMe,team,level,isMicOn,isCameraOn,agoraUid,isSpeaking);

@override
String toString() {
  return 'RoomPlayerModel(uid: $uid, name: $name, avatarUrl: $avatarUrl, isReady: $isReady, isMe: $isMe, team: $team, level: $level, isMicOn: $isMicOn, isCameraOn: $isCameraOn, agoraUid: $agoraUid, isSpeaking: $isSpeaking)';
}


}

/// @nodoc
abstract mixin class $RoomPlayerModelCopyWith<$Res>  {
  factory $RoomPlayerModelCopyWith(RoomPlayerModel value, $Res Function(RoomPlayerModel) _then) = _$RoomPlayerModelCopyWithImpl;
@useResult
$Res call({
 String uid, String name, String? avatarUrl, bool isReady, bool isMe, String team, int? level, bool isMicOn, bool isCameraOn, int? agoraUid, bool isSpeaking
});




}
/// @nodoc
class _$RoomPlayerModelCopyWithImpl<$Res>
    implements $RoomPlayerModelCopyWith<$Res> {
  _$RoomPlayerModelCopyWithImpl(this._self, this._then);

  final RoomPlayerModel _self;
  final $Res Function(RoomPlayerModel) _then;

/// Create a copy of RoomPlayerModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? name = null,Object? avatarUrl = freezed,Object? isReady = null,Object? isMe = null,Object? team = null,Object? level = freezed,Object? isMicOn = null,Object? isCameraOn = null,Object? agoraUid = freezed,Object? isSpeaking = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,isReady: null == isReady ? _self.isReady : isReady // ignore: cast_nullable_to_non_nullable
as bool,isMe: null == isMe ? _self.isMe : isMe // ignore: cast_nullable_to_non_nullable
as bool,team: null == team ? _self.team : team // ignore: cast_nullable_to_non_nullable
as String,level: freezed == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int?,isMicOn: null == isMicOn ? _self.isMicOn : isMicOn // ignore: cast_nullable_to_non_nullable
as bool,isCameraOn: null == isCameraOn ? _self.isCameraOn : isCameraOn // ignore: cast_nullable_to_non_nullable
as bool,agoraUid: freezed == agoraUid ? _self.agoraUid : agoraUid // ignore: cast_nullable_to_non_nullable
as int?,isSpeaking: null == isSpeaking ? _self.isSpeaking : isSpeaking // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RoomPlayerModel].
extension RoomPlayerModelPatterns on RoomPlayerModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoomPlayerModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoomPlayerModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoomPlayerModel value)  $default,){
final _that = this;
switch (_that) {
case _RoomPlayerModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoomPlayerModel value)?  $default,){
final _that = this;
switch (_that) {
case _RoomPlayerModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String name,  String? avatarUrl,  bool isReady,  bool isMe,  String team,  int? level,  bool isMicOn,  bool isCameraOn,  int? agoraUid,  bool isSpeaking)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoomPlayerModel() when $default != null:
return $default(_that.uid,_that.name,_that.avatarUrl,_that.isReady,_that.isMe,_that.team,_that.level,_that.isMicOn,_that.isCameraOn,_that.agoraUid,_that.isSpeaking);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String name,  String? avatarUrl,  bool isReady,  bool isMe,  String team,  int? level,  bool isMicOn,  bool isCameraOn,  int? agoraUid,  bool isSpeaking)  $default,) {final _that = this;
switch (_that) {
case _RoomPlayerModel():
return $default(_that.uid,_that.name,_that.avatarUrl,_that.isReady,_that.isMe,_that.team,_that.level,_that.isMicOn,_that.isCameraOn,_that.agoraUid,_that.isSpeaking);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String name,  String? avatarUrl,  bool isReady,  bool isMe,  String team,  int? level,  bool isMicOn,  bool isCameraOn,  int? agoraUid,  bool isSpeaking)?  $default,) {final _that = this;
switch (_that) {
case _RoomPlayerModel() when $default != null:
return $default(_that.uid,_that.name,_that.avatarUrl,_that.isReady,_that.isMe,_that.team,_that.level,_that.isMicOn,_that.isCameraOn,_that.agoraUid,_that.isSpeaking);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RoomPlayerModel implements RoomPlayerModel {
  const _RoomPlayerModel({required this.uid, required this.name, this.avatarUrl, this.isReady = false, this.isMe = false, this.team = 'A', this.level, this.isMicOn = true, this.isCameraOn = false, this.agoraUid, this.isSpeaking = false});
  factory _RoomPlayerModel.fromJson(Map<String, dynamic> json) => _$RoomPlayerModelFromJson(json);

@override final  String uid;
@override final  String name;
@override final  String? avatarUrl;
@override@JsonKey() final  bool isReady;
@override@JsonKey() final  bool isMe;
@override@JsonKey() final  String team;
@override final  int? level;
@override@JsonKey() final  bool isMicOn;
@override@JsonKey() final  bool isCameraOn;
@override final  int? agoraUid;
@override@JsonKey() final  bool isSpeaking;

/// Create a copy of RoomPlayerModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoomPlayerModelCopyWith<_RoomPlayerModel> get copyWith => __$RoomPlayerModelCopyWithImpl<_RoomPlayerModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoomPlayerModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoomPlayerModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.isReady, isReady) || other.isReady == isReady)&&(identical(other.isMe, isMe) || other.isMe == isMe)&&(identical(other.team, team) || other.team == team)&&(identical(other.level, level) || other.level == level)&&(identical(other.isMicOn, isMicOn) || other.isMicOn == isMicOn)&&(identical(other.isCameraOn, isCameraOn) || other.isCameraOn == isCameraOn)&&(identical(other.agoraUid, agoraUid) || other.agoraUid == agoraUid)&&(identical(other.isSpeaking, isSpeaking) || other.isSpeaking == isSpeaking));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,name,avatarUrl,isReady,isMe,team,level,isMicOn,isCameraOn,agoraUid,isSpeaking);

@override
String toString() {
  return 'RoomPlayerModel(uid: $uid, name: $name, avatarUrl: $avatarUrl, isReady: $isReady, isMe: $isMe, team: $team, level: $level, isMicOn: $isMicOn, isCameraOn: $isCameraOn, agoraUid: $agoraUid, isSpeaking: $isSpeaking)';
}


}

/// @nodoc
abstract mixin class _$RoomPlayerModelCopyWith<$Res> implements $RoomPlayerModelCopyWith<$Res> {
  factory _$RoomPlayerModelCopyWith(_RoomPlayerModel value, $Res Function(_RoomPlayerModel) _then) = __$RoomPlayerModelCopyWithImpl;
@override @useResult
$Res call({
 String uid, String name, String? avatarUrl, bool isReady, bool isMe, String team, int? level, bool isMicOn, bool isCameraOn, int? agoraUid, bool isSpeaking
});




}
/// @nodoc
class __$RoomPlayerModelCopyWithImpl<$Res>
    implements _$RoomPlayerModelCopyWith<$Res> {
  __$RoomPlayerModelCopyWithImpl(this._self, this._then);

  final _RoomPlayerModel _self;
  final $Res Function(_RoomPlayerModel) _then;

/// Create a copy of RoomPlayerModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? name = null,Object? avatarUrl = freezed,Object? isReady = null,Object? isMe = null,Object? team = null,Object? level = freezed,Object? isMicOn = null,Object? isCameraOn = null,Object? agoraUid = freezed,Object? isSpeaking = null,}) {
  return _then(_RoomPlayerModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,isReady: null == isReady ? _self.isReady : isReady // ignore: cast_nullable_to_non_nullable
as bool,isMe: null == isMe ? _self.isMe : isMe // ignore: cast_nullable_to_non_nullable
as bool,team: null == team ? _self.team : team // ignore: cast_nullable_to_non_nullable
as String,level: freezed == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int?,isMicOn: null == isMicOn ? _self.isMicOn : isMicOn // ignore: cast_nullable_to_non_nullable
as bool,isCameraOn: null == isCameraOn ? _self.isCameraOn : isCameraOn // ignore: cast_nullable_to_non_nullable
as bool,agoraUid: freezed == agoraUid ? _self.agoraUid : agoraUid // ignore: cast_nullable_to_non_nullable
as int?,isSpeaking: null == isSpeaking ? _self.isSpeaking : isSpeaking // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
