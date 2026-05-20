import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/constants/app_radius.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/features/tournament/domain/entities/tournament.dart';
import 'package:bloot/features/tournament/presentation/cubit/tournament_cubit.dart';
import 'package:bloot/features/tournament/presentation/cubit/tournament_state.dart';

class TournamentListPage extends StatelessWidget {
  const TournamentListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TournamentCubit, TournamentState>(
      listener: (context, state) {
        state.whenOrNull(
          error: (message) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          },
        );
      },
      builder: (context, state) {
        final tournaments = state is TournamentLoaded
            ? state.tournaments
            : <Tournament>[];
        final selectedFilter = state is TournamentLoaded
            ? state.selectedFilterIndex
            : 0;
        final filters = [
          'all'.tr(),
          'active'.tr(),
          'upcoming'.tr(),
          'completed'.tr(),
          'my_tournaments'.tr(),
        ];

        return Scaffold(
          backgroundColor: ColorManager.darkCanvas,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Text(
                        'tournaments'.tr(),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: ColorManager.darkTextPrimary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: ColorManager.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.emoji_events_rounded,
                              size: 16,
                              color: ColorManager.secondary,
                            ),
                            SizedBox(width: 6),
                            Text(
                              '2,450',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: ColorManager.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Filters
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: AppSpacing.screenHorizontal,
                    ),
                    scrollDirection: Axis.horizontal,
                    itemCount: filters.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final isSelected = index == selectedFilter;
                      return GestureDetector(
                        onTap: () =>
                            context.read<TournamentCubit>().selectFilter(index),
                        child: Container(
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: AppSpacing.screenHorizontal,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? ColorManager.primary
                                : ColorManager.darkSurface,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            border: Border.all(
                              color: isSelected
                                  ? ColorManager.primary
                                  : ColorManager.darkBorderSoft,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            filters[index],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? ColorManager.darkTextPrimary
                                  : ColorManager.darkTextSecondary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: AppSpacing.screenHorizontal,
                    ),
                    itemCount: tournaments.length,
                    itemBuilder: (context, index) {
                      final t = tournaments[index];
                      return _TournamentListCard(
                        tournament: t,
                        onTap: () => context.pushNamed(
                          RouteNames.tournamentDetail,
                          pathParameters: {'id': t.id},
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TournamentListCard extends StatelessWidget {
  const _TournamentListCard({required this.tournament, required this.onTap});

  final Tournament tournament;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = tournament.status;
    final statusColor = status == 'Live'
        ? ColorManager.live
        : status == 'upcoming'.tr()
        ? ColorManager.primary
        : ColorManager.darkTextMuted;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: ColorManager.darkSurface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: tournament.isPremium
                ? ColorManager.secondary.withValues(alpha: 0.4)
                : ColorManager.darkBorderSoft,
            width: tournament.isPremium ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    tournament.isPremium
                        ? ColorManager.secondary.withValues(alpha: 0.3)
                        : ColorManager.primary.withValues(alpha: 0.2),
                    ColorManager.darkSurface,
                  ],
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.emoji_events_rounded,
                      size: 56,
                      color:
                          (tournament.isPremium
                                  ? ColorManager.secondary
                                  : ColorManager.primary)
                              .withValues(alpha: 0.15),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
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
                        status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ),
                  if (tournament.isPremium)
                    const Positioned(
                      top: 12,
                      right: 12,
                      child: Icon(
                        Icons.workspace_premium_rounded,
                        color: ColorManager.secondary,
                        size: 24,
                      ),
                    ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tournament.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: ColorManager.darkTextPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const Icon(
                        Icons.emoji_events_rounded,
                        size: 16,
                        color: ColorManager.secondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        tournament.prize,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ColorManager.secondary,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: ColorManager.darkTextMuted.withValues(
                          alpha: 0.7,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tournament.date,
                        style: const TextStyle(
                          fontSize: 12,
                          color: ColorManager.darkTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.people_rounded,
                        size: 14,
                        color: ColorManager.darkTextMuted.withValues(
                          alpha: 0.7,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tournament.participants,
                        style: const TextStyle(
                          fontSize: 12,
                          color: ColorManager.darkTextSecondary,
                        ),
                      ),
                      const Spacer(),
                      if (tournament.isJoined)
                        Container(
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: ColorManager.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'joined'.tr(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: ColorManager.success,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
