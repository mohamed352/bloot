// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatState()';
}


}

/// @nodoc
class $ChatStateCopyWith<$Res>  {
$ChatStateCopyWith(ChatState _, $Res Function(ChatState) __);
}


/// Adds pattern-matching-related methods to [ChatState].
extension ChatStatePatterns on ChatState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ChatInitial value)?  initial,TResult Function( ChatLoading value)?  loading,TResult Function( ChatConversationsLoaded value)?  conversationsLoaded,TResult Function( ChatMessagesLoaded value)?  messagesLoaded,TResult Function( ChatError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ChatInitial() when initial != null:
return initial(_that);case ChatLoading() when loading != null:
return loading(_that);case ChatConversationsLoaded() when conversationsLoaded != null:
return conversationsLoaded(_that);case ChatMessagesLoaded() when messagesLoaded != null:
return messagesLoaded(_that);case ChatError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ChatInitial value)  initial,required TResult Function( ChatLoading value)  loading,required TResult Function( ChatConversationsLoaded value)  conversationsLoaded,required TResult Function( ChatMessagesLoaded value)  messagesLoaded,required TResult Function( ChatError value)  error,}){
final _that = this;
switch (_that) {
case ChatInitial():
return initial(_that);case ChatLoading():
return loading(_that);case ChatConversationsLoaded():
return conversationsLoaded(_that);case ChatMessagesLoaded():
return messagesLoaded(_that);case ChatError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ChatInitial value)?  initial,TResult? Function( ChatLoading value)?  loading,TResult? Function( ChatConversationsLoaded value)?  conversationsLoaded,TResult? Function( ChatMessagesLoaded value)?  messagesLoaded,TResult? Function( ChatError value)?  error,}){
final _that = this;
switch (_that) {
case ChatInitial() when initial != null:
return initial(_that);case ChatLoading() when loading != null:
return loading(_that);case ChatConversationsLoaded() when conversationsLoaded != null:
return conversationsLoaded(_that);case ChatMessagesLoaded() when messagesLoaded != null:
return messagesLoaded(_that);case ChatError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<ChatConversation> conversations,  int selectedFilterIndex)?  conversationsLoaded,TResult Function( String conversationId,  List<ChatMessage> messages)?  messagesLoaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ChatInitial() when initial != null:
return initial();case ChatLoading() when loading != null:
return loading();case ChatConversationsLoaded() when conversationsLoaded != null:
return conversationsLoaded(_that.conversations,_that.selectedFilterIndex);case ChatMessagesLoaded() when messagesLoaded != null:
return messagesLoaded(_that.conversationId,_that.messages);case ChatError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<ChatConversation> conversations,  int selectedFilterIndex)  conversationsLoaded,required TResult Function( String conversationId,  List<ChatMessage> messages)  messagesLoaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case ChatInitial():
return initial();case ChatLoading():
return loading();case ChatConversationsLoaded():
return conversationsLoaded(_that.conversations,_that.selectedFilterIndex);case ChatMessagesLoaded():
return messagesLoaded(_that.conversationId,_that.messages);case ChatError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<ChatConversation> conversations,  int selectedFilterIndex)?  conversationsLoaded,TResult? Function( String conversationId,  List<ChatMessage> messages)?  messagesLoaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case ChatInitial() when initial != null:
return initial();case ChatLoading() when loading != null:
return loading();case ChatConversationsLoaded() when conversationsLoaded != null:
return conversationsLoaded(_that.conversations,_that.selectedFilterIndex);case ChatMessagesLoaded() when messagesLoaded != null:
return messagesLoaded(_that.conversationId,_that.messages);case ChatError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class ChatInitial implements ChatState {
  const ChatInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatState.initial()';
}


}




/// @nodoc


class ChatLoading implements ChatState {
  const ChatLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatState.loading()';
}


}




/// @nodoc


class ChatConversationsLoaded implements ChatState {
  const ChatConversationsLoaded({required final  List<ChatConversation> conversations, this.selectedFilterIndex = 0}): _conversations = conversations;
  

 final  List<ChatConversation> _conversations;
 List<ChatConversation> get conversations {
  if (_conversations is EqualUnmodifiableListView) return _conversations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_conversations);
}

@JsonKey() final  int selectedFilterIndex;

/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatConversationsLoadedCopyWith<ChatConversationsLoaded> get copyWith => _$ChatConversationsLoadedCopyWithImpl<ChatConversationsLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatConversationsLoaded&&const DeepCollectionEquality().equals(other._conversations, _conversations)&&(identical(other.selectedFilterIndex, selectedFilterIndex) || other.selectedFilterIndex == selectedFilterIndex));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_conversations),selectedFilterIndex);

@override
String toString() {
  return 'ChatState.conversationsLoaded(conversations: $conversations, selectedFilterIndex: $selectedFilterIndex)';
}


}

/// @nodoc
abstract mixin class $ChatConversationsLoadedCopyWith<$Res> implements $ChatStateCopyWith<$Res> {
  factory $ChatConversationsLoadedCopyWith(ChatConversationsLoaded value, $Res Function(ChatConversationsLoaded) _then) = _$ChatConversationsLoadedCopyWithImpl;
@useResult
$Res call({
 List<ChatConversation> conversations, int selectedFilterIndex
});




}
/// @nodoc
class _$ChatConversationsLoadedCopyWithImpl<$Res>
    implements $ChatConversationsLoadedCopyWith<$Res> {
  _$ChatConversationsLoadedCopyWithImpl(this._self, this._then);

  final ChatConversationsLoaded _self;
  final $Res Function(ChatConversationsLoaded) _then;

/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? conversations = null,Object? selectedFilterIndex = null,}) {
  return _then(ChatConversationsLoaded(
conversations: null == conversations ? _self._conversations : conversations // ignore: cast_nullable_to_non_nullable
as List<ChatConversation>,selectedFilterIndex: null == selectedFilterIndex ? _self.selectedFilterIndex : selectedFilterIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class ChatMessagesLoaded implements ChatState {
  const ChatMessagesLoaded({required this.conversationId, required final  List<ChatMessage> messages}): _messages = messages;
  

 final  String conversationId;
 final  List<ChatMessage> _messages;
 List<ChatMessage> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}


/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatMessagesLoadedCopyWith<ChatMessagesLoaded> get copyWith => _$ChatMessagesLoadedCopyWithImpl<ChatMessagesLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatMessagesLoaded&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&const DeepCollectionEquality().equals(other._messages, _messages));
}


@override
int get hashCode => Object.hash(runtimeType,conversationId,const DeepCollectionEquality().hash(_messages));

@override
String toString() {
  return 'ChatState.messagesLoaded(conversationId: $conversationId, messages: $messages)';
}


}

/// @nodoc
abstract mixin class $ChatMessagesLoadedCopyWith<$Res> implements $ChatStateCopyWith<$Res> {
  factory $ChatMessagesLoadedCopyWith(ChatMessagesLoaded value, $Res Function(ChatMessagesLoaded) _then) = _$ChatMessagesLoadedCopyWithImpl;
@useResult
$Res call({
 String conversationId, List<ChatMessage> messages
});




}
/// @nodoc
class _$ChatMessagesLoadedCopyWithImpl<$Res>
    implements $ChatMessagesLoadedCopyWith<$Res> {
  _$ChatMessagesLoadedCopyWithImpl(this._self, this._then);

  final ChatMessagesLoaded _self;
  final $Res Function(ChatMessagesLoaded) _then;

/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? conversationId = null,Object? messages = null,}) {
  return _then(ChatMessagesLoaded(
conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<ChatMessage>,
  ));
}


}

/// @nodoc


class ChatError implements ChatState {
  const ChatError({required this.message});
  

 final  String message;

/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatErrorCopyWith<ChatError> get copyWith => _$ChatErrorCopyWithImpl<ChatError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'ChatState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $ChatErrorCopyWith<$Res> implements $ChatStateCopyWith<$Res> {
  factory $ChatErrorCopyWith(ChatError value, $Res Function(ChatError) _then) = _$ChatErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$ChatErrorCopyWithImpl<$Res>
    implements $ChatErrorCopyWith<$Res> {
  _$ChatErrorCopyWithImpl(this._self, this._then);

  final ChatError _self;
  final $Res Function(ChatError) _then;

/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(ChatError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
