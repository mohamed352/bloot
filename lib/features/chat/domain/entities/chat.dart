/// Domain entity representing a chat conversation.
class ChatConversation {
  const ChatConversation({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.lastMessage,
    required this.time,
    this.unread = 0,
    required this.type,
  });

  final String id;
  final String name;
  final String? avatarUrl;
  final String lastMessage;
  final String time;
  final int unread;
  final String type;
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.text,
    this.isMe = false,
    required this.time,
    this.type = 'text',
    this.imageUrl,
  });

  final String id;
  final String text;
  final bool isMe;
  final String time;
  final String type;
  final String? imageUrl;
}
