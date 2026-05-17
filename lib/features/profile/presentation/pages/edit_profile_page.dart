import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import 'package:bloot/core/components/app_button.dart';
import 'package:bloot/core/style/colors.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController(text: 'Ahmed Al-Saud');
  final _usernameController = TextEditingController(text: 'ahmed_baloot');
  final _bioController = TextEditingController(
    text: 'bio_text'.tr(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.darkCanvas,
      appBar: AppBar(
        title: Text('edit_profile'.tr()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Avatar
              Stack(
                alignment: AlignmentDirectional.bottomEnd,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ColorManager.primary.withValues(alpha: 0.3),
                        width: 3,
                      ),
                      image: const DecorationImage(
                        image: NetworkImage('https://i.pravatar.cc/150?img=11'),
                        fit: BoxFit.cover,
                      ),
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
              const SizedBox(height: 32),
              _buildTextField(
                label: 'display_name'.tr(),
                controller: _nameController,
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'username'.tr(),
                controller: _usernameController,
                icon: Icons.alternate_email_rounded,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'bio'.tr(),
                controller: _bioController,
                icon: Icons.info_outline_rounded,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              _buildDropdown('region'.tr(), 'riyadh_saudi_arabia'.tr()),
              const SizedBox(height: 20),
              _buildDropdown('favorite_mode'.tr(), 'Hokm'),
              const SizedBox(height: 32),
              AppButton(
                text: 'save_changes'.tr(),
                onPressed: () => context.pop(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
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
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(
            color: ColorManager.darkTextPrimary,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: ColorManager.darkTextMuted, size: 20),
            filled: true,
            fillColor: ColorManager.darkSectionGray,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: ColorManager.darkBorderSoft,
              ),
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

  Widget _buildDropdown(String label, String value) {
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
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: ColorManager.darkSectionGray,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: ColorManager.darkBorderSoft,
            ),
          ),
          child: Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  color: ColorManager.darkTextPrimary,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: ColorManager.darkTextMuted,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
