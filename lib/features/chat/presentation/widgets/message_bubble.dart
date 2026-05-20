import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:bloot/core/constants/app_radius.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/extension/context_values.dart';
import 'package:bloot/features/chat/domain/entities/chat.dart';

/// Chat message bubble with RTL-aware alignment.
///
/// Messages from the current user are aligned to the start (left in LTR,
/// right in RTL) with a purple background. Received messages use a dark
/// surface background.
class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isMe = message.isMe;

    return Align(
      alignment: isMe
          ? AlignmentDirectional.centerStart
          : AlignmentDirectional.centerEnd,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.75,
        ),
        child: Container(
          margin: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
          padding: const EdgeInsetsDirectional.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isMe ? colors.primary : colors.surface,
            borderRadius: BorderRadiusDirectional.only(
              topStart: const Radius.circular(AppRadius.lg),
              topEnd: const Radius.circular(AppRadius.lg),
              bottomStart: Radius.circular(isMe ? 4 : AppRadius.lg),
              bottomEnd: Radius.circular(isMe ? AppRadius.lg : 4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: CachedNetworkImage(
                    imageUrl: message.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 120,
                      color: colors.surfaceVariant,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 120,
                      color: colors.surfaceVariant,
                      child: Icon(
                        Icons.broken_image_rounded,
                        color: colors.textMuted,
                      ),
                    ),
                  ),
                ),
              if (message.text.isNotEmpty) ...[
                if (message.imageUrl != null)
                  const SizedBox(height: AppSpacing.sm),
                Text(
                  message.text,
                  style: TextStyle(
                    fontSize: 14,
                    color: isMe ? colors.textPrimary : colors.textPrimary,
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                message.time,
                style: TextStyle(
                  fontSize: 10,
                  color: isMe
                      ? colors.textPrimary.withValues(alpha: 0.7)
                      : colors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
