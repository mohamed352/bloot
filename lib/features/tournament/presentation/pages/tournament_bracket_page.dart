import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import 'package:bloot/core/constants/app_radius.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/features/tournament/presentation/widgets/bracket_match_card.dart';

class TournamentBracketPage extends StatelessWidget {
  const TournamentBracketPage({super.key, required this.id});

  final String id;

  static const String _tournamentName = 'Gulf Champions Cup';

  @override
  Widget build(BuildContext context) {
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
              title: const Text(
                _tournamentName,
                style: TextStyle(
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
              delegate: SliverChildListDelegate([
                _buildRoundSection(
                  roundName: 'quarter_final'.tr(),
                  matches: const [
                    BracketMatchCard(
                      playerAName: 'Ahmed',
                      playerBName: 'Khalid',
                      playerAScore: 2,
                      playerBScore: 1,
                      status: MatchStatus.finished,
                      playerAAvatarUrl: 'https://i.pravatar.cc/150?img=11',
                      playerBAvatarUrl: 'https://i.pravatar.cc/150?img=12',
                    ),
                    SizedBox(height: AppSpacing.md),
                    BracketMatchCard(
                      playerAName: 'Faisal',
                      playerBName: 'Omar',
                      playerAScore: 0,
                      playerBScore: 2,
                      status: MatchStatus.finished,
                      playerAAvatarUrl: 'https://i.pravatar.cc/150?img=13',
                      playerBAvatarUrl: 'https://i.pravatar.cc/150?img=14',
                    ),
                    SizedBox(height: AppSpacing.md),
                    BracketMatchCard(
                      playerAName: 'Saad',
                      playerBName: 'Yousef',
                      playerAScore: 2,
                      playerBScore: 0,
                      status: MatchStatus.finished,
                      playerAAvatarUrl: 'https://i.pravatar.cc/150?img=15',
                      playerBAvatarUrl: 'https://i.pravatar.cc/150?img=16',
                    ),
                    SizedBox(height: AppSpacing.md),
                    BracketMatchCard(
                      playerAName: 'Nasser',
                      playerBName: 'Hamad',
                      playerAScore: 1,
                      playerBScore: 2,
                      status: MatchStatus.finished,
                      playerAAvatarUrl: 'https://i.pravatar.cc/150?img=17',
                      playerBAvatarUrl: 'https://i.pravatar.cc/150?img=18',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildRoundSection(
                  roundName: 'semi_final'.tr(),
                  matches: const [
                    BracketMatchCard(
                      playerAName: 'Ahmed',
                      playerBName: 'Omar',
                      playerAScore: 2,
                      playerBScore: 1,
                      status: MatchStatus.finished,
                      playerAAvatarUrl: 'https://i.pravatar.cc/150?img=11',
                      playerBAvatarUrl: 'https://i.pravatar.cc/150?img=14',
                    ),
                    SizedBox(height: AppSpacing.md),
                    BracketMatchCard(
                      playerAName: 'Saad',
                      playerBName: 'Hamad',
                      status: MatchStatus.live,
                      playerAScore: 1,
                      playerBScore: 1,
                      playerAAvatarUrl: 'https://i.pravatar.cc/150?img=15',
                      playerBAvatarUrl: 'https://i.pravatar.cc/150?img=18',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildRoundSection(
                  roundName: 'final'.tr(),
                  matches: const [
                    BracketMatchCard(
                      playerAName: 'Ahmed',
                      playerBName: 'TBD',
                      status: MatchStatus.upcoming,
                      isUserMatch: true,
                      playerAAvatarUrl: 'https://i.pravatar.cc/150?img=11',
                      playerBAvatarUrl: 'https://i.pravatar.cc/150?img=19',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
              ]),
            ),
          ),
        ],
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
