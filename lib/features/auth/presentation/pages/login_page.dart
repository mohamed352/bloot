import 'dart:io';

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:bloot/features/auth/presentation/cubit/auth_state.dart';
import 'package:bloot/core/constants/app_spacing.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        state.whenOrNull(
          profileRequired: () => context.pushNamed(RouteNames.completeProfile),
          authenticated: (_) => context.goNamed(RouteNames.home),
          error: (message) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          },
        );
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return Scaffold(
          backgroundColor: ColorManager.darkCanvas,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: 24,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 40),
                            // Bloot title
                            const Center(
                              child: Text(
                                'Bloot',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  color: ColorManager.primary,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxxl),
                            // Welcome Back headline
                            Center(
                              child: Text(
                                'welcome_back'.tr(),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: ColorManager.darkTextPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            // Subtitle
                            Center(
                              child: Text(
                                'sign_in_to_continue_playing'.tr(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: ColorManager.darkTextSecondary
                                      .withValues(alpha: 0.8),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxxl),
                            // Apple button — iOS only
                            if (Platform.isIOS) ...[
                              _SocialButton(
                                icon: Icons.apple,
                                label: 'Apple',
                                isApple: true,
                                isLoading: isLoading,
                                onTap: () =>
                                    context.read<AuthCubit>().signInWithApple(),
                              ),
                              const SizedBox(height: AppSpacing.md),
                            ],
                            // Google button
                            _SocialButton(
                              icon: Icons.g_mobiledata_rounded,
                              label: 'Google',
                              isLoading: isLoading,
                              onTap: () =>
                                  context.read<AuthCubit>().signInWithGoogle(),
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                            // Terms hint
                            Center(
                              child: Text(
                                'by_creating_account'.tr(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: ColorManager.darkTextMuted,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.pushNamed(RouteNames.terms),
                              child: Center(
                                child: Text(
                                  'terms_of_service'.tr(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: ColorManager.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.isLoading,
    required this.onTap,
    this.isApple = false,
  });

  final IconData icon;
  final String label;
  final bool isLoading;
  final bool isApple;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: isApple ? ColorManager.darkCanvas : const Color(0x00000000),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: ColorManager.darkBorderSoft,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: ColorManager.primary,
                ),
              )
            else
              Icon(
                icon,
                color: ColorManager.darkTextPrimary,
                size: isApple ? 24 : 28,
              ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: ColorManager.darkTextPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
