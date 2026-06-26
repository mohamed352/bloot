import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/components/app_button.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/constants/app_radius.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.darkCanvas,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.xxl),
                // Illustration area
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        ColorManager.primary.withValues(alpha: 0.2),
                        const Color(0x00000000),
                      ],
                      radius: 0.8,
                    ),
                  ),
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Central table
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ColorManager.darkSurface,
                            border: Border.all(
                              color: ColorManager.primary.withValues(
                                alpha: 0.3,
                              ),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.style_rounded,
                            size: 64,
                            color: ColorManager.primary,
                          ),
                        ),
                        // Orbiting phones
                        ...[
                          const Offset(-100, -60),
                          const Offset(100, -60),
                          const Offset(-100, 60),
                          const Offset(100, 60),
                        ].asMap().entries.map((e) {
                          return Transform.translate(
                            offset: e.value,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: ColorManager.darkSurface,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                                border: Border.all(
                                  color: e.key.isEven
                                      ? ColorManager.primary.withValues(
                                          alpha: 0.4,
                                        )
                                      : ColorManager.secondary.withValues(
                                          alpha: 0.4,
                                        ),
                                ),
                              ),
                              child: Icon(
                                e.key.isEven
                                    ? Icons.videocam_rounded
                                    : Icons.mic_rounded,
                                color: e.key.isEven
                                    ? ColorManager.primary
                                    : ColorManager.secondary,
                                size: 24,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),
                // Headline
                Text(
                  'play_baloot_go_live'.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: ColorManager.darkTextPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'premium_baloot_platform'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: ColorManager.darkTextSecondary.withValues(
                      alpha: 0.8,
                    ),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),
                // Feature highlights
                _FeatureCard(
                  icon: Icons.videocam_rounded,
                  title: 'live_voice_and_video'.tr(),
                  subtitle: 'play_with_friends_face_to_face'.tr(),
                  color: ColorManager.primary,
                ),
                const SizedBox(height: AppSpacing.md),
                _FeatureCard(
                  icon: Icons.live_tv_rounded,
                  title: 'stream_to_fans'.tr(),
                  subtitle: 'build_your_audience'.tr(),
                  color: ColorManager.secondary,
                ),
                const SizedBox(height: AppSpacing.xxl),
                // Pagination dots
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Dot(isActive: true),
                    SizedBox(width: 8),
                    _Dot(isActive: false),
                    SizedBox(width: 8),
                    _Dot(isActive: false),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
                AppButton(
                  text: 'get_started'.tr(),
                  onPressed: () => context.pushNamed(RouteNames.login),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'already_have_an_account'.tr(),
                      style: const TextStyle(
                        color: ColorManager.darkTextMuted,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.pushNamed(RouteNames.login),
                      child: Text(
                        'sign_in'.tr(),
                        style: const TextStyle(
                          color: ColorManager.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: ColorManager.darkSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: ColorManager.darkTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: ColorManager.darkTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? ColorManager.primary
            : ColorManager.darkTextMuted.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
