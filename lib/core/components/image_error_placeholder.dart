import 'package:flutter/material.dart';
import 'package:bloot/core/extension/context_values.dart';

class ImageErrorPlaceholder extends StatelessWidget {
  const ImageErrorPlaceholder({super.key, this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return DecoratedBox(
      decoration: BoxDecoration(color: colors.surfaceVariant),
      child: SizedBox(
        width: width,
        height: height,
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 48,
          color: colors.textMuted,
        ),
      ),
    );
  }
}
