import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:bloot/core/logger/app_logger.dart';
import 'package:bloot/features/notifications/domain/entities/notification_item.dart';
import 'package:bloot/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:bloot/features/notifications/presentation/cubit/notifications_state.dart';

@injectable
class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit({
    required NotificationsRepository notificationsRepository,
  }) : _notificationsRepository = notificationsRepository,
       super(const NotificationsState.initial());

  final NotificationsRepository _notificationsRepository;

  Future<void> loadNotifications() async {
    emit(const NotificationsState.loading());
    try {
      final notifications =
          await _notificationsRepository.getNotifications();
      if (notifications.isEmpty) {
        emit(const NotificationsState.empty());
      } else {
        emit(NotificationsState.loaded(notifications: notifications));
      }
    } catch (e) {
      AppLogger.error('Failed to load notifications', error: e);
      emit(NotificationsState.error(message: e.toString()));
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationsRepository.markAsRead(notificationId);
      state.whenOrNull(
        loaded: (notifications) {
          final updated = notifications.map((n) {
            if (n.id == notificationId) {
              return NotificationItem(
                id: n.id,
                title: n.title,
                body: n.body,
                type: n.type,
                read: true,
                createdAt: n.createdAt,
              );
            }
            return n;
          }).toList();
          emit(NotificationsState.loaded(notifications: updated));
        },
      );
    } catch (e) {
      AppLogger.error('Failed to mark notification as read', error: e);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _notificationsRepository.markAllAsRead();
      state.whenOrNull(
        loaded: (notifications) {
          final updated = notifications
              .map(
                (n) => NotificationItem(
                  id: n.id,
                  title: n.title,
                  body: n.body,
                  type: n.type,
                  read: true,
                  createdAt: n.createdAt,
                ),
              )
              .toList();
          emit(NotificationsState.loaded(notifications: updated));
        },
      );
    } catch (e) {
      AppLogger.error('Failed to mark all notifications as read', error: e);
    }
  }
}
