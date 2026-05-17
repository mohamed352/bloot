import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import 'package:bloot/core/style/colors.dart';

class WatchStreamPage extends StatefulWidget {
  const WatchStreamPage({super.key, required this.id});
  final String id;

  @override
  State<WatchStreamPage> createState() => _WatchStreamPageState();
}

class _WatchStreamPageState extends State<WatchStreamPage> {
  final TextEditingController _chatController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {'user': 'Viewer1', 'text': 'Great play!', 'isMe': false},
    {'user': 'Viewer2', 'text': 'Nice move Ahmed', 'isMe': false},
    {'user': 'You', 'text': 'Hello everyone', 'isMe': true},
    {'user': 'Viewer3', 'text': 'gg'.tr(), 'isMe': false},
  ];

  void _sendMessage() {
    if (_chatController.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'user': 'You',
        'text': _chatController.text.trim(),
        'isMe': true,
      });
    });
    _chatController.clear();
  }

  @override
  Widget build(BuildContext context) {
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
                  GridView.count(
                    crossAxisCount: 2,
                    padding: EdgeInsets.zero,
                    children: const [
                      _VideoSquare(name: 'Ahmed', isMuted: false, hasCamera: true, team: 'A'),
                      _VideoSquare(name: 'Khalid', isMuted: true, hasCamera: true, team: 'B'),
                      _VideoSquare(name: 'Faisal', isMuted: false, hasCamera: false, team: 'B'),
                      _VideoSquare(name: 'Omar', isMuted: false, hasCamera: true, team: 'A'),
                    ],
                  ),
                  // Top bar overlay
                  SafeArea(
                    child: Container(
                      padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.6),
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
                            onPressed: () => context.pop(),
                          ),
                          Container(
                            padding: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: ColorManager.live.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.circle, size: 6, color: ColorManager.darkTextPrimary),
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
                          const SizedBox(width: 10),
                          Icon(Icons.visibility_rounded, size: 14, color: ColorManager.darkTextPrimary.withValues(alpha: 0.7)),
                          const SizedBox(width: 4),
                          Text(
                            '1,240',
                            style: TextStyle(fontSize: 12, color: ColorManager.darkTextPrimary.withValues(alpha: 0.7)),
                          ),
                          const Spacer(),
                          Icon(Icons.more_vert_rounded, color: ColorManager.darkTextPrimary.withValues(alpha: 0.7)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Game table info
          Container(
            padding: const EdgeInsets.all(12),
            color: ColorManager.darkSurface,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: ColorManager.gameTableTop.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: ColorManager.gameTableBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.style_rounded,
                        size: 16,
                        color: ColorManager.success,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'us_52_them_48'.tr(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: ColorManager.success,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: ColorManager.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
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
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg['isMe'] as bool;
                return Align(
                  alignment: isMe ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isMe
                          ? ColorManager.primary.withValues(alpha: 0.2)
                          : ColorManager.darkSurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        if (!isMe)
                          Text(
                            msg['user'] as String,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: ColorManager.primary,
                            ),
                          ),
                        Text(
                          msg['text'] as String,
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
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8),
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
                  _ActionButton(icon: Icons.favorite_rounded, label: 'like'.tr(), color: ColorManager.error),
                  _ActionButton(icon: Icons.card_giftcard_rounded, label: 'gift'.tr(), color: ColorManager.secondary),
                  _ActionButton(icon: Icons.share_rounded, label: 'share'.tr(), color: ColorManager.info),
                  _ActionButton(icon: Icons.person_add_rounded, label: 'follow'.tr(), color: ColorManager.primary),
                ],
              ),
            ),
          ),
          // Chat input
          Container(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 8),
            color: ColorManager.darkSurface,
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: ColorManager.darkSectionGray,
                        borderRadius: BorderRadius.circular(999),
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
                          contentPadding: const EdgeInsetsDirectional.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
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
  }
}

class _VideoSquare extends StatelessWidget {
  const _VideoSquare({
    required this.name,
    required this.isMuted,
    required this.hasCamera,
    required this.team,
  });

  final String name;
  final bool isMuted;
  final bool hasCamera;
  final String team;

  @override
  Widget build(BuildContext context) {
    final teamColor = team == 'A' ? ColorManager.primary : ColorManager.secondary;
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: ColorManager.darkCanvas,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: teamColor.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          if (hasCamera)
            Center(
              child: CircleAvatar(
                radius: 32,
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/150?u=$name',
                ),
              ),
            )
          else
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
          // Mic indicator
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                size: 14,
                color: isMuted ? ColorManager.error : ColorManager.success,
              ),
            ),
          ),
          // Name label
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
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
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}