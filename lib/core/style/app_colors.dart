import 'package:flutter/material.dart';
import 'package:bloot/core/style/colors.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.cardBackground,
    required this.surfaceVariant,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textDisabled,
    required this.textPlaceholder,
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.primaryGlow,
    required this.secondary,
    required this.secondaryLight,
    required this.secondaryGlow,
    required this.success,
    required this.successLight,
    required this.warning,
    required this.warningLight,
    required this.error,
    required this.errorLight,
    required this.info,
    required this.infoLight,
    required this.border,
    required this.divider,
    required this.borderFocus,
    required this.shadow,
    required this.elevatedShadow,
  });

  final Color background;
  final Color surface;
  final Color cardBackground;
  final Color surfaceVariant;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textDisabled;
  final Color textPlaceholder;
  final Color primary;
  final Color primaryDark;
  final Color primaryLight;
  final Color primaryGlow;
  final Color secondary;
  final Color secondaryLight;
  final Color secondaryGlow;
  final Color success;
  final Color successLight;
  final Color warning;
  final Color warningLight;
  final Color error;
  final Color errorLight;
  final Color info;
  final Color infoLight;
  final Color border;
  final Color divider;
  final Color borderFocus;
  final Color shadow;
  final Color elevatedShadow;

  static const AppColors dark = AppColors(
    background: ColorManager.darkCanvas,
    surface: ColorManager.darkSurface,
    cardBackground: ColorManager.darkSurface,
    surfaceVariant: ColorManager.darkSectionGray,
    textPrimary: ColorManager.darkTextPrimary,
    textSecondary: ColorManager.darkTextSecondary,
    textMuted: ColorManager.darkTextMuted,
    textDisabled: ColorManager.darkTextMuted,
    textPlaceholder: ColorManager.darkTextMuted,
    primary: ColorManager.primary,
    primaryDark: ColorManager.primaryDark,
    primaryLight: ColorManager.darkPrimaryLight,
    primaryGlow: ColorManager.primaryGlow,
    secondary: ColorManager.secondary,
    secondaryLight: ColorManager.darkSecondaryLight,
    secondaryGlow: ColorManager.secondaryGlow,
    success: ColorManager.success,
    successLight: ColorManager.darkSuccessLight,
    warning: ColorManager.warning,
    warningLight: ColorManager.darkWarningLight,
    error: ColorManager.error,
    errorLight: ColorManager.darkErrorLight,
    info: ColorManager.info,
    infoLight: ColorManager.darkInfoLight,
    border: ColorManager.darkBorderSoft,
    divider: ColorManager.darkBorderSubtle,
    borderFocus: ColorManager.primary,
    shadow: ColorManager.cardShadow,
    elevatedShadow: ColorManager.elevatedShadow,
  );

  @override
  ThemeExtension<AppColors> copyWith({
    Color? background,
    Color? surface,
    Color? cardBackground,
    Color? surfaceVariant,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? textDisabled,
    Color? textPlaceholder,
    Color? primary,
    Color? primaryDark,
    Color? primaryLight,
    Color? primaryGlow,
    Color? secondary,
    Color? secondaryLight,
    Color? secondaryGlow,
    Color? success,
    Color? successLight,
    Color? warning,
    Color? warningLight,
    Color? error,
    Color? errorLight,
    Color? info,
    Color? infoLight,
    Color? border,
    Color? divider,
    Color? borderFocus,
    Color? shadow,
    Color? elevatedShadow,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      cardBackground: cardBackground ?? this.cardBackground,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      textDisabled: textDisabled ?? this.textDisabled,
      textPlaceholder: textPlaceholder ?? this.textPlaceholder,
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      primaryLight: primaryLight ?? this.primaryLight,
      primaryGlow: primaryGlow ?? this.primaryGlow,
      secondary: secondary ?? this.secondary,
      secondaryLight: secondaryLight ?? this.secondaryLight,
      secondaryGlow: secondaryGlow ?? this.secondaryGlow,
      success: success ?? this.success,
      successLight: successLight ?? this.successLight,
      warning: warning ?? this.warning,
      warningLight: warningLight ?? this.warningLight,
      error: error ?? this.error,
      errorLight: errorLight ?? this.errorLight,
      info: info ?? this.info,
      infoLight: infoLight ?? this.infoLight,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      borderFocus: borderFocus ?? this.borderFocus,
      shadow: shadow ?? this.shadow,
      elevatedShadow: elevatedShadow ?? this.elevatedShadow,
    );
  }

  @override
  ThemeExtension<AppColors> lerp(
    covariant ThemeExtension<AppColors>? other,
    double t,
  ) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      textPlaceholder: Color.lerp(textPlaceholder, other.textPlaceholder, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      primaryGlow: Color.lerp(primaryGlow, other.primaryGlow, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      secondaryLight: Color.lerp(secondaryLight, other.secondaryLight, t)!,
      secondaryGlow: Color.lerp(secondaryGlow, other.secondaryGlow, t)!,
      success: Color.lerp(success, other.success, t)!,
      successLight: Color.lerp(successLight, other.successLight, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningLight: Color.lerp(warningLight, other.warningLight, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorLight: Color.lerp(errorLight, other.errorLight, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoLight: Color.lerp(infoLight, other.infoLight, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      borderFocus: Color.lerp(borderFocus, other.borderFocus, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      elevatedShadow: Color.lerp(elevatedShadow, other.elevatedShadow, t)!,
    );
  }
}
