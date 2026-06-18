import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:bloot/features/chat/domain/entities/chat.dart';

part 'new_message_state.freezed.dart';

@freezed
class NewMessageState with _$NewMessageState {
  const factory NewMessageState.initial() = _Initial;
  const factory NewMessageState.loading() = _Loading;
  const factory NewMessageState.loaded({
    required List<ChatConversation> users,
  }) = _Loaded;
  const factory NewMessageState.creating() = _Creating;
  const factory NewMessageState.conversationCreated({
    required ChatConversation conversation,
  }) = _ConversationCreated;
  const factory NewMessageState.error({required String message}) = _Error;
}
