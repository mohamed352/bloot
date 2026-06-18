import 'dart:async';

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import 'package:bloot/core/components/cached_avatar.dart';
import 'package:bloot/core/constants/app_radius.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/services/agora_service.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/features/discover/domain/entities/discover_stream.dart';
import 'package:bloot/features/discover/presentation/cubit/discover_cubit.dart';
import 'package:bloot/features/discover/presentation/cubit/discover_state.dart';
import 'package:bloot/features/discover/presentation/widgets/stream_video_square.dart';

class WatchStreamPage extends StatefulWidget {
  const WatchStreamPage({super.key, required this.id});
  final String id;

  @override
  State<WatchStreamPage> createState() => _WatchStreamPageState();
}

class _WatchStreamPageState extends State<WatchStreamPage> {
  final TextEditingController _chatController = TextEditingController();
  late final AgoraService _agoraService;
  StreamSubscription<AgoraUserJoinedEvent>? _userJoinedSub;
  StreamSubscription<AgoraUserOfflineEvent>? _userOfflineSub;
  int _liveViewerCount = 0;

  @override
  void initState() {
    super.initState();
    _agoraService = context.read<AgoraService>();
    _listenToAgoraEvents();
  }

  void _listenToAgoraEvents() {
    _userJoinedSub = _agoraService.onUserJoined.listen((event) {
      setState(() => _liveViewerCount++);
    });
    _userOfflineSub = _agoraService.onUserOffline.listen((event) {
      setState(() => _liveViewerCount = (_liveViewerCount - 1).clamp(0, 9999));
    });
  }

  Future<void> _joinAgoraChannel(String? channelName) async {
    if (channelName == null || channelName.isEmpty) return;
    try {
      await _agoraService.joinAsAudience(channelName: channelName);
    } catch (e) {
      debugPrint('Failed to join Agora stream: $e');
    }
  }

  Future<void> _leaveAgoraChannel() async {
    try {
      await _agoraService.leaveChannel();
    } catch (e) {
      debugPrint('Failed to leave Agora stream: $e');
    }
  }

  void _sendMessage() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;
    context.read<DiscoverCubit>().sendChatMessage(widget.id, text);
    _chatController.clear();
  }

  @override
  void dispose() {
    _userJoinedSub?.cancel();
    _userOfflineSub?.cancel();
    _chatController.dispose();
    _leaveAgoraChannel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DiscoverCubit, DiscoverState>(
      listener: (context, state) {
        state.whenOrNull(
          error: (message) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          },
          streamLoaded: (stream, _) {
            _joinAgoraChannel(stream.agoraChannelName);
          },
        );
      },
      builder: (context, state) {
        final stream = state is DiscoverStreamLoaded ? state.stream : null;
        final messages = state is DiscoverStreamLoaded
            ? state.messages
            : <StreamChatMessage>[];

        return Scaffold(
          backgroundColor: ColorManager.darkCanvas,
          body: Column(
            children: [
              // Video grid
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  color: ColorManager.darkSurface,
                  child: Stack(
                    children: [
                      _buildVideoGrid(stream),
                      // Top bar overlay
                      SafeArea(
                        child: Container(
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                ColorManager.darkCanvas.withValues(alpha: 0.6),
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
                                onPressed: () => context.pop(),
                              ),
                              _PulsingLiveBadge(),
                              const SizedBox(width: 10),
                              Icon(
                                Icons.visibility_rounded,
                                size: 14,
                                color: ColorManager.darkTextPrimary.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                stream != null
                                    ? '${stream.viewers + _liveViewerCount}'
                                    : '--',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: ColorManager.darkTextPrimary
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.more_vert_rounded,
                                color: ColorManager.darkTextPrimary.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Stream info
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                color: ColorManager.darkSurface,
                child: Row(
                  children: [
                    CachedAvatar(
                      imageUrl: stream?.avatarUrl ?? '',
                      size: 40,
                      borderRadius: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stream?.title ?? '--',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: ColorManager.darkTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            stream?.host ?? '--',
                            style: const TextStyle(
                              fontSize: 12,
                              color: ColorManager.darkTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: ColorManager.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
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
              ),
              // Chat messages
              Expanded(
                child: messages.isEmpty
                    ? Center(
                        child: Text(
                          'chat_unavailable'.tr(),
                          style: const TextStyle(
                            fontSize: 13,
                            color: ColorManager.darkTextMuted,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          return Align(
                            alignment: msg.isMe
                                ? AlignmentDirectional.centerEnd
                                : AlignmentDirectional.centerStart,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsetsDirectional.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: msg.isMe
                                    ? ColorManager.primary.withValues(alpha: 0.2)
                                    : ColorManager.darkSurface,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                              ),
                              child: Column(
                                crossAxisAlignment: msg.isMe
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  if (!msg.isMe)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (msg.senderAvatar != null &&
                                            msg.senderAvatar!.isNotEmpty)
                                          CachedAvatar(
                                            imageUrl: msg.senderAvatar!,
                                            size: 16,
                                            borderRadius: 8,
                                          )
                                        else
                                          const Icon(
                                            Icons.account_circle_rounded,
                                            size: 16,
                                            color: ColorManager.primary,
                                          ),
                                        const SizedBox(width: 6),
                                        Text(
                                          msg.senderName,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: ColorManager.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  Text(
                                    msg.text,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: ColorManager.darkTextPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              // Interaction buttons
              Container(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: const BoxDecoration(
                  color: ColorManager.darkSurface,
                  border: Border(
                    top: BorderSide(color: ColorManager.darkBorderSoft),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      _ActionButton(
                        icon: Icons.favorite_rounded,
                        label: 'like'.tr(),
                        color: ColorManager.error,
                      ),
                      _ActionButton(
                        icon: Icons.card_giftcard_rounded,
                        label: 'gift'.tr(),
                        color: ColorManager.secondary,
                      ),
                      _ActionButton(
                        icon: Icons.share_rounded,
                        label: 'share'.tr(),
                        color: ColorManager.info,
                        onTap: stream != null
                            ? () => Share.share(
                                  '\u{1F4FA} ${stream.title} by ${stream.host}\n'
                                  'https://bloot.app/stream/${widget.id}',
                                )
                            : null,
                      ),
                      _ActionButton(
                        icon: Icons.person_add_rounded,
                        label: 'follow'.tr(),
                        color: ColorManager.primary,
                      ),
                    ],
                  ),
                ),
              ),
              // Chat input
              Container(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                color: ColorManager.darkSurface,
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: ColorManager.darkSectionGray,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: TextField(
                            controller: _chatController,
                            style: const TextStyle(
                              color: ColorManager.darkTextPrimary,
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              hintText: 'say_something'.tr(),
                              hintStyle: const TextStyle(
                                color: ColorManager.darkTextMuted,
                                fontSize: 14,
                              ),
                              contentPadding:
                                  const EdgeInsetsDirectional.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      GestureDetector(
                        onTap: _sendMessage,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: ColorManager.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.send_rounded,
                            color: ColorManager.darkTextPrimary,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVideoGrid(DiscoverStream? stream) {
    final players = stream?.players ?? [];

    if (players.length == 4) {
      return GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.zero,
        children: players
            .map((player) => StreamVideoSquare(player: player))
            .toList(),
      );
    }

    // Fallback: show static squares when player data is unavailable
    return GridView.count(
      crossAxisCount: 2,
      padding: EdgeInsets.zero,
      children: const [
        _FallbackVideoSquare(name: 'Player 1', team: 'A'),
        _FallbackVideoSquare(name: 'Player 2', team: 'B'),
        _FallbackVideoSquare(name: 'Player 3', team: 'B'),
        _FallbackVideoSquare(name: 'Player 4', team: 'A'),
      ],
    );
  }
}

/// Pulsing red LIVE badge.
class _PulsingLiveBadge extends StatefulWidget {
  @override
  State<_PulsingLiveBadge> createState() => _PulsingLiveBadgeState();
}

class _PulsingLiveBadgeState extends State<_PulsingLiveBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: ColorManager.live.withValues(alpha: _animation.value * 0.9),
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
        );
      },
    );
  }
}

class _FallbackVideoSquare extends StatelessWidget {
  const _FallbackVideoSquare({
    required this.name,
    required this.team,
  });

  final String name;
  final String team;

  @override
  Widget build(BuildContext context) {
    final teamColor = team == 'A'
        ? ColorManager.primary
        : ColorManager.secondary;
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: ColorManager.darkCanvas,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: teamColor.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.videocam_off_rounded,
                  size: 32,
                  color: ColorManager.darkTextMuted.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: const TextStyle(
                    color: ColorManager.darkTextMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          PositionedDirectional(
            bottom: 8,
            start: 8,
            child: Container(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: ColorManager.darkCanvas.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 11,
                  color: ColorManager.darkTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.8)),
          ),
        ],
      ),
    ),
  );
  }
}

