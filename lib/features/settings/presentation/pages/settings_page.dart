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
                      title: 'account'.tr(),
                      onTap: () => context.pushNamed(RouteNames.accountSettings),
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
