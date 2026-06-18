import 'package:flutter/material.dart';

import 'package:bloot/core/components/app_button.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/di/injection.dart';
import 'package:bloot/core/extension/context_values.dart';
import 'package:bloot/core/services/remote_config_service.dart';
import 'package:url_launcher/url_launcher.dart';

/// Full-screen force update page shown when the app version is too old.
///
/// Blocks all navigation until the user updates the app.
class ForceUpdatePage extends StatelessWidget {
  const ForceUpdatePage({super.key});

  Future<void> _openStore() async {
    final url = getIt<RemoteConfigService>().forceUpdateStoreUrl;
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Icon(
                Icons.system_update_rounded,
                size: 80,
                color: colors.primary,
              ),
              const SizedBox(height: AppSpacing.xxxl),
              Text(
                'Update Required',
                textAlign: TextAlign.center,
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'A new version of Bloot is available. Please update to continue playing.',
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const Spacer(),
              AppButton(
                text: 'Update Now',
                onPressed: _openStore,
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}
