import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bloot/core/components/app_button.dart';
import 'package:bloot/core/constants/app_radius.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/style/colors.dart';

class JoinTournamentBottomSheet extends StatelessWidget {
  const JoinTournamentBottomSheet({
    super.key,
    required this.tournamentName,
    required this.entryFee,
    required this.onConfirm,
    required this.onCancel,
  });

  final String tournamentName;
  final String entryFee;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ColorManager.darkSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsetsDirectional.only(
        start: AppSpacing.lg,
        end: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: AppSpacing.xxl,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ColorManager.darkTextMuted.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Tournament name
            Text(
              tournamentName,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: ColorManager.darkTextPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Entry fee row
            _buildInfoRow(
              icon: Icons.monetization_on_rounded,
              label: 'entry_fee'.tr(),
              value: entryFee,
              valueColor: ColorManager.secondary,
            ),
            const SizedBox(height: AppSpacing.md),
            // Balance row
            _buildInfoRow(
              icon: Icons.account_balance_wallet_rounded,
              label: 'your_balance'.tr(),
              value: '2,450 coins',
              valueColor: ColorManager.darkTextPrimary,
            ),
            const SizedBox(height: AppSpacing.lg),
            // Checkbox row
            Row(
              children: [
                const Icon(
                  Icons.check_box_rounded,
                  color: ColorManager.secondary,
                  size: 22,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'agree_tournament_rules'.tr(),
                    style: const TextStyle(
                      fontSize: 13,
                      color: ColorManager.darkTextSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            // Confirm button
            GradientButton(
              text: 'confirm_join'.tr(),
              onPressed: onConfirm,
              gradient: GradientButton.goldGradient,
              borderRadius: AppRadius.full,
            ),
            const SizedBox(height: AppSpacing.md),
            // Cancel button
            SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: ColorManager.darkBorderSoft),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
                child: Text(
                  'cancel'.tr(),
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: ColorManager.darkTextSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: ColorManager.darkTextMuted.withValues(alpha: 0.7),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: ColorManager.darkTextSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
