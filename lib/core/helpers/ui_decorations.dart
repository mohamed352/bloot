import 'package:flutter/material.dart';
import 'package:bloot/core/style/app_colors.dart';

abstract class UIDecorations {
  static List<BoxShadow> cardShadow(AppColors colors) => [
    BoxShadow(color: colors.shadow, blurRadius: 10, offset: const Offset(0, 4)),
  ];

  static List<BoxShadow> elevatedShadow(AppColors colors) => [
    BoxShadow(
      color: colors.elevatedShadow,
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> primaryGlow(AppColors colors) => [
    BoxShadow(
      color: colors.primaryGlow,
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  static BoxDecoration cardDecoration(AppColors colors) => BoxDecoration(
    color: colors.cardBackground,
    borderRadius: const BorderRadius.all(Radius.circular(16)),
    border: Border.all(color: colors.divider),
    boxShadow: cardShadow(colors),
  );

  static BoxDecoration sectionDecoration(AppColors colors) => BoxDecoration(
    color: colors.surfaceVariant,
    borderRadius: const BorderRadius.all(Radius.circular(12)),
  );

  static BoxDecoration inputDecoration(AppColors colors) => BoxDecoration(
    color: colors.surfaceVariant,
    borderRadius: const BorderRadius.all(Radius.circular(12)),
    border: Border.all(color: colors.border),
  );

  static BoxDecoration pillDecoration(
    AppColors colors, {
    Color? backgroundColor,
    Color? borderColor,
  }) => BoxDecoration(
    color: backgroundColor ?? colors.primaryLight,
    borderRadius: const BorderRadius.all(Radius.circular(999)),
    border: borderColor != null ? Border.all(color: borderColor) : null,
  );
}
