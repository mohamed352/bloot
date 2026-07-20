import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:bloot/features/notifications/domain/entities/notification_item.dart';

part 'notification_item_model.freezed.dart';
part 'notification_item_model.g.dart';

@freezed
abstract class NotificationItemModel with _$NotificationItemModel {
  const factory NotificationItemModel({
    required String id,
    required String title,
    required String body,
    required String type,
    String? titleAr,
    String? bodyAr,
    String? roomId,
    @Default(false) bool read,
    DateTime? createdAt,
  }) = _NotificationItemModel;

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationItemModelFromJson(json);
}

extension NotificationItemModelX on NotificationItemModel {
  NotificationItem toEntity() => NotificationItem(
        id: id,
        title: title,
        body: body,
        type: type,
        titleAr: titleAr,
        bodyAr: bodyAr,
        roomId: roomId,
        read: read,
        createdAt: createdAt,
      );
}
