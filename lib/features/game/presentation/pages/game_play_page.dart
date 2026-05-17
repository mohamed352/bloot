import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import 'package:bloot/core/style/colors.dart';

class GamePlayPage extends StatefulWidget {
  const GamePlayPage({super.key, required this.id});
  final String id;

  @override
  State<GamePlayPage> createState() => _GamePlayPageState();
}

class _GamePlayPageState extends State<GamePlayPage> {
  bool _controlsVisible = true;
  int? _selectedCardIndex;
  final List<String> _myHand = List.generate(13, (i) => 'card_$i');

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _controlsVisible = false);
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleControls() {
    setState(() => _controlsVisible = !_controlsVisible);
  }

  @override
  Widget build(BuildContext context) {
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
                  colors: [ColorManager.gameTableTop, ColorManager.gameTableBot],
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
                    const _GamePlayerSeat(
                      name: 'Khalid',
                      avatar: 'https://i.pravatar.cc/150?img=12',
                      isTop: true,
                      isActive: false,
                      team: 'A',
                    ),
                    const Spacer(),
                    // Middle row: left, table, right
                    Row(
                      children: [
                        // Left player (opponent)
                        const _GamePlayerSeat(
                          name: 'Faisal',
                          avatar: 'https://i.pravatar.cc/150?img=33',
                          isTop: false,
                          isActive: true,
                          team: 'B',
                        ),
                        const SizedBox(width: 12),
                        // Game table
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 1.4,
                            child: Container(
                              decoration: BoxDecoration(
                                color: ColorManager.gameTableTop.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(20),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Score display: Us: 8 — Them: 12
                                      Container(
                                        padding: const EdgeInsetsDirectional.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.5),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'us'.tr(),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: ColorManager.darkTextSecondary,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            const Text(
                                              '8',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                                color: ColorManager.darkTextPrimary,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Text(
                                              '—',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: ColorManager.darkTextMuted,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Text(
                                              '12',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                                color: ColorManager.secondary,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'them'.tr(),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: ColorManager.secondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsetsDirectional.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: ColorManager.primary.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'hokm_spades'.tr(),
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
                        const SizedBox(width: 12),
                        // Right player (opponent)
                        const _GamePlayerSeat(
                          name: 'Omar',
                          avatar: 'https://i.pravatar.cc/150?img=44',
                          isTop: false,
                          isActive: false,
                          team: 'A',
                        ),
                      ],
                    ),
                    const Spacer(),
                    // My hand area (bottom - you)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // My player info
                        _GamePlayerSeat(
                          name: 'you'.tr(),
                          avatar: 'https://i.pravatar.cc/150?img=11',
                          isTop: false,
                          isActive: true,
                          team: 'B',
                        ),
                        const SizedBox(height: 8),
                        // Cards
                        SizedBox(
                          height: 80,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: _myHand.length,
                            itemBuilder: (context, index) {
                              final isSelected = _selectedCardIndex == index;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedCardIndex = isSelected ? null : index;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  curve: Curves.easeOutBack,
                                  margin: const EdgeInsetsDirectional.symmetric(horizontal: 2),
                                  transform: Matrix4.translationValues(
                                    0,
                                    isSelected ? -16 : 0,
                                    0,
                                  ),
                                  child: _PlayingCard(index: index),
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
            if (_controlsVisible)
              SafeArea(
                child: Container(
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: ColorManager.darkTextPrimary),
                        onPressed: () => _showLeaveDialog(context),
                      ),
                      const Spacer(),
                      const _ControlIcon(Icons.mic_rounded, ColorManager.success),
                      const _ControlIcon(Icons.videocam_off_rounded, ColorManager.darkTextMuted),
                      _ControlIcon(Icons.chat_bubble_outline_rounded, ColorManager.darkTextPrimary.withValues(alpha: 0.7)),
                      _ControlIcon(Icons.settings_rounded, ColorManager.darkTextPrimary.withValues(alpha: 0.7)),
                    ],
                  ),
                ),
              ),
            // Bottom control bar: chat, mic, checkmark (play), video, exit
            if (_controlsVisible)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Container(
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
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
                          color: ColorManager.darkTextPrimary.withValues(alpha: 0.7),
                          onTap: () {},
                        ),
                        const SizedBox(width: 16),
                        _BottomControlButton(
                          icon: Icons.mic_rounded,
                          color: ColorManager.success,
                          onTap: () {},
                        ),
                        const SizedBox(width: 16),
                        // Play / checkmark button
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [ColorManager.primary, ColorManager.primaryDark],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: ColorManager.primary.withValues(alpha: 0.4),
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
                        const SizedBox(width: 16),
                        _BottomControlButton(
                          icon: Icons.videocam_off_rounded,
                          color: ColorManager.darkTextMuted,
                          onTap: () {},
                        ),
                        const SizedBox(width: 16),
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
  }

  void _showLeaveDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorManager.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
  const _GamePlayerSeat({
    required this.name,
    required this.avatar,
    required this.isTop,
    required this.isActive,
    required this.team,
  });

  final String name;
  final String avatar;
  final bool isTop;
  final bool isActive;
  final String team;

  @override
  Widget build(BuildContext context) {
    final teamColor = team == 'A' ? ColorManager.primary : ColorManager.secondary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? teamColor : Colors.transparent,
              width: 2,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: teamColor.withValues(alpha: 0.4),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: CircleAvatar(
            radius: isTop ? 22 : 26,
            backgroundImage: NetworkImage(avatar),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isActive ? teamColor : ColorManager.darkTextPrimary,
          ),
        ),
        if (!isTop)
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
  const _PlayingCard({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 70,
      decoration: BoxDecoration(
        color: ColorManager.cardWhite,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
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
              ['A', 'K', 'Q', 'J', '10', '9', '8', '7', '6', '5', '4', '3', '2'][index % 13],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: ColorManager.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Icon(
              [Icons.favorite, Icons.square, Icons.circle, Icons.change_history][index % 4],
              size: 16,
              color: [Colors.red, Colors.black, Colors.red, Colors.black][index % 4],
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
        color: ColorManager.cardWhite,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
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
          color: Colors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}
