import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:bloot/features/notifications/domain/entities/notification_item.dart';

part 'notifications_state.freezed.dart';

@freezed
class NotificationsState with _$NotificationsState {
  const factory NotificationsState.initial() = NotificationsInitial;
  const factory NotificationsState.loading() = NotificationsLoading;
  const factory NotificationsState.loaded({
    required List<NotificationItem> notifications,
  }) = NotificationsLoaded;
  const factory NotificationsState.empty() = NotificationsEmpty;
  const factory NotificationsState.error({required String message}) =
      NotificationsError;
}
