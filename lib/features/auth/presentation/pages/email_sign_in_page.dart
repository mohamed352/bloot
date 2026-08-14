import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/components/app_button.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/features/auth/domain/utils/auth_validators.dart';
import 'package:bloot/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:bloot/features/auth/presentation/cubit/auth_state.dart';
import 'package:bloot/core/constants/app_spacing.dart';

class EmailSignInPage extends StatefulWidget {
  const EmailSignInPage({super.key});

  @override
  State<EmailSignInPage> createState() => _EmailSignInPageState();
}

class _EmailSignInPageState extends State<EmailSignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      AuthValidators.validateEmail(_emailController.text) == null &&
      AuthValidators.validatePassword(_passwordController.text) == null;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        state.whenOrNull(
          profileRequired: (_) =>
              context.pushNamed(RouteNames.completeProfile),
          authenticated: (_) => context.goNamed(RouteNames.home),
          error: (message) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message.tr())));
          },
        );
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return Scaffold(
          backgroundColor: ColorManager.darkCanvas,
          appBar: AppBar(
            backgroundColor: const Color(0x00000000),
            elevation: 0,
            title: Text('sign_in_with_email'.tr()),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.xxxl),
                  _buildTextField(
                    label: 'email'.tr(),
                    hint: 'enter_your_email'.tr(),
                    controller: _emailController,
                    icon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: 'password'.tr(),
                    hint: 'enter_your_password'.tr(),
                    controller: _passwordController,
                    icon: Icons.lock_outline_rounded,
                    obscureText: _obscurePassword,
                    suffix: GestureDetector(
                      onTap: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                      child: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: ColorManager.darkTextMuted,
                        size: 20,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  GradientButton(
                    text: 'sign_in'.tr(),
                    gradient: GradientButton.goldGradient,
                    isLoading: isLoading,
                    onPressed: _canSubmit && !isLoading
                        ? () {
                            context.read<AuthCubit>().signInWithEmail(
                              email: _emailController.text.trim(),
                              password: _passwordController.text,
                            );
                          }
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    Widget? suffix,
    bool obscureText = false,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: ColorManager.darkTextSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          onChanged: onChanged,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(
            color: ColorManager.darkTextPrimary,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: ColorManager.darkTextMuted),
            prefixIcon: Icon(icon, color: ColorManager.darkTextMuted, size: 20),
            suffixIcon: suffix != null
                ? Padding(
                    padding: const EdgeInsetsDirectional.only(end: 12),
                    child: suffix,
                  )
                : null,
            filled: true,
            fillColor: ColorManager.darkSectionGray,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: ColorManager.darkBorderSoft),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: ColorManager.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
