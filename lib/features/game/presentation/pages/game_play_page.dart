import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:bloot/core/components/cached_avatar.dart';
import 'package:bloot/core/constants/app_radius.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/features/game/domain/entities/game.dart';
import 'package:bloot/features/game/presentation/cubit/game_cubit.dart';
import 'package:bloot/features/game/presentation/cubit/game_state.dart';

class GamePlayPage extends StatefulWidget {
  const GamePlayPage({super.key, required this.id});
  final String id;

  @override
  State<GamePlayPage> createState() => _GamePlayPageState();
}

class _GamePlayPageState extends State<GamePlayPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) context.read<GameCubit>().hideControls();
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleControls() {
    context.read<GameCubit>().toggleControls();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameCubit, GameState>(
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
        final game = state is GameLoaded ? state.game : null;
        final controlsVisible = state is GameLoaded && state.controlsVisible;
        final selectedCardIndex = state is GameLoaded
            ? state.selectedCardIndex
            : null;
        final myHand = game?.myHand ?? [];

        return GestureDetector(
          onTap: _toggleControls,
          child: Scaffold(
            backgroundColor: ColorManager.darkCanvas,
            body: Stack(
              children: [
                // Background
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ColorManager.gameTableTop,
                        ColorManager.gameTableBot,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                // Game layout
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        // Top player (partner)
                        if (game != null && game.players.length > 1)
                          _GamePlayerSeat(player: game.players[0]),
                        // Middle row: left, table, right
                        Expanded(
                          child: Row(
                            children: [
                              // Left player (opponent)
                              if (game != null && game.players.length > 2)
                                _GamePlayerSeat(player: game.players[1]),
                              const SizedBox(width: AppSpacing.md),
                              // Game table
                              Expanded(
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    double width = constraints.maxWidth;
                                    double height = width / 1.4;
                                    if (height > constraints.maxHeight) {
                                      height = constraints.maxHeight;
                                      width = height * 1.4;
                                    }
                                    return Center(
                                      child: SizedBox(
                                        width: width,
                                        height: height,
                                        child: AspectRatio(
                                          aspectRatio: 1.4,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: ColorManager.gameTableTop.withValues(
                                                alpha: 0.6,
                                              ),
                                              borderRadius: BorderRadius.circular(
                                                AppRadius.xl,
                                              ),
                                              border: Border.all(
                                                color: ColorManager.gameTableBorder,
                                                width: 2,
                                              ),
                                            ),
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                // Center info
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    // Score display
                                                    Container(
                                                      padding:
                                                          const EdgeInsetsDirectional.symmetric(
                                                            horizontal: 16,
                                                            vertical: 8,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: ColorManager.darkCanvas
                                                            .withValues(alpha: 0.5),
                                                        borderRadius:
                                                            BorderRadius.circular(10),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            'us'.tr(),
                                                            style: const TextStyle(
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.w600,
                                                              color: ColorManager
                                                                  .darkTextSecondary,
                                                            ),
                                                          ),
                                                          const SizedBox(width: 4),
                                                          Text(
                                                            '${game?.scoreUs ?? 8}',
                                                            style: const TextStyle(
                                                              fontSize: 18,
                                                              fontWeight: FontWeight.w700,
                                                              color: ColorManager
                                                                  .darkTextPrimary,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: AppSpacing.sm,
                                                          ),
                                                          const Text(
                                                            '—',
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              color: ColorManager
                                                                  .darkTextMuted,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: AppSpacing.sm,
                                                          ),
                                                          Text(
                                                            '${game?.scoreThem ?? 12}',
                                                            style: const TextStyle(
                                                              fontSize: 18,
                                                              fontWeight: FontWeight.w700,
                                                              color:
                                                                  ColorManager.secondary,
                                                            ),
                                                          ),
                                                          const SizedBox(width: 4),
                                                          Text(
                                                            'them'.tr(),
                                                            style: const TextStyle(
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.w600,
                                                              color:
                                                                  ColorManager.secondary,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(height: AppSpacing.sm),
                                                    Container(
                                                      padding:
                                                          const EdgeInsetsDirectional.symmetric(
                                                            horizontal: 10,
                                                            vertical: 4,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: ColorManager.primary
                                                            .withValues(alpha: 0.2),
                                                        borderRadius:
                                                            BorderRadius.circular(6),
                                                      ),
                                                      child: Text(
                                                        game?.trump ?? 'hokm_spades'.tr(),
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w600,
                                                          color: ColorManager.primary,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                // Played cards
                                                ...[
                                                  const Offset(0, -40),
                                                  const Offset(0, 40),
                                                  const Offset(-50, 0),
                                                  const Offset(50, 0),
                                                ].map((offset) {
                                                  return Transform.translate(
                                                    offset: offset,
                                                    child: const _MiniCard(),
                                                  );
                                                }),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              // Right player (opponent)
                              if (game != null && game.players.length > 3)
                                _GamePlayerSeat(player: game.players[2]),
                            ],
                          ),
                        ),
                        // My hand area (bottom - you)
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // My player info
                            if (game != null && game.players.length > 3)
                              _GamePlayerSeat(player: game.players[3]),
                            const SizedBox(height: AppSpacing.sm),
                            // Cards
                            SizedBox(
                              height: 80,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemCount: myHand.length,
                                itemBuilder: (context, index) {
                                  final isSelected = selectedCardIndex == index;
                                  return GestureDetector(
                                    onTap: () {
                                      context.read<GameCubit>().selectCard(
                                        isSelected ? null : index,
                                      );
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 150,
                                      ),
                                      curve: Curves.easeOutBack,
                                      margin:
                                          const EdgeInsetsDirectional.symmetric(
                                            horizontal: 2,
                                          ),
                                      transform: Matrix4.translationValues(
                                        0,
                                        isSelected ? -16 : 0,
                                        0,
                                      ),
                                      child: _PlayingCard(card: myHand[index]),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Top controls overlay
                if (controlsVisible)
                  SafeArea(
                    child: Container(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            ColorManager.darkCanvas.withValues(alpha: 0.7),
                            const Color(0x00000000),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: ColorManager.darkTextPrimary,
                            ),
                            onPressed: () => _showLeaveDialog(context),
                          ),
                          const Spacer(),
                          const _ControlIcon(
                            Icons.mic_rounded,
                            ColorManager.success,
                          ),
                          const _ControlIcon(
                            Icons.videocam_off_rounded,
                            ColorManager.darkTextMuted,
                          ),
                          _ControlIcon(
                            Icons.chat_bubble_outline_rounded,
                            ColorManager.darkTextPrimary.withValues(alpha: 0.7),
                          ),
                          _ControlIcon(
                            Icons.settings_rounded,
                            ColorManager.darkTextPrimary.withValues(alpha: 0.7),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Bottom control bar
                if (controlsVisible)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      child: Container(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0x00000000),
                              ColorManager.darkCanvas.withValues(alpha: 0.7),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _BottomControlButton(
                              icon: Icons.chat_bubble_outline_rounded,
                              color: ColorManager.darkTextPrimary.withValues(
                                alpha: 0.7,
                              ),
                              onTap: () {},
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            _BottomControlButton(
                              icon: Icons.mic_rounded,
                              color: ColorManager.success,
                              onTap: () {},
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      ColorManager.primary,
                                      ColorManager.primaryDark,
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: ColorManager.primary.withValues(
                                        alpha: 0.4,
                                      ),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: ColorManager.darkTextPrimary,
                                  size: 28,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            _BottomControlButton(
                              icon: Icons.videocam_off_rounded,
                              color: ColorManager.darkTextMuted,
                              onTap: () {},
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            _BottomControlButton(
                              icon: Icons.logout_rounded,
                              color: ColorManager.error,
                              onTap: () => _showLeaveDialog(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLeaveDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorManager.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: Text(
          'leave_game'.tr(),
          style: const TextStyle(color: ColorManager.darkTextPrimary),
        ),
        content: Text(
          'forfeit_warning'.tr(),
          style: const TextStyle(color: ColorManager.darkTextSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              context.pop();
            },
            child: Text(
              'leave'.tr(),
              style: const TextStyle(color: ColorManager.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _GamePlayerSeat extends StatelessWidget {
  const _GamePlayerSeat({required this.player});

  final GamePlayer player;

  @override
  Widget build(BuildContext context) {
    final teamColor = player.team == 'A'
        ? ColorManager.primary
        : ColorManager.secondary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: player.isActive ? teamColor : const Color(0x00000000),
              width: 2,
            ),
            boxShadow: player.isActive
                ? [
                    BoxShadow(
                      color: teamColor.withValues(alpha: 0.4),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: CachedAvatar(
            imageUrl: player.avatarUrl,
            size: player.isTop ? 44 : 52,
            borderRadius: player.isTop ? 22 : 26,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          player.name,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: player.isActive ? teamColor : ColorManager.darkTextPrimary,
          ),
        ),
        if (!player.isTop)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.mic_rounded,
                size: 12,
                color: ColorManager.success.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.videocam_off_rounded,
                size: 12,
                color: ColorManager.darkTextMuted.withValues(alpha: 0.5),
              ),
            ],
          ),
      ],
    );
  }
}

class _PlayingCard extends StatelessWidget {
  const _PlayingCard({required this.card});

  final String card;

  @override
  Widget build(BuildContext context) {
    final rank = card.substring(0, card.length - 1);
    final suit = card.substring(card.length - 1);
    final suitIcon =
        {
          '♥': Icons.favorite,
          '♦': Icons.square,
          '♠': Icons.change_history,
          '♣': Icons.circle,
        }[suit] ??
        Icons.help_outline;
    final isRed = suit == '♥' || suit == '♦';

    return Container(
      width: 50,
      height: 70,
      decoration: BoxDecoration(
        color: ColorManager.darkSurface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        boxShadow: [
          BoxShadow(
            color: ColorManager.darkCanvas.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              rank,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isRed
                    ? ColorManager.error
                    : ColorManager.darkTextPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Icon(
              suitIcon,
              size: 16,
              color: isRed ? ColorManager.error : ColorManager.darkTextPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 50,
      decoration: BoxDecoration(
        color: ColorManager.darkSurface,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: ColorManager.darkCanvas.withValues(alpha: 0.3),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }
}

class _ControlIcon extends StatelessWidget {
  const _ControlIcon(this.icon, this.color);

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: color, size: 22),
      onPressed: () {},
    );
  }
}

class _BottomControlButton extends StatelessWidget {
  const _BottomControlButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: ColorManager.darkCanvas.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}
