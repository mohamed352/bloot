import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:bloot/core/components/app_button.dart';
import 'package:bloot/core/components/cached_avatar.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/constants/app_radius.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bloot/features/tournament/presentation/cubit/tournament_cubit.dart';
import 'package:bloot/features/tournament/presentation/cubit/tournament_state.dart';
import 'package:bloot/features/tournament/presentation/widgets/join_tournament_bottom_sheet.dart';

class TournamentDetailPage extends StatelessWidget {
  const TournamentDetailPage({super.key, required this.id});
  final String id;

  void _showJoinBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return JoinTournamentBottomSheet(
          tournamentName: 'gulf_champions_cup'.tr(),
          entryFee: '500',
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
        final isJoining = state is TournamentJoining;

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
                        color: ColorManager.secondary.withValues(alpha: 0.15),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsetsDirectional.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: ColorManager.live.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: ColorManager.live.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              'live'.tr(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: ColorManager.live,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'gulf_champions_cup'.tr(),
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
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.monetization_on_rounded,
                            color: ColorManager.secondary,
                            size: 32,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '10,000',
                            style: TextStyle(
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
                        'tomorrow_8pm'.tr(),
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
                  title: 'participants_23_64'.tr(),
                  child: SizedBox(
                    height: 48,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 12,
                      separatorBuilder: (_, _) =>
                          const SizedBox(width: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        return CachedAvatar(
                          imageUrl:
                              'https://i.pravatar.cc/150?img=${index + 10}',
                          size: 40,
                          borderRadius: 20,
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
                            color: ColorManager.primary.withValues(alpha: 0.3),
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
                  child: Column(
                    children: [
                      _buildPrizeRow(
                        '1st'.tr(),
                        '4,000',
                        ColorManager.secondary,
                        Icons.emoji_events_rounded,
                      ),
                      _buildPrizeRow(
                        '2nd'.tr(),
                        '2,500',
                        ColorManager.darkTextSecondary,
                        Icons.emoji_events_rounded,
                      ),
                      _buildPrizeRow(
                        '3rd'.tr(),
                        '1,500',
                        ColorManager.secondaryDark,
                        Icons.emoji_events_rounded,
                      ),
                      _buildPrizeRow(
                        '4th'.tr(),
                        '500',
                        ColorManager.darkTextMuted,
                        Icons.emoji_events_rounded,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                AppButton(
                  text: 'join_tournament'.tr(),
                  onPressed: isJoining ? null : () => _showJoinBottomSheet(context),
                  isLoading: isJoining,
                ),
                const SizedBox(height: AppSpacing.sm),
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
      },
    );
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
