import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/components/app_button.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/core/constants/app_spacing.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

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
                  color: ColorManager.error.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 56,
                  color: ColorManager.error,
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              Text(
                'something_went_wrong'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: ColorManager.darkTextPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'unexpected_error_message'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: ColorManager.darkTextSecondary.withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              AppButton(
                text: 'try_again'.tr(),
                onPressed: () => context.goNamed(RouteNames.home),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                text: 'go_home'.tr(),
                isOutlined: true,
                onPressed: () => context.goNamed(RouteNames.home),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
