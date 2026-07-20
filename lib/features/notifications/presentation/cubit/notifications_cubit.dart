import 'dart:async';

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
  StreamSubscription<List<NotificationItem>>? _subscription;

  /// Subscribes to the real-time notifications stream so new notifications
  /// (e.g. room invites) appear without a manual refresh.
  Future<void> loadNotifications() async {
    emit(const NotificationsState.loading());
    await _subscription?.cancel();
    _subscription = _notificationsRepository.watchNotifications().listen(
      (notifications) {
        if (notifications.isEmpty) {
          emit(const NotificationsState.empty());
        } else {
          emit(NotificationsState.loaded(notifications: notifications));
        }
      },
      onError: (Object error) {
        AppLogger.error('Failed to load notifications', error: error);
        emit(NotificationsState.error(message: error.toString()));
      },
    );
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

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
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
