import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:bloot/core/style/colors.dart';

/// Reusable avatar widget that caches remote images and shows a placeholder.
class CachedAvatar extends StatelessWidget {
  const CachedAvatar({
    super.key,
    required this.imageUrl,
    this.size = 48,
    this.borderRadius,
    this.borderColor,
    this.borderWidth = 0,
  });

  final String? imageUrl;
  final double size;
  final double? borderRadius;
  final Color? borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? size / 2;

    Widget image;
    if (imageUrl == null || imageUrl!.isEmpty) {
      image = _placeholder();
    } else {
      image = CachedNetworkImage(
        imageUrl: imageUrl!,
        placeholder: (a, b) => _placeholder(),
        errorWidget: (a, b, c) => _placeholder(),
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    }

    if (borderWidth > 0 && borderColor != null) {
      image = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: borderColor!, width: borderWidth),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: image,
        ),
      );
    } else {
      image = ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: image,
      );
    }

    return image;
  }

  Widget _placeholder() {
    return Container(
      width: size,
      height: size,
      color: ColorManager.darkSectionGray,
      child: Icon(
        Icons.person,
        size: size * 0.5,
        color: ColorManager.darkTextMuted,
      ),
    );
  }
}
