import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/components/app_button.dart';
import 'package:bloot/core/style/colors.dart';

class RoomLobbyPage extends StatefulWidget {
  const RoomLobbyPage({super.key, required this.id});
  final String id;

  @override
  State<RoomLobbyPage> createState() => _RoomLobbyPageState();
}

class _RoomLobbyPageState extends State<RoomLobbyPage> {
  bool _isReady = false;
  bool _chatOpen = false;
  final List<Map<String, dynamic>> _chatMessages = [
    {'user': 'Ahmed', 'text': 'welcome_everyone'.tr()},
    {'user': 'System', 'text': 'khalid_joined_the_room'.tr()},
  ];

  final List<Map<String, dynamic>> _seats = [
    {'name': 'Ahmed', 'avatar': 'https://i.pravatar.cc/150?img=11', 'ready': true, 'isMe': true, 'team': 'A', 'level': 12},
    {'name': 'Khalid', 'avatar': 'https://i.pravatar.cc/150?img=12', 'ready': true, 'isMe': false, 'team': 'A', 'level': 8},
    {'name': 'Faisal', 'avatar': 'https://i.pravatar.cc/150?img=33', 'ready': false, 'isMe': false, 'team': 'B', 'level': 15},
    {'name': null, 'avatar': null, 'ready': false, 'isMe': false, 'team': 'B', 'level': null},
  ];

  final List<String> _quickChatChips = [
    'ready'.tr(),
    'lets_go'.tr(),
    'need_1_more'.tr(),
  ];

  int get _readyCount => _seats.where((s) => s['ready'] == true).length;

  @override
  Widget build(BuildContext context) {
    final allReady = _readyCount == 4;

    return Scaffold(
      backgroundColor: ColorManager.darkCanvas,
      appBar: AppBar(
        title: Text('room_lobby'.tr()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Room code with Share button
                  Container(
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 12),
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
                        const SizedBox(width: 12),
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
                          onTap: () {},
                        ),
                        const SizedBox(width: 8),
                        _IconButton(
                          icon: Icons.share_rounded,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 24),
                  // Diamond seat layout
                  // Partner at top
                  _SeatWidget(
                    seat: _seats[1],
                    label: 'your_partner'.tr(),
                    position: SeatPosition.top,
                  ),
                  const SizedBox(height: 16),
                  // VS indicator
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: ColorManager.secondary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ColorManager.secondary.withValues(alpha: 0.3),
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
                  const SizedBox(height: 16),
                  // Opponents left and right
                  Row(
                    children: [
                      Expanded(
                        child: _SeatWidget(
                          seat: _seats[2],
                          label: 'opponent_1'.tr(),
                          position: SeatPosition.left,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _SeatWidget(
                          seat: _seats[3],
                          label: 'opponent_2'.tr(),
                          position: SeatPosition.right,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // You at bottom
                  _SeatWidget(
                    seat: _seats[0],
                    label: 'you'.tr(),
                    position: SeatPosition.bottom,
                  ),
                  const SizedBox(height: 24),
                  // Room Settings section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ColorManager.darkSurface,
                      borderRadius: BorderRadius.circular(16),
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
                        const SizedBox(height: 12),
                        _buildSettingRow(Icons.mic_rounded, 'voice_chat'.tr(), 'on'.tr()),
                        const Divider(color: ColorManager.darkBorderSoft, height: 16),
                        _buildSettingRow(Icons.videocam_rounded, 'camera'.tr(), 'off'.tr()),
                        const Divider(color: ColorManager.darkBorderSoft, height: 16),
                        _buildSettingRow(Icons.visibility_rounded, 'spectators'.tr(), 'allowed'.tr()),
                        const Divider(color: ColorManager.darkBorderSoft, height: 16),
                        _buildSettingRow(Icons.meeting_room_rounded, 'room_type'.tr(), 'private'.tr()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Quick chat chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: _quickChatChips.map((chip) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _chatMessages.add({'user': 'Ahmed', 'text': chip});
                          });
                        },
                        child: Container(
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: ColorManager.darkSectionGray,
                            borderRadius: BorderRadius.circular(999),
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
                  const SizedBox(height: 24),
                  // Ready indicator
                  Text(
                    "$_readyCount/4 ${'ready'.tr()}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: ColorManager.darkTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: _isReady ? 'not_ready'.tr() : 'i_am_ready'.tr(),
                          isOutlined: _isReady,
                          onPressed: () => setState(() => _isReady = !_isReady),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          text: 'start_game'.tr(),
                          onPressed: allReady
                              ? () => context.pushNamed(
                                    RouteNames.gamePlay,
                                    pathParameters: {'id': widget.id},
                                  )
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Chat toggle
                  TextButton.icon(
                    onPressed: () => setState(() => _chatOpen = !_chatOpen),
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                    label: Text(_chatOpen ? 'hide_chat'.tr() : 'open_chat'.tr()),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          // Chat drawer
          if (_chatOpen)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 280,
                decoration: BoxDecoration(
                  color: ColorManager.darkSurface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: ColorManager.darkBorderSoft,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _chatMessages.length,
                        itemBuilder: (context, index) {
                          final msg = _chatMessages[index];
                          final isSystem = msg['user'] == 'System';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: isSystem
                                ? Center(
                                    child: Text(
                                      msg['text'] as String,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: ColorManager.darkTextMuted,
                                      ),
                                    ),
                                  )
                                : Text.rich(
                                    TextSpan(
                                      text: '${msg['user']}: ',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: ColorManager.primary,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: msg['text'] as String,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w400,
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
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: ColorManager.darkSectionGray,
                                borderRadius: BorderRadius.circular(999),
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
                                  contentPadding: const EdgeInsetsDirectional.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {},
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
        ],
      ),
    );
  }

  Widget _buildSettingRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: ColorManager.primary),
        const SizedBox(width: 12),
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

enum SeatPosition { top, left, right, bottom }

class _SeatWidget extends StatelessWidget {
  const _SeatWidget({
    required this.seat,
    required this.label,
    required this.position,
  });

  final Map<String, dynamic> seat;
  final String label;
  final SeatPosition position;

  @override
  Widget build(BuildContext context) {
    final isEmpty = seat['name'] == null;
    final teamColor = seat['team'] == 'A' ? ColorManager.primary : ColorManager.secondary;
    final isReady = seat['ready'] == true;
    final isMe = seat['isMe'] == true;
    final level = seat['level'] as int?;

    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: ColorManager.darkSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isEmpty
              ? ColorManager.darkBorderSoft
              : teamColor.withValues(alpha: isReady ? 0.6 : 0.3),
          width: isReady ? 2.5 : 1.5,
          style: isEmpty ? BorderStyle.solid : BorderStyle.solid,
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
                    border: Border.all(
                      color: ColorManager.darkBorderSoft,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: ColorManager.darkTextMuted,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$label ${'empty'.tr()}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: ColorManager.darkTextMuted,
                  ),
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'invite'.tr(),
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
                          color: isActive(position, isMe)
                              ? teamColor
                              : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: isActive(position, isMe)
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
                        radius: 32,
                        backgroundImage: NetworkImage(seat['avatar'] as String),
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
                            color: ColorManager.secondary,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Lvl $level',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  seat['name'] as String,
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
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isReady
                            ? ColorManager.success.withValues(alpha: 0.15)
                            : ColorManager.darkSectionGray,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        isReady ? 'ready'.tr() : 'not_ready'.tr(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isReady ? ColorManager.success : ColorManager.darkTextMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  bool isActive(SeatPosition position, bool isMe) {
    // For demo, bottom (you) is active
    return position == SeatPosition.bottom && isMe;
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
        child: Icon(
          icon,
          size: 18,
          color: ColorManager.darkTextSecondary,
        ),
      ),
    );
  }
}
