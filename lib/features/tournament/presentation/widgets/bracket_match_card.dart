import 'package:flutter/material.dart';

import 'package:bloot/core/components/cached_avatar.dart';
import 'package:bloot/core/constants/app_radius.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/style/colors.dart';

enum MatchStatus { live, finished, upcoming }

class BracketMatchCard extends StatelessWidget {
  const BracketMatchCard({
    super.key,
    required this.playerAName,
    required this.playerBName,
    this.playerAScore,
    this.playerBScore,
    required this.status,
    this.isUserMatch = false,
    this.playerAAvatarUrl,
    this.playerBAvatarUrl,
  });

  final String playerAName;
  final String playerBName;
  final int? playerAScore;
  final int? playerBScore;
  final MatchStatus status;
  final bool isUserMatch;
  final String? playerAAvatarUrl;
  final String? playerBAvatarUrl;

  Color get _statusColor {
    switch (status) {
      case MatchStatus.live:
        return ColorManager.live;
      case MatchStatus.finished:
        return ColorManager.darkTextMuted;
      case MatchStatus.upcoming:
        return ColorManager.primary;
    }
  }

  String get _statusLabel {
    switch (status) {
      case MatchStatus.live:
        return 'Live';
      case MatchStatus.finished:
        return 'Finished';
      case MatchStatus.upcoming:
        return 'Upcoming';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: ColorManager.darkSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isUserMatch
              ? ColorManager.secondary.withValues(alpha: 0.6)
              : ColorManager.darkBorderSoft,
          width: isUserMatch ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildPlayerSide(
                  name: playerAName,
                  score: playerAScore,
                  avatarUrl: playerAAvatarUrl,
                  alignEnd: false,
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.md,
                ),
                child: _buildCenterContent(),
              ),
              Expanded(
                child: _buildPlayerSide(
                  name: playerBName,
                  score: playerBScore,
                  avatarUrl: playerBAvatarUrl,
                  alignEnd: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Container(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 8,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _statusLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _statusColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterContent() {
    if (playerAScore != null && playerBScore != null) {
      return Text(
        '$playerAScore - $playerBScore',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: ColorManager.darkTextPrimary,
        ),
      );
    }
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: ColorManager.darkSectionGray,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: const Text(
        'VS',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: ColorManager.darkTextMuted,
        ),
      ),
    );
  }

  Widget _buildPlayerSide({
    required String name,
    required int? score,
    required String? avatarUrl,
    required bool alignEnd,
  }) {
    final avatar = CachedAvatar(
      imageUrl: avatarUrl,
      size: 32,
      borderRadius: 8,
    );
    final nameWidget = Text(
      name,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: ColorManager.darkTextPrimary,
      ),
      overflow: TextOverflow.ellipsis,
      textAlign: alignEnd ? TextAlign.end : TextAlign.start,
    );

    if (alignEnd) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(child: nameWidget),
          const SizedBox(width: AppSpacing.sm),
          avatar,
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        avatar,
        const SizedBox(width: AppSpacing.sm),
        Flexible(child: nameWidget),
      ],
    );
  }
}
