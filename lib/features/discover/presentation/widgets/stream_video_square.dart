import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bloot/core/components/cached_avatar.dart';
import 'package:bloot/core/constants/app_radius.dart';
import 'package:bloot/core/services/agora_service.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/features/discover/domain/entities/discover_stream.dart';

/// Video square for stream spectators.
///
/// Renders a remote Agora video feed for a stream player, with their
/// avatar as fallback when camera is off.
class StreamVideoSquare extends StatefulWidget {
  const StreamVideoSquare({super.key, required this.player});

  final StreamPlayer player;

  @override
  State<StreamVideoSquare> createState() => _StreamVideoSquareState();
}

class _StreamVideoSquareState extends State<StreamVideoSquare> {
  late final AgoraService _agoraService;

  @override
  void initState() {
    super.initState();
    _agoraService = context.read<AgoraService>();
  }

  @override
  Widget build(BuildContext context) {
    final teamColor = widget.player.team == 'A'
        ? ColorManager.primary
        : ColorManager.secondary;

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: ColorManager.darkCanvas,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: teamColor.withValues(alpha: 0.5), width: 2),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video feed or avatar fallback
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md - 2),
            child: widget.player.isCameraOn
                ? _agoraService.getRemoteVideoView(widget.player.agoraUid)
                : Center(
                    child: CachedAvatar(
                      imageUrl: widget.player.avatarUrl ?? '',
                      size: 64,
                      borderRadius: 32,
                    ),
                  ),
          ),

          // Mic indicator
          PositionedDirectional(
            top: 8,
            end: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: ColorManager.darkCanvas.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                widget.player.isMicOn
                    ? Icons.mic_rounded
                    : Icons.mic_off_rounded,
                size: 14,
                color: widget.player.isMicOn
                    ? ColorManager.success
                    : ColorManager.error,
              ),
            ),
          ),

          // Name label
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
                widget.player.name,
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
