import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/style/colors.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  int _selectedFilter = 0;
  final _filters = ['all'.tr(), 'rooms'.tr(), 'direct'.tr(), 'tournaments'.tr()];

  final List<Map<String, dynamic>> _chats = [
    {
      'name': 'Khalid Al-Rashid',
      'avatar': 'https://i.pravatar.cc/150?img=12',
      'message': 'good_game_yesterday'.tr(),
      'time': '2m',
      'unread': 2,
      'type': 'direct'.tr(),
    },
    {
      'name': 'Room: Weekend Bash',
      'avatar': null,
      'message': 'ahmed_im_ready_when_you_are'.tr(),
      'time': '15m',
      'unread': 0,
      'type': 'rooms'.tr(),
    },
    {
      'name': 'Faisal Band',
      'avatar': 'https://i.pravatar.cc/150?img=33',
      'message': 'lets_play_again_tonight'.tr(),
      'time': '1h',
      'unread': 1,
      'type': 'direct'.tr(),
    },
    {
      'name': 'Tournament: Gulf Cup',
      'avatar': null,
      'message': 'registration_closes_in_2_hours'.tr(),
      'time': '3h',
      'unread': 0,
      'type': 'tournaments'.tr(),
    },
    {
      'name': 'Omar Hassan',
      'avatar': 'https://i.pravatar.cc/150?img=44',
      'message': 'sent_a_room_invitation'.tr(),
      'time': '1d',
      'unread': 0,
      'type': 'direct'.tr(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.darkCanvas,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'messages'.tr(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: ColorManager.darkTextPrimary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: ColorManager.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.edit_rounded,
                        color: ColorManager.primary,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
            // Filters
            SizedBox(
              height: 40,
              child: ListView.separated(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final isSelected = index == _selectedFilter;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = index),
                    child: Container(
                      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? ColorManager.primary
                            : ColorManager.darkSurface,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isSelected
                              ? ColorManager.primary
                              : ColorManager.darkBorderSoft,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _filters[index],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? ColorManager.darkTextPrimary
                              : ColorManager.darkTextSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            // Chat list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
                itemCount: _chats.length,
                itemBuilder: (context, index) {
                  final chat = _chats[index];
                  return _ChatListItem(
                    chat: chat,
                    onTap: () => context.pushNamed(
                      RouteNames.directMessage,
                      pathParameters: {'userId': 'user_$index'},
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatListItem extends StatelessWidget {
  const _ChatListItem({required this.chat, required this.onTap});

  final Map<String, dynamic> chat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unread = chat['unread'] as int;
    final hasAvatar = chat['avatar'] != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ColorManager.darkSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ColorManager.darkBorderSoft,
          ),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: ColorManager.darkSectionGray,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ColorManager.darkBorderSoft,
                    ),
                  ),
                  child: hasAvatar
                      ? ClipOval(
                          child: Image.network(
                            chat['avatar'] as String,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          chat['type'] == 'rooms'.tr()
                              ? Icons.meeting_room_rounded
                              : Icons.emoji_events_rounded,
                          color: ColorManager.primary,
                        ),
                ),
                if (unread > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: ColorManager.error,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$unread',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: ColorManager.darkTextPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat['name'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.w500,
                            color: ColorManager.darkTextPrimary,
                          ),
                        ),
                      ),
                      Text(
                        chat['time'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: ColorManager.darkTextMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chat['message'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: unread > 0
                          ? ColorManager.darkTextSecondary
                          : ColorManager.darkTextMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
