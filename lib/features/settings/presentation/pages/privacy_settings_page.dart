import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/di/injection.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/features/moderation/domain/repositories/moderation_repository.dart';
import 'package:bloot/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:bloot/features/settings/presentation/cubit/settings_state.dart';

class PrivacySettingsPage extends StatelessWidget {
  const PrivacySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.darkCanvas,
      appBar: AppBar(
        title: Text('privacy'.tr()),
        backgroundColor: const Color(0x00000000),
        elevation: 0,
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          final visibility = state is SettingsLoaded
              ? state.profileVisibility
              : 'everyone';

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'profile_visibility'.tr(),
                  style: const TextStyle(color: ColorManager.darkTextPrimary),
                ),
                subtitle: Text(
                  visibility.tr(),
                  style: const TextStyle(color: ColorManager.darkTextSecondary),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: ColorManager.darkTextMuted,
                ),
                onTap: () => _showVisibilitySheet(context, visibility),
              ),
              const Divider(color: ColorManager.darkBorderSoft),
              StreamBuilder<Set<String>>(
                stream: getIt<ModerationRepository>().watchBlockedUserIds(),
                builder: (context, snapshot) {
                  final count = snapshot.data?.length ?? 0;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'blocked_users'.tr(),
                      style: const TextStyle(
                        color: ColorManager.darkTextPrimary,
                      ),
                    ),
                    subtitle: Text(
                      count > 0
                          ? 'blocked_users_count'.tr(args: ['$count'])
                          : 'no_blocked_users'.tr(),
                      style: const TextStyle(
                        color: ColorManager.darkTextSecondary,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: ColorManager.darkTextMuted,
                    ),
                    onTap: () => context.pushNamed(RouteNames.blockedUsers),
                  );
                },
              ),
              const Divider(color: ColorManager.darkBorderSoft),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'data_download'.tr(),
                  style: const TextStyle(color: ColorManager.darkTextPrimary),
                ),
                trailing: const Icon(
                  Icons.download_rounded,
                  color: ColorManager.darkTextMuted,
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data download request sent')),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showVisibilitySheet(BuildContext context, String current) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: ColorManager.darkSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['everyone', 'friends', 'nobody'].map((option) {
            return ListTile(
              title: Text(
                option.tr(),
                style: TextStyle(
                  color: option == current
                      ? ColorManager.primary
                      : ColorManager.darkTextPrimary,
                ),
              ),
              trailing: option == current
                  ? const Icon(Icons.check_rounded, color: ColorManager.primary)
                  : null,
              onTap: () {
                context.read<SettingsCubit>().setProfileVisibility(option);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
