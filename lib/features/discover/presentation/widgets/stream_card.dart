import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:bloot/core/components/cached_avatar.dart';
import 'package:bloot/core/constants/app_radius.dart';
import 'package:bloot/core/extension/context_values.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/features/discover/domain/entities/discover_stream.dart';
import 'package:bloot/generated/locale_keys.g.dart';

/// Card widget displaying a live stream thumbnail and metadata.
///
/// Used in the discover grid and home horizontal lists.
class StreamCard extends StatelessWidget {
  const StreamCard({super.key, required this.stream, required this.onTap});

  final DiscoverStream stream;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.lg),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      colors.primary.withValues(
                        alpha: 0.2 + (stream.viewers % 3) * 0.1,
                      ),
                      colors.cardBackground,
                    ],
                    begin: AlignmentDirectional.topStart,
                    end: AlignmentDirectional.bottomEnd,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.videocam_rounded,
                        size: 40,
                        color: colors.primary.withValues(alpha: 0.15),
                      ),
                    ),
                    PositionedDirectional(
                      top: 8,
                      start: 8,
                      child: Container(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: ColorManager.live.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.circle,
                              size: 5,
                              color: ColorManager.darkTextPrimary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              LocaleKeys.live.tr(),
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: ColorManager.darkTextPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      top: 8,
                      end: 8,
                      child: Container(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: colors.background.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.visibility_rounded,
                              size: 10,
                              color: ColorManager.darkTextPrimary,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${stream.viewers}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: ColorManager.darkTextPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stream.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ColorManager.darkTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      CachedAvatar(
                        imageUrl: stream.avatarUrl,
                        size: 20,
                        borderRadius: 10,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        stream.host,
                        style: const TextStyle(
                          fontSize: 11,
                          color: ColorManager.darkTextSecondary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          stream.category,
                          style: const TextStyle(
                            fontSize: 9,
                            color: ColorManager.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
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
