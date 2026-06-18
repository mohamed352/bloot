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
import 'package:bloot/features/tournament/presentation/widgets/bracket_match_card.dart';

class TournamentBracketPage extends StatelessWidget {
  const TournamentBracketPage({super.key, required this.id});

  final String id;

  static const Map<int, String> _roundNames = {
    0: 'round_of_64',
    1: 'round_of_32',
    2: 'sweet_16',
    3: 'quarter_final',
    4: 'semi_final',
    5: 'final',
  };

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
          matchReady: (tournamentId, roomId, matchId) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('tournament_match_ready'.tr()),
                action: SnackBarAction(
                  label: 'join_match'.tr(),
                  onPressed: () => context.pushNamed(
                    RouteNames.roomLobby,
                    pathParameters: {'id': roomId},
                  ),
                ),
                duration: const Duration(seconds: 10),
              ),
            );
          },
        );
      },
      builder: (context, state) {
        final tournament = state.maybeWhen(
          detailLoaded: (t) => t,
          orElse: () => null,
        );

        return Scaffold(
          backgroundColor: ColorManager.darkCanvas,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                backgroundColor: ColorManager.darkSurface,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: ColorManager.darkTextPrimary,
                  ),
                  onPressed: () => context.pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    tournament?.name.tr() ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: ColorManager.darkTextPrimary,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ColorManager.secondary.withValues(alpha: 0.25),
                          ColorManager.darkSurface,
                        ],
                        begin: AlignmentDirectional.topStart,
                        end: AlignmentDirectional.bottomEnd,
                      ),
                    ),
                    child: const Stack(
                      children: [
                        PositionedDirectional(
                          top: 80,
                          start: 16,
                          child: Icon(
                            Icons.emoji_events_rounded,
                            size: 80,
                            color: ColorManager.secondaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    tournament == null || tournament.bracket.isEmpty
                        ? [
                            _buildEmptyBracket(),
                          ]
                        : _buildRounds(tournament),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildRounds(Tournament tournament) {
    // Group matches by roundIndex preserving order
    final matchesByRound = <int, List<Widget>>{};
    for (final match in tournament.bracket) {
      final roundKey = match.roundIndex;
      final card = BracketMatchCard(
        playerAName: match.playerAName,
        playerBName: match.playerBName,
        playerAScore: match.playerAScore,
        playerBScore: match.playerBScore,
        status: _parseStatus(match.status),
        isUserMatch: match.isUserMatch,
        playerAAvatarUrl: match.playerAAvatarUrl,
        playerBAvatarUrl: match.playerBAvatarUrl,
      );
      matchesByRound.putIfAbsent(roundKey, () => []).add(card);
    }

    final widgets = <Widget>[];
    for (final round in _roundNames.keys.toList()..sort()) {
      final matches = matchesByRound[round];
      if (matches == null || matches.isEmpty) continue;

      widgets.add(
        _buildRoundSection(
          roundName: (_roundNames[round] ?? 'unknown').tr(),
          matches: matches
              .expand((m) => [m, const SizedBox(height: AppSpacing.md)])
              .toList()
            ..removeLast(),
        ),
      );
      widgets.add(const SizedBox(height: AppSpacing.lg));
    }

    // Add any rounds not in the predefined names at the end
    for (final entry in matchesByRound.entries) {
      if (_roundNames.containsKey(entry.key)) continue;
      widgets.add(
        _buildRoundSection(
          roundName: 'round_${entry.key}'.tr(),
          matches: entry.value
              .expand((m) => [m, const SizedBox(height: AppSpacing.md)])
              .toList()
            ..removeLast(),
        ),
      );
      widgets.add(const SizedBox(height: AppSpacing.lg));
    }

    widgets.add(const SizedBox(height: AppSpacing.xxl));
    return widgets;
  }

  MatchStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'live':
        return MatchStatus.live;
      case 'finished':
        return MatchStatus.finished;
      default:
        return MatchStatus.upcoming;
    }
  }

  Widget _buildEmptyBracket() {
    return Container(
      padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: ColorManager.darkSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: ColorManager.darkBorderSoft),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.account_tree_rounded,
              size: 48,
              color: ColorManager.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'bracket_not_available'.tr(),
              style: const TextStyle(
                color: ColorManager.darkTextMuted,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundSection({
    required String roundName,
    required List<Widget> matches,
  }) {
    return Container(
      padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: ColorManager.darkSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: ColorManager.darkBorderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            roundName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: ColorManager.darkTextPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...matches,
        ],
      ),
    );
  }
}
