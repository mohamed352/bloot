import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/constants/app_radius.dart';
import 'package:bloot/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:bloot/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:bloot/features/settings/presentation/cubit/settings_state.dart';

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
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            return state.when(
              initial: () => const Center(
                child: CircularProgressIndicator(color: ColorManager.primary),
              ),
              loaded: (
                voiceChatEnabled,
                cameraEnabled,
                autoRotateGame,
                soundEffectsEnabled,
                backgroundMusicEnabled,
                showOnlineStatus,
                gameSpeed,
                speakerMode,
                profileVisibility,
              ) {
                return ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    _buildSectionTitle('account'.tr()),
                    _buildSettingTile(
                      icon: Icons.person_rounded,
                      title: 'edit_profile'.tr(),
                      onTap: () => context.pushNamed(RouteNames.editProfile),
                    ),
                    _buildSettingTile(
                      icon: Icons.person_rounded,
                      title: 'account'.tr(),
                      onTap: () => context.pushNamed(RouteNames.accountSettings),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    _buildSectionTitle('game'.tr()),
                    _buildToggleTile(
                      title: 'voice_chat'.tr(),
                      value: voiceChatEnabled,
                      onChanged: (v) =>
                          context.read<SettingsCubit>().toggleVoiceChat(v),
                    ),
                    _buildToggleTile(
                      title: 'camera'.tr(),
                      value: cameraEnabled,
                      onChanged: (v) =>
                          context.read<SettingsCubit>().toggleCamera(v),
                    ),
                    _buildSettingTile(
                      icon: Icons.speaker_rounded,
                      title: 'speaker_mode'.tr(),
                      subtitle: speakerMode.tr(),
                      onTap: () => _showSpeakerModeSheet(
                        context,
                        current: speakerMode,
                      ),
                    ),
                    _buildToggleTile(
                      title: 'auto_rotate_for_game'.tr(),
                      value: autoRotateGame,
                      onChanged: (v) =>
                          context.read<SettingsCubit>().toggleAutoRotate(v),
                    ),
                    _buildSettingTile(
                      icon: Icons.speed_rounded,
                      title: 'game_speed'.tr(),
                      subtitle: gameSpeed.tr(),
                      onTap: () => _showGameSpeedSheet(
                        context,
                        current: gameSpeed,
                      ),
                    ),
                    _buildToggleTile(
                      title: 'sound_effects'.tr(),
                      value: soundEffectsEnabled,
                      onChanged: (v) =>
                          context.read<SettingsCubit>().toggleSoundEffects(v),
                    ),
                    _buildToggleTile(
                      title: 'background_music'.tr(),
                      value: backgroundMusicEnabled,
                      onChanged: (v) =>
                          context.read<SettingsCubit>().toggleBackgroundMusic(v),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    _buildSectionTitle('privacy'.tr()),
                    _buildToggleTile(
                      title: 'show_online_status'.tr(),
                      value: showOnlineStatus,
                      onChanged: (v) =>
                          context.read<SettingsCubit>().toggleShowOnlineStatus(
                            v,
                          ),
                    ),
                    _buildSettingTile(
                      icon: Icons.visibility_rounded,
                      title: 'profile_visibility'.tr(),
                      subtitle: profileVisibility.tr(),
                      onTap: () => _showProfileVisibilitySheet(
                        context,
                        current: profileVisibility,
                      ),
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
                    _buildSettingTile(
                      icon: Icons.notifications_rounded,
                      title: 'notification_settings'.tr(),
                      onTap: () => context.pushNamed(RouteNames.notificationSettings),
                    ),
                    _buildSettingTile(
                      icon: Icons.volume_up_rounded,
                      title: 'audio'.tr(),
                      onTap: () => context.pushNamed(RouteNames.audioSettings),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    _buildSectionTitle('support'.tr()),
                    _buildSettingTile(
                      icon: Icons.language_rounded,
                      title: 'language'.tr(),
                      onTap: () => context.pushNamed(RouteNames.languageSettings),
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
                      onTap: () => context.pushNamed(RouteNames.aboutSettings),
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
                      onTap: () => _showDeleteAccountDialog(context),
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
                );
              },
              error: (message) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: ColorManager.darkTextMuted,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      message,
                      style: const TextStyle(
                        color: ColorManager.darkTextSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextButton(
                      onPressed: () =>
                          context.read<SettingsCubit>().loadSettings(),
                      child: Text('commonRetry'.tr()),
                    ),
                  ],
                ),
              ),
            );
          },
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

  Widget _buildToggleTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
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
            value: value,
            onChanged: onChanged,
            activeTrackColor: ColorManager.primary,
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Coming soon')));
  }

  void _showGameSpeedSheet(BuildContext context, {required String current}) {
    _showSelectionSheet(
      context: context,
      title: 'game_speed'.tr(),
      options: ['normal', 'fast', 'slow'],
      current: current,
      onSelected: (value) => context.read<SettingsCubit>().setGameSpeed(value),
    );
  }

  void _showSpeakerModeSheet(BuildContext context, {required String current}) {
    _showSelectionSheet(
      context: context,
      title: 'speaker_mode'.tr(),
      options: ['speaker', 'earpiece'],
      current: current,
      onSelected: (value) => context.read<SettingsCubit>().setSpeakerMode(value),
    );
  }

  void _showProfileVisibilitySheet(
    BuildContext context, {
    required String current,
  }) {
    _showSelectionSheet(
      context: context,
      title: 'profile_visibility'.tr(),
      options: ['everyone', 'friends', 'nobody'],
      current: current,
      onSelected: (value) =>
          context.read<SettingsCubit>().setProfileVisibility(value),
    );
  }

  void _showSelectionSheet({
    required BuildContext context,
    required String title,
    required List<String> options,
    required String current,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ColorManager.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: ColorManager.darkTextPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                ...options.map((option) {
                  final isSelected = option == current;
                  return GestureDetector(
                    onTap: () {
                      onSelected(option);
                      context.pop();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? ColorManager.primary.withValues(alpha: 0.15)
                            : ColorManager.darkCanvas,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: isSelected
                              ? ColorManager.primary
                              : ColorManager.darkBorderSoft,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              option.tr(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: isSelected
                                    ? ColorManager.primary
                                    : ColorManager.darkTextPrimary,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_rounded,
                              color: ColorManager.primary,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
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
              context.read<AuthCubit>().signOut();
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

  void _showDeleteAccountDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          final canDelete = controller.text.trim() == 'DELETE';
          return AlertDialog(
            backgroundColor: ColorManager.darkSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            title: Text(
              'delete_account_confirm_title'.tr(),
              style: const TextStyle(color: ColorManager.error),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'delete_account_confirm_body'.tr(),
                  style: const TextStyle(color: ColorManager.darkTextSecondary),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: controller,
                  style: const TextStyle(color: ColorManager.darkTextPrimary),
                  decoration: InputDecoration(
                    hintText: 'Type DELETE to confirm',
                    hintStyle: const TextStyle(
                      color: ColorManager.darkTextMuted,
                    ),
                    filled: true,
                    fillColor: ColorManager.darkCanvas,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: const BorderSide(
                        color: ColorManager.darkBorderSoft,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: const BorderSide(
                        color: ColorManager.error,
                      ),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => dialogContext.pop(),
                child: Text('cancel'.tr()),
              ),
              TextButton(
                onPressed: canDelete
                    ? () {
                        dialogContext.pop();
                        context.read<AuthCubit>().deleteAccount();
                      }
                    : null,
                child: Text(
                  'delete_account'.tr(),
                  style: TextStyle(
                    color: canDelete
                        ? ColorManager.error
                        : ColorManager.darkTextMuted,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ).whenComplete(controller.dispose);
  }
}
