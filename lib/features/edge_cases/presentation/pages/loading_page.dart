import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:bloot/core/components/skeleton_card.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/style/colors.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.darkCanvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: ColorManager.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.style_rounded,
                  size: 40,
                  color: ColorManager.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              Text(
                'commonLoading'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: ColorManager.darkTextPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                message ?? 'loading_message'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: ColorManager.darkTextSecondary.withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              const SkeletonCard(),
              const SizedBox(height: AppSpacing.md),
              const SkeletonCard(),
              const SizedBox(height: AppSpacing.md),
              const SkeletonCard(),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
