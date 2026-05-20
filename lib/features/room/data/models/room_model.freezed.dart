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

 String get id; String get name; String get type; bool get voiceEnabled; bool get cameraEnabled; bool get allowSpectators; String get gameSpeed; String? get creatorName; String? get inviteCode; List<RoomPlayerModel> get players; List<RoomChatMessageModel> get chatMessages;
/// Create a copy of RoomModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoomModelCopyWith<RoomModel> get copyWith => _$RoomModelCopyWithImpl<RoomModel>(this as RoomModel, _$identity);

  /// Serializes this RoomModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoomModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.voiceEnabled, voiceEnabled) || other.voiceEnabled == voiceEnabled)&&(identical(other.cameraEnabled, cameraEnabled) || other.cameraEnabled == cameraEnabled)&&(identical(other.allowSpectators, allowSpectators) || other.allowSpectators == allowSpectators)&&(identical(other.gameSpeed, gameSpeed) || other.gameSpeed == gameSpeed)&&(identical(other.creatorName, creatorName) || other.creatorName == creatorName)&&(identical(other.inviteCode, inviteCode) || other.inviteCode == inviteCode)&&const DeepCollectionEquality().equals(other.players, players)&&const DeepCollectionEquality().equals(other.chatMessages, chatMessages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,voiceEnabled,cameraEnabled,allowSpectators,gameSpeed,creatorName,inviteCode,const DeepCollectionEquality().hash(players),const DeepCollectionEquality().hash(chatMessages));

@override
String toString() {
  return 'RoomModel(id: $id, name: $name, type: $type, voiceEnabled: $voiceEnabled, cameraEnabled: $cameraEnabled, allowSpectators: $allowSpectators, gameSpeed: $gameSpeed, creatorName: $creatorName, inviteCode: $inviteCode, players: $players, chatMessages: $chatMessages)';
}


}

/// @nodoc
abstract mixin class $RoomModelCopyWith<$Res>  {
  factory $RoomModelCopyWith(RoomModel value, $Res Function(RoomModel) _then) = _$RoomModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String type, bool voiceEnabled, bool cameraEnabled, bool allowSpectators, String gameSpeed, String? creatorName, String? inviteCode, List<RoomPlayerModel> players, List<RoomChatMessageModel> chatMessages
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = null,Object? voiceEnabled = null,Object? cameraEnabled = null,Object? allowSpectators = null,Object? gameSpeed = null,Object? creatorName = freezed,Object? inviteCode = freezed,Object? players = null,Object? chatMessages = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,voiceEnabled: null == voiceEnabled ? _self.voiceEnabled : voiceEnabled // ignore: cast_nullable_to_non_nullable
as bool,cameraEnabled: null == cameraEnabled ? _self.cameraEnabled : cameraEnabled // ignore: cast_nullable_to_non_nullable
as bool,allowSpectators: null == allowSpectators ? _self.allowSpectators : allowSpectators // ignore: cast_nullable_to_non_nullable
as bool,gameSpeed: null == gameSpeed ? _self.gameSpeed : gameSpeed // ignore: cast_nullable_to_non_nullable
as String,creatorName: freezed == creatorName ? _self.creatorName : creatorName // ignore: cast_nullable_to_non_nullable
as String?,inviteCode: freezed == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String?,players: null == players ? _self.players : players // ignore: cast_nullable_to_non_nullable
as List<RoomPlayerModel>,chatMessages: null == chatMessages ? _self.chatMessages : chatMessages // ignore: cast_nullable_to_non_nullable
as List<RoomChatMessageModel>,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String type,  bool voiceEnabled,  bool cameraEnabled,  bool allowSpectators,  String gameSpeed,  String? creatorName,  String? inviteCode,  List<RoomPlayerModel> players,  List<RoomChatMessageModel> chatMessages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoomModel() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.voiceEnabled,_that.cameraEnabled,_that.allowSpectators,_that.gameSpeed,_that.creatorName,_that.inviteCode,_that.players,_that.chatMessages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String type,  bool voiceEnabled,  bool cameraEnabled,  bool allowSpectators,  String gameSpeed,  String? creatorName,  String? inviteCode,  List<RoomPlayerModel> players,  List<RoomChatMessageModel> chatMessages)  $default,) {final _that = this;
switch (_that) {
case _RoomModel():
return $default(_that.id,_that.name,_that.type,_that.voiceEnabled,_that.cameraEnabled,_that.allowSpectators,_that.gameSpeed,_that.creatorName,_that.inviteCode,_that.players,_that.chatMessages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String type,  bool voiceEnabled,  bool cameraEnabled,  bool allowSpectators,  String gameSpeed,  String? creatorName,  String? inviteCode,  List<RoomPlayerModel> players,  List<RoomChatMessageModel> chatMessages)?  $default,) {final _that = this;
switch (_that) {
case _RoomModel() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.voiceEnabled,_that.cameraEnabled,_that.allowSpectators,_that.gameSpeed,_that.creatorName,_that.inviteCode,_that.players,_that.chatMessages);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RoomModel implements RoomModel {
  const _RoomModel({required this.id, required this.name, required this.type, this.voiceEnabled = true, this.cameraEnabled = false, this.allowSpectators = true, this.gameSpeed = 'normal', this.creatorName, this.inviteCode, final  List<RoomPlayerModel> players = const <RoomPlayerModel>[], final  List<RoomChatMessageModel> chatMessages = const <RoomChatMessageModel>[]}): _players = players,_chatMessages = chatMessages;
  factory _RoomModel.fromJson(Map<String, dynamic> json) => _$RoomModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  String type;
@override@JsonKey() final  bool voiceEnabled;
@override@JsonKey() final  bool cameraEnabled;
@override@JsonKey() final  bool allowSpectators;
@override@JsonKey() final  String gameSpeed;
@override final  String? creatorName;
@override final  String? inviteCode;
 final  List<RoomPlayerModel> _players;
@override@JsonKey() List<RoomPlayerModel> get players {
  if (_players is EqualUnmodifiableListView) return _players;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_players);
}

 final  List<RoomChatMessageModel> _chatMessages;
@override@JsonKey() List<RoomChatMessageModel> get chatMessages {
  if (_chatMessages is EqualUnmodifiableListView) return _chatMessages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_chatMessages);
}


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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoomModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.voiceEnabled, voiceEnabled) || other.voiceEnabled == voiceEnabled)&&(identical(other.cameraEnabled, cameraEnabled) || other.cameraEnabled == cameraEnabled)&&(identical(other.allowSpectators, allowSpectators) || other.allowSpectators == allowSpectators)&&(identical(other.gameSpeed, gameSpeed) || other.gameSpeed == gameSpeed)&&(identical(other.creatorName, creatorName) || other.creatorName == creatorName)&&(identical(other.inviteCode, inviteCode) || other.inviteCode == inviteCode)&&const DeepCollectionEquality().equals(other._players, _players)&&const DeepCollectionEquality().equals(other._chatMessages, _chatMessages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,voiceEnabled,cameraEnabled,allowSpectators,gameSpeed,creatorName,inviteCode,const DeepCollectionEquality().hash(_players),const DeepCollectionEquality().hash(_chatMessages));

@override
String toString() {
  return 'RoomModel(id: $id, name: $name, type: $type, voiceEnabled: $voiceEnabled, cameraEnabled: $cameraEnabled, allowSpectators: $allowSpectators, gameSpeed: $gameSpeed, creatorName: $creatorName, inviteCode: $inviteCode, players: $players, chatMessages: $chatMessages)';
}


}

/// @nodoc
abstract mixin class _$RoomModelCopyWith<$Res> implements $RoomModelCopyWith<$Res> {
  factory _$RoomModelCopyWith(_RoomModel value, $Res Function(_RoomModel) _then) = __$RoomModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String type, bool voiceEnabled, bool cameraEnabled, bool allowSpectators, String gameSpeed, String? creatorName, String? inviteCode, List<RoomPlayerModel> players, List<RoomChatMessageModel> chatMessages
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,Object? voiceEnabled = null,Object? cameraEnabled = null,Object? allowSpectators = null,Object? gameSpeed = null,Object? creatorName = freezed,Object? inviteCode = freezed,Object? players = null,Object? chatMessages = null,}) {
  return _then(_RoomModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,voiceEnabled: null == voiceEnabled ? _self.voiceEnabled : voiceEnabled // ignore: cast_nullable_to_non_nullable
as bool,cameraEnabled: null == cameraEnabled ? _self.cameraEnabled : cameraEnabled // ignore: cast_nullable_to_non_nullable
as bool,allowSpectators: null == allowSpectators ? _self.allowSpectators : allowSpectators // ignore: cast_nullable_to_non_nullable
as bool,gameSpeed: null == gameSpeed ? _self.gameSpeed : gameSpeed // ignore: cast_nullable_to_non_nullable
as String,creatorName: freezed == creatorName ? _self.creatorName : creatorName // ignore: cast_nullable_to_non_nullable
as String?,inviteCode: freezed == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String?,players: null == players ? _self._players : players // ignore: cast_nullable_to_non_nullable
as List<RoomPlayerModel>,chatMessages: null == chatMessages ? _self._chatMessages : chatMessages // ignore: cast_nullable_to_non_nullable
as List<RoomChatMessageModel>,
  ));
}


}


/// @nodoc
mixin _$RoomPlayerModel {

 String get name; String? get avatarUrl; bool get isReady; bool get isMe; String get team; int? get level;
/// Create a copy of RoomPlayerModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoomPlayerModelCopyWith<RoomPlayerModel> get copyWith => _$RoomPlayerModelCopyWithImpl<RoomPlayerModel>(this as RoomPlayerModel, _$identity);

  /// Serializes this RoomPlayerModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoomPlayerModel&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.isReady, isReady) || other.isReady == isReady)&&(identical(other.isMe, isMe) || other.isMe == isMe)&&(identical(other.team, team) || other.team == team)&&(identical(other.level, level) || other.level == level));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,avatarUrl,isReady,isMe,team,level);

@override
String toString() {
  return 'RoomPlayerModel(name: $name, avatarUrl: $avatarUrl, isReady: $isReady, isMe: $isMe, team: $team, level: $level)';
}


}

/// @nodoc
abstract mixin class $RoomPlayerModelCopyWith<$Res>  {
  factory $RoomPlayerModelCopyWith(RoomPlayerModel value, $Res Function(RoomPlayerModel) _then) = _$RoomPlayerModelCopyWithImpl;
@useResult
$Res call({
 String name, String? avatarUrl, bool isReady, bool isMe, String team, int? level
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
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? avatarUrl = freezed,Object? isReady = null,Object? isMe = null,Object? team = null,Object? level = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,isReady: null == isReady ? _self.isReady : isReady // ignore: cast_nullable_to_non_nullable
as bool,isMe: null == isMe ? _self.isMe : isMe // ignore: cast_nullable_to_non_nullable
as bool,team: null == team ? _self.team : team // ignore: cast_nullable_to_non_nullable
as String,level: freezed == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String? avatarUrl,  bool isReady,  bool isMe,  String team,  int? level)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoomPlayerModel() when $default != null:
return $default(_that.name,_that.avatarUrl,_that.isReady,_that.isMe,_that.team,_that.level);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String? avatarUrl,  bool isReady,  bool isMe,  String team,  int? level)  $default,) {final _that = this;
switch (_that) {
case _RoomPlayerModel():
return $default(_that.name,_that.avatarUrl,_that.isReady,_that.isMe,_that.team,_that.level);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String? avatarUrl,  bool isReady,  bool isMe,  String team,  int? level)?  $default,) {final _that = this;
switch (_that) {
case _RoomPlayerModel() when $default != null:
return $default(_that.name,_that.avatarUrl,_that.isReady,_that.isMe,_that.team,_that.level);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RoomPlayerModel implements RoomPlayerModel {
  const _RoomPlayerModel({required this.name, this.avatarUrl, this.isReady = false, this.isMe = false, this.team = 'A', this.level});
  factory _RoomPlayerModel.fromJson(Map<String, dynamic> json) => _$RoomPlayerModelFromJson(json);

@override final  String name;
@override final  String? avatarUrl;
@override@JsonKey() final  bool isReady;
@override@JsonKey() final  bool isMe;
@override@JsonKey() final  String team;
@override final  int? level;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoomPlayerModel&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.isReady, isReady) || other.isReady == isReady)&&(identical(other.isMe, isMe) || other.isMe == isMe)&&(identical(other.team, team) || other.team == team)&&(identical(other.level, level) || other.level == level));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,avatarUrl,isReady,isMe,team,level);

@override
String toString() {
  return 'RoomPlayerModel(name: $name, avatarUrl: $avatarUrl, isReady: $isReady, isMe: $isMe, team: $team, level: $level)';
}


}

/// @nodoc
abstract mixin class _$RoomPlayerModelCopyWith<$Res> implements $RoomPlayerModelCopyWith<$Res> {
  factory _$RoomPlayerModelCopyWith(_RoomPlayerModel value, $Res Function(_RoomPlayerModel) _then) = __$RoomPlayerModelCopyWithImpl;
@override @useResult
$Res call({
 String name, String? avatarUrl, bool isReady, bool isMe, String team, int? level
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
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? avatarUrl = freezed,Object? isReady = null,Object? isMe = null,Object? team = null,Object? level = freezed,}) {
  return _then(_RoomPlayerModel(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,isReady: null == isReady ? _self.isReady : isReady // ignore: cast_nullable_to_non_nullable
as bool,isMe: null == isMe ? _self.isMe : isMe // ignore: cast_nullable_to_non_nullable
as bool,team: null == team ? _self.team : team // ignore: cast_nullable_to_non_nullable
as String,level: freezed == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$RoomChatMessageModel {

 String get user; String get text;
/// Create a copy of RoomChatMessageModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoomChatMessageModelCopyWith<RoomChatMessageModel> get copyWith => _$RoomChatMessageModelCopyWithImpl<RoomChatMessageModel>(this as RoomChatMessageModel, _$identity);

  /// Serializes this RoomChatMessageModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoomChatMessageModel&&(identical(other.user, user) || other.user == user)&&(identical(other.text, text) || other.text == text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,user,text);

@override
String toString() {
  return 'RoomChatMessageModel(user: $user, text: $text)';
}


}

/// @nodoc
abstract mixin class $RoomChatMessageModelCopyWith<$Res>  {
  factory $RoomChatMessageModelCopyWith(RoomChatMessageModel value, $Res Function(RoomChatMessageModel) _then) = _$RoomChatMessageModelCopyWithImpl;
@useResult
$Res call({
 String user, String text
});




}
/// @nodoc
class _$RoomChatMessageModelCopyWithImpl<$Res>
    implements $RoomChatMessageModelCopyWith<$Res> {
  _$RoomChatMessageModelCopyWithImpl(this._self, this._then);

  final RoomChatMessageModel _self;
  final $Res Function(RoomChatMessageModel) _then;

/// Create a copy of RoomChatMessageModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? user = null,Object? text = null,}) {
  return _then(_self.copyWith(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RoomChatMessageModel].
extension RoomChatMessageModelPatterns on RoomChatMessageModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoomChatMessageModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoomChatMessageModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoomChatMessageModel value)  $default,){
final _that = this;
switch (_that) {
case _RoomChatMessageModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoomChatMessageModel value)?  $default,){
final _that = this;
switch (_that) {
case _RoomChatMessageModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String user,  String text)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoomChatMessageModel() when $default != null:
return $default(_that.user,_that.text);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String user,  String text)  $default,) {final _that = this;
switch (_that) {
case _RoomChatMessageModel():
return $default(_that.user,_that.text);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String user,  String text)?  $default,) {final _that = this;
switch (_that) {
case _RoomChatMessageModel() when $default != null:
return $default(_that.user,_that.text);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RoomChatMessageModel implements RoomChatMessageModel {
  const _RoomChatMessageModel({required this.user, required this.text});
  factory _RoomChatMessageModel.fromJson(Map<String, dynamic> json) => _$RoomChatMessageModelFromJson(json);

@override final  String user;
@override final  String text;

/// Create a copy of RoomChatMessageModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoomChatMessageModelCopyWith<_RoomChatMessageModel> get copyWith => __$RoomChatMessageModelCopyWithImpl<_RoomChatMessageModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoomChatMessageModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoomChatMessageModel&&(identical(other.user, user) || other.user == user)&&(identical(other.text, text) || other.text == text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,user,text);

@override
String toString() {
  return 'RoomChatMessageModel(user: $user, text: $text)';
}


}

/// @nodoc
abstract mixin class _$RoomChatMessageModelCopyWith<$Res> implements $RoomChatMessageModelCopyWith<$Res> {
  factory _$RoomChatMessageModelCopyWith(_RoomChatMessageModel value, $Res Function(_RoomChatMessageModel) _then) = __$RoomChatMessageModelCopyWithImpl;
@override @useResult
$Res call({
 String user, String text
});




}
/// @nodoc
class __$RoomChatMessageModelCopyWithImpl<$Res>
    implements _$RoomChatMessageModelCopyWith<$Res> {
  __$RoomChatMessageModelCopyWithImpl(this._self, this._then);

  final _RoomChatMessageModel _self;
  final $Res Function(_RoomChatMessageModel) _then;

/// Create a copy of RoomChatMessageModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? user = null,Object? text = null,}) {
  return _then(_RoomChatMessageModel(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
