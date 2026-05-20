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
  creatorName: json['creatorName'] as String?,
  inviteCode: json['inviteCode'] as String?,
  players:
      (json['players'] as List<dynamic>?)
          ?.map((e) => RoomPlayerModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <RoomPlayerModel>[],
  chatMessages:
      (json['chatMessages'] as List<dynamic>?)
          ?.map((e) => RoomChatMessageModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <RoomChatMessageModel>[],
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
      'creatorName': instance.creatorName,
      'inviteCode': instance.inviteCode,
      'players': instance.players,
      'chatMessages': instance.chatMessages,
    };

_RoomPlayerModel _$RoomPlayerModelFromJson(Map<String, dynamic> json) =>
    _RoomPlayerModel(
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      isReady: json['isReady'] as bool? ?? false,
      isMe: json['isMe'] as bool? ?? false,
      team: json['team'] as String? ?? 'A',
      level: (json['level'] as num?)?.toInt(),
    );

Map<String, dynamic> _$RoomPlayerModelToJson(_RoomPlayerModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'avatarUrl': instance.avatarUrl,
      'isReady': instance.isReady,
      'isMe': instance.isMe,
      'team': instance.team,
      'level': instance.level,
    };

_RoomChatMessageModel _$RoomChatMessageModelFromJson(
  Map<String, dynamic> json,
) => _RoomChatMessageModel(
  user: json['user'] as String,
  text: json['text'] as String,
);

Map<String, dynamic> _$RoomChatMessageModelToJson(
  _RoomChatMessageModel instance,
) => <String, dynamic>{'user': instance.user, 'text': instance.text};
