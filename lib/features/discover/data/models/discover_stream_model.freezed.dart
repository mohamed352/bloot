// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'discover_stream_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StreamPlayerModel {

 String get uid; String get name; String? get avatarUrl; int get agoraUid; String get team; bool get isCameraOn; bool get isMicOn;
/// Create a copy of StreamPlayerModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StreamPlayerModelCopyWith<StreamPlayerModel> get copyWith => _$StreamPlayerModelCopyWithImpl<StreamPlayerModel>(this as StreamPlayerModel, _$identity);

  /// Serializes this StreamPlayerModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StreamPlayerModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.agoraUid, agoraUid) || other.agoraUid == agoraUid)&&(identical(other.team, team) || other.team == team)&&(identical(other.isCameraOn, isCameraOn) || other.isCameraOn == isCameraOn)&&(identical(other.isMicOn, isMicOn) || other.isMicOn == isMicOn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,name,avatarUrl,agoraUid,team,isCameraOn,isMicOn);

@override
String toString() {
  return 'StreamPlayerModel(uid: $uid, name: $name, avatarUrl: $avatarUrl, agoraUid: $agoraUid, team: $team, isCameraOn: $isCameraOn, isMicOn: $isMicOn)';
}


}

/// @nodoc
abstract mixin class $StreamPlayerModelCopyWith<$Res>  {
  factory $StreamPlayerModelCopyWith(StreamPlayerModel value, $Res Function(StreamPlayerModel) _then) = _$StreamPlayerModelCopyWithImpl;
@useResult
$Res call({
 String uid, String name, String? avatarUrl, int agoraUid, String team, bool isCameraOn, bool isMicOn
});




}
/// @nodoc
class _$StreamPlayerModelCopyWithImpl<$Res>
    implements $StreamPlayerModelCopyWith<$Res> {
  _$StreamPlayerModelCopyWithImpl(this._self, this._then);

  final StreamPlayerModel _self;
  final $Res Function(StreamPlayerModel) _then;

/// Create a copy of StreamPlayerModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? name = null,Object? avatarUrl = freezed,Object? agoraUid = null,Object? team = null,Object? isCameraOn = null,Object? isMicOn = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,agoraUid: null == agoraUid ? _self.agoraUid : agoraUid // ignore: cast_nullable_to_non_nullable
as int,team: null == team ? _self.team : team // ignore: cast_nullable_to_non_nullable
as String,isCameraOn: null == isCameraOn ? _self.isCameraOn : isCameraOn // ignore: cast_nullable_to_non_nullable
as bool,isMicOn: null == isMicOn ? _self.isMicOn : isMicOn // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [StreamPlayerModel].
extension StreamPlayerModelPatterns on StreamPlayerModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StreamPlayerModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StreamPlayerModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StreamPlayerModel value)  $default,){
final _that = this;
switch (_that) {
case _StreamPlayerModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StreamPlayerModel value)?  $default,){
final _that = this;
switch (_that) {
case _StreamPlayerModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String name,  String? avatarUrl,  int agoraUid,  String team,  bool isCameraOn,  bool isMicOn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StreamPlayerModel() when $default != null:
return $default(_that.uid,_that.name,_that.avatarUrl,_that.agoraUid,_that.team,_that.isCameraOn,_that.isMicOn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String name,  String? avatarUrl,  int agoraUid,  String team,  bool isCameraOn,  bool isMicOn)  $default,) {final _that = this;
switch (_that) {
case _StreamPlayerModel():
return $default(_that.uid,_that.name,_that.avatarUrl,_that.agoraUid,_that.team,_that.isCameraOn,_that.isMicOn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String name,  String? avatarUrl,  int agoraUid,  String team,  bool isCameraOn,  bool isMicOn)?  $default,) {final _that = this;
switch (_that) {
case _StreamPlayerModel() when $default != null:
return $default(_that.uid,_that.name,_that.avatarUrl,_that.agoraUid,_that.team,_that.isCameraOn,_that.isMicOn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StreamPlayerModel implements StreamPlayerModel {
  const _StreamPlayerModel({required this.uid, required this.name, this.avatarUrl, required this.agoraUid, this.team = 'A', this.isCameraOn = false, this.isMicOn = true});
  factory _StreamPlayerModel.fromJson(Map<String, dynamic> json) => _$StreamPlayerModelFromJson(json);

@override final  String uid;
@override final  String name;
@override final  String? avatarUrl;
@override final  int agoraUid;
@override@JsonKey() final  String team;
@override@JsonKey() final  bool isCameraOn;
@override@JsonKey() final  bool isMicOn;

/// Create a copy of StreamPlayerModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StreamPlayerModelCopyWith<_StreamPlayerModel> get copyWith => __$StreamPlayerModelCopyWithImpl<_StreamPlayerModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StreamPlayerModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StreamPlayerModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.agoraUid, agoraUid) || other.agoraUid == agoraUid)&&(identical(other.team, team) || other.team == team)&&(identical(other.isCameraOn, isCameraOn) || other.isCameraOn == isCameraOn)&&(identical(other.isMicOn, isMicOn) || other.isMicOn == isMicOn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,name,avatarUrl,agoraUid,team,isCameraOn,isMicOn);

@override
String toString() {
  return 'StreamPlayerModel(uid: $uid, name: $name, avatarUrl: $avatarUrl, agoraUid: $agoraUid, team: $team, isCameraOn: $isCameraOn, isMicOn: $isMicOn)';
}


}

/// @nodoc
abstract mixin class _$StreamPlayerModelCopyWith<$Res> implements $StreamPlayerModelCopyWith<$Res> {
  factory _$StreamPlayerModelCopyWith(_StreamPlayerModel value, $Res Function(_StreamPlayerModel) _then) = __$StreamPlayerModelCopyWithImpl;
@override @useResult
$Res call({
 String uid, String name, String? avatarUrl, int agoraUid, String team, bool isCameraOn, bool isMicOn
});




}
/// @nodoc
class __$StreamPlayerModelCopyWithImpl<$Res>
    implements _$StreamPlayerModelCopyWith<$Res> {
  __$StreamPlayerModelCopyWithImpl(this._self, this._then);

  final _StreamPlayerModel _self;
  final $Res Function(_StreamPlayerModel) _then;

/// Create a copy of StreamPlayerModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? name = null,Object? avatarUrl = freezed,Object? agoraUid = null,Object? team = null,Object? isCameraOn = null,Object? isMicOn = null,}) {
  return _then(_StreamPlayerModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,agoraUid: null == agoraUid ? _self.agoraUid : agoraUid // ignore: cast_nullable_to_non_nullable
as int,team: null == team ? _self.team : team // ignore: cast_nullable_to_non_nullable
as String,isCameraOn: null == isCameraOn ? _self.isCameraOn : isCameraOn // ignore: cast_nullable_to_non_nullable
as bool,isMicOn: null == isMicOn ? _self.isMicOn : isMicOn // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$DiscoverStreamModel {

 String get id; String get title; String get host; int get viewers; String get avatarUrl; String get category; bool get isLive; bool get isPremium; String? get agoraChannelName; String? get roomId; List<StreamPlayerModel> get players;
/// Create a copy of DiscoverStreamModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiscoverStreamModelCopyWith<DiscoverStreamModel> get copyWith => _$DiscoverStreamModelCopyWithImpl<DiscoverStreamModel>(this as DiscoverStreamModel, _$identity);

  /// Serializes this DiscoverStreamModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiscoverStreamModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.host, host) || other.host == host)&&(identical(other.viewers, viewers) || other.viewers == viewers)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.category, category) || other.category == category)&&(identical(other.isLive, isLive) || other.isLive == isLive)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&(identical(other.agoraChannelName, agoraChannelName) || other.agoraChannelName == agoraChannelName)&&(identical(other.roomId, roomId) || other.roomId == roomId)&&const DeepCollectionEquality().equals(other.players, players));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,host,viewers,avatarUrl,category,isLive,isPremium,agoraChannelName,roomId,const DeepCollectionEquality().hash(players));

@override
String toString() {
  return 'DiscoverStreamModel(id: $id, title: $title, host: $host, viewers: $viewers, avatarUrl: $avatarUrl, category: $category, isLive: $isLive, isPremium: $isPremium, agoraChannelName: $agoraChannelName, roomId: $roomId, players: $players)';
}


}

/// @nodoc
abstract mixin class $DiscoverStreamModelCopyWith<$Res>  {
  factory $DiscoverStreamModelCopyWith(DiscoverStreamModel value, $Res Function(DiscoverStreamModel) _then) = _$DiscoverStreamModelCopyWithImpl;
@useResult
$Res call({
 String id, String title, String host, int viewers, String avatarUrl, String category, bool isLive, bool isPremium, String? agoraChannelName, String? roomId, List<StreamPlayerModel> players
});




}
/// @nodoc
class _$DiscoverStreamModelCopyWithImpl<$Res>
    implements $DiscoverStreamModelCopyWith<$Res> {
  _$DiscoverStreamModelCopyWithImpl(this._self, this._then);

  final DiscoverStreamModel _self;
  final $Res Function(DiscoverStreamModel) _then;

/// Create a copy of DiscoverStreamModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? host = null,Object? viewers = null,Object? avatarUrl = null,Object? category = null,Object? isLive = null,Object? isPremium = null,Object? agoraChannelName = freezed,Object? roomId = freezed,Object? players = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,viewers: null == viewers ? _self.viewers : viewers // ignore: cast_nullable_to_non_nullable
as int,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,isLive: null == isLive ? _self.isLive : isLive // ignore: cast_nullable_to_non_nullable
as bool,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,agoraChannelName: freezed == agoraChannelName ? _self.agoraChannelName : agoraChannelName // ignore: cast_nullable_to_non_nullable
as String?,roomId: freezed == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as String?,players: null == players ? _self.players : players // ignore: cast_nullable_to_non_nullable
as List<StreamPlayerModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [DiscoverStreamModel].
extension DiscoverStreamModelPatterns on DiscoverStreamModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DiscoverStreamModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DiscoverStreamModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DiscoverStreamModel value)  $default,){
final _that = this;
switch (_that) {
case _DiscoverStreamModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DiscoverStreamModel value)?  $default,){
final _that = this;
switch (_that) {
case _DiscoverStreamModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String host,  int viewers,  String avatarUrl,  String category,  bool isLive,  bool isPremium,  String? agoraChannelName,  String? roomId,  List<StreamPlayerModel> players)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DiscoverStreamModel() when $default != null:
return $default(_that.id,_that.title,_that.host,_that.viewers,_that.avatarUrl,_that.category,_that.isLive,_that.isPremium,_that.agoraChannelName,_that.roomId,_that.players);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String host,  int viewers,  String avatarUrl,  String category,  bool isLive,  bool isPremium,  String? agoraChannelName,  String? roomId,  List<StreamPlayerModel> players)  $default,) {final _that = this;
switch (_that) {
case _DiscoverStreamModel():
return $default(_that.id,_that.title,_that.host,_that.viewers,_that.avatarUrl,_that.category,_that.isLive,_that.isPremium,_that.agoraChannelName,_that.roomId,_that.players);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String host,  int viewers,  String avatarUrl,  String category,  bool isLive,  bool isPremium,  String? agoraChannelName,  String? roomId,  List<StreamPlayerModel> players)?  $default,) {final _that = this;
switch (_that) {
case _DiscoverStreamModel() when $default != null:
return $default(_that.id,_that.title,_that.host,_that.viewers,_that.avatarUrl,_that.category,_that.isLive,_that.isPremium,_that.agoraChannelName,_that.roomId,_that.players);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DiscoverStreamModel implements DiscoverStreamModel {
  const _DiscoverStreamModel({required this.id, required this.title, required this.host, required this.viewers, required this.avatarUrl, this.category = 'Baloot', this.isLive = true, this.isPremium = false, this.agoraChannelName, this.roomId, final  List<StreamPlayerModel> players = const []}): _players = players;
  factory _DiscoverStreamModel.fromJson(Map<String, dynamic> json) => _$DiscoverStreamModelFromJson(json);

@override final  String id;
@override final  String title;
@override final  String host;
@override final  int viewers;
@override final  String avatarUrl;
@override@JsonKey() final  String category;
@override@JsonKey() final  bool isLive;
@override@JsonKey() final  bool isPremium;
@override final  String? agoraChannelName;
@override final  String? roomId;
 final  List<StreamPlayerModel> _players;
@override@JsonKey() List<StreamPlayerModel> get players {
  if (_players is EqualUnmodifiableListView) return _players;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_players);
}


/// Create a copy of DiscoverStreamModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DiscoverStreamModelCopyWith<_DiscoverStreamModel> get copyWith => __$DiscoverStreamModelCopyWithImpl<_DiscoverStreamModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DiscoverStreamModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DiscoverStreamModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.host, host) || other.host == host)&&(identical(other.viewers, viewers) || other.viewers == viewers)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.category, category) || other.category == category)&&(identical(other.isLive, isLive) || other.isLive == isLive)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&(identical(other.agoraChannelName, agoraChannelName) || other.agoraChannelName == agoraChannelName)&&(identical(other.roomId, roomId) || other.roomId == roomId)&&const DeepCollectionEquality().equals(other._players, _players));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,host,viewers,avatarUrl,category,isLive,isPremium,agoraChannelName,roomId,const DeepCollectionEquality().hash(_players));

@override
String toString() {
  return 'DiscoverStreamModel(id: $id, title: $title, host: $host, viewers: $viewers, avatarUrl: $avatarUrl, category: $category, isLive: $isLive, isPremium: $isPremium, agoraChannelName: $agoraChannelName, roomId: $roomId, players: $players)';
}


}

/// @nodoc
abstract mixin class _$DiscoverStreamModelCopyWith<$Res> implements $DiscoverStreamModelCopyWith<$Res> {
  factory _$DiscoverStreamModelCopyWith(_DiscoverStreamModel value, $Res Function(_DiscoverStreamModel) _then) = __$DiscoverStreamModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String host, int viewers, String avatarUrl, String category, bool isLive, bool isPremium, String? agoraChannelName, String? roomId, List<StreamPlayerModel> players
});




}
/// @nodoc
class __$DiscoverStreamModelCopyWithImpl<$Res>
    implements _$DiscoverStreamModelCopyWith<$Res> {
  __$DiscoverStreamModelCopyWithImpl(this._self, this._then);

  final _DiscoverStreamModel _self;
  final $Res Function(_DiscoverStreamModel) _then;

/// Create a copy of DiscoverStreamModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? host = null,Object? viewers = null,Object? avatarUrl = null,Object? category = null,Object? isLive = null,Object? isPremium = null,Object? agoraChannelName = freezed,Object? roomId = freezed,Object? players = null,}) {
  return _then(_DiscoverStreamModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,viewers: null == viewers ? _self.viewers : viewers // ignore: cast_nullable_to_non_nullable
as int,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,isLive: null == isLive ? _self.isLive : isLive // ignore: cast_nullable_to_non_nullable
as bool,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,agoraChannelName: freezed == agoraChannelName ? _self.agoraChannelName : agoraChannelName // ignore: cast_nullable_to_non_nullable
as String?,roomId: freezed == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as String?,players: null == players ? _self._players : players // ignore: cast_nullable_to_non_nullable
as List<StreamPlayerModel>,
  ));
}


}


/// @nodoc
mixin _$StreamChatMessageModel {

 String get id; String get senderUid; String get senderName; String? get senderAvatar; String get text; String get type; DateTime? get createdAt; bool get isMe;
/// Create a copy of StreamChatMessageModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StreamChatMessageModelCopyWith<StreamChatMessageModel> get copyWith => _$StreamChatMessageModelCopyWithImpl<StreamChatMessageModel>(this as StreamChatMessageModel, _$identity);

  /// Serializes this StreamChatMessageModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StreamChatMessageModel&&(identical(other.id, id) || other.id == id)&&(identical(other.senderUid, senderUid) || other.senderUid == senderUid)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.senderAvatar, senderAvatar) || other.senderAvatar == senderAvatar)&&(identical(other.text, text) || other.text == text)&&(identical(other.type, type) || other.type == type)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isMe, isMe) || other.isMe == isMe));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,senderUid,senderName,senderAvatar,text,type,createdAt,isMe);

@override
String toString() {
  return 'StreamChatMessageModel(id: $id, senderUid: $senderUid, senderName: $senderName, senderAvatar: $senderAvatar, text: $text, type: $type, createdAt: $createdAt, isMe: $isMe)';
}


}

/// @nodoc
abstract mixin class $StreamChatMessageModelCopyWith<$Res>  {
  factory $StreamChatMessageModelCopyWith(StreamChatMessageModel value, $Res Function(StreamChatMessageModel) _then) = _$StreamChatMessageModelCopyWithImpl;
@useResult
$Res call({
 String id, String senderUid, String senderName, String? senderAvatar, String text, String type, DateTime? createdAt, bool isMe
});




}
/// @nodoc
class _$StreamChatMessageModelCopyWithImpl<$Res>
    implements $StreamChatMessageModelCopyWith<$Res> {
  _$StreamChatMessageModelCopyWithImpl(this._self, this._then);

  final StreamChatMessageModel _self;
  final $Res Function(StreamChatMessageModel) _then;

/// Create a copy of StreamChatMessageModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? senderUid = null,Object? senderName = null,Object? senderAvatar = freezed,Object? text = null,Object? type = null,Object? createdAt = freezed,Object? isMe = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,senderUid: null == senderUid ? _self.senderUid : senderUid // ignore: cast_nullable_to_non_nullable
as String,senderName: null == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String,senderAvatar: freezed == senderAvatar ? _self.senderAvatar : senderAvatar // ignore: cast_nullable_to_non_nullable
as String?,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isMe: null == isMe ? _self.isMe : isMe // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [StreamChatMessageModel].
extension StreamChatMessageModelPatterns on StreamChatMessageModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StreamChatMessageModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StreamChatMessageModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StreamChatMessageModel value)  $default,){
final _that = this;
switch (_that) {
case _StreamChatMessageModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StreamChatMessageModel value)?  $default,){
final _that = this;
switch (_that) {
case _StreamChatMessageModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String senderUid,  String senderName,  String? senderAvatar,  String text,  String type,  DateTime? createdAt,  bool isMe)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StreamChatMessageModel() when $default != null:
return $default(_that.id,_that.senderUid,_that.senderName,_that.senderAvatar,_that.text,_that.type,_that.createdAt,_that.isMe);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String senderUid,  String senderName,  String? senderAvatar,  String text,  String type,  DateTime? createdAt,  bool isMe)  $default,) {final _that = this;
switch (_that) {
case _StreamChatMessageModel():
return $default(_that.id,_that.senderUid,_that.senderName,_that.senderAvatar,_that.text,_that.type,_that.createdAt,_that.isMe);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String senderUid,  String senderName,  String? senderAvatar,  String text,  String type,  DateTime? createdAt,  bool isMe)?  $default,) {final _that = this;
switch (_that) {
case _StreamChatMessageModel() when $default != null:
return $default(_that.id,_that.senderUid,_that.senderName,_that.senderAvatar,_that.text,_that.type,_that.createdAt,_that.isMe);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StreamChatMessageModel implements StreamChatMessageModel {
  const _StreamChatMessageModel({required this.id, required this.senderUid, required this.senderName, this.senderAvatar, required this.text, this.type = 'text', this.createdAt, this.isMe = false});
  factory _StreamChatMessageModel.fromJson(Map<String, dynamic> json) => _$StreamChatMessageModelFromJson(json);

@override final  String id;
@override final  String senderUid;
@override final  String senderName;
@override final  String? senderAvatar;
@override final  String text;
@override@JsonKey() final  String type;
@override final  DateTime? createdAt;
@override@JsonKey() final  bool isMe;

/// Create a copy of StreamChatMessageModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StreamChatMessageModelCopyWith<_StreamChatMessageModel> get copyWith => __$StreamChatMessageModelCopyWithImpl<_StreamChatMessageModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StreamChatMessageModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StreamChatMessageModel&&(identical(other.id, id) || other.id == id)&&(identical(other.senderUid, senderUid) || other.senderUid == senderUid)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.senderAvatar, senderAvatar) || other.senderAvatar == senderAvatar)&&(identical(other.text, text) || other.text == text)&&(identical(other.type, type) || other.type == type)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isMe, isMe) || other.isMe == isMe));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,senderUid,senderName,senderAvatar,text,type,createdAt,isMe);

@override
String toString() {
  return 'StreamChatMessageModel(id: $id, senderUid: $senderUid, senderName: $senderName, senderAvatar: $senderAvatar, text: $text, type: $type, createdAt: $createdAt, isMe: $isMe)';
}


}

/// @nodoc
abstract mixin class _$StreamChatMessageModelCopyWith<$Res> implements $StreamChatMessageModelCopyWith<$Res> {
  factory _$StreamChatMessageModelCopyWith(_StreamChatMessageModel value, $Res Function(_StreamChatMessageModel) _then) = __$StreamChatMessageModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String senderUid, String senderName, String? senderAvatar, String text, String type, DateTime? createdAt, bool isMe
});




}
/// @nodoc
class __$StreamChatMessageModelCopyWithImpl<$Res>
    implements _$StreamChatMessageModelCopyWith<$Res> {
  __$StreamChatMessageModelCopyWithImpl(this._self, this._then);

  final _StreamChatMessageModel _self;
  final $Res Function(_StreamChatMessageModel) _then;

/// Create a copy of StreamChatMessageModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? senderUid = null,Object? senderName = null,Object? senderAvatar = freezed,Object? text = null,Object? type = null,Object? createdAt = freezed,Object? isMe = null,}) {
  return _then(_StreamChatMessageModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,senderUid: null == senderUid ? _self.senderUid : senderUid // ignore: cast_nullable_to_non_nullable
as String,senderName: null == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String,senderAvatar: freezed == senderAvatar ? _self.senderAvatar : senderAvatar // ignore: cast_nullable_to_non_nullable
as String?,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isMe: null == isMe ? _self.isMe : isMe // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
