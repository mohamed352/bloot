import 'package:flutter/material.dart';

import 'package:bloot/core/components/cached_avatar.dart';
import 'package:bloot/core/extension/context_values.dart';
import 'package:bloot/core/style/colors.dart';

/// Circular avatar with an edit overlay button.
///
/// Used in profile creation and edit profile screens.
class AvatarPicker extends StatelessWidget {
  const AvatarPicker({super.key, this.imageUrl, this.size = 100, this.onTap});

  final String? imageUrl;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: AlignmentDirectional.bottomEnd,
        children: [
          CachedAvatar(
            imageUrl: imageUrl,
            size: size,
            borderRadius: size / 2,
            borderColor: colors.border,
            borderWidth: 2,
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: colors.background, width: 2),
            ),
            child: const Icon(
              Icons.edit_rounded,
              size: 16,
              color: ColorManager.darkTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
