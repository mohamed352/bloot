import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:bloot/core/components/app_button.dart';
import 'package:bloot/core/components/cached_avatar.dart';
import 'package:bloot/core/constants/app_radius.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/features/profile/domain/entities/user_profile.dart';
import 'package:bloot/features/profile/presentation/cubit/edit_profile_cubit.dart';
import 'package:bloot/features/profile/presentation/cubit/edit_profile_state.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _bioController;

  String? _avatarUrl;
  String? _region;
  String? _favoriteMode;
  bool _controllersInitialized = false;

  static const List<String> _regions = [
    'riyadh_saudi_arabia',
    'dubai_uae',
    'kuwait_city',
    'manama_bahrain',
    'doha_qatar',
  ];

  static const List<String> _favoriteModes = [
    'hokm_games',
    'sun_games',
    'khaleeji_baloot',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _usernameController = TextEditingController();
    _bioController = TextEditingController();

    final cubit = context.read<EditProfileCubit>();
    final profile = cubit.state.whenOrNull(loaded: (profile, _) => profile);

    if (profile != null) {
      _populateControllers(profile);
    } else {
      cubit.loadCurrentUserProfile();
    }
  }

  void _populateControllers(UserProfile profile) {
    _nameController.text = profile.displayName ?? '';
    _usernameController.text = profile.username ?? '';
    _bioController.text = profile.bio ?? '';
    _avatarUrl = profile.avatarUrl;
    _region = profile.region;
    _favoriteMode = profile.favoriteMode;
    _controllersInitialized = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditProfileCubit, EditProfileState>(
      listener: (context, state) {
        state.whenOrNull(
          loaded: (profile, _) {
            if (!_controllersInitialized) {
              _populateControllers(profile);
              setState(() {});
            }
          },
          saved: () => context.pop(),
          error: (message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: ColorManager.error,
              ),
            );
          },
        );
      },
      builder: (context, state) {
        final isSaving = state is EditProfileSaving;

        return Scaffold(
          backgroundColor: ColorManager.darkCanvas,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: ColorManager.darkTextPrimary,
              ),
              onPressed: isSaving ? null : () => context.pop(),
            ),
            title: Text(
              'edit_profile'.tr(),
              style: const TextStyle(
                color: ColorManager.darkTextPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            centerTitle: true,
          ),
          body: Stack(
            children: [
              SafeArea(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsetsDirectional.all(
                      AppSpacing.screenHorizontal,
                    ),
                    children: [
                      _buildAvatarPicker(context),
                      const SizedBox(height: AppSpacing.xxl),
                      _buildTextField(
                        label: 'display_name'.tr(),
                        controller: _nameController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'validationNameRequired'.tr();
                          }
                          if (value.trim().length < 3) {
                            return 'validationNameMinLength'.tr();
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _buildTextField(
                        label: 'username'.tr(),
                        controller: _usernameController,
                        prefixText: '@',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'validationFieldRequired'.tr();
                          }
                          if (value.trim().length < 3) {
                            return 'validationNameMinLength'.tr();
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _buildTextField(
                        label: 'bio'.tr(),
                        controller: _bioController,
                        maxLines: 3,
                        maxLength: 150,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _buildDropdown(
                        label: 'region'.tr(),
                        value: _region,
                        items: _regions,
                        onChanged: (value) {
                          setState(() => _region = value);
                          context.read<EditProfileCubit>().markChanged();
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _buildDropdown(
                        label: 'favorite_mode'.tr(),
                        value: _favoriteMode,
                        items: _favoriteModes,
                        onChanged: (value) {
                          setState(() => _favoriteMode = value);
                          context.read<EditProfileCubit>().markChanged();
                        },
                      ),
                      const SizedBox(height: AppSpacing.xxxl),
                      AppButton(
                        text: 'save_changes'.tr(),
                        isLoading: isSaving,
                        onPressed: isSaving ? null : _onSave,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
              if (isSaving)
                Container(
                  color: ColorManager.darkCanvas.withValues(alpha: 0.5),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: ColorManager.primary,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatarPicker(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: _onPickAvatar,
        child: Stack(
          alignment: AlignmentDirectional.bottomEnd,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: ColorManager.secondary.withValues(alpha: 0.6),
                  width: 3,
                ),
              ),
              child: CachedAvatar(
                imageUrl: _avatarUrl ?? '',
                size: 92,
                borderRadius: 46,
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: ColorManager.primary,
                shape: BoxShape.circle,
                border: Border.all(color: ColorManager.darkCanvas, width: 2),
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
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? prefixText,
    int? maxLines,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: ColorManager.darkTextSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          maxLines: maxLines ?? 1,
          maxLength: maxLength,
          validator: validator,
          onChanged: (_) => context.read<EditProfileCubit>().markChanged(),
          style: const TextStyle(color: ColorManager.darkTextPrimary),
          decoration: InputDecoration(
            prefixText: prefixText,
            prefixStyle: const TextStyle(color: ColorManager.darkTextMuted),
            filled: true,
            fillColor: ColorManager.darkSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            counterStyle: const TextStyle(
              color: ColorManager.darkTextMuted,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: ColorManager.darkTextSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: ColorManager.darkSurface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: ColorManager.darkSurface,
              style: const TextStyle(color: ColorManager.darkTextPrimary),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: ColorManager.darkTextSecondary,
              ),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item.tr()),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _onPickAvatar() async {
    final cubit = context.read<EditProfileCubit>();
    final url = await cubit.pickAndUploadAvatar();
    if (url != null) {
      setState(() => _avatarUrl = url);
      cubit.markChanged();
    }
  }

  void _onSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<EditProfileCubit>().saveProfile(
      displayName: _nameController.text.trim(),
      username: _usernameController.text.trim(),
      bio: _bioController.text.trim(),
      region: _region,
      favoriteMode: _favoriteMode,
      avatarUrl: _avatarUrl,
    );
  }
}
