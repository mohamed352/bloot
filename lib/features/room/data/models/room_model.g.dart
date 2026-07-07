// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RoomModel _$RoomModelFromJson(Map<String, dynamic> json) => _RoomModel(
  id: json['id'] as String,
  name: json['name'] as String,
  type: json['type'] as String,
  voiceEnabled: json['voiceEnabled'] as bool? ?? true,
  cameraEnabled: json['cameraEnabled'] as bool? ?? false,
  allowSpectators: json['allowSpectators'] as bool? ?? true,
  gameSpeed: json['gameSpeed'] as String? ?? 'normal',
  password: json['password'] as String?,
  creatorUid: json['creatorUid'] as String?,
  inviteCode: json['inviteCode'] as String?,
  agoraChannelName: json['agoraChannelName'] as String?,
  players:
      (json['players'] as List<dynamic>?)
          ?.map((e) => RoomPlayerModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <RoomPlayerModel>[],
  status: json['status'] as String? ?? 'waiting',
  gameId: json['gameId'] as String?,
  isStreaming: json['isStreaming'] as bool? ?? false,
  streamId: json['streamId'] as String?,
);

Map<String, dynamic> _$RoomModelToJson(_RoomModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'voiceEnabled': instance.voiceEnabled,
      'cameraEnabled': instance.cameraEnabled,
      'allowSpectators': instance.allowSpectators,
      'gameSpeed': instance.gameSpeed,
      'password': instance.password,
      'creatorUid': instance.creatorUid,
      'inviteCode': instance.inviteCode,
      'agoraChannelName': instance.agoraChannelName,
      'players': instance.players,
      'status': instance.status,
      'gameId': instance.gameId,
      'isStreaming': instance.isStreaming,
      'streamId': instance.streamId,
    };

_RoomPlayerModel _$RoomPlayerModelFromJson(Map<String, dynamic> json) =>
    _RoomPlayerModel(
      uid: json['uid'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      isReady: json['isReady'] as bool? ?? false,
      isMe: json['isMe'] as bool? ?? false,
      team: json['team'] as String? ?? 'A',
      level: (json['level'] as num?)?.toInt(),
      isMicOn: json['isMicOn'] as bool? ?? true,
      isCameraOn: json['isCameraOn'] as bool? ?? false,
      agoraUid: (json['agoraUid'] as num?)?.toInt(),
      isSpeaking: json['isSpeaking'] as bool? ?? false,
    );

Map<String, dynamic> _$RoomPlayerModelToJson(_RoomPlayerModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'avatarUrl': instance.avatarUrl,
      'isReady': instance.isReady,
      'isMe': instance.isMe,
      'team': instance.team,
      'level': instance.level,
      'isMicOn': instance.isMicOn,
      'isCameraOn': instance.isCameraOn,
      'agoraUid': instance.agoraUid,
      'isSpeaking': instance.isSpeaking,
    };
