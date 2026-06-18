import 'package:bloot/features/notifications/domain/entities/notification_item.dart';

/// Repository contract for user notifications.
abstract class NotificationsRepository {
  /// Returns all notifications for the current user, newest first.
  Future<List<NotificationItem>> getNotifications();

  /// Returns only unread notifications.
  Future<List<NotificationItem>> getUnreadNotifications();

  /// Marks a single notification as read.
  Future<void> markAsRead(String notificationId);

  /// Marks all notifications as read.
  Future<void> markAllAsRead();
}
