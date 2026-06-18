import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/style/colors.dart';

/// Full-screen overlay shown when the player loses network connection.
class DisconnectOverlay extends StatelessWidget {
  const DisconnectOverlay({
    super.key,
    required this.secondsRemaining,
    required this.onExit,
  });

  final int secondsRemaining;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorManager.darkCanvas.withValues(alpha: 0.92),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 64,
              color: ColorManager.error,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'connection_lost'.tr(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: ColorManager.darkTextPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'reconnecting_in'.tr(namedArgs: {'seconds': '$secondsRemaining'}),
              style: const TextStyle(
                fontSize: 14,
                color: ColorManager.darkTextSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: ColorManager.primary,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            TextButton(
              onPressed: onExit,
              child: Text(
                'exit_game'.tr(),
                style: const TextStyle(color: ColorManager.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
