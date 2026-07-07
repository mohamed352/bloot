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
    String? password,
    String? creatorUid,
    String? inviteCode,
    String? agoraChannelName,
    @Default(<RoomPlayerModel>[]) List<RoomPlayerModel> players,
    @Default('waiting') String status,
    String? gameId,
    @Default(false) bool isStreaming,
    String? streamId,
  }) = _RoomModel;

  factory RoomModel.fromJson(Map<String, dynamic> json) =>
      _$RoomModelFromJson(json);
}

@freezed
abstract class RoomPlayerModel with _$RoomPlayerModel {
  const factory RoomPlayerModel({
    required String uid,
    required String name,
    String? avatarUrl,
    @Default(false) bool isReady,
    @Default(false) bool isMe,
    @Default('A') String team,
    int? level,
    @Default(true) bool isMicOn,
    @Default(false) bool isCameraOn,
    int? agoraUid,
    @Default(false) bool isSpeaking,
  }) = _RoomPlayerModel;

  factory RoomPlayerModel.fromJson(Map<String, dynamic> json) =>
      _$RoomPlayerModelFromJson(json);
}

extension RoomModelX on RoomModel {
  Room toEntity({String? currentUserUid}) => Room(
    id: id,
    name: name,
    type: RoomType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => RoomType.private,
    ),
    voiceEnabled: voiceEnabled,
    cameraEnabled: cameraEnabled,
    allowSpectators: allowSpectators,
    gameSpeed: GameSpeed.values.firstWhere(
      (e) => e.name == gameSpeed,
      orElse: () => GameSpeed.normal,
    ),
    password: password,
    creatorUid: creatorUid,
    inviteCode: inviteCode,
    agoraChannelName: agoraChannelName,
    players: players
        .map((p) => p.toEntity(currentUserUid: currentUserUid))
        .toList(),
    status: RoomStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => RoomStatus.waiting,
    ),
    gameId: gameId,
    isStreaming: isStreaming,
    streamId: streamId,
  );
}

extension RoomPlayerModelX on RoomPlayerModel {
  RoomPlayer toEntity({String? currentUserUid}) => RoomPlayer(
    uid: uid,
    name: name,
    avatarUrl: avatarUrl,
    isReady: isReady,
    isMe: currentUserUid != null && uid == currentUserUid,
    team: team,
    level: level,
    isMicOn: isMicOn,
    isCameraOn: isCameraOn,
    agoraUid: agoraUid ?? uid.hashCode.abs(),
    isSpeaking: isSpeaking,
  );
}
