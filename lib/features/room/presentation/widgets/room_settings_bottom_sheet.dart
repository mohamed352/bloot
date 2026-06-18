import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/constants/app_radius.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/features/room/domain/entities/room.dart';
import 'package:bloot/generated/locale_keys.g.dart';

class RoomSettingsBottomSheet extends StatelessWidget {
  const RoomSettingsBottomSheet({
    super.key,
    required this.room,
    required this.onLeave,
  });

  final Room room;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ColorManager.darkSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsetsDirectional.only(
        start: AppSpacing.lg,
        end: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: AppSpacing.xxl,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ColorManager.darkTextMuted.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'room_settings'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: ColorManager.darkTextPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildSettingRow(
              Icons.mic_rounded,
              'voice_chat'.tr(),
              room.voiceEnabled ? LocaleKeys.labelOn.tr() : LocaleKeys.off.tr(),
            ),
            const Divider(color: ColorManager.darkBorderSoft, height: 16),
            _buildSettingRow(
              Icons.videocam_rounded,
              'camera'.tr(),
              room.cameraEnabled ? LocaleKeys.labelOn.tr() : LocaleKeys.off.tr(),
            ),
            const Divider(color: ColorManager.darkBorderSoft, height: 16),
            _buildSettingRow(
              Icons.visibility_rounded,
              'spectators'.tr(),
              room.allowSpectators ? 'allowed'.tr() : 'not_allowed'.tr(),
            ),
            const Divider(color: ColorManager.darkBorderSoft, height: 16),
            _buildSettingRow(
              Icons.meeting_room_rounded,
              'room_type'.tr(),
              room.type.name.tr(),
            ),
            const SizedBox(height: AppSpacing.xxl),
            ListTile(
              leading: const Icon(
                Icons.notifications_rounded,
                color: ColorManager.primary,
              ),
              title: Text(
                'notifications'.tr(),
                style: const TextStyle(
                  fontSize: 14,
                  color: ColorManager.darkTextPrimary,
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: ColorManager.darkTextMuted,
              ),
              onTap: () {
                context.pop();
                context.pushNamed(RouteNames.notifications);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            ListTile(
              leading: const Icon(
                Icons.logout_rounded,
                color: ColorManager.error,
              ),
              title: Text(
                'leave_room'.tr(),
                style: const TextStyle(fontSize: 14, color: ColorManager.error),
              ),
              onTap: () {
                context.pop();
                _showLeaveConfirmation(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLeaveConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorManager.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'leave_room'.tr(),
          style: const TextStyle(color: ColorManager.darkTextPrimary),
        ),
        content: Text(
          'leave_room_confirm'.tr(),
          style: const TextStyle(color: ColorManager.darkTextSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              onLeave();
            },
            child: Text(
              'leave'.tr(),
              style: const TextStyle(color: ColorManager.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: ColorManager.primary),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: ColorManager.darkTextPrimary,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ColorManager.primary,
          ),
        ),
      ],
    );
  }
}
