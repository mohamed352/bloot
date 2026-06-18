import 'package:injectable/injectable.dart';

import 'package:bloot/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:bloot/features/notifications/data/models/notification_item_model.dart';
import 'package:bloot/features/notifications/domain/entities/notification_item.dart';
import 'package:bloot/features/notifications/domain/repositories/notifications_repository.dart';

@LazySingleton(as: NotificationsRepository)
class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl({
    required NotificationsRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final NotificationsRemoteDataSource _remoteDataSource;

  @override
  Future<List<NotificationItem>> getNotifications() async {
    final models = await _remoteDataSource.getNotifications();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<NotificationItem>> getUnreadNotifications() async {
    final models = await _remoteDataSource.getUnreadNotifications();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _remoteDataSource.markAsRead(notificationId);
  }

  @override
  Future<void> markAllAsRead() async {
    await _remoteDataSource.markAllAsRead();
  }
}
