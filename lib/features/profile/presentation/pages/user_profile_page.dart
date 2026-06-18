import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/components/cached_avatar.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/constants/app_radius.dart';
import 'package:bloot/features/profile/domain/entities/achievement.dart';
import 'package:bloot/features/profile/domain/entities/game_history.dart';
import 'package:bloot/features/profile/domain/entities/user_profile.dart';
import 'package:bloot/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:bloot/features/profile/presentation/cubit/profile_state.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key, required this.userId});

  final String userId;

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.darkCanvas,
      body: SafeArea(
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            return state.when(
              initial: () => const Center(child: CircularProgressIndicator()),
              loading: () => const Center(child: CircularProgressIndicator()),
              loaded: (profile, gameHistory, achievements) =>
                  _buildProfileContent(context, profile, gameHistory, achievements),
              error: (message) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: ColorManager.darkTextMuted,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      message,
                      style: const TextStyle(
                        color: ColorManager.darkTextSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextButton(
                      onPressed: () => context
                          .read<ProfileCubit>()
                          .loadProfile(widget.userId),
                      child: Text('commonRetry'.tr()),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    UserProfile profile,
    List<GameHistory> gameHistory,
    List<Achievement> achievements,
  ) {
    final xpProgress = profile.xpToNextLevel > 0
        ? profile.xp / profile.xpToNextLevel
        : 0.0;

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  // Avatar + name with gold ring and level badge
                  Stack(
                    alignment: AlignmentDirectional.bottomEnd,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: ColorManager.secondary.withValues(
                              alpha: 0.6,
                            ),
                            width: 3,
                          ),
                        ),
                        child: CachedAvatar(
                          imageUrl: profile.avatarUrl ?? '',
                          size: 92,
                          borderRadius: 46,
                        ),
                      ),
                      // Level badge overlapping avatar bottom-right
                      Container(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: ColorManager.secondary,
                          borderRadius: BorderRadius.circular(
                            AppRadius.full,
                          ),
                          border: Border.all(
                            color: ColorManager.darkCanvas,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          'Lvl ${profile.level}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: ColorManager.darkTextPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    profile.displayName ?? 'User',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: ColorManager.darkTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (profile.username != null && profile.username!.isNotEmpty)
                    Text(
                      '@${profile.username}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: ColorManager.darkTextSecondary,
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  // XP bar
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: ColorManager.darkSectionGray,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: FractionallySizedBox(
                      alignment: AlignmentDirectional.centerStart,
                      widthFactor: xpProgress.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              ColorManager.primary,
                              ColorManager.primaryLight,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(
                            AppRadius.full,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${profile.xp} / ${profile.xpToNextLevel} XP',
                    style: const TextStyle(
                      fontSize: 12,
                      color: ColorManager.darkTextMuted,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Stats row with cards and icons
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.emoji_events_rounded,
                          label: 'wins'.tr(),
                          value: '${profile.gamesWon}',
                          color: ColorManager.secondary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.style_rounded,
                          label: 'games'.tr(),
                          value: '${profile.gamesPlayed}',
                          color: ColorManager.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.people_rounded,
                          label: 'followers'.tr(),
                          value: '${profile.followersCount}',
                          color: ColorManager.info,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Quick actions
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.edit_rounded,
                          label: 'edit_profile'.tr(),
                          onTap: () => context.pushNamed(
                            RouteNames.editProfile,
                            extra: profile,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.share_rounded,
                          label: 'share'.tr(),
                          onTap: () {
                            Share.share(
                              '\u{1F464} ${profile.displayName}\n'
                              'https://bloot.app/user/${widget.userId}',
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.settings_rounded,
                          label: 'settings'.tr(),
                          onTap: () =>
                              context.pushNamed(RouteNames.settings),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Tab bar
                  TabBar(
                    controller: _tabController,
                    indicatorColor: ColorManager.primary,
                    labelColor: ColorManager.primary,
                    unselectedLabelColor: ColorManager.darkTextMuted,
                    labelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    tabs: [
                      Tab(text: 'stats'.tr()),
                      Tab(text: 'history'.tr()),
                      Tab(text: 'about'.tr()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          _StatsTab(profile: profile, achievements: achievements),
          _HistoryTab(games: gameHistory),
          _AboutTab(profile: profile),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: ColorManager.darkSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: ColorManager.darkTextPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: ColorManager.darkTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: ColorManager.darkSurface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: ColorManager.darkBorderSoft),
        ),
        child: Column(
          children: [
            Icon(icon, color: ColorManager.primary, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: ColorManager.darkTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsTab extends StatelessWidget {
  const _StatsTab({
    required this.profile,
    required this.achievements,
  });

  final UserProfile profile;
  final List<Achievement> achievements;

  @override
  Widget build(BuildContext context) {
    final winRate = profile.gamesPlayed > 0
        ? profile.gamesWon / profile.gamesPlayed
        : 0.0;
    final winRatePercent = (winRate * 100).toInt();
    final sunWinRate = profile.sunGamesPlayed > 0
        ? profile.sunGamesWon / profile.sunGamesPlayed
        : 0.0;
    final hokmWinRate = profile.hokmGamesPlayed > 0
        ? profile.hokmGamesWon / profile.hokmGamesPlayed
        : 0.0;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // Win rate with subtitle
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ColorManager.darkSurface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: ColorManager.darkBorderSoft),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: winRate.clamp(0.0, 1.0),
                      strokeWidth: 8,
                      backgroundColor: ColorManager.darkSectionGray,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        ColorManager.primary,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$winRatePercent%',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: ColorManager.darkTextPrimary,
                          ),
                        ),
                        Text(
                          'win_rate'.tr(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: ColorManager.darkTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'overall_win_rate'.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ColorManager.darkTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'last_30_days'.tr(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: ColorManager.darkTextMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Horizontal bar charts
                    _BarChartRow(
                      label: 'sun_games'.tr(),
                      value: sunWinRate,
                      color: ColorManager.primary,
                    ),
                    const SizedBox(height: 10),
                    _BarChartRow(
                      label: 'hokm_games'.tr(),
                      value: hokmWinRate,
                      color: ColorManager.secondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        // Achievements with unlock dates
        Text(
          'achievements'.tr(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: ColorManager.darkTextPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: achievements.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              return _AchievementCard(achievement: achievement);
            },
          ),
        ),
      ],
    );
  }
}

class _BarChartRow extends StatelessWidget {
  const _BarChartRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: ColorManager.darkTextSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: ColorManager.darkSectionGray,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
            FractionallySizedBox(
              widthFactor: value,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '${(value * 100).toInt()}%',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab({required this.games});

  final List<GameHistory> games;

  @override
  Widget build(BuildContext context) {
    if (games.isEmpty) {
      return Center(
        child: Text(
          'no_games_yet'.tr(),
          style: const TextStyle(
            color: ColorManager.darkTextMuted,
            fontSize: 14,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        final duration = game.durationMinutes != null
            ? '${game.durationMinutes}m'
            : '';
        final date = game.playedAt != null
            ? _formatDate(game.playedAt!)
            : '';

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: ColorManager.darkSurface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: ColorManager.darkBorderSoft),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: game.won
                      ? ColorManager.success.withValues(alpha: 0.15)
                      : ColorManager.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  game.won ? Icons.check_rounded : Icons.close_rounded,
                  color: game.won ? ColorManager.success : ColorManager.error,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.score,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: ColorManager.darkTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      duration.isNotEmpty
                          ? '${game.type} • $duration'
                          : game.type,
                      style: const TextStyle(
                        fontSize: 12,
                        color: ColorManager.darkTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (date.isNotEmpty)
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: ColorManager.darkTextMuted,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (date == today) return 'today'.tr();
    if (date == yesterday) return 'yesterday'.tr();

    final diff = now.difference(dateTime);
    if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    }
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          if (profile.bio != null && profile.bio!.isNotEmpty)
            _AboutCard(
              icon: Icons.info_outline_rounded,
              label: 'bio'.tr(),
              value: profile.bio!,
            ),
          if (profile.bio != null && profile.bio!.isNotEmpty)
            const SizedBox(height: AppSpacing.md),
          _AboutCard(
            icon: Icons.calendar_today_rounded,
            label: 'member_since'.tr(),
            value: 'march_2024'.tr(),
          ),
          const SizedBox(height: AppSpacing.md),
          if (profile.favoriteMode != null && profile.favoriteMode!.isNotEmpty)
            _AboutCard(
              icon: Icons.favorite_rounded,
              label: 'favorite_mode'.tr(),
              value: profile.favoriteMode!.tr(),
            ),
          if (profile.favoriteMode != null && profile.favoriteMode!.isNotEmpty)
            const SizedBox(height: AppSpacing.md),
          if (profile.region != null && profile.region!.isNotEmpty)
            _AboutCard(
              icon: Icons.location_on_rounded,
              label: 'region'.tr(),
              value: profile.region!.tr(),
            ),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.achievement});

  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final earned = achievement.earned;

    return Container(
      width: 80,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: earned
            ? ColorManager.secondary.withValues(alpha: 0.15)
            : ColorManager.darkSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: earned
              ? ColorManager.secondary.withValues(alpha: 0.3)
              : ColorManager.darkBorderSoft,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _iconForName(achievement.iconName),
            color: earned ? ColorManager.secondary : ColorManager.darkTextMuted,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            achievement.title.tr(),
            style: TextStyle(
              fontSize: 10,
              color: earned ? ColorManager.secondary : ColorManager.darkTextMuted,
            ),
          ),
          if (earned && achievement.unlockedAt != null) ...[
            const SizedBox(height: 2),
            Text(
              _formatUnlockDate(achievement.unlockedAt!),
              style: const TextStyle(
                fontSize: 9,
                color: ColorManager.darkTextMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _iconForName(String? name) {
    switch (name) {
      case 'emoji_events':
        return Icons.emoji_events_rounded;
      case 'local_fire_department':
        return Icons.local_fire_department_rounded;
      case 'star':
        return Icons.star_rounded;
      case 'people':
        return Icons.people_rounded;
      case 'monetization_on':
        return Icons.monetization_on_rounded;
      case 'workspace_premium':
        return Icons.workspace_premium_rounded;
      default:
        return Icons.lock_rounded;
    }
  }

  String _formatUnlockDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: ColorManager.darkSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: ColorManager.darkBorderSoft),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: ColorManager.primary),
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
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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
