import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:bloot/core/components/app_button.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/di/injection.dart';
import 'package:bloot/core/extension/context_values.dart';
import 'package:bloot/core/services/remote_config_service.dart';
import 'package:bloot/generated/locale_keys.g.dart';

/// Full-screen maintenance page shown during server downtime.
class MaintenancePage extends StatelessWidget {
  const MaintenancePage({super.key});

  Future<void> _retry(BuildContext context) async {
    final remoteConfig = getIt<RemoteConfigService>();
    await remoteConfig.fetchAndActivate();
    if (!remoteConfig.isMaintenanceMode && context.mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final message = getIt<RemoteConfigService>().maintenanceMessage;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Icon(
                Icons.build_circle_rounded,
                size: 80,
                color: colors.secondary,
              ),
              const SizedBox(height: AppSpacing.xxxl),
              Text(
                'Under Maintenance',
                textAlign: TextAlign.center,
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                message.isNotEmpty
                    ? message
                    : 'We are improving Bloot for you. Please check back soon.',
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const Spacer(),
              AppButton(
                text: LocaleKeys.try_again.tr(),
                isOutlined: true,
                onPressed: () => _retry(context),
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}
