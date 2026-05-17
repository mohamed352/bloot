import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  const AppText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.textAlign,
    this.overflow,
    this.minFontSize = 11,
    this.autoSize = false,
  });

  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final double minFontSize;
  final bool autoSize;

  @override
  Widget build(BuildContext context) {
    if (autoSize) {
      return AutoSizeText(
        text,
        style: style,
        maxLines: maxLines,
        textAlign: textAlign,
        overflow: overflow ?? TextOverflow.ellipsis,
        minFontSize: minFontSize,
      );
    }
    return Text(
      text,
      style: style,
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: overflow,
    );
  }
}
