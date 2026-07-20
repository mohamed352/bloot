// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationItemModel _$NotificationItemModelFromJson(
  Map<String, dynamic> json,
) => _NotificationItemModel(
  id: json['id'] as String,
  title: json['title'] as String,
  body: json['body'] as String,
  type: json['type'] as String,
  titleAr: json['titleAr'] as String?,
  bodyAr: json['bodyAr'] as String?,
  roomId: json['roomId'] as String?,
  read: json['read'] as bool? ?? false,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$NotificationItemModelToJson(
  _NotificationItemModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'body': instance.body,
  'type': instance.type,
  'titleAr': instance.titleAr,
  'bodyAr': instance.bodyAr,
  'roomId': instance.roomId,
  'read': instance.read,
  'createdAt': instance.createdAt?.toIso8601String(),
};
