import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import 'package:bloot/core/components/cached_avatar.dart';
import 'package:bloot/core/di/injection.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/core/utils/riyadh_time.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/constants/app_radius.dart';
import 'package:bloot/features/chat/domain/entities/chat.dart';
import 'package:bloot/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:bloot/features/chat/presentation/cubit/chat_state.dart';
import 'package:bloot/features/moderation/domain/repositories/moderation_repository.dart';
import 'package:bloot/features/moderation/presentation/widgets/block_user_dialog.dart';
import 'package:bloot/features/moderation/presentation/widgets/report_user_sheet.dart';

class DirectMessagePage extends StatefulWidget {
  const DirectMessagePage({
    super.key,
    required this.conversationId,
    this.conversation,
  });

  final String conversationId;
  final ChatConversation? conversation;

  @override
  State<DirectMessagePage> createState() => _DirectMessagePageState();
}

class _DirectMessagePageState extends State<DirectMessagePage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  late final Stream<Set<String>> _blockedUserIdsStream;

  String? get _currentUid =>
      getIt<firebase_auth.FirebaseAuth>().currentUser?.uid;

  /// Direct conversation IDs are `dm_<uidA>_<uidB>` (sorted); the other
  /// participant is the ID that is not the current user.
  String? get _otherUserId {
    final currentUid = _currentUid;
    final id = widget.conversationId;
    if (currentUid == null || !id.startsWith('dm_')) return null;
    final parts = id.substring(3).split('_');
    for (final part in parts) {
      if (part.isNotEmpty && part != currentUid) return part;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _blockedUserIdsStream = getIt<ModerationRepository>().watchBlockedUserIds();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _inputFocusNode.unfocus();
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<ChatCubit>().sendMessage(widget.conversationId, text);
    _controller.clear();
  }

  Future<void> _onMenuSelected(
    BuildContext context,
    String value,
    bool isBlocked,
  ) async {
    final otherUserId = _otherUserId;
    if (otherUserId == null) return;

    if (value == 'report') {
      await showReportUserSheet(
        context,
        targetUid: otherUserId,
        targetType: 'user',
      );
    } else if (value == 'block') {
      await showBlockUserDialog(
        context,
        targetUid: otherUserId,
        displayName: widget.conversation?.name ?? 'User',
      );
    } else if (value == 'unblock') {
      final messenger = ScaffoldMessenger.of(context);
      try {
        await getIt<ModerationRepository>().unblockUser(otherUserId);
        messenger.showSnackBar(SnackBar(content: Text('user_unblocked'.tr())));
      } catch (_) {
        messenger.showSnackBar(SnackBar(content: Text('block_failed'.tr())));
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _inputFocusNode.dispose();
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
        final conversation = widget.conversation;

        return StreamBuilder<Set<String>>(
          stream: _blockedUserIdsStream,
          builder: (context, blockedSnapshot) {
            final otherUserId = _otherUserId;
            final isBlocked =
                otherUserId != null &&
                (blockedSnapshot.data?.contains(otherUserId) ?? false);
            final allMessages = state is ChatMessagesLoaded
                ? state.messages
                : <ChatMessage>[];
            // Hide the blocked user's messages (in a DM every non-me
            // message comes from the other participant).
            final messages = isBlocked
                ? allMessages.where((m) => m.isMe).toList()
                : allMessages;

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
                    CachedAvatar(
                      imageUrl: conversation?.avatarUrl,
                      size: 36,
                      borderRadius: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            conversation?.name ?? '',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (otherUserId != null)
                            _OnlineStatus(userId: otherUserId),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  if (otherUserId != null)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded),
                      color: ColorManager.darkSurface,
                      onSelected: (value) =>
                          _onMenuSelected(context, value, isBlocked),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'report',
                          child: Text('report_user'.tr()),
                        ),
                        PopupMenuItem(
                          value: isBlocked ? 'unblock' : 'block',
                          child: Text(
                            isBlocked ? 'unblock'.tr() : 'block_user'.tr(),
                          ),
                        ),
                      ],
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
                                borderRadius: BorderRadius.circular(
                                  AppRadius.full,
                                ),
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

                        final msg = messages[index];
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
                                              color:
                                                  ColorManager.darkSectionGray,
                                              child: const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              ),
                                            );
                                          },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              width: 200,
                                              height: 150,
                                              color:
                                                  ColorManager.darkSectionGray,
                                              child: const Icon(
                                                Icons
                                                    .image_not_supported_rounded,
                                                color:
                                                    ColorManager.darkTextMuted,
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
                  // Input
                  if (isBlocked)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      color: ColorManager.darkSurface,
                      child: SafeArea(
                        top: false,
                        child: Column(
                          children: [
                            Text(
                              'user_blocked_banner'.tr(),
                              style: const TextStyle(
                                color: ColorManager.darkTextSecondary,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            TextButton(
                              onPressed: () =>
                                  _onMenuSelected(context, 'unblock', true),
                              child: Text('unblock'.tr()),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      color: ColorManager.darkSurface,
                      child: SafeArea(
                        top: false,
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
                                  controller: _controller,
                                  focusNode: _inputFocusNode,
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
      },
    );
  }
}

/// Real-time online/offline indicator for the DM app bar.
///
/// Watches `users/{userId}` and shows:
/// - a green dot + "Online" while the user is connected (see
///   `PresenceService` which keeps `isOnline` fresh via RTDB onDisconnect),
/// - a gray dot + "Last seen <time>" otherwise.
/// Honors the user's `settings.showOnlineStatus` privacy flag.
class _OnlineStatus extends StatelessWidget {
  const _OnlineStatus({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: getIt<FirebaseFirestore>()
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        if (data == null) return const SizedBox.shrink();

        final settings = data['settings'];
        final showStatus =
            !(settings is Map && settings['showOnlineStatus'] == false);
        if (!showStatus) return const SizedBox.shrink();

        final isOnline = data['isOnline'] == true;
        final color = isOnline
            ? ColorManager.success
            : ColorManager.darkTextMuted;
        final label = isOnline
            ? 'online'.tr()
            : 'last_seen_at'.tr(
                namedArgs: {'time': formatLastSeen(data['lastSeen'])},
              );

        return Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: color),
            ),
          ],
        );
      },
    );
  }
}

/// Formats a Firestore `lastSeen` value (Timestamp, millis int, or DateTime)
/// in Saudi Arabia time: HH:mm for today, dd/MM HH:mm otherwise.
@visibleForTesting
String formatLastSeen(Object? lastSeen, {DateTime? now}) {
  DateTime? time;
  if (lastSeen is Timestamp) {
    time = lastSeen.toDate();
  } else if (lastSeen is int) {
    time = DateTime.fromMillisecondsSinceEpoch(lastSeen);
  } else if (lastSeen is DateTime) {
    time = lastSeen;
  }
  if (time == null) return '—';
  return formatRiyadhDateClock(time, now: now);
}
