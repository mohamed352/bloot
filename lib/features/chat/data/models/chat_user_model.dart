import 'package:bloot/features/chat/domain/entities/chat_user.dart';

/// Lightweight model for user-search results in the "new message" flow.
class ChatUserModel {
  const ChatUserModel({
    required this.id,
    required this.displayName,
    this.username,
    this.avatarUrl,
  });

  final String id;
  final String displayName;
  final String? username;
  final String? avatarUrl;

  ChatUser toEntity() => ChatUser(
    id: id,
    displayName: displayName,
    username: username,
    avatarUrl: avatarUrl,
  );
}
