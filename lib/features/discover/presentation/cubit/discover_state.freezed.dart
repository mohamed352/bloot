// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'discover_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DiscoverState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiscoverState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DiscoverState()';
}


}

/// @nodoc
class $DiscoverStateCopyWith<$Res>  {
$DiscoverStateCopyWith(DiscoverState _, $Res Function(DiscoverState) __);
}


/// Adds pattern-matching-related methods to [DiscoverState].
extension DiscoverStatePatterns on DiscoverState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( DiscoverInitial value)?  initial,TResult Function( DiscoverLoading value)?  loading,TResult Function( DiscoverStreamsLoaded value)?  streamsLoaded,TResult Function( DiscoverStreamLoaded value)?  streamLoaded,TResult Function( DiscoverError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case DiscoverInitial() when initial != null:
return initial(_that);case DiscoverLoading() when loading != null:
return loading(_that);case DiscoverStreamsLoaded() when streamsLoaded != null:
return streamsLoaded(_that);case DiscoverStreamLoaded() when streamLoaded != null:
return streamLoaded(_that);case DiscoverError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( DiscoverInitial value)  initial,required TResult Function( DiscoverLoading value)  loading,required TResult Function( DiscoverStreamsLoaded value)  streamsLoaded,required TResult Function( DiscoverStreamLoaded value)  streamLoaded,required TResult Function( DiscoverError value)  error,}){
final _that = this;
switch (_that) {
case DiscoverInitial():
return initial(_that);case DiscoverLoading():
return loading(_that);case DiscoverStreamsLoaded():
return streamsLoaded(_that);case DiscoverStreamLoaded():
return streamLoaded(_that);case DiscoverError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( DiscoverInitial value)?  initial,TResult? Function( DiscoverLoading value)?  loading,TResult? Function( DiscoverStreamsLoaded value)?  streamsLoaded,TResult? Function( DiscoverStreamLoaded value)?  streamLoaded,TResult? Function( DiscoverError value)?  error,}){
final _that = this;
switch (_that) {
case DiscoverInitial() when initial != null:
return initial(_that);case DiscoverLoading() when loading != null:
return loading(_that);case DiscoverStreamsLoaded() when streamsLoaded != null:
return streamsLoaded(_that);case DiscoverStreamLoaded() when streamLoaded != null:
return streamLoaded(_that);case DiscoverError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<DiscoverStream> streams,  int selectedFilterIndex)?  streamsLoaded,TResult Function( DiscoverStream stream,  List<StreamChatMessage> messages)?  streamLoaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case DiscoverInitial() when initial != null:
return initial();case DiscoverLoading() when loading != null:
return loading();case DiscoverStreamsLoaded() when streamsLoaded != null:
return streamsLoaded(_that.streams,_that.selectedFilterIndex);case DiscoverStreamLoaded() when streamLoaded != null:
return streamLoaded(_that.stream,_that.messages);case DiscoverError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<DiscoverStream> streams,  int selectedFilterIndex)  streamsLoaded,required TResult Function( DiscoverStream stream,  List<StreamChatMessage> messages)  streamLoaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case DiscoverInitial():
return initial();case DiscoverLoading():
return loading();case DiscoverStreamsLoaded():
return streamsLoaded(_that.streams,_that.selectedFilterIndex);case DiscoverStreamLoaded():
return streamLoaded(_that.stream,_that.messages);case DiscoverError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<DiscoverStream> streams,  int selectedFilterIndex)?  streamsLoaded,TResult? Function( DiscoverStream stream,  List<StreamChatMessage> messages)?  streamLoaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case DiscoverInitial() when initial != null:
return initial();case DiscoverLoading() when loading != null:
return loading();case DiscoverStreamsLoaded() when streamsLoaded != null:
return streamsLoaded(_that.streams,_that.selectedFilterIndex);case DiscoverStreamLoaded() when streamLoaded != null:
return streamLoaded(_that.stream,_that.messages);case DiscoverError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class DiscoverInitial implements DiscoverState {
  const DiscoverInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiscoverInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DiscoverState.initial()';
}


}




/// @nodoc


class DiscoverLoading implements DiscoverState {
  const DiscoverLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiscoverLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DiscoverState.loading()';
}


}




/// @nodoc


class DiscoverStreamsLoaded implements DiscoverState {
  const DiscoverStreamsLoaded({required final  List<DiscoverStream> streams, this.selectedFilterIndex = 0}): _streams = streams;
  

 final  List<DiscoverStream> _streams;
 List<DiscoverStream> get streams {
  if (_streams is EqualUnmodifiableListView) return _streams;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_streams);
}

@JsonKey() final  int selectedFilterIndex;

/// Create a copy of DiscoverState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiscoverStreamsLoadedCopyWith<DiscoverStreamsLoaded> get copyWith => _$DiscoverStreamsLoadedCopyWithImpl<DiscoverStreamsLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiscoverStreamsLoaded&&const DeepCollectionEquality().equals(other._streams, _streams)&&(identical(other.selectedFilterIndex, selectedFilterIndex) || other.selectedFilterIndex == selectedFilterIndex));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_streams),selectedFilterIndex);

@override
String toString() {
  return 'DiscoverState.streamsLoaded(streams: $streams, selectedFilterIndex: $selectedFilterIndex)';
}


}

/// @nodoc
abstract mixin class $DiscoverStreamsLoadedCopyWith<$Res> implements $DiscoverStateCopyWith<$Res> {
  factory $DiscoverStreamsLoadedCopyWith(DiscoverStreamsLoaded value, $Res Function(DiscoverStreamsLoaded) _then) = _$DiscoverStreamsLoadedCopyWithImpl;
@useResult
$Res call({
 List<DiscoverStream> streams, int selectedFilterIndex
});




}
/// @nodoc
class _$DiscoverStreamsLoadedCopyWithImpl<$Res>
    implements $DiscoverStreamsLoadedCopyWith<$Res> {
  _$DiscoverStreamsLoadedCopyWithImpl(this._self, this._then);

  final DiscoverStreamsLoaded _self;
  final $Res Function(DiscoverStreamsLoaded) _then;

/// Create a copy of DiscoverState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? streams = null,Object? selectedFilterIndex = null,}) {
  return _then(DiscoverStreamsLoaded(
streams: null == streams ? _self._streams : streams // ignore: cast_nullable_to_non_nullable
as List<DiscoverStream>,selectedFilterIndex: null == selectedFilterIndex ? _self.selectedFilterIndex : selectedFilterIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class DiscoverStreamLoaded implements DiscoverState {
  const DiscoverStreamLoaded({required this.stream, required final  List<StreamChatMessage> messages}): _messages = messages;
  

 final  DiscoverStream stream;
 final  List<StreamChatMessage> _messages;
 List<StreamChatMessage> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}


/// Create a copy of DiscoverState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiscoverStreamLoadedCopyWith<DiscoverStreamLoaded> get copyWith => _$DiscoverStreamLoadedCopyWithImpl<DiscoverStreamLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiscoverStreamLoaded&&(identical(other.stream, stream) || other.stream == stream)&&const DeepCollectionEquality().equals(other._messages, _messages));
}


@override
int get hashCode => Object.hash(runtimeType,stream,const DeepCollectionEquality().hash(_messages));

@override
String toString() {
  return 'DiscoverState.streamLoaded(stream: $stream, messages: $messages)';
}


}

/// @nodoc
abstract mixin class $DiscoverStreamLoadedCopyWith<$Res> implements $DiscoverStateCopyWith<$Res> {
  factory $DiscoverStreamLoadedCopyWith(DiscoverStreamLoaded value, $Res Function(DiscoverStreamLoaded) _then) = _$DiscoverStreamLoadedCopyWithImpl;
@useResult
$Res call({
 DiscoverStream stream, List<StreamChatMessage> messages
});




}
/// @nodoc
class _$DiscoverStreamLoadedCopyWithImpl<$Res>
    implements $DiscoverStreamLoadedCopyWith<$Res> {
  _$DiscoverStreamLoadedCopyWithImpl(this._self, this._then);

  final DiscoverStreamLoaded _self;
  final $Res Function(DiscoverStreamLoaded) _then;

/// Create a copy of DiscoverState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? stream = null,Object? messages = null,}) {
  return _then(DiscoverStreamLoaded(
stream: null == stream ? _self.stream : stream // ignore: cast_nullable_to_non_nullable
as DiscoverStream,messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<StreamChatMessage>,
  ));
}


}

/// @nodoc


class DiscoverError implements DiscoverState {
  const DiscoverError({required this.message});
  

 final  String message;

/// Create a copy of DiscoverState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiscoverErrorCopyWith<DiscoverError> get copyWith => _$DiscoverErrorCopyWithImpl<DiscoverError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiscoverError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'DiscoverState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $DiscoverErrorCopyWith<$Res> implements $DiscoverStateCopyWith<$Res> {
  factory $DiscoverErrorCopyWith(DiscoverError value, $Res Function(DiscoverError) _then) = _$DiscoverErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$DiscoverErrorCopyWithImpl<$Res>
    implements $DiscoverErrorCopyWith<$Res> {
  _$DiscoverErrorCopyWithImpl(this._self, this._then);

  final DiscoverError _self;
  final $Res Function(DiscoverError) _then;

/// Create a copy of DiscoverState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(DiscoverError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
