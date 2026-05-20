import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:bloot/core/components/app_scaffold.dart';
import 'package:bloot/core/components/custom_app_bar.dart';
import 'package:bloot/core/components/empty_state_widget.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/extension/context_values.dart';
import 'package:bloot/generated/locale_keys.g.dart';

/// Notification feed screen showing all user notifications.
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    // TODO: Replace with real notifications from a Cubit
    final notifications = <_NotificationItem>[];

    return AppScaffold(
      appBar: CustomAppBar(
        title: LocaleKeys.notifications.tr(),
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () {},
              child: Text(LocaleKeys.commonDelete.tr()),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.notifications_none_rounded,
              title: 'No notifications yet',
              subtitle: 'When you get notifications, they will appear here',
            )
          : ListView.separated(
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
                return _NotificationTile(item: item);
              },
            ),
    );
  }
}

class _NotificationItem {
  const _NotificationItem({
    required this.icon,
    required this.title,
    required this.body,
    required this.time,
  });

  final IconData icon;
  final String title;
  final String body;
  final String time;
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item});

  final _NotificationItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      onTap: () {},
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
                color: colors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.icon,
                color: colors.primary,
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
                      fontWeight: FontWeight.w700,
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
                    item.time,
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
