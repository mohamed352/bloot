import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:bloot/features/chat/domain/entities/chat.dart';

part 'chat_model.freezed.dart';
part 'chat_model.g.dart';

@freezed
abstract class ChatConversationModel with _$ChatConversationModel {
  const factory ChatConversationModel({
    required String id,
    required String name,
    String? avatarUrl,
    required String lastMessage,
    required String time,
    @Default(0) int unread,
    required String type,
  }) = _ChatConversationModel;

  factory ChatConversationModel.fromJson(Map<String, dynamic> json) =>
      _$ChatConversationModelFromJson(json);
}

@freezed
abstract class ChatMessageModel with _$ChatMessageModel {
  const factory ChatMessageModel({
    required String id,
    required String text,
    @Default(false) bool isMe,
    required String time,
    @Default('text') String type,
    String? imageUrl,
  }) = _ChatMessageModel;

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageModelFromJson(json);
}

extension ChatConversationModelX on ChatConversationModel {
  ChatConversation toEntity() => ChatConversation(
    id: id,
    name: name,
    avatarUrl: avatarUrl,
    lastMessage: lastMessage,
    time: time,
    unread: unread,
    type: type,
  );
}

extension ChatMessageModelX on ChatMessageModel {
  ChatMessage toEntity() => ChatMessage(
    id: id,
    text: text,
    isMe: isMe,
    time: time,
    type: type,
    imageUrl: imageUrl,
  );
}
