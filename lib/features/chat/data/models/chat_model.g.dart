// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatConversationModel _$ChatConversationModelFromJson(
  Map<String, dynamic> json,
) => _ChatConversationModel(
  id: json['id'] as String,
  name: json['name'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  lastMessage: json['lastMessage'] as String,
  time: json['time'] as String,
  unread: (json['unread'] as num?)?.toInt() ?? 0,
  type: json['type'] as String,
);

Map<String, dynamic> _$ChatConversationModelToJson(
  _ChatConversationModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'avatarUrl': instance.avatarUrl,
  'lastMessage': instance.lastMessage,
  'time': instance.time,
  'unread': instance.unread,
  'type': instance.type,
};

_ChatMessageModel _$ChatMessageModelFromJson(Map<String, dynamic> json) =>
    _ChatMessageModel(
      id: json['id'] as String,
      text: json['text'] as String,
      isMe: json['isMe'] as bool? ?? false,
      time: json['time'] as String,
      type: json['type'] as String? ?? 'text',
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$ChatMessageModelToJson(_ChatMessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'isMe': instance.isMe,
      'time': instance.time,
      'type': instance.type,
      'imageUrl': instance.imageUrl,
    };
