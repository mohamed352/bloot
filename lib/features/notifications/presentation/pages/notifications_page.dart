import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bloot/core/components/app_scaffold.dart';
import 'package:bloot/core/components/custom_app_bar.dart';
import 'package:bloot/core/components/empty_state_widget.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/extension/context_values.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/features/notifications/domain/entities/notification_item.dart';
import 'package:bloot/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:bloot/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:bloot/generated/locale_keys.g.dart';

/// Notification feed screen showing all user notifications.
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: CustomAppBar(
        title: LocaleKeys.notifications.tr(),
        actions: [
          BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) {
              final hasUnread = state.maybeWhen(
                loaded: (notifications) =>
                    notifications.any((n) => !n.read),
                orElse: () => false,
              );
              if (!hasUnread) return const SizedBox.shrink();
              return TextButton(
                onPressed: () =>
                    context.read<NotificationsCubit>().markAllAsRead(),
                child: Text(LocaleKeys.commonDelete.tr()),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Center(
              child: CircularProgressIndicator(color: ColorManager.primary),
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(color: ColorManager.primary),
            ),
            loaded: (notifications) => _NotificationsList(
              notifications: notifications,
            ),
            empty: () => EmptyStateWidget(
              icon: Icons.notifications_none_rounded,
              title: LocaleKeys.notificationsEmptyTitle.tr(),
              subtitle: LocaleKeys.notificationsEmptySubtitle.tr(),
            ),
            error: (message) => Center(
              child: Text(
                message,
                style: const TextStyle(color: ColorManager.darkTextSecondary),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NotificationsList extends StatelessWidget {
  const _NotificationsList({required this.notifications});

  final List<NotificationItem> notifications;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return ListView.separated(
      padding: const EdgeInsetsDirectional.symmetric(
        vertical: AppSpacing.md,
      ),
      itemCount: notifications.length,
      separatorBuilder: (context, index) => Divider(
        color: colors.divider,
        indent: AppSpacing.screenHorizontal,
        endIndent: AppSpacing.screenHorizontal,
      ),
      itemBuilder: (context, index) {
        final item = notifications[index];
        return _NotificationTile(
          item: item,
          onTap: () {
            if (!item.read) {
              context.read<NotificationsCubit>().markAsRead(item.id);
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(LocaleKeys.notificationOpened.tr())),
            );
          },
        );
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.item,
    required this.onTap,
  });

  final NotificationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.screenHorizontal,
          vertical: AppSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: item.read
                    ? colors.primary.withValues(alpha: 0.1)
                    : colors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _iconForType(item.type),
                color: item.read ? colors.textMuted : colors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: item.read ? FontWeight.w600 : FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(item.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (!item.read)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsetsDirectional.only(start: AppSpacing.sm),
                decoration: const BoxDecoration(
                  color: ColorManager.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'tournament':
        return Icons.emoji_events_rounded;
      case 'room_invite':
        return Icons.videogame_asset_rounded;
      case 'follow':
        return Icons.person_add_rounded;
      case 'game':
        return Icons.local_fire_department_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return 'now'.tr();
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(dateTime);
    }
  }
}
