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
    this.creatorUid,
    this.inviteCode,
    this.agoraChannelName,
    this.players = const [],
    this.chatMessages = const [],
    this.status = RoomStatus.waiting,
    this.gameId,
    this.isStreaming = false,
    this.streamId,
  });

  final String id;
  final String name;
  final RoomType type;
  final bool voiceEnabled;
  final bool cameraEnabled;
  final bool allowSpectators;
  final GameSpeed gameSpeed;
  final String? creatorUid;
  final String? inviteCode;
  final String? agoraChannelName;
  final List<RoomPlayer> players;
  final List<RoomChatMessage> chatMessages;
  final RoomStatus status;
  final String? gameId;
  final bool isStreaming;
  final String? streamId;

  Room copyWith({
    String? id,
    String? name,
    RoomType? type,
    bool? voiceEnabled,
    bool? cameraEnabled,
    bool? allowSpectators,
    GameSpeed? gameSpeed,
    String? creatorUid,
    String? inviteCode,
    String? agoraChannelName,
    List<RoomPlayer>? players,
    List<RoomChatMessage>? chatMessages,
    RoomStatus? status,
    String? gameId,
    bool? isStreaming,
    String? streamId,
  }) => Room(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    voiceEnabled: voiceEnabled ?? this.voiceEnabled,
    cameraEnabled: cameraEnabled ?? this.cameraEnabled,
    allowSpectators: allowSpectators ?? this.allowSpectators,
    gameSpeed: gameSpeed ?? this.gameSpeed,
    creatorUid: creatorUid ?? this.creatorUid,
    inviteCode: inviteCode ?? this.inviteCode,
    agoraChannelName: agoraChannelName ?? this.agoraChannelName,
    players: players ?? this.players,
    chatMessages: chatMessages ?? this.chatMessages,
    status: status ?? this.status,
    gameId: gameId ?? this.gameId,
    isStreaming: isStreaming ?? this.isStreaming,
    streamId: streamId ?? this.streamId,
  );
}

enum RoomType { private, public, liveStream }

enum GameSpeed { relaxed, normal, fast }

enum RoomStatus { waiting, playing, finished }

class RoomPlayer {
  const RoomPlayer({
    required this.uid,
    required this.name,
    this.avatarUrl,
    this.isReady = false,
    this.isMe = false,
    this.team = 'A',
    this.level,
    this.isMicOn = true,
    this.isCameraOn = false,
    this.agoraUid,
    this.isSpeaking = false,
  });

  final String uid;
  final String name;
  final String? avatarUrl;
  final bool isReady;
  final bool isMe;
  final String team;
  final int? level;
  final bool isMicOn;
  final bool isCameraOn;

  /// The Agora UID derived from [uid.hashCode.abs()].
  final int? agoraUid;

  /// Whether this player is currently speaking (based on Agora volume indication).
  final bool isSpeaking;

  RoomPlayer copyWith({
    String? uid,
    String? name,
    String? avatarUrl,
    bool? isReady,
    bool? isMe,
    String? team,
    int? level,
    bool? isMicOn,
    bool? isCameraOn,
    int? agoraUid,
    bool? isSpeaking,
  }) =>
      RoomPlayer(
        uid: uid ?? this.uid,
        name: name ?? this.name,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        isReady: isReady ?? this.isReady,
        isMe: isMe ?? this.isMe,
        team: team ?? this.team,
        level: level ?? this.level,
        isMicOn: isMicOn ?? this.isMicOn,
        isCameraOn: isCameraOn ?? this.isCameraOn,
        agoraUid: agoraUid ?? this.agoraUid,
        isSpeaking: isSpeaking ?? this.isSpeaking,
      );
}

class RoomChatMessage {
  const RoomChatMessage({
    required this.user,
    required this.text,
    this.isSystem = false,
  });

  final String user;
  final String text;
  final bool isSystem;
}
