import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/components/app_button.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/core/constants/app_spacing.dart';

class OfflinePage extends StatelessWidget {
  const OfflinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.darkCanvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: ColorManager.warning.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  size: 56,
                  color: ColorManager.warning,
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              Text(
                'no_internet_connection'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: ColorManager.darkTextPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'offline_message'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: ColorManager.darkTextSecondary.withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              AppButton(
                text: 'retry'.tr(),
                icon: Icons.refresh_rounded,
                onPressed: () => context.goNamed(RouteNames.home),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                text: 'go_to_settings'.tr(),
                isOutlined: true,
                onPressed: () => context.pushNamed(RouteNames.settings),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
