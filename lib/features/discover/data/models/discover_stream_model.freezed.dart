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
mixin _$DiscoverStreamModel {

 String get id; String get title; String get host; int get viewers; String get avatarUrl; String get category; bool get isLive; bool get isPremium;
/// Create a copy of DiscoverStreamModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiscoverStreamModelCopyWith<DiscoverStreamModel> get copyWith => _$DiscoverStreamModelCopyWithImpl<DiscoverStreamModel>(this as DiscoverStreamModel, _$identity);

  /// Serializes this DiscoverStreamModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiscoverStreamModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.host, host) || other.host == host)&&(identical(other.viewers, viewers) || other.viewers == viewers)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.category, category) || other.category == category)&&(identical(other.isLive, isLive) || other.isLive == isLive)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,host,viewers,avatarUrl,category,isLive,isPremium);

@override
String toString() {
  return 'DiscoverStreamModel(id: $id, title: $title, host: $host, viewers: $viewers, avatarUrl: $avatarUrl, category: $category, isLive: $isLive, isPremium: $isPremium)';
}


}

/// @nodoc
abstract mixin class $DiscoverStreamModelCopyWith<$Res>  {
  factory $DiscoverStreamModelCopyWith(DiscoverStreamModel value, $Res Function(DiscoverStreamModel) _then) = _$DiscoverStreamModelCopyWithImpl;
@useResult
$Res call({
 String id, String title, String host, int viewers, String avatarUrl, String category, bool isLive, bool isPremium
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? host = null,Object? viewers = null,Object? avatarUrl = null,Object? category = null,Object? isLive = null,Object? isPremium = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,viewers: null == viewers ? _self.viewers : viewers // ignore: cast_nullable_to_non_nullable
as int,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,isLive: null == isLive ? _self.isLive : isLive // ignore: cast_nullable_to_non_nullable
as bool,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String host,  int viewers,  String avatarUrl,  String category,  bool isLive,  bool isPremium)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DiscoverStreamModel() when $default != null:
return $default(_that.id,_that.title,_that.host,_that.viewers,_that.avatarUrl,_that.category,_that.isLive,_that.isPremium);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String host,  int viewers,  String avatarUrl,  String category,  bool isLive,  bool isPremium)  $default,) {final _that = this;
switch (_that) {
case _DiscoverStreamModel():
return $default(_that.id,_that.title,_that.host,_that.viewers,_that.avatarUrl,_that.category,_that.isLive,_that.isPremium);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String host,  int viewers,  String avatarUrl,  String category,  bool isLive,  bool isPremium)?  $default,) {final _that = this;
switch (_that) {
case _DiscoverStreamModel() when $default != null:
return $default(_that.id,_that.title,_that.host,_that.viewers,_that.avatarUrl,_that.category,_that.isLive,_that.isPremium);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DiscoverStreamModel implements DiscoverStreamModel {
  const _DiscoverStreamModel({required this.id, required this.title, required this.host, required this.viewers, required this.avatarUrl, this.category = 'Baloot', this.isLive = true, this.isPremium = false});
  factory _DiscoverStreamModel.fromJson(Map<String, dynamic> json) => _$DiscoverStreamModelFromJson(json);

@override final  String id;
@override final  String title;
@override final  String host;
@override final  int viewers;
@override final  String avatarUrl;
@override@JsonKey() final  String category;
@override@JsonKey() final  bool isLive;
@override@JsonKey() final  bool isPremium;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DiscoverStreamModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.host, host) || other.host == host)&&(identical(other.viewers, viewers) || other.viewers == viewers)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.category, category) || other.category == category)&&(identical(other.isLive, isLive) || other.isLive == isLive)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,host,viewers,avatarUrl,category,isLive,isPremium);

@override
String toString() {
  return 'DiscoverStreamModel(id: $id, title: $title, host: $host, viewers: $viewers, avatarUrl: $avatarUrl, category: $category, isLive: $isLive, isPremium: $isPremium)';
}


}

/// @nodoc
abstract mixin class _$DiscoverStreamModelCopyWith<$Res> implements $DiscoverStreamModelCopyWith<$Res> {
  factory _$DiscoverStreamModelCopyWith(_DiscoverStreamModel value, $Res Function(_DiscoverStreamModel) _then) = __$DiscoverStreamModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String host, int viewers, String avatarUrl, String category, bool isLive, bool isPremium
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? host = null,Object? viewers = null,Object? avatarUrl = null,Object? category = null,Object? isLive = null,Object? isPremium = null,}) {
  return _then(_DiscoverStreamModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,viewers: null == viewers ? _self.viewers : viewers // ignore: cast_nullable_to_non_nullable
as int,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,isLive: null == isLive ? _self.isLive : isLive // ignore: cast_nullable_to_non_nullable
as bool,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$StreamChatMessageModel {

 String get user; String get text; bool get isMe;
/// Create a copy of StreamChatMessageModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StreamChatMessageModelCopyWith<StreamChatMessageModel> get copyWith => _$StreamChatMessageModelCopyWithImpl<StreamChatMessageModel>(this as StreamChatMessageModel, _$identity);

  /// Serializes this StreamChatMessageModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StreamChatMessageModel&&(identical(other.user, user) || other.user == user)&&(identical(other.text, text) || other.text == text)&&(identical(other.isMe, isMe) || other.isMe == isMe));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,user,text,isMe);

@override
String toString() {
  return 'StreamChatMessageModel(user: $user, text: $text, isMe: $isMe)';
}


}

/// @nodoc
abstract mixin class $StreamChatMessageModelCopyWith<$Res>  {
  factory $StreamChatMessageModelCopyWith(StreamChatMessageModel value, $Res Function(StreamChatMessageModel) _then) = _$StreamChatMessageModelCopyWithImpl;
@useResult
$Res call({
 String user, String text, bool isMe
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
@pragma('vm:prefer-inline') @override $Res call({Object? user = null,Object? text = null,Object? isMe = null,}) {
  return _then(_self.copyWith(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,isMe: null == isMe ? _self.isMe : isMe // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String user,  String text,  bool isMe)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StreamChatMessageModel() when $default != null:
return $default(_that.user,_that.text,_that.isMe);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String user,  String text,  bool isMe)  $default,) {final _that = this;
switch (_that) {
case _StreamChatMessageModel():
return $default(_that.user,_that.text,_that.isMe);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String user,  String text,  bool isMe)?  $default,) {final _that = this;
switch (_that) {
case _StreamChatMessageModel() when $default != null:
return $default(_that.user,_that.text,_that.isMe);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StreamChatMessageModel implements StreamChatMessageModel {
  const _StreamChatMessageModel({required this.user, required this.text, this.isMe = false});
  factory _StreamChatMessageModel.fromJson(Map<String, dynamic> json) => _$StreamChatMessageModelFromJson(json);

@override final  String user;
@override final  String text;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StreamChatMessageModel&&(identical(other.user, user) || other.user == user)&&(identical(other.text, text) || other.text == text)&&(identical(other.isMe, isMe) || other.isMe == isMe));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,user,text,isMe);

@override
String toString() {
  return 'StreamChatMessageModel(user: $user, text: $text, isMe: $isMe)';
}


}

/// @nodoc
abstract mixin class _$StreamChatMessageModelCopyWith<$Res> implements $StreamChatMessageModelCopyWith<$Res> {
  factory _$StreamChatMessageModelCopyWith(_StreamChatMessageModel value, $Res Function(_StreamChatMessageModel) _then) = __$StreamChatMessageModelCopyWithImpl;
@override @useResult
$Res call({
 String user, String text, bool isMe
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
@override @pragma('vm:prefer-inline') $Res call({Object? user = null,Object? text = null,Object? isMe = null,}) {
  return _then(_StreamChatMessageModel(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,isMe: null == isMe ? _self.isMe : isMe // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
