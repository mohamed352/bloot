import 'package:flutter/material.dart';

/// Bloot Design System Colors — matches DESIGN.md tokens
abstract class ColorManager {
  // Light theme (deferred post-MVP)
  static const Color softCloud = Color(0xFFF7F8FA);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color sectionGray = Color(0xFFF0F2F5);

  // Brand — Purple
  static const Color primary = Color(0xFF8B5CF6);
  static const Color primaryDark = Color(0xFF7C3AED);
  static const Color primaryLight = Color(0xFFA78BFA);

  // Brand — Gold
  static const Color secondary = Color(0xFFF59E0B);
  static const Color secondaryLight = Color(0xFFFBBF24);
  static const Color secondaryDark = Color(0xFFD97706);

  // States
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFE8F9EE);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color live = Color(0xFFFF1A1A);

  // Text (light theme)
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textDisabled = Color(0xFFD1D5DB);
  static const Color textPlaceholder = Color(0xFF9CA3AF);

  // Borders (light theme)
  static const Color borderSoft = Color(0xFFE5E7EB);
  static const Color borderSubtle = Color(0xFFF3F4F6);

  // Glows & Shadows
  static const Color primaryGlow = Color(0x4D8B5CF6);
  static const Color secondaryGlow = Color(0x4DF59E0B);

  static const Color cardShadow = Color(0x0F8B5CF6);
  static const Color elevatedShadow = Color(0x1A8B5CF6);
  static const Color shadow = Color(0x0D000000);

  // Dark theme surfaces — Premium Dark Card Room
  static const Color darkCanvas = Color(0xFF0A0A0F);
  static const Color darkSurface = Color(0xFF161622);
  static const Color darkSectionGray = Color(0xFF1E1E2E);
  static const Color darkHover = Color(0xFF252538);

  // Dark theme text
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkTextMuted = Color(0xFF6B7280);
  static const Color darkTextDisabled = Color(0xFF4B5563);

  // Dark theme borders
  static const Color darkBorderSoft = Color(0xFF27273A);
  static const Color darkBorderSubtle = Color(0xFF1F1F2E);
  static const Color darkBorderPurple = Color(0x268B5CF6);

  // Dark theme state overlays
  static const Color darkPrimaryLight = Color(0x268B5CF6);
  static const Color darkSecondaryLight = Color(0x26F59E0B);
  static const Color darkSuccessLight = Color(0x2622C55E);
  static const Color darkWarningLight = Color(0x26F59E0B);
  static const Color darkErrorLight = Color(0x26EF4444);
  static const Color darkInfoLight = Color(0x263B82F6);

  // Game table
  static const Color gameTableTop = Color(0xFF0D2818);
  static const Color gameTableBot = Color(0xFF091A10);
  static const Color gameTableBorder = Color(0x4022C55E);
}
