import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/components/app_button.dart';
import 'package:bloot/core/style/colors.dart';

class _Country {
  final String name;
  final String flag;
  final String code;

  const _Country({
    required this.name,
    required this.flag,
    required this.code,
  });
}

const List<_Country> _countries = [
  _Country(name: 'Saudi Arabia', flag: '🇸🇦', code: '+966'),
  _Country(name: 'United Arab Emirates', flag: '🇦🇪', code: '+971'),
  _Country(name: 'Kuwait', flag: '🇰🇼', code: '+965'),
  _Country(name: 'Qatar', flag: '🇶🇦', code: '+974'),
  _Country(name: 'Bahrain', flag: '🇧🇭', code: '+973'),
  _Country(name: 'Oman', flag: '🇴🇲', code: '+968'),
  _Country(name: 'Egypt', flag: '🇪🇬', code: '+20'),
  _Country(name: 'Jordan', flag: '🇯🇴', code: '+962'),
  _Country(name: 'Iraq', flag: '🇮🇶', code: '+964'),
];

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  _Country _selectedCountry = _countries.first;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _showCountryPicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ColorManager.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ColorManager.darkTextMuted.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'commonSearch'.tr(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ColorManager.darkTextPrimary,
                  ),
                ),
              ),
              const Divider(
                color: ColorManager.darkBorderSoft,
                height: 1,
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _countries.length,
                  itemBuilder: (context, index) {
                    final country = _countries[index];
                    final isSelected = country.code == _selectedCountry.code;
                    return ListTile(
                      leading: Text(country.flag, style: const TextStyle(fontSize: 24)),
                      title: Text(
                        country.name,
                        style: TextStyle(
                          color: isSelected
                              ? ColorManager.primary
                              : ColorManager.darkTextPrimary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      trailing: Text(
                        country.code,
                        style: TextStyle(
                          color: isSelected
                              ? ColorManager.primary
                              : ColorManager.darkTextSecondary,
                        ),
                      ),
                      onTap: () {
                        setState(() => _selectedCountry = country);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.darkCanvas,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top content
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
                        const SizedBox(height: 32),
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
                        const SizedBox(height: 8),
                        // Subtitle
                        Center(
                          child: Text(
                            'sign_in_to_continue_playing'.tr(),
                            style: TextStyle(
                              fontSize: 14,
                              color: ColorManager.darkTextSecondary.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Phone Number label
                        Text(
                          'phone_number'.tr(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: ColorManager.darkTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Phone input with integrated decoration
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(
                            color: ColorManager.darkTextPrimary,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            hintText: '50 123 4567',
                            hintStyle: const TextStyle(
                              color: ColorManager.darkTextMuted,
                            ),
                            prefixIcon: InkWell(
                              onTap: _showCountryPicker,
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                margin: const EdgeInsetsDirectional.only(end: 8),
                                padding: const EdgeInsetsDirectional.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: const BoxDecoration(
                                  border: BorderDirectional(
                                    end: BorderSide(
                                      color: ColorManager.darkBorderSoft,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _selectedCountry.flag,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _selectedCountry.code,
                                      style: const TextStyle(
                                        color: ColorManager.darkTextPrimary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: ColorManager.darkTextMuted,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            prefixIconConstraints: const BoxConstraints(),
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
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Send Code button with purple gradient
                        GradientButton(
                          text: 'send_code'.tr(),
                          gradient: GradientButton.purpleGradient,
                          onPressed: () => context.pushNamed(RouteNames.otp),
                        ),
                        const SizedBox(height: 24),
                        // OR CONTINUE WITH divider
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(
                                color: ColorManager.darkBorderSoft,
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
                              child: Text(
                                'or_continue_with',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: ColorManager.darkTextMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ).tr(),
                            ),
                            const Expanded(
                              child: Divider(
                                color: ColorManager.darkBorderSoft,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Social login buttons
                        Row(
                          children: [
                            // Apple button (dark)
                            Expanded(
                              child: GestureDetector(
                                onTap: () {},
                                child: Container(
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: ColorManager.darkBorderSoft,
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.apple,
                                        color: ColorManager.darkTextPrimary,
                                        size: 24,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Apple',
                                        style: TextStyle(
                                          color: ColorManager.darkTextPrimary,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Google button (outlined)
                            Expanded(
                              child: GestureDetector(
                                onTap: () {},
                                child: Container(
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: ColorManager.darkBorderSoft,
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.g_mobiledata_rounded,
                                        color: ColorManager.darkTextPrimary,
                                        size: 28,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Google',
                                        style: TextStyle(
                                          color: ColorManager.darkTextPrimary,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Bottom content
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24, top: 24),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'dont_have_account'.tr(),
                              style: const TextStyle(
                                fontSize: 14,
                                color: ColorManager.darkTextSecondary,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.pushNamed(RouteNames.completeProfile),
                              child: Text(
                                'sign_up'.tr(),
                                style: const TextStyle(
                                  color: ColorManager.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
