import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/components/cached_avatar.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/constants/app_radius.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

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
        child: NestedScrollView(
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
                            child: const CachedAvatar(
                              imageUrl: 'https://i.pravatar.cc/150?img=11',
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
                            child: const Text(
                              'Lvl 12',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: ColorManager.darkTextPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const Text(
                        'Ahmed Al-Saud',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: ColorManager.darkTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '@ahmed_baloot',
                        style: TextStyle(
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
                          widthFactor: 0.65,
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
                        'xp_to_level_6'.tr(),
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
                              value: '142',
                              color: ColorManager.secondary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.style_rounded,
                              label: 'games'.tr(),
                              value: '289',
                              color: ColorManager.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.people_rounded,
                              label: 'followers'.tr(),
                              value: '1.2K',
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
                              onTap: () =>
                                  context.pushNamed(RouteNames.editProfile),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _ActionButton(
                              icon: Icons.share_rounded,
                              label: 'share'.tr(),
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Profile shared'),
                                  ),
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
            children: const [_StatsTab(), _HistoryTab(), _AboutTab()],
          ),
        ),
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
  const _StatsTab();

  @override
  Widget build(BuildContext context) {
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
                    const CircularProgressIndicator(
                      value: 0.49,
                      strokeWidth: 8,
                      backgroundColor: ColorManager.darkSectionGray,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        ColorManager.primary,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '49%',
                          style: TextStyle(
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
                      value: 0.52,
                      color: ColorManager.primary,
                    ),
                    const SizedBox(height: 10),
                    _BarChartRow(
                      label: 'hokm_games'.tr(),
                      value: 0.47,
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
            itemCount: 6,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final earned = index < 3;
              final unlockDates = ['Oct 12', 'Nov 3', 'Dec 1'];
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
                      [
                        Icons.emoji_events_rounded,
                        Icons.local_fire_department_rounded,
                        Icons.star_rounded,
                        Icons.lock_rounded,
                        Icons.lock_rounded,
                        Icons.lock_rounded,
                      ][index],
                      color: earned
                          ? ColorManager.secondary
                          : ColorManager.darkTextMuted,
                      size: 28,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        'first_win'.tr(),
                        'win_streak'.tr(),
                        'top_10'.tr(),
                        'locked'.tr(),
                        'locked'.tr(),
                        'locked'.tr(),
                      ][index],
                      style: TextStyle(
                        fontSize: 10,
                        color: earned
                            ? ColorManager.secondary
                            : ColorManager.darkTextMuted,
                      ),
                    ),
                    if (earned) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Unlocked ${unlockDates[index]}',
                        style: const TextStyle(
                          fontSize: 9,
                          color: ColorManager.darkTextMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              );
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
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    final games = [
      _GameHistory(
        won: true,
        score: '52-48',
        type: 'Hokm',
        duration: '24m',
        date: 'today'.tr(),
      ),
      _GameHistory(
        won: false,
        score: '45-55',
        type: 'Sun',
        duration: '18m',
        date: 'yesterday'.tr(),
      ),
      _GameHistory(
        won: true,
        score: '60-40',
        type: 'Hokm',
        duration: '32m',
        date: '2_days_ago'.tr(),
      ),
      _GameHistory(
        won: true,
        score: '58-42',
        type: 'Sun',
        duration: '28m',
        date: '3_days_ago'.tr(),
      ),
      _GameHistory(
        won: false,
        score: '50-50',
        type: 'Hokm',
        duration: '35m',
        date: 'last_week'.tr(),
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
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
                      '${game.type} • ${game.duration}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: ColorManager.darkTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                game.date,
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
}

class _GameHistory {
  _GameHistory({
    required this.won,
    required this.score,
    required this.type,
    required this.duration,
    required this.date,
  });

  final bool won;
  final String score;
  final String type;
  final String duration;
  final String date;
}

class _AboutTab extends StatelessWidget {
  const _AboutTab();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          _AboutCard(
            icon: Icons.info_outline_rounded,
            label: 'bio'.tr(),
            value: 'bio_text'.tr(),
          ),
          const SizedBox(height: AppSpacing.md),
          _AboutCard(
            icon: Icons.calendar_today_rounded,
            label: 'member_since'.tr(),
            value: 'march_2024'.tr(),
          ),
          const SizedBox(height: AppSpacing.md),
          _AboutCard(
            icon: Icons.favorite_rounded,
            label: 'favorite_mode'.tr(),
            value: 'Hokm',
          ),
          const SizedBox(height: AppSpacing.md),
          _AboutCard(
            icon: Icons.location_on_rounded,
            label: 'region'.tr(),
            value: 'riyadh_saudi_arabia'.tr(),
          ),
        ],
      ),
    );
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
