import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:bloot/core/components/app_button.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/extension/context_values.dart';
import 'package:bloot/generated/locale_keys.g.dart';

/// Full-screen maintenance page shown during server downtime.
class MaintenancePage extends StatelessWidget {
  const MaintenancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

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
                'We are improving Bloot for you. Please check back soon.',
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Estimated return: Soon',
                textAlign: TextAlign.center,
                style: context.textTheme.bodySmall?.copyWith(
                  color: colors.textMuted,
                ),
              ),
              const Spacer(),
              AppButton(
                text: LocaleKeys.try_again.tr(),
                isOutlined: true,
                onPressed: () {
                  // TODO: Retry health check
                },
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}
