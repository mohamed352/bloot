import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/core/localization/language_manager.dart';

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.locale;

    return Scaffold(
      backgroundColor: ColorManager.darkCanvas,
      appBar: AppBar(
        title: Text('language'.tr()),
        backgroundColor: const Color(0x00000000),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: LanguageManager.supportedLocales.map((locale) {
          final isSelected = locale.languageCode == currentLocale.languageCode;
          final label = locale.languageCode == 'ar' ? 'العربية' : 'English';

          return ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? ColorManager.primary
                    : ColorManager.darkTextPrimary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            trailing: isSelected
                ? const Icon(
                    Icons.check_rounded,
                    color: ColorManager.primary,
                  )
                : null,
            onTap: () {
              context.setLocale(locale);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }
}
