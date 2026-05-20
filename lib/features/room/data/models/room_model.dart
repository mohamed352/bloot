import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:bloot/features/room/domain/entities/room.dart';

part 'room_model.freezed.dart';
part 'room_model.g.dart';

@freezed
abstract class RoomModel with _$RoomModel {
  const factory RoomModel({
    required String id,
    required String name,
    required String type,
    @Default(true) bool voiceEnabled,
    @Default(false) bool cameraEnabled,
    @Default(true) bool allowSpectators,
    @Default('normal') String gameSpeed,
    String? creatorName,
    String? inviteCode,
    @Default(<RoomPlayerModel>[]) List<RoomPlayerModel> players,
    @Default(<RoomChatMessageModel>[]) List<RoomChatMessageModel> chatMessages,
  }) = _RoomModel;

  factory RoomModel.fromJson(Map<String, dynamic> json) =>
      _$RoomModelFromJson(json);
}

@freezed
abstract class RoomPlayerModel with _$RoomPlayerModel {
  const factory RoomPlayerModel({
    required String name,
    String? avatarUrl,
    @Default(false) bool isReady,
    @Default(false) bool isMe,
    @Default('A') String team,
    int? level,
  }) = _RoomPlayerModel;

  factory RoomPlayerModel.fromJson(Map<String, dynamic> json) =>
      _$RoomPlayerModelFromJson(json);
}

@freezed
abstract class RoomChatMessageModel with _$RoomChatMessageModel {
  const factory RoomChatMessageModel({
    required String user,
    required String text,
  }) = _RoomChatMessageModel;

  factory RoomChatMessageModel.fromJson(Map<String, dynamic> json) =>
      _$RoomChatMessageModelFromJson(json);
}

extension RoomModelX on RoomModel {
  Room toEntity() => Room(
    id: id,
    name: name,
    type: RoomType.values.firstWhere((e) => e.name == type),
    voiceEnabled: voiceEnabled,
    cameraEnabled: cameraEnabled,
    allowSpectators: allowSpectators,
    gameSpeed: GameSpeed.values.firstWhere((e) => e.name == gameSpeed),
    creatorName: creatorName,
    inviteCode: inviteCode,
    players: players.map((p) => p.toEntity()).toList(),
    chatMessages: chatMessages.map((m) => m.toEntity()).toList(),
  );
}

extension RoomPlayerModelX on RoomPlayerModel {
  RoomPlayer toEntity() => RoomPlayer(
    name: name,
    avatarUrl: avatarUrl,
    isReady: isReady,
    isMe: isMe,
    team: team,
    level: level,
  );
}

extension RoomChatMessageModelX on RoomChatMessageModel {
  RoomChatMessage toEntity() => RoomChatMessage(user: user, text: text);
}
