import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:bloot/core/constants/app_radius.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/extension/context_values.dart';
import 'package:bloot/generated/locale_keys.g.dart';

/// Bidding phase overlay shown during the Baloot game.
///
/// Allows the current bidder to select Sun, Hokm, or Pass,
/// and choose a trump suit for Hokm.
class BiddingOverlay extends StatelessWidget {
  const BiddingOverlay({
    super.key,
    required this.currentBidder,
    required this.onBid,
    this.timeLeft = 30,
  });

  final String currentBidder;
  final ValueChanged<String> onBid;
  final int timeLeft;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      color: colors.background.withValues(alpha: 0.85),
      child: Center(
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$currentBidder ${'bidding'.tr()}',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${'time_remaining'.tr()}: ${timeLeft}s',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              Row(
                children: [
                  Expanded(
                    child: _BidButton(
                      label: 'Sun',
                      icon: Icons.wb_sunny_rounded,
                      color: colors.secondary,
                      onTap: () => onBid('sun'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: _BidButton(
                      label: 'Hokm',
                      icon: Icons.shield_rounded,
                      color: colors.primary,
                      onTap: () => onBid('hokm'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: _BidButton(
                      label: LocaleKeys.commonCancel.tr(),
                      icon: Icons.close_rounded,
                      color: colors.textMuted,
                      onTap: () => onBid('pass'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxxl),
              if (timeLeft <= 5)
                Text(
                  'hurry_up'.tr(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.error,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BidButton extends StatelessWidget {
  const _BidButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
