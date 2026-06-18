import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/components/cached_avatar.dart';
import 'package:bloot/core/components/empty_state_widget.dart';
import 'package:bloot/core/components/skeleton_card.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/constants/app_radius.dart';
import 'package:bloot/features/home/domain/entities/home_stream.dart';
import 'package:bloot/features/home/presentation/cubit/home_cubit.dart';
import 'package:bloot/features/home/presentation/cubit/home_state.dart';
import 'package:bloot/features/tournament/domain/entities/tournament.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.darkCanvas,
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            return RefreshIndicator(
              color: ColorManager.primary,
              backgroundColor: ColorManager.darkSurface,
              onRefresh: () => context.read<HomeCubit>().refresh(),
              child: CustomScrollView(
                slivers: [
                  // Top bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => context.pushNamed(
                              RouteNames.userProfile,
                              pathParameters: {'userId': 'me'},
                            ),
                            child: _UserAvatar(state: state),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _UserInfo(state: state),
                          ),
                          Stack(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.notifications_outlined,
                                  color: ColorManager.darkTextPrimary,
                                ),
                                onPressed: () =>
                                    context.pushNamed(RouteNames.notifications),
                              ),
                              if (state.maybeWhen(
                                loaded: (profile, streams, tournaments, count) => count > 0,
                                empty: (profile, tournaments, count) => count > 0,
                                orElse: () => false,
                              ))
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: ColorManager.error,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Hero Banner with background image and gradient overlay
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: AppSpacing.screenHorizontal,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://images.unsplash.com/photo-1541963463532-d68292c34b19?w=800&q=80',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            gradient: LinearGradient(
                              colors: [
                                ColorManager.primary.withValues(alpha: 0.7),
                                ColorManager.primaryDark.withValues(alpha: 0.4),
                                ColorManager.darkSurface.withValues(alpha: 0.8),
                              ],
                              begin: AlignmentDirectional.topStart,
                              end: AlignmentDirectional.bottomEnd,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                right: -20,
                                top: -20,
                                child: Icon(
                                  Icons.style_rounded,
                                  size: 140,
                                  color: ColorManager.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding:
                                          const EdgeInsetsDirectional.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                      decoration: BoxDecoration(
                                        color: ColorManager.live.withValues(
                                          alpha: 0.15,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.circle,
                                            size: 8,
                                            color: ColorManager.live,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'live'.tr(),
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              color: ColorManager.live,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    Text(
                                      'baloot_live'.tr(),
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: ColorManager.darkTextPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'your_voice_your_passion_your_table'.tr(),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: ColorManager.darkTextPrimary
                                            .withValues(alpha: 0.7),
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    GestureDetector(
                                      onTap: () => context.pushNamed(
                                        RouteNames.discover,
                                      ),
                                      child: Container(
                                        padding:
                                            const EdgeInsetsDirectional.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                        decoration: BoxDecoration(
                                          color: ColorManager.darkTextPrimary,
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.full,
                                          ),
                                        ),
                                        child: Text(
                                          'discover_streams'.tr(),
                                          style: const TextStyle(
                                            color: ColorManager.primaryDark,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
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
                  ),
                  // Quick Actions - 3 horizontal cards in a row
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'quick_actions'.tr(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: ColorManager.darkTextPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final cardWidth =
                                  (constraints.maxWidth - 3 * AppSpacing.md) /
                                  4;
                              return Row(
                                children: [
                                  SizedBox(
                                    width: cardWidth,
                                    child: _QuickActionCard(
                                      icon: Icons.people_rounded,
                                      title: 'play_with_friends'.tr(),
                                      subtitle: 'create_or_join_room'.tr(),
                                      color: ColorManager.primary,
                                      onTap: () =>
                                          context.pushNamed(RouteNames.play),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  SizedBox(
                                    width: cardWidth,
                                    child: _QuickActionCard(
                                      icon: Icons.mic_rounded,
                                      title: 'voice_tables'.tr(),
                                      subtitle: 'voice_only_games'.tr(),
                                      color: ColorManager.info,
                                      onTap: () =>
                                          context.pushNamed(RouteNames.play),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  SizedBox(
                                    width: cardWidth,
                                    child: _QuickActionCard(
                                      icon: Icons.videocam_rounded,
                                      title: 'live_stream'.tr(),
                                      subtitle: 'watch_players_live'.tr(),
                                      color: ColorManager.live,
                                      onTap: () => context.pushNamed(
                                        RouteNames.discover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  SizedBox(
                                    width: cardWidth,
                                    child: _QuickActionCard(
                                      icon: Icons.emoji_events_rounded,
                                      title: 'tournaments'.tr(),
                                      subtitle: 'join_competitions'.tr(),
                                      color: ColorManager.secondary,
                                      onTap: () => context.pushNamed(
                                        RouteNames.tournamentsTab,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          if (kDebugMode) ...[
                            const SizedBox(height: AppSpacing.md),
                            // Play with Bots — local simulator for testing
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => context.pushNamed('gameSim'),
                                icon: const Icon(
                                  Icons.smart_toy_rounded,
                                  size: 20,
                                ),
                                label: Text('play_with_bots'.tr()),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorManager.success.withValues(
                                    alpha: 0.15,
                                  ),
                                  foregroundColor: ColorManager.success,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: ColorManager.success.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  // Live Now header with red dot
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: AppSpacing.screenHorizontal,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                'live_now'.tr(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: ColorManager.darkTextPrimary,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: ColorManager.live,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () =>
                                context.pushNamed(RouteNames.discover),
                            child: Text(
                              'see_all'.tr(),
                              style: const TextStyle(
                                color: ColorManager.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Live streams content based on state
                  _buildStreamsSection(state),
                  // Upcoming Tournaments header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: 16,
                        end: 16,
                        top: 24,
                        bottom: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'upcoming_tournaments'.tr(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: ColorManager.darkTextPrimary,
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                context.pushNamed(RouteNames.tournamentsTab),
                            child: Text(
                              'view_all'.tr(),
                              style: const TextStyle(
                                color: ColorManager.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildTournamentsSection(state),
                  const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStreamsSection(HomeState state) {
    return state.maybeWhen(
      loading: () => SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => const Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: 16,
              vertical: 6,
            ),
            child: SkeletonCard(height: 180),
          ),
          childCount: 3,
        ),
      ),
      loaded: (profile, streams, tournaments, count) => SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _StreamCard(stream: streams[index]),
          childCount: streams.length,
        ),
      ),
      empty: (profile, tournaments, count) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: EmptyStateWidget(
            icon: Icons.videocam_off_rounded,
            title: 'no_live_streams'.tr(),
            subtitle: 'check_back_later_for_live_games'.tr(),
          ),
        ),
      ),
      error: (message) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: EmptyStateWidget(
            icon: Icons.error_outline_rounded,
            title: 'something_went_wrong'.tr(),
            subtitle: message,
          ),
        ),
      ),
      orElse: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
    );
  }

  Widget _buildTournamentsSection(HomeState state) {
    final tournaments = state.maybeWhen(
      loaded: (profile, streams, tournaments, count) => tournaments,
      empty: (profile, tournaments, count) => tournaments,
      orElse: () => null,
    );

    if (state is HomeError) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    if (state is HomeLoading || tournaments == null) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 180,
          child: ListView.separated(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppSpacing.screenHorizontal,
            ),
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) => const SkeletonCard(
              height: 180,
              width: 220,
            ),
          ),
        ),
      );
    }

    if (tournaments.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 180,
        child: ListView.separated(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          scrollDirection: Axis.horizontal,
          itemCount: tournaments.length,
          separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
          itemBuilder: (context, index) => _TournamentCard(
            tournament: tournaments[index],
          ),
        ),
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final profile = state.maybeWhen(
      loaded: (profile, streams, tournaments, count) => profile,
      empty: (profile, tournaments, count) => profile,
      orElse: () => null,
    );

    return CachedAvatar(
      imageUrl: profile?.avatarUrl ?? '',
      size: 40,
      borderRadius: 20,
    );
  }
}

class _UserInfo extends StatelessWidget {
  const _UserInfo({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final profile = state.maybeWhen(
      loaded: (profile, streams, tournaments, count) => profile,
      empty: (profile, tournaments, count) => profile,
      orElse: () => null,
    );

    final displayName = profile?.displayName ?? 'User';
    final level = profile?.level ?? 1;
    final coins = profile?.coins ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$displayName • ${'level'.tr()} $level',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ColorManager.darkTextPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            const Icon(
              Icons.monetization_on_rounded,
              size: 14,
              color: ColorManager.secondary,
            ),
            const SizedBox(width: 4),
            Text(
              '$coins',
              style: const TextStyle(
                fontSize: 13,
                color: ColorManager.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ColorManager.darkSurface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ColorManager.darkTextPrimary,
                ),
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                subtitle,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 11,
                  color: ColorManager.darkTextSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreamCard extends StatelessWidget {
  const _StreamCard({required this.stream});

  final HomeStream stream;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushNamed(
        RouteNames.watchStream,
        pathParameters: {'id': stream.id},
      ),
      child: Container(
        margin: const EdgeInsetsDirectional.symmetric(
          horizontal: 16,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: ColorManager.darkSurface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: ColorManager.darkBorderSoft),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail area
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                gradient: LinearGradient(
                  colors: [
                    ColorManager.primary.withValues(alpha: 0.3),
                    ColorManager.darkSurface,
                  ],
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd,
                ),
              ),
              child: Stack(
                children: [
                  // Placeholder pattern
                  Center(
                    child: Icon(
                      Icons.videocam_rounded,
                      size: 48,
                      color: ColorManager.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  // LIVE badge
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: ColorManager.live.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.circle,
                            size: 6,
                            color: ColorManager.darkTextPrimary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'live'.tr(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: ColorManager.darkTextPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Viewer count
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: ColorManager.darkCanvas.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.visibility_rounded,
                            size: 12,
                            color: ColorManager.darkTextPrimary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${stream.viewerCount}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: ColorManager.darkTextPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  CachedAvatar(
                    imageUrl: stream.hostAvatar,
                    size: 32,
                    borderRadius: 16,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stream.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ColorManager.darkTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              stream.hostName,
                              style: const TextStyle(
                                fontSize: 12,
                                color: ColorManager.darkTextSecondary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsetsDirectional.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: ColorManager.primary.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                stream.type,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: ColorManager.primary,
                                  fontWeight: FontWeight.w600,
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
          ],
        ),
      ),
    );
  }
}

class _TournamentCard extends StatelessWidget {
  const _TournamentCard({required this.tournament});

  final Tournament tournament;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushNamed(
        RouteNames.tournamentDetail,
        pathParameters: {'id': tournament.id},
      ),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ColorManager.darkSurface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    tournament.name.tr(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ColorManager.darkTextPrimary,
                    ),
                  ),
                ),
                if (tournament.isPremium)
                  const Icon(
                    Icons.workspace_premium_rounded,
                    color: ColorManager.secondary,
                    size: 16,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              tournament.date.tr(),
              style: const TextStyle(
                fontSize: 12,
                color: ColorManager.darkTextSecondary,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  size: 14,
                  color: ColorManager.secondary,
                ),
                const SizedBox(width: 4),
                Text(
                  tournament.prize,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ColorManager.secondary,
                  ),
                ),
                const Spacer(),
                Text(
                  tournament.participants,
                  style: const TextStyle(
                    fontSize: 12,
                    color: ColorManager.darkTextMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // Join button (gold)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.pushNamed(
                  RouteNames.tournamentDetail,
                  pathParameters: {'id': tournament.id},
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorManager.secondary.withValues(
                    alpha: 0.2,
                  ),
                  foregroundColor: ColorManager.secondary,
                  elevation: 0,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: Text('join'.tr()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
