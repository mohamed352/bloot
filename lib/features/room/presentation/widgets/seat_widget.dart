import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import 'package:bloot/core/components/cached_avatar.dart';
import 'package:bloot/core/constants/app_radius.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/extension/context_values.dart';
import 'package:bloot/core/services/agora_service.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/features/room/domain/entities/room.dart';
import 'package:bloot/generated/locale_keys.g.dart';

/// Position of a player seat in the room lobby layout.
enum SeatPosition { top, left, right, bottom }

/// Visual representation of a player seat in the room lobby.
///
/// Shows either the player's Agora video feed (when camera is on) or their
/// avatar. Displays name, ready status, team color, mic/camera indicators,
/// and a speaking glow effect.
class SeatWidget extends StatefulWidget {
  const SeatWidget({
    super.key,
    required this.player,
    required this.label,
    required this.position,
    this.isCreator = false,
    this.inviteCode,
    this.onKick,
  });

  final RoomPlayer? player;
  final String label;
  final SeatPosition position;
  final bool isCreator;
  final String? inviteCode;
  final ValueChanged<String>? onKick;

  @override
  State<SeatWidget> createState() => _SeatWidgetState();
}

class _SeatWidgetState extends State<SeatWidget> {
  late final AgoraService _agoraService;

  @override
  void initState() {
    super.initState();
    _agoraService = context.read<AgoraService>();
    _subscribeToVideo();
  }

  @override
  void didUpdateWidget(covariant SeatWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-subscribe if player changed from null to non-null with camera on
    final oldCameraOn = oldWidget.player?.isCameraOn ?? false;
    final newCameraOn = widget.player?.isCameraOn ?? false;
    if (!oldCameraOn && newCameraOn) {
      _subscribeToVideo();
    } else if (oldCameraOn && !newCameraOn) {
      _unsubscribeFromVideo();
    }
  }

  @override
  void dispose() {
    _unsubscribeFromVideo();
    super.dispose();
  }

  void _subscribeToVideo() {
    if (widget.player == null) return;
    if (!widget.player!.isCameraOn) return;
    if (!widget.player!.isMe) {
      _agoraService.subscribeToRemoteVideo();
    }
  }

  void _unsubscribeFromVideo() {
    if (widget.player == null) return;
    if (!widget.player!.isMe) {
      _agoraService.unsubscribeFromRemoteVideo().ignore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final player = widget.player;
    final isEmpty = player == null;
    final teamColor = player?.team == 'A' ? colors.primary : colors.secondary;
    final isReady = player?.isReady ?? false;
    final isMe = player?.isMe ?? false;
    final level = player?.level;
    final isSpeaking = player?.isSpeaking ?? false;
    final isCameraOn = player?.isCameraOn ?? false;
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: isEmpty
              ? colors.border
              : isSpeaking
                  ? ColorManager.success.withValues(alpha: 0.8)
                  : teamColor.withValues(alpha: isReady ? 0.6 : 0.3),
          width: isSpeaking ? 3 : (isReady ? 2.5 : 1.5),
        ),
        boxShadow: isSpeaking
            ? [
                BoxShadow(
                  color: ColorManager.success.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.border, width: 2),
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    color: colors.textMuted,
                    size: 28,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${widget.label} ${LocaleKeys.empty.tr()}',
                  style: TextStyle(fontSize: 13, color: colors.textMuted),
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () {
                    if (widget.inviteCode != null) {
                      Share.share(
                        LocaleKeys.shareRoomMessage.tr(
                          namedArgs: {'code': widget.inviteCode!},
                        ),
                      );
                    }
                  },
                  child: Text(
                    LocaleKeys.invite.tr(),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: AlignmentDirectional.bottomEnd,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isActive(widget.position, isMe)
                              ? teamColor
                              : const Color(0x00000000),
                          width: 2,
                        ),
                        boxShadow: _isActive(widget.position, isMe)
                            ? [
                                BoxShadow(
                                  color: teamColor.withValues(alpha: 0.4),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: isCameraOn
                          ? _buildVideoView(player)
                          : CachedAvatar(
                              imageUrl: player.avatarUrl,
                              size: 80,
                              borderRadius: 40,
                            ),
                    ),
                    if (isReady)
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: ColorManager.success,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: ColorManager.darkTextPrimary,
                        ),
                      ),
                    if (level != null)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colors.secondary,
                            borderRadius:
                                BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            'Lvl $level',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: ColorManager.darkTextPrimary,
                            ),
                          ),
                        ),
                      ),
                    if (widget.isCreator && !isMe)
                      PositionedDirectional(
                        top: 0,
                        end: 0,
                        child: GestureDetector(
                          onTap: () => _showKickDialog(context, player),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: ColorManager.error,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  player.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: ColorManager.darkTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      player.isMicOn
                          ? Icons.mic_rounded
                          : Icons.mic_off_rounded,
                      size: 14,
                      color: player.isMicOn
                          ? ColorManager.success
                          : ColorManager.error,
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      player.isCameraOn
                          ? Icons.videocam_rounded
                          : Icons.videocam_off_rounded,
                      size: 14,
                      color: player.isCameraOn
                          ? ColorManager.success
                          : ColorManager.darkTextMuted.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isReady
                            ? ColorManager.success.withValues(alpha: 0.15)
                            : ColorManager.darkSectionGray,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        isReady
                            ? LocaleKeys.ready.tr()
                            : LocaleKeys.not_ready.tr(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isReady
                              ? ColorManager.success
                              : ColorManager.darkTextMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  void _showKickDialog(BuildContext context, RoomPlayer player) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorManager.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'kick_player'.tr(),
          style: const TextStyle(color: ColorManager.darkTextPrimary),
        ),
        content: Text(
          'kick_confirm'.tr(namedArgs: {'name': player.name}),
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
              widget.onKick?.call(player.uid);
            },
            child: Text(
              'kick_player'.tr(),
              style: const TextStyle(color: ColorManager.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoView(RoomPlayer player) {
    if (player.isMe) {
      return _agoraService.getLocalVideoView();
    }
    if (player.agoraUid == null) {
      return CachedAvatar(
        imageUrl: player.avatarUrl,
        size: 80,
        borderRadius: 40,
      );
    }
    return _agoraService.getRemoteVideoView(player.agoraUid!);
  }

  bool _isActive(SeatPosition position, bool isMe) {
    return position == SeatPosition.bottom && isMe;
  }
}
