/// Domain entity representing a discoverable stream.
class DiscoverStream {
  const DiscoverStream({
    required this.id,
    required this.title,
    required this.host,
    required this.viewers,
    required this.avatarUrl,
    this.category = 'Baloot',
    this.isLive = true,
    this.isPremium = false,
  });

  final String id;
  final String title;
  final String host;
  final int viewers;
  final String avatarUrl;
  final String category;
  final bool isLive;
  final bool isPremium;
}

class StreamChatMessage {
  const StreamChatMessage({
    required this.user,
    required this.text,
    this.isMe = false,
  });

  final String user;
  final String text;
  final bool isMe;
}
