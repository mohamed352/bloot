import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/components/app_button.dart';
import 'package:bloot/core/constants/app_radius.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/generated/locale_keys.g.dart';
import 'package:bloot/features/room/presentation/cubit/room_cubit.dart';
import 'package:bloot/features/room/presentation/cubit/room_state.dart';
import 'package:bloot/features/room/presentation/widgets/room_settings_bottom_sheet.dart';
import 'package:bloot/features/room/presentation/widgets/seat_widget.dart';

class RoomLobbyPage extends StatelessWidget {
  const RoomLobbyPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RoomCubit, RoomState>(
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
        final room = state is RoomLoaded ? state.room : null;
        final chatOpen = state is RoomLoaded && state.chatOpen;
        final players = room?.players ?? [];
        final chatMessages = room?.chatMessages ?? [];
        final readyCount = players.where((p) => p.isReady).length;
        final allReady = readyCount == 4;
        final isReady = room?.players.any((p) => p.isMe && p.isReady) ?? false;
        final quickChatChips = [
          'ready'.tr(),
          'lets_go'.tr(),
          'need_1_more'.tr(),
        ];

        return Scaffold(
          backgroundColor: ColorManager.darkCanvas,
          appBar: AppBar(
            title: Text('room_lobby'.tr()),
            backgroundColor: const Color(0x00000000),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.share_rounded),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Room code copied')),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings_rounded),
                onPressed: () {
                  showModalBottomSheet<void>(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (context) => const RoomSettingsBottomSheet(),
                  );
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: Column(
                    children: [
                      // Room code with Share button
                      Container(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: ColorManager.darkSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: ColorManager.darkBorderSoft,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.meeting_room_rounded,
                              color: ColorManager.primary,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'room_code'.tr(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: ColorManager.darkTextSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'BLO-8472',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: ColorManager.darkTextPrimary,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            _IconButton(
                              icon: Icons.copy_rounded,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Room code copied'),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            _IconButton(
                              icon: Icons.share_rounded,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Room code copied'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Waiting for players status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.hourglass_empty_rounded,
                            size: 16,
                            color: ColorManager.darkTextMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'waiting_for_players'.tr(),
                            style: const TextStyle(
                              fontSize: 13,
                              color: ColorManager.darkTextMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      // Diamond seat layout
                      // Partner at top
                      SeatWidget(
                        player: players.length > 1 ? players[1] : null,
                        label: LocaleKeys.your_partner.tr(),
                        position: SeatPosition.top,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      // VS indicator
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: ColorManager.secondary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: ColorManager.secondary.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'vs'.tr(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: ColorManager.secondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      // Opponents left and right
                      Row(
                        children: [
                          Expanded(
                            child: SeatWidget(
                              player: players.length > 2 ? players[2] : null,
                              label: LocaleKeys.opponent_1.tr(),
                              position: SeatPosition.left,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: SeatWidget(
                              player: players.length > 3 ? players[3] : null,
                              label: LocaleKeys.opponent_2.tr(),
                              position: SeatPosition.right,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      // You at bottom
                      SeatWidget(
                        player: players.isNotEmpty ? players[0] : null,
                        label: LocaleKeys.you.tr(),
                        position: SeatPosition.bottom,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      // Room Settings section
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: ColorManager.darkSurface,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(
                            color: ColorManager.darkBorderSoft,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'room_settings'.tr(),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: ColorManager.darkTextPrimary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _buildSettingRow(
                              Icons.mic_rounded,
                              'voice_chat'.tr(),
                              LocaleKeys.labelOn.tr(),
                            ),
                            const Divider(
                              color: ColorManager.darkBorderSoft,
                              height: 16,
                            ),
                            _buildSettingRow(
                              Icons.videocam_rounded,
                              'camera'.tr(),
                              'off'.tr(),
                            ),
                            const Divider(
                              color: ColorManager.darkBorderSoft,
                              height: 16,
                            ),
                            _buildSettingRow(
                              Icons.visibility_rounded,
                              'spectators'.tr(),
                              'allowed'.tr(),
                            ),
                            const Divider(
                              color: ColorManager.darkBorderSoft,
                              height: 16,
                            ),
                            _buildSettingRow(
                              Icons.meeting_room_rounded,
                              'room_type'.tr(),
                              'private'.tr(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      // Quick chat chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: quickChatChips.map((chip) {
                          return GestureDetector(
                            onTap: () {
                              if (room != null) {
                                context.read<RoomCubit>().sendChatMessage(
                                  room.id,
                                  chip,
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsetsDirectional.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: ColorManager.darkSectionGray,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.full,
                                ),
                                border: Border.all(
                                  color: ColorManager.darkBorderSoft,
                                ),
                              ),
                              child: Text(
                                chip,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: ColorManager.darkTextSecondary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      // Ready indicator
                      Text(
                        '$readyCount/4 ${'ready'.tr()}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: ColorManager.darkTextSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              text: isReady
                                  ? 'not_ready'.tr()
                                  : 'i_am_ready'.tr(),
                              isOutlined: isReady,
                              onPressed: room != null
                                  ? () => context.read<RoomCubit>().toggleReady(
                                      room.id,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: AppButton(
                              text: 'start_game'.tr(),
                              onPressed: allReady
                                  ? () => context.pushNamed(
                                      RouteNames.gamePlay,
                                      pathParameters: {'id': id},
                                    )
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Chat toggle
                      TextButton.icon(
                        onPressed: () => context.read<RoomCubit>().toggleChat(),
                        icon: const Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 18,
                        ),
                        label: Text(
                          chatOpen ? 'hide_chat'.tr() : 'open_chat'.tr(),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ),
                ),
              ),
              // Chat drawer
              if (chatOpen)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    top: false,
                    child: Container(
                      height: 280,
                      decoration: BoxDecoration(
                        color: ColorManager.darkSurface,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: ColorManager.darkCanvas.withValues(
                              alpha: 0.4,
                            ),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: AppSpacing.sm),
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: ColorManager.darkBorderSoft,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              itemCount: chatMessages.length,
                              itemBuilder: (context, index) {
                                final msg = chatMessages[index];
                                final isSystem = msg.user == 'System';
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: isSystem
                                      ? Center(
                                          child: Text(
                                            msg.text,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: ColorManager.darkTextMuted,
                                            ),
                                          ),
                                        )
                                      : Text.rich(
                                          TextSpan(
                                            text: '${msg.user}: ',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: ColorManager.primary,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: msg.text,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  color: ColorManager
                                                      .darkTextPrimary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: ColorManager.darkSectionGray,
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.full,
                                      ),
                                    ),
                                    child: TextField(
                                      style: const TextStyle(
                                        color: ColorManager.darkTextPrimary,
                                        fontSize: 14,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'message'.tr(),
                                        hintStyle: const TextStyle(
                                          color: ColorManager.darkTextMuted,
                                        ),
                                        contentPadding:
                                            const EdgeInsetsDirectional.symmetric(
                                              horizontal: 16,
                                              vertical: 10,
                                            ),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                GestureDetector(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Message sent'),
                                      ),
                                    );
                                  },
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
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: ColorManager.primary),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: ColorManager.darkTextPrimary,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ColorManager.primary,
          ),
        ),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: ColorManager.darkSectionGray,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: ColorManager.darkTextSecondary),
      ),
    );
  }
}
