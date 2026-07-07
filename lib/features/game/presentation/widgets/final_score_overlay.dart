import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:bloot/core/components/app_button.dart';
import 'package:bloot/core/constants/app_radius.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/extension/context_values.dart';
import 'package:bloot/generated/locale_keys.g.dart';

/// Game-end celebration overlay with final scores and rematch options.
class FinalScoreOverlay extends StatelessWidget {
  const FinalScoreOverlay({
    super.key,
    required this.teamAScore,
    required this.teamBScore,
    required this.isWinner,
    required this.onRematch,
    required this.onHome,
  });

  final int teamAScore;
  final int teamBScore;
  final bool isWinner;
  final VoidCallback onRematch;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      color: colors.background.withValues(alpha: 0.92),
      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.xxl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isWinner
                    ? Icons.emoji_events_rounded
                    : Icons.sentiment_dissatisfied_rounded,
                size: 64,
                color: isWinner ? colors.secondary : colors.textMuted,
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                isWinner
                    ? LocaleKeys.victory.tr()
                    : LocaleKeys.defeat.tr(),
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isWinner ? colors.secondary : colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                isWinner
                    ? LocaleKeys.congratulations_on_win.tr()
                    : LocaleKeys.better_luck_next_time.tr(),
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              Container(
                padding: const EdgeInsetsDirectional.all(AppSpacing.xxl),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: colors.border),
                ),
                child: Row(
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
              ),
              const SizedBox(height: AppSpacing.xxxl),
              AppButton(text: LocaleKeys.rematch.tr(), onPressed: onRematch),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                text: LocaleKeys.go_home.tr(),
                isOutlined: true,
                onPressed: onHome,
              ),
            ],
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
            fontSize: 40,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }
}
