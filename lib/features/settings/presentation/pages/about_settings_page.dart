import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/style/colors.dart';

class AboutSettingsPage extends StatelessWidget {
  const AboutSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.darkCanvas,
      appBar: AppBar(
        title: Text('about'.tr()),
        backgroundColor: const Color(0x00000000),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const Center(
            child: Column(
              children: [
                SizedBox(height: AppSpacing.xxl),
                Text(
                  'Bloot',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: ColorManager.primary,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'v1.0.0',
                  style: TextStyle(
                    fontSize: 14,
                    color: ColorManager.darkTextMuted,
                  ),
                ),
                SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'terms_of_service'.tr(),
              style: const TextStyle(color: ColorManager.darkTextPrimary),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: ColorManager.darkTextMuted,
            ),
            onTap: () => context.pushNamed(RouteNames.terms),
          ),
          const Divider(color: ColorManager.darkBorderSoft),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'privacy_policy'.tr(),
              style: const TextStyle(color: ColorManager.darkTextPrimary),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: ColorManager.darkTextMuted,
            ),
            onTap: () => context.pushNamed(RouteNames.privacy),
          ),
          const Divider(color: ColorManager.darkBorderSoft),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Contact Support',
              style: TextStyle(color: ColorManager.darkTextPrimary),
            ),
            subtitle: Text(
              'support@bloot.app',
              style: TextStyle(color: ColorManager.darkTextSecondary),
            ),
            trailing: Icon(
              Icons.mail_outline_rounded,
              color: ColorManager.darkTextMuted,
            ),
          ),
          const Divider(color: ColorManager.darkBorderSoft),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Follow us',
              style: TextStyle(color: ColorManager.darkTextPrimary),
            ),
            subtitle: Text(
              '@blootapp',
              style: TextStyle(color: ColorManager.darkTextSecondary),
            ),
            trailing: Icon(
              Icons.open_in_new_rounded,
              color: ColorManager.darkTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}
