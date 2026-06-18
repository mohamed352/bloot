// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discover_stream_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StreamPlayerModel _$StreamPlayerModelFromJson(Map<String, dynamic> json) =>
    _StreamPlayerModel(
      uid: json['uid'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      agoraUid: (json['agoraUid'] as num).toInt(),
      team: json['team'] as String? ?? 'A',
      isCameraOn: json['isCameraOn'] as bool? ?? false,
      isMicOn: json['isMicOn'] as bool? ?? true,
    );

Map<String, dynamic> _$StreamPlayerModelToJson(_StreamPlayerModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'avatarUrl': instance.avatarUrl,
      'agoraUid': instance.agoraUid,
      'team': instance.team,
      'isCameraOn': instance.isCameraOn,
      'isMicOn': instance.isMicOn,
    };

_DiscoverStreamModel _$DiscoverStreamModelFromJson(Map<String, dynamic> json) =>
    _DiscoverStreamModel(
      id: json['id'] as String,
      title: json['title'] as String,
      host: json['host'] as String,
      viewers: (json['viewers'] as num).toInt(),
      avatarUrl: json['avatarUrl'] as String,
      category: json['category'] as String? ?? 'Baloot',
      isLive: json['isLive'] as bool? ?? true,
      isPremium: json['isPremium'] as bool? ?? false,
      agoraChannelName: json['agoraChannelName'] as String?,
      roomId: json['roomId'] as String?,
      players:
          (json['players'] as List<dynamic>?)
              ?.map(
                (e) => StreamPlayerModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$DiscoverStreamModelToJson(
  _DiscoverStreamModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'host': instance.host,
  'viewers': instance.viewers,
  'avatarUrl': instance.avatarUrl,
  'category': instance.category,
  'isLive': instance.isLive,
  'isPremium': instance.isPremium,
  'agoraChannelName': instance.agoraChannelName,
  'roomId': instance.roomId,
  'players': instance.players,
};

_StreamChatMessageModel _$StreamChatMessageModelFromJson(
  Map<String, dynamic> json,
) => _StreamChatMessageModel(
  id: json['id'] as String,
  senderUid: json['senderUid'] as String,
  senderName: json['senderName'] as String,
  senderAvatar: json['senderAvatar'] as String?,
  text: json['text'] as String,
  type: json['type'] as String? ?? 'text',
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  isMe: json['isMe'] as bool? ?? false,
);

Map<String, dynamic> _$StreamChatMessageModelToJson(
  _StreamChatMessageModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'senderUid': instance.senderUid,
  'senderName': instance.senderName,
  'senderAvatar': instance.senderAvatar,
  'text': instance.text,
  'type': instance.type,
  'createdAt': instance.createdAt?.toIso8601String(),
  'isMe': instance.isMe,
};
