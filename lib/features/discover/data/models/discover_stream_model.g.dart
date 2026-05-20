// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discover_stream_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
};

_StreamChatMessageModel _$StreamChatMessageModelFromJson(
  Map<String, dynamic> json,
) => _StreamChatMessageModel(
  user: json['user'] as String,
  text: json['text'] as String,
  isMe: json['isMe'] as bool? ?? false,
);

Map<String, dynamic> _$StreamChatMessageModelToJson(
  _StreamChatMessageModel instance,
) => <String, dynamic>{
  'user': instance.user,
  'text': instance.text,
  'isMe': instance.isMe,
};
