import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:bloot/core/components/cached_avatar.dart';
import 'package:bloot/core/constants/app_radius.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/extension/context_values.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/features/room/domain/entities/room.dart';
import 'package:bloot/generated/locale_keys.g.dart';

/// Position of a player seat in the room lobby layout.
enum SeatPosition { top, left, right, bottom }

/// Visual representation of a player seat in the room lobby.
///
/// Shows avatar, name, ready status, and team color. Empty seats show
/// an invite placeholder.
class SeatWidget extends StatelessWidget {
  const SeatWidget({
    super.key,
    required this.player,
    required this.label,
    required this.position,
  });

  final RoomPlayer? player;
  final String label;
  final SeatPosition position;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isEmpty = player == null;
    final teamColor = player?.team == 'A' ? colors.primary : colors.secondary;
    final isReady = player?.isReady ?? false;
    final isMe = player?.isMe ?? false;
    final level = player?.level;

    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: isEmpty
              ? colors.border
              : teamColor.withValues(alpha: isReady ? 0.6 : 0.3),
          width: isReady ? 2.5 : 1.5,
        ),
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
                  '$label ${LocaleKeys.empty.tr()}',
                  style: TextStyle(fontSize: 13, color: colors.textMuted),
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invite sent')),
                    );
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
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isActive(position, isMe)
                              ? teamColor
                              : const Color(0x00000000),
                          width: 2,
                        ),
                        boxShadow: _isActive(position, isMe)
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
                        imageUrl: player!.avatarUrl,
                        size: 64,
                        borderRadius: 32,
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
                            borderRadius: BorderRadius.circular(AppRadius.full),
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
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  player!.name,
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
                    const Icon(
                      Icons.mic_rounded,
                      size: 14,
                      color: ColorManager.success,
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.videocam_off_rounded,
                      size: 14,
                      color: ColorManager.darkTextMuted.withValues(alpha: 0.5),
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

  bool _isActive(SeatPosition position, bool isMe) {
    // Bottom seat (you) is visually active.
    return position == SeatPosition.bottom && isMe;
  }
}
