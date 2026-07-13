import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/components/cached_avatar.dart';
import 'package:bloot/core/di/injection.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/constants/app_radius.dart';
import 'package:bloot/features/moderation/presentation/widgets/block_user_dialog.dart';
import 'package:bloot/features/moderation/presentation/widgets/report_user_sheet.dart';
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

class _UserProfilePageState extends State<UserProfilePage> {
  bool _isOtherUser = false;

  @override
  Widget build(BuildContext context) {
    final currentUid = getIt<firebase_auth.FirebaseAuth>().currentUser?.uid;
    _isOtherUser = widget.userId != 'me' && widget.userId != currentUid;

    return Scaffold(
      backgroundColor: ColorManager.darkCanvas,
      body: SafeArea(
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            return state.when(
              initial: () => const Center(child: CircularProgressIndicator()),
              loading: () => const Center(child: CircularProgressIndicator()),
              loaded: (profile, gameHistory, achievements) =>
                  _buildProfileContent(
                    context,
                    profile,
                    gameHistory,
                  ),
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
                      onPressed: () => context.read<ProfileCubit>().loadProfile(
                        widget.userId,
                      ),
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
  ) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  if (_isOtherUser)
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert_rounded,
                          color: ColorManager.darkTextSecondary,
                        ),
                        color: ColorManager.darkSurface,
                        onSelected: (value) => _onMenuSelected(context, value),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'report',
                            child: Text('report_user'.tr()),
                          ),
                          PopupMenuItem(
                            value: 'block',
                            child: Text('block_user'.tr()),
                          ),
                        ],
                      ),
                    ),
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
                          borderRadius: BorderRadius.circular(AppRadius.full),
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
                          onTap: () => context.pushNamed(RouteNames.settings),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ];
      },
      body: _HistoryTab(games: gameHistory.take(6).toList()),
    );
  }

  Future<void> _onMenuSelected(BuildContext context, String value) async {
    if (value == 'report') {
      await showReportUserSheet(
        context,
        targetUid: widget.userId,
        targetType: 'user',
      );
    } else if (value == 'block') {
      final state = context.read<ProfileCubit>().state;
      final displayName = state is ProfileLoaded
          ? (state.profile.displayName ?? 'User')
          : 'User';
      if (!context.mounted) return;
      final blocked = await showBlockUserDialog(
        context,
        targetUid: widget.userId,
        displayName: displayName,
      );
      if (blocked && context.mounted) {
        context.pop();
      }
    }
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
        final date = game.playedAt != null ? _formatDate(game.playedAt!) : '';

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


