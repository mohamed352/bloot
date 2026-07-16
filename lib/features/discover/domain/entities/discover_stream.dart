/// Domain entity representing a player in a stream.
class StreamPlayer {
  const StreamPlayer({
    required this.uid,
    required this.name,
    this.avatarUrl,
    required this.agoraUid,
    this.team = 'A',
    this.isCameraOn = false,
    this.isMicOn = true,
  });

  final String uid;
  final String name;
  final String? avatarUrl;
  final int agoraUid;
  final String team;
  final bool isCameraOn;
  final bool isMicOn;
}

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
    this.agoraChannelName,
    this.roomId,
    this.players = const [],
  });

  final String id;
  final String title;
  final String host;
  final int viewers;
  final String avatarUrl;
  final String category;
  final bool isLive;
  final bool isPremium;
  final String? agoraChannelName;
  final String? roomId;
  final List<StreamPlayer> players;

  DiscoverStream copyWith({
    String? id,
    String? title,
    String? host,
    int? viewers,
    String? avatarUrl,
    String? category,
    bool? isLive,
    bool? isPremium,
    String? agoraChannelName,
    String? roomId,
    List<StreamPlayer>? players,
  }) {
    return DiscoverStream(
      id: id ?? this.id,
      title: title ?? this.title,
      host: host ?? this.host,
      viewers: viewers ?? this.viewers,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      category: category ?? this.category,
      isLive: isLive ?? this.isLive,
      isPremium: isPremium ?? this.isPremium,
      agoraChannelName: agoraChannelName ?? this.agoraChannelName,
      roomId: roomId ?? this.roomId,
      players: players ?? this.players,
    );
  }
}

class StreamChatMessage {
  const StreamChatMessage({
    required this.id,
    required this.senderUid,
    required this.senderName,
    this.senderAvatar,
    required this.text,
    this.type = 'text',
    this.createdAt,
    this.isMe = false,
  });

  final String id;
  final String senderUid;
  final String senderName;
  final String? senderAvatar;
  final String text;
  final String type;
  final DateTime? createdAt;
  final bool isMe;
}
