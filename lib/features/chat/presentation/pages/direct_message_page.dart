import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import 'package:bloot/core/style/colors.dart';

class DirectMessagePage extends StatefulWidget {
  const DirectMessagePage({super.key, required this.userId});
  final String userId;

  @override
  State<DirectMessagePage> createState() => _DirectMessagePageState();
}

class _DirectMessagePageState extends State<DirectMessagePage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {'text': 'hey_want_to_play_tonight'.tr(), 'isMe': false, 'time': '10:30 AM', 'type': 'text'},
    {'text': 'sure_what_time'.tr(), 'isMe': true, 'time': '10:32 AM', 'type': 'text'},
    {'text': 'around_8_pm'.tr(), 'isMe': false, 'time': '10:33 AM', 'type': 'text'},
    {'text': 'perfect_ill_create_a_room'.tr(), 'isMe': true, 'time': '10:35 AM', 'type': 'text'},
    {'text': 'good_game_yesterday'.tr(), 'isMe': false, 'time': '9:00 AM', 'type': 'text'},
    // Image message placeholder
    {'text': '', 'isMe': true, 'time': '10:36 AM', 'type': 'image', 'imageUrl': 'https://images.unsplash.com/photo-1541963463532-d68292c34b19?w=400&q=80'},
  ];

  final List<String> _quickActions = [
    'good_game'.tr(),
    'nice_move'.tr(),
    'gg'.tr(),
    'ready'.tr(),
  ];

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'text': _controller.text.trim(),
        'isMe': true,
        'time': 'now'.tr(),
        'type': 'text',
      });
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.darkCanvas,
      appBar: AppBar(
        backgroundColor: ColorManager.darkSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Khalid Al-Rashid',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: ColorManager.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'online'.tr(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: ColorManager.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.videocam_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + 1, // +1 for "Today" separator
              itemBuilder: (context, index) {
                // Today separator at the bottom (since reversed)
                if (index == _messages.length) {
                  return Center(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: ColorManager.darkSectionGray,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'today'.tr(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: ColorManager.darkTextMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }

                final msg = _messages[_messages.length - 1 - index];
                final isMe = msg['isMe'] as bool;
                final isImage = msg['type'] == 'image';

                return Align(
                  alignment: isMe ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: isImage
                        ? const EdgeInsets.all(4)
                        : const EdgeInsetsDirectional.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isMe
                          ? ColorManager.primary.withValues(alpha: 0.2)
                          : ColorManager.darkSurface,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isMe ? 16 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        if (isImage && msg['imageUrl'] != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              msg['imageUrl'] as String,
                              width: 200,
                              height: 150,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  width: 200,
                                  height: 150,
                                  color: ColorManager.darkSectionGray,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 200,
                                  height: 150,
                                  color: ColorManager.darkSectionGray,
                                  child: const Icon(
                                    Icons.image_not_supported_rounded,
                                    color: ColorManager.darkTextMuted,
                                  ),
                                );
                              },
                            ),
                          )
                        else
                          Text(
                            msg['text'] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              color: ColorManager.darkTextPrimary,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              msg['time'] as String,
                              style: const TextStyle(
                                fontSize: 10,
                                color: ColorManager.darkTextMuted,
                              ),
                            ),
                            if (isMe) ...[
                              const SizedBox(width: 4),
                              // Read receipts: double checkmarks
                              const Icon(
                                Icons.done_all_rounded,
                                size: 14,
                                color: ColorManager.info,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Quick actions
          Container(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 8),
            color: ColorManager.darkSurface,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _quickActions.map((action) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _messages.add({
                          'text': action,
                          'isMe': true,
                          'time': 'now'.tr(),
                          'type': 'text',
                        });
                      });
                    },
                    child: Container(
                      margin: const EdgeInsetsDirectional.only(end: 8),
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
                        action,
                        style: const TextStyle(
                          fontSize: 12,
                          color: ColorManager.darkTextSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Input with image icon + emoji icon + text field + send button
          Container(
            padding: const EdgeInsets.all(12),
            color: ColorManager.darkSurface,
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.image_rounded,
                      color: ColorManager.darkTextMuted,
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.emoji_emotions_outlined,
                      color: ColorManager.darkTextMuted,
                    ),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: ColorManager.darkSectionGray,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(
                          color: ColorManager.darkTextPrimary,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'type_a_message'.tr(),
                          hintStyle: const TextStyle(
                            color: ColorManager.darkTextMuted,
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
