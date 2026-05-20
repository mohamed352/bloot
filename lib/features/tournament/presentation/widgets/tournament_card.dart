import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:bloot/core/constants/app_radius.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/extension/context_values.dart';
import 'package:bloot/core/style/app_colors.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/features/tournament/domain/entities/tournament.dart';
import 'package:bloot/generated/locale_keys.g.dart';

/// Card widget displaying tournament summary information.
///
/// Used in the tournament list screen.
class TournamentCard extends StatelessWidget {
  const TournamentCard({
    super.key,
    required this.tournament,
    required this.onTap,
    this.onJoin,
  });

  final Tournament tournament;
  final VoidCallback onTap;
  final VoidCallback? onJoin;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: tournament.isPremium
                ? colors.secondary.withValues(alpha: 0.4)
                : colors.border,
            width: tournament.isPremium ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    tournament.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: ColorManager.darkTextPrimary,
                    ),
                  ),
                ),
                if (tournament.isPremium)
                  Container(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colors.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 12,
                          color: colors.secondary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          LocaleKeys.prize_pool.tr(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: colors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Icon(
                  Icons.emoji_events_rounded,
                  size: 16,
                  color: colors.secondary,
                ),
                const SizedBox(width: 6),
                Text(
                  tournament.prize,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(Icons.people_rounded, size: 14, color: colors.textMuted),
                const SizedBox(width: 4),
                Text(
                  tournament.participants,
                  style: TextStyle(fontSize: 12, color: colors.textSecondary),
                ),
                const SizedBox(width: AppSpacing.lg),
                Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: colors.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  tournament.date,
                  style: TextStyle(fontSize: 12, color: colors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor(colors).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      tournament.status,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _statusColor(colors),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                if (onJoin != null)
                  GestureDetector(
                    onTap: onJoin,
                    child: Container(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: tournament.isJoined
                            ? colors.surfaceVariant
                            : colors.primary,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        tournament.isJoined
                            ? LocaleKeys.joined.tr()
                            : LocaleKeys.join.tr(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: tournament.isJoined
                              ? colors.textSecondary
                              : colors.textPrimary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(AppColors colors) {
    final statusLower = tournament.status.toLowerCase();
    if (statusLower.contains('active') || statusLower.contains('live')) {
      return colors.success;
    }
    if (statusLower.contains('upcoming')) {
      return colors.info;
    }
    if (statusLower.contains('completed')) {
      return colors.textMuted;
    }
    return colors.primary;
  }
}
