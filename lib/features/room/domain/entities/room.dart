/// Domain entity representing a game room.
class Room {
  const Room({
    required this.id,
    required this.name,
    required this.type,
    this.voiceEnabled = true,
    this.cameraEnabled = false,
    this.allowSpectators = true,
    this.gameSpeed = GameSpeed.normal,
    this.creatorName,
    this.inviteCode,
    this.players = const [],
    this.chatMessages = const [],
  });

  final String id;
  final String name;
  final RoomType type;
  final bool voiceEnabled;
  final bool cameraEnabled;
  final bool allowSpectators;
  final GameSpeed gameSpeed;
  final String? creatorName;
  final String? inviteCode;
  final List<RoomPlayer> players;
  final List<RoomChatMessage> chatMessages;
}

enum RoomType { private, public, liveStream }

enum GameSpeed { relaxed, normal, fast }

class RoomPlayer {
  const RoomPlayer({
    required this.name,
    this.avatarUrl,
    this.isReady = false,
    this.isMe = false,
    this.team = 'A',
    this.level,
  });

  final String name;
  final String? avatarUrl;
  final bool isReady;
  final bool isMe;
  final String team;
  final int? level;
}

class RoomChatMessage {
  const RoomChatMessage({required this.user, required this.text});

  final String user;
  final String text;
}
