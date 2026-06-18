import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:bloot/core/components/app_button.dart';
import 'package:bloot/core/components/cached_avatar.dart';
import 'package:bloot/core/constants/app_radius.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/features/tournament/domain/entities/tournament.dart';
import 'package:bloot/features/tournament/presentation/cubit/tournament_cubit.dart';
import 'package:bloot/features/tournament/presentation/cubit/tournament_state.dart';
import 'package:bloot/features/tournament/presentation/widgets/join_tournament_bottom_sheet.dart';

class TournamentDetailPage extends StatelessWidget {
  const TournamentDetailPage({super.key, required this.id});
  final String id;

  void _showJoinBottomSheet(BuildContext context, Tournament tournament) {
    final cubit = context.read<TournamentCubit>();
    final balance = cubit.currentUserProfile?.coins;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return JoinTournamentBottomSheet(
          tournamentName: tournament.name.tr(),
          entryFee: tournament.entryFee.isNotEmpty
              ? tournament.entryFee
              : '0',
          balance: balance != null ? '$balance coins' : null,
          onConfirm: () {
            Navigator.of(sheetContext).pop();
            context.read<TournamentCubit>().joinTournament(id);
          },
          onCancel: () => Navigator.of(sheetContext).pop(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TournamentCubit, TournamentState>(
      listener: (context, state) {
        state.whenOrNull(
          joined: (tournamentId) {
            context.pushNamed(
              'tournamentBracket',
              pathParameters: {'id': tournamentId},
            );
          },
          joinError: (message) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          },
        );
      },
      builder: (context, state) {
        return state.when(
          initial: () => const Scaffold(
            backgroundColor: ColorManager.darkCanvas,
            body: Center(
              child: CircularProgressIndicator(color: ColorManager.primary),
            ),
          ),
          loading: () => const Scaffold(
            backgroundColor: ColorManager.darkCanvas,
            body: Center(
              child: CircularProgressIndicator(color: ColorManager.primary),
            ),
          ),
          loaded: (tournaments, index) => const Scaffold(
            backgroundColor: ColorManager.darkCanvas,
            body: Center(
              child: CircularProgressIndicator(color: ColorManager.primary),
            ),
          ),
          error: (message) => Scaffold(
            backgroundColor: ColorManager.darkCanvas,
            body: Center(
              child: Text(
                message,
                style: const TextStyle(color: ColorManager.darkTextSecondary),
              ),
            ),
          ),
          detailLoading: () => const Scaffold(
            backgroundColor: ColorManager.darkCanvas,
            body: Center(
              child: CircularProgressIndicator(color: ColorManager.primary),
            ),
          ),
          detailLoaded: (tournament) => _buildDetailContent(context, tournament),
          detailError: (message) => Scaffold(
            backgroundColor: ColorManager.darkCanvas,
            body: Center(
              child: Text(
                message,
                style: const TextStyle(color: ColorManager.darkTextSecondary),
              ),
            ),
          ),
          joining: () => _buildDetailContent(
            context,
            state.maybeWhen(
              detailLoaded: (t) => t,
              orElse: () => null,
            ),
            isJoining: true,
          ),
          joined: (_) => _buildDetailContent(
            context,
            state.maybeWhen(
              detailLoaded: (t) => t,
              orElse: () => null,
            ),
          ),
          joinError: (_) => _buildDetailContent(
            context,
            state.maybeWhen(
              detailLoaded: (t) => t,
              orElse: () => null,
            ),
          ),
          matchReady: (_, roomId, matchId) => _buildDetailContent(
            context,
            state.maybeWhen(
              detailLoaded: (t) => t,
              orElse: () => null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailContent(
    BuildContext context,
    Tournament? tournament, {
    bool isJoining = false,
  }) {
    if (tournament == null) {
      return const Scaffold(
        backgroundColor: ColorManager.darkCanvas,
        body: Center(
          child: CircularProgressIndicator(color: ColorManager.primary),
        ),
      );
    }

    final statusColor = _statusColor(tournament.status);

    return Scaffold(
      backgroundColor: ColorManager.darkCanvas,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ColorManager.secondary.withValues(alpha: 0.3),
                      ColorManager.darkSurface,
                    ],
                    begin: AlignmentDirectional.topStart,
                    end: AlignmentDirectional.bottomEnd,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.emoji_events_rounded,
                        size: 100,
                        color: ColorManager.secondary.withValues(
                          alpha: 0.15,
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      bottom: 16,
                      start: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsetsDirectional.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: statusColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              tournament.status.toLowerCase().tr(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: statusColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            tournament.name.tr(),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: ColorManager.darkTextPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Prize pool
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: ColorManager.darkSurface,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(
                      color: ColorManager.secondary.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'prize_pool'.tr(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: ColorManager.darkTextSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.monetization_on_rounded,
                            color: ColorManager.secondary,
                            size: 32,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            tournament.prize.tr(),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: ColorManager.secondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // Details
                _buildSection(
                  title: 'details'.tr(),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        Icons.calendar_today_rounded,
                        'date'.tr(),
                        tournament.date.tr(),
                      ),
                      _buildDetailRow(
                        Icons.videogame_asset_rounded,
                        'game_type'.tr(),
                        'khaleeji_baloot'.tr(),
                      ),
                      _buildDetailRow(
                        Icons.format_list_numbered_rounded,
                        'format'.tr(),
                        'single_elimination'.tr(),
                      ),
                      _buildDetailRow(
                        Icons.repeat_rounded,
                        'rounds'.tr(),
                        '6_rounds'.tr(),
                      ),
                      _buildDetailRow(
                        Icons.login_rounded,
                        'entry'.tr(),
                        '500_coins'.tr(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // Rules
                _buildSection(
                  title: 'rules'.tr(),
                  child: Text(
                    'standard_rules'.tr(),
                    style: const TextStyle(
                      fontSize: 13,
                      color: ColorManager.darkTextSecondary,
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // Participants
                _buildSection(
                  title: 'participants_${tournament.participants.replaceAll('/', '_')}'
                          .tr(),
                  child: SizedBox(
                    height: 48,
                    child: Builder(
                      builder: (context) {
                        final profiles = context
                            .read<TournamentCubit>()
                            .participantProfiles;
                        final avatarUrls = profiles
                            .map((p) => p.avatarUrl)
                            .whereType<String>()
                            .toList();
                        return ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: avatarUrls.isNotEmpty
                              ? avatarUrls.length
                              : 1,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            if (avatarUrls.isEmpty) {
                              return const CachedAvatar(
                                imageUrl: null,
                                size: 40,
                                borderRadius: 20,
                              );
                            }
                            return CachedAvatar(
                              imageUrl: avatarUrls[index],
                              size: 40,
                              borderRadius: 20,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // Bracket preview
                _buildSection(
                  title: 'bracket'.tr(),
                  child: Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: ColorManager.darkSectionGray,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.account_tree_rounded,
                            size: 48,
                            color: ColorManager.primary.withValues(
                              alpha: 0.3,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'bracket_visualization'.tr(),
                            style: const TextStyle(
                              color: ColorManager.darkTextMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // Prize distribution
                _buildSection(
                  title: 'prize_distribution'.tr(),
                  child: tournament.prizes.isEmpty
                      ? Text(
                          'no_prizes_available'.tr(),
                          style: const TextStyle(
                            fontSize: 13,
                            color: ColorManager.darkTextMuted,
                          ),
                        )
                      : Column(
                          children: tournament.prizes.asMap().entries.map((entry) {
                            final index = entry.key;
                            final prize = entry.value;
                            final color = switch (index) {
                              0 => ColorManager.secondary,
                              1 => ColorManager.darkTextSecondary,
                              2 => ColorManager.secondaryDark,
                              _ => ColorManager.darkTextMuted,
                            };
                            return _buildPrizeRow(
                              prize.place.tr(),
                              prize.amount,
                              color,
                              Icons.emoji_events_rounded,
                            );
                          }).toList(),
                        ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                AppButton(
                  text: tournament.isJoined
                      ? 'view_bracket'.tr()
                      : 'join_tournament'.tr(),
                  onPressed: isJoining
                      ? null
                      : () {
                          if (tournament.isJoined) {
                            context.pushNamed(
                              'tournamentBracket',
                              pathParameters: {'id': id},
                            );
                          } else {
                            _showJoinBottomSheet(context, tournament);
                          }
                        },
                  isLoading: isJoining,
                ),
                const SizedBox(height: AppSpacing.sm),
                if (!tournament.isJoined)
                  AppTextButton(
                    text: 'view_bracket'.tr(),
                    onPressed: () => context.pushNamed(
                      'tournamentBracket',
                      pathParameters: {'id': id},
                    ),
                    color: ColorManager.secondary,
                  ),
                const SizedBox(height: AppSpacing.xxl),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'live':
        return ColorManager.live;
      case 'upcoming':
        return ColorManager.info;
      case 'completed':
        return ColorManager.darkTextMuted;
      default:
        return ColorManager.primary;
    }
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: ColorManager.darkSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: ColorManager.darkBorderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: ColorManager.darkTextPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: ColorManager.darkTextMuted.withValues(alpha: 0.7),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: ColorManager.darkTextSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ColorManager.darkTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrizeRow(
    String place,
    String amount,
    Color color,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: AppSpacing.md),
          Text(
            place,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const Spacer(),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: ColorManager.darkTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
