import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:bloot/features/chat/domain/entities/chat.dart';

part 'chat_state.freezed.dart';

@freezed
class ChatState with _$ChatState {
  const factory ChatState.initial() = ChatInitial;
  const factory ChatState.loading() = ChatLoading;
  const factory ChatState.conversationsLoaded({
    required List<ChatConversation> conversations,
    @Default(0) int selectedFilterIndex,
  }) = ChatConversationsLoaded;
  const factory ChatState.messagesLoaded({
    required String conversationId,
    required List<ChatMessage> messages,
  }) = ChatMessagesLoaded;
  const factory ChatState.error({required String message}) = ChatError;
}
