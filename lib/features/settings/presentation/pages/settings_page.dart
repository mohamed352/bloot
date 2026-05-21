import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/constants/app_radius.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.darkCanvas,
      appBar: AppBar(
        title: Text('settings'.tr()),
        backgroundColor: const Color(0x00000000),
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _buildSectionTitle('account'.tr()),
            _buildSettingTile(
              icon: Icons.person_rounded,
              title: 'edit_profile'.tr(),
              onTap: () => context.pushNamed(RouteNames.editProfile),
            ),
            _buildSettingTile(
              icon: Icons.alternate_email_rounded,
              title: 'change_username'.tr(),
              onTap: () => _showComingSoon(context),
            ),
            _buildSettingTile(
              icon: Icons.link_rounded,
              title: 'linked_accounts'.tr(),
              onTap: () => _showComingSoon(context),
            ),
            _buildSettingTile(
              icon: Icons.block_rounded,
              title: 'block_list'.tr(),
              onTap: () => _showComingSoon(context),
            ),
            const SizedBox(height: AppSpacing.xxl),
            _buildSectionTitle('game'.tr()),
            _buildToggleTile('voice_chat'.tr(), true),
            _buildToggleTile('camera'.tr(), false),
            _buildSettingTile(
              icon: Icons.speaker_rounded,
              title: 'speaker_mode'.tr(),
              subtitle: 'speaker'.tr(),
              onTap: () => _showComingSoon(context),
            ),
            _buildToggleTile('auto_rotate_for_game'.tr(), true),
            _buildSettingTile(
              icon: Icons.speed_rounded,
              title: 'game_speed'.tr(),
              subtitle: 'normal'.tr(),
              onTap: () => _showComingSoon(context),
            ),
            _buildToggleTile('sound_effects'.tr(), true),
            _buildToggleTile('background_music'.tr(), false),
            const SizedBox(height: AppSpacing.xxl),
            _buildSectionTitle('privacy'.tr()),
            _buildToggleTile('show_online_status'.tr(), true),
            _buildSettingTile(
              icon: Icons.visibility_rounded,
              title: 'profile_visibility'.tr(),
              subtitle: 'everyone'.tr(),
              onTap: () => _showComingSoon(context),
            ),
            _buildSettingTile(
              icon: Icons.notifications_rounded,
              title: 'notifications'.tr(),
              onTap: () => context.pushNamed(RouteNames.notifications),
            ),
            _buildSettingTile(
              icon: Icons.volume_off_rounded,
              title: 'muted_users'.tr(),
              onTap: () => _showComingSoon(context),
            ),
            const SizedBox(height: AppSpacing.xxl),
            _buildSectionTitle('support'.tr()),
            _buildSettingTile(
              icon: Icons.help_outline_rounded,
              title: 'help_center'.tr(),
              onTap: () => _showComingSoon(context),
            ),
            _buildSettingTile(
              icon: Icons.mail_outline_rounded,
              title: 'contact_support'.tr(),
              onTap: () => _showComingSoon(context),
            ),
            _buildSettingTile(
              icon: Icons.report_problem_outlined,
              title: 'report_a_problem'.tr(),
              onTap: () => _showComingSoon(context),
            ),
            _buildSettingTile(
              icon: Icons.description_outlined,
              title: 'terms_of_service'.tr(),
              onTap: () => context.pushNamed(RouteNames.terms),
            ),
            _buildSettingTile(
              icon: Icons.privacy_tip_outlined,
              title: 'privacy_policy'.tr(),
              onTap: () => context.pushNamed(RouteNames.privacy),
            ),
            _buildSettingTile(
              icon: Icons.info_outline_rounded,
              title: 'about_bloot'.tr(),
              onTap: () => _showComingSoon(context),
            ),
            const SizedBox(height: AppSpacing.xxl),
            _buildSectionTitle('danger_zone'.tr()),
            _buildSettingTile(
              icon: Icons.logout_rounded,
              title: 'log_out'.tr(),
              iconColor: ColorManager.error,
              textColor: ColorManager.error,
              onTap: () => _showLogoutDialog(context),
            ),
            _buildSettingTile(
              icon: Icons.delete_forever_rounded,
              title: 'delete_account'.tr(),
              iconColor: ColorManager.error,
              textColor: ColorManager.error,
              onTap: () => _showComingSoon(context),
            ),
            const SizedBox(height: AppSpacing.xxl),
            const Center(
              child: Text(
                'Bloot v1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: ColorManager.darkTextMuted,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: ColorManager.primary,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ColorManager.darkSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ColorManager.darkBorderSoft),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: iconColor ?? ColorManager.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor ?? ColorManager.darkTextPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: ColorManager.darkTextMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: ColorManager.darkTextMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTile(String title, bool initialValue) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: ColorManager.darkSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: ColorManager.darkBorderSoft),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ColorManager.darkTextPrimary,
                  ),
                ),
              ),
              Switch.adaptive(
                value: initialValue,
                onChanged: (v) {},
                activeTrackColor: ColorManager.primary,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Coming soon')));
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorManager.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: Text(
          'log_out_question'.tr(),
          style: const TextStyle(color: ColorManager.darkTextPrimary),
        ),
        content: Text(
          'logout_confirmation'.tr(),
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
              context.goNamed(RouteNames.login);
            },
            child: Text(
              'log_out'.tr(),
              style: const TextStyle(color: ColorManager.error),
            ),
          ),
        ],
      ),
    );
  }
}
