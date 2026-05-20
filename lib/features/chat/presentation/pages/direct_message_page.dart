import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:bloot/core/components/cached_avatar.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/constants/app_radius.dart';
import 'package:bloot/features/chat/domain/entities/chat.dart';
import 'package:bloot/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:bloot/features/chat/presentation/cubit/chat_state.dart';

class DirectMessagePage extends StatefulWidget {
  const DirectMessagePage({super.key, required this.userId});
  final String userId;

  @override
  State<DirectMessagePage> createState() => _DirectMessagePageState();
}

class _DirectMessagePageState extends State<DirectMessagePage> {
  final TextEditingController _controller = TextEditingController();

  final List<String> _quickActions = [
    'good_game'.tr(),
    'nice_move'.tr(),
    'gg'.tr(),
    'ready'.tr(),
  ];

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<ChatCubit>().sendMessage(widget.userId, text);
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatCubit, ChatState>(
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
        final messages = state is ChatMessagesLoaded
            ? state.messages
            : <ChatMessage>[];

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
                const CachedAvatar(
                  imageUrl: 'https://i.pravatar.cc/150?img=12',
                  size: 36,
                  borderRadius: 18,
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
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: messages.length + 1,
                  itemBuilder: (context, index) {
                    if (index == messages.length) {
                      return Center(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: ColorManager.darkSectionGray,
                            borderRadius: BorderRadius.circular(AppRadius.full),
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

                    final msg = messages[messages.length - 1 - index];
                    final isImage = msg.type == 'image';

                    return Align(
                      alignment: msg.isMe
                          ? AlignmentDirectional.centerEnd
                          : AlignmentDirectional.centerStart,
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
                          color: msg.isMe
                              ? ColorManager.primary.withValues(alpha: 0.2)
                              : ColorManager.darkSurface,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(msg.isMe ? 16 : 4),
                            bottomRight: Radius.circular(msg.isMe ? 4 : 16),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: msg.isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            if (isImage && msg.imageUrl != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                                child: Image.network(
                                  msg.imageUrl!,
                                  width: 200,
                                  height: 150,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
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
                                msg.text,
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
                                  msg.time,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: ColorManager.darkTextMuted,
                                  ),
                                ),
                                if (msg.isMe) ...[
                                  const SizedBox(width: 4),
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
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                color: ColorManager.darkSurface,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _quickActions.map((action) {
                      return GestureDetector(
                        onTap: () => context.read<ChatCubit>().sendMessage(
                          widget.userId,
                          action,
                        ),
                        child: Container(
                          margin: const EdgeInsetsDirectional.only(end: 8),
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: ColorManager.darkSectionGray,
                            borderRadius: BorderRadius.circular(AppRadius.full),
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
              // Input
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
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
                            borderRadius: BorderRadius.circular(AppRadius.full),
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
}
