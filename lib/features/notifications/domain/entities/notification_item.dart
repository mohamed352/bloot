/// Domain entity representing a user notification.
class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.titleAr,
    this.bodyAr,
    this.roomId,
    this.read = false,
    this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final String type;

  /// Optional Arabic localization written by the backend.
  final String? titleAr;
  final String? bodyAr;

  /// Associated room for actionable notifications (e.g. `roomInvite`).
  final String? roomId;
  final bool read;
  final DateTime? createdAt;
}
