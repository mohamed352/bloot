import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/components/app_button.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:bloot/features/auth/presentation/cubit/auth_state.dart';
import 'package:bloot/core/constants/app_spacing.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _displayNameController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _usernameAvailable = true;

  @override
  void dispose() {
    _displayNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        state.whenOrNull(
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
          appBar: AppBar(
            backgroundColor: const Color(0x00000000),
            elevation: 0,
            title: Text('complete_profile'.tr()),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  // Avatar picker
                  Stack(
                    alignment: AlignmentDirectional.bottomEnd,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ColorManager.darkSurface,
                          border: Border.all(
                            color: ColorManager.primary.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          size: 48,
                          color: ColorManager.darkTextMuted,
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: ColorManager.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 16,
                          color: ColorManager.darkTextPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  // Display name
                  _buildTextField(
                    label: 'display_name'.tr(),
                    hint: 'your_name'.tr(),
                    controller: _displayNameController,
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 20),
                  // Username
                  _buildTextField(
                    label: 'username'.tr(),
                    hint: '@username',
                    controller: _usernameController,
                    icon: Icons.alternate_email_rounded,
                    suffix: _usernameAvailable
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: ColorManager.success,
                            size: 20,
                          )
                        : const Icon(
                            Icons.error_rounded,
                            color: ColorManager.error,
                            size: 20,
                          ),
                    onChanged: (value) {
                      setState(() {
                        _usernameAvailable =
                            value.length < 4 || value != 'taken';
                      });
                    },
                  ),
                  if (!_usernameAvailable)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'username_taken'.tr(),
                        style: const TextStyle(
                          color: ColorManager.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xxxl),
                  GradientButton(
                    text: 'start_playing'.tr(),
                    gradient: GradientButton.goldGradient,
                    isLoading: isLoading,
                    onPressed: isLoading
                        ? null
                        : () {
                            context.read<AuthCubit>().completeProfile(
                              name: _displayNameController.text.trim(),
                              username: _usernameController.text.trim(),
                            );
                          },
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
          style: const TextStyle(
            color: ColorManager.darkTextPrimary,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: ColorManager.darkTextMuted),
            prefixIcon: Icon(icon, color: ColorManager.darkTextMuted, size: 20),
            suffixIcon: suffix,
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
