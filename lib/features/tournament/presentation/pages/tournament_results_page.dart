import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/style/colors.dart';

/// Displays tournament results with champion celebration and prize info.
class TournamentResultsPage extends StatelessWidget {
  const TournamentResultsPage({
    super.key,
    required this.tournamentId,
    required this.tournamentName,
    required this.championName,
    this.prizeAmount,
    this.prizeCurrency = 'SAR',
    this.runnerUpName,
    this.playerCount = 0,
  });

  final String tournamentId;
  final String tournamentName;
  final String championName;
  final int? prizeAmount;
  final String prizeCurrency;
  final String? runnerUpName;
  final int playerCount;

  static const Color _gold = Color(0xFFFBBF24);
  static const Color _silver = Color(0xFF9CA3AF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.darkCanvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'tournament_results'.tr(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: ColorManager.darkTextPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xl),
            // Trophy icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: _gold.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                size: 64,
                color: _gold,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              tournamentName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: ColorManager.darkTextPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'tournament_complete'.tr(),
              style: const TextStyle(
                fontSize: 14,
                color: ColorManager.darkTextSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            // Champion card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_gold, Color(0xFFFFD54F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    'champion'.tr().toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.black54,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    championName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                  if (prizeAmount != null && prizeAmount! > 0) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      '${NumberFormat.decimalPattern().format(prizeAmount)} $prizeCurrency',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (runnerUpName != null && runnerUpName!.isNotEmpty)
              _ResultRow(
                rank: 2,
                label: 'runner_up'.tr(),
                name: runnerUpName!,
                iconColor: _silver,
              ),
            if (playerCount > 0) ...[
              const SizedBox(height: AppSpacing.lg),
              _ResultRow(
                rank: 0,
                label: 'participants'.tr(),
                name: '$playerCount',
                iconColor: ColorManager.darkTextMuted,
              ),
            ],
            const SizedBox(height: AppSpacing.xxl),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  final prizeText = prizeAmount != null && prizeAmount! > 0
                      ? ' \u2022 $prizeAmount $prizeCurrency'
                      : '';
                  Share.share(
                    '\u{1F3C6} $championName won $tournamentName!$prizeText\n'
                    'https://bloot.app/tournament/$tournamentId',
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: ColorManager.darkTextPrimary,
                  side: const BorderSide(color: ColorManager.darkBorderSoft),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('share_result'.tr()),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.goNamed(RouteNames.home),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorManager.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('back_to_home'.tr()),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.rank,
    required this.label,
    required this.name,
    required this.iconColor,
  });

  final int rank;
  final String label;
  final String name;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: ColorManager.darkSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (rank > 0)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '#$rank',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: iconColor,
                  ),
                ),
              ),
            )
          else
            Icon(Icons.people_outline_rounded, size: 20, color: iconColor),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: ColorManager.darkTextMuted,
                  ),
                ),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ColorManager.darkTextPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
