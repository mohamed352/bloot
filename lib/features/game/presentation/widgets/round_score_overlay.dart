import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:bloot/core/components/app_button.dart';
import 'package:bloot/core/constants/app_radius.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/extension/context_values.dart';
import 'package:bloot/generated/locale_keys.g.dart';

/// Round-end score summary overlay.
///
/// Displays team scores for the completed round and a button to
/// proceed to the next round.
class RoundScoreOverlay extends StatelessWidget {
  const RoundScoreOverlay({
    super.key,
    required this.teamAScore,
    required this.teamBScore,
    required this.roundPoints,
    required this.onNextRound,
  });

  final int teamAScore;
  final int teamBScore;
  final Map<String, int> roundPoints;
  final VoidCallback onNextRound;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      color: colors.background.withValues(alpha: 0.9),
      child: Center(
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: Container(
            padding: const EdgeInsetsDirectional.all(AppSpacing.xxl),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  LocaleKeys.round_end.tr(),
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _TeamScore(
                      label: LocaleKeys.us.tr(),
                      score: teamAScore,
                      color: colors.primary,
                    ),
                    Container(width: 1, height: 60, color: colors.divider),
                    _TeamScore(
                      label: LocaleKeys.them.tr(),
                      score: teamBScore,
                      color: colors.secondary,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
                if (roundPoints.isNotEmpty)
                  Column(
                    children: roundPoints.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsetsDirectional.only(
                          bottom: AppSpacing.sm,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: TextStyle(
                                fontSize: 13,
                                color: colors.textSecondary,
                              ),
                            ),
                            Text(
                              '${entry.value}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: colors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: AppSpacing.xxl),
                AppButton(text: 'next_round'.tr(), onPressed: onNextRound),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TeamScore extends StatelessWidget {
  const _TeamScore({
    required this.label,
    required this.score,
    required this.color,
  });

  final String label;
  final int score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '$score',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }
}
