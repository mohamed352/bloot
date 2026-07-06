import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/components/app_button.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/features/auth/domain/utils/auth_validators.dart';
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
  bool _termsAccepted = false;
  bool _isCheckingUsername = false;
  bool _isUploadingAvatar = false;
  String? _avatarUrl;
  File? _avatarFile;
  Timer? _usernameDebounce;

  @override
  void dispose() {
    _displayNameController.dispose();
    _usernameController.dispose();
    _usernameDebounce?.cancel();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    setState(() {
      _avatarFile = File(picked.path);
      _isUploadingAvatar = true;
    });

    final url = await context.read<AuthCubit>().uploadAvatar(File(picked.path));

    if (mounted) {
      setState(() {
        _isUploadingAvatar = false;
        if (url != null) _avatarUrl = url;
        _avatarFile = null;
      });
    }
  }

  void _onUsernameChanged(String value) {
    _usernameDebounce?.cancel();
    if (value.trim().length < 3) {
      setState(() {
        _usernameAvailable = true;
        _isCheckingUsername = false;
      });
      return;
    }
    setState(() => _isCheckingUsername = true);
    _usernameDebounce = Timer(const Duration(milliseconds: 500), () async {
      final available = await context
          .read<AuthCubit>()
          .checkUsernameAvailability(value.trim());
      if (mounted) {
        setState(() {
          _usernameAvailable = available;
          _isCheckingUsername = false;
        });
      }
    });
  }

  bool get _canSubmit {
    final name = _displayNameController.text.trim();
    final username = _usernameController.text.trim();
    return AuthValidators.validateDisplayName(name) == null &&
        AuthValidators.validateUsername(username) == null &&
        _usernameAvailable &&
        _termsAccepted &&
        !_isCheckingUsername;
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
            title: Text('complete_profile'.tr()),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  // Avatar picker
                  GestureDetector(
                    onTap: _isUploadingAvatar ? null : _pickAvatar,
                    child: Stack(
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
                            image: _avatarFile != null
                                ? DecorationImage(
                                    image: FileImage(_avatarFile!),
                                    fit: BoxFit.cover,
                                  )
                                : _avatarUrl != null
                                    ? DecorationImage(
                                        image: NetworkImage(_avatarUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                          ),
                          child: _avatarFile == null && _avatarUrl == null
                              ? const Icon(
                                  Icons.person_rounded,
                                  size: 48,
                                  color: ColorManager.darkTextMuted,
                                )
                              : null,
                        ),
                        if (_isUploadingAvatar)
                          const SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: ColorManager.primary,
                            ),
                          )
                        else
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
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  // Display name
                  _buildTextField(
                    label: 'display_name'.tr(),
                    hint: 'your_name'.tr(),
                    controller: _displayNameController,
                    icon: Icons.person_outline_rounded,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 20),
                  // Username
                  _buildTextField(
                    label: 'username'.tr(),
                    hint: '@username',
                    controller: _usernameController,
                    icon: Icons.alternate_email_rounded,
                    suffix: _isCheckingUsername
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: ColorManager.primary,
                            ),
                          )
                        : _usernameAvailable &&
                              _usernameController.text.trim().length >= 3
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: ColorManager.success,
                            size: 20,
                          )
                        : !_usernameAvailable &&
                              _usernameController.text.trim().length >= 3
                        ? const Icon(
                            Icons.error_rounded,
                            color: ColorManager.error,
                            size: 20,
                          )
                        : null,
                    onChanged: _onUsernameChanged,
                  ),
                  if (!_usernameAvailable &&
                      _usernameController.text.trim().length >= 3)
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
                  const SizedBox(height: AppSpacing.xl),
                  // Terms of Service
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _termsAccepted,
                        onChanged: (value) {
                          setState(() => _termsAccepted = value ?? false);
                        },
                        activeColor: ColorManager.primary,
                        side: const BorderSide(
                          color: ColorManager.darkBorderSoft,
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => context.pushNamed(RouteNames.terms),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.only(top: 12),
                            child: Text.rich(
                              TextSpan(
                                text: 'by_creating_account'.tr(),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: ColorManager.darkTextSecondary,
                                  height: 1.4,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'terms_of_service'.tr(),
                                    style: const TextStyle(
                                      color: ColorManager.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  GradientButton(
                    text: 'start_playing'.tr(),
                    gradient: GradientButton.goldGradient,
                    isLoading: isLoading,
                    onPressed: _canSubmit && !isLoading
                        ? () {
                            context.read<AuthCubit>().completeProfile(
                              name: _displayNameController.text.trim(),
                              username: _usernameController.text.trim(),
                              avatarUrl: _avatarUrl,
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
