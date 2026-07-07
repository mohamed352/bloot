import 'package:flutter/material.dart';

import 'package:bloot/features/game/presentation/widgets/playing_card/playing_card_model.dart';

/// Fully customizable visual style for [PlayingCardWidget].
///
/// Use [PlayingCardStyle.standard] for a classic white-faced look, or build
/// your own with the default constructor + [copyWith].
@immutable
class PlayingCardStyle {
  const PlayingCardStyle({
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.backgroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.shadow,
    required this.cornerPadding,
    required this.rankTextStyle,
    required this.suitTextStyle,
    required this.centerSuitSize,
    required this.centerSuitOpacity,
    required this.redColor,
    required this.blackColor,
    this.faceDownColor = const Color(0xFF1E3A5F),
    this.faceDownPatternColor = const Color(0xFF2A4A70),
  });

  /// Classic white playing card look.
  static const PlayingCardStyle standard = PlayingCardStyle(
    width: 56,
    height: 80,
    borderRadius: BorderRadius.all(Radius.circular(6)),
    backgroundColor: Color(0xFFFFFFFF),
    borderColor: Color(0xFFE0E0E0),
    borderWidth: 0.5,
    shadow: BoxShadow(
      color: Color(0x40000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
    cornerPadding: EdgeInsets.all(4),
    rankTextStyle: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      height: 1.0,
    ),
    suitTextStyle: TextStyle(fontSize: 10, height: 1.0),
    centerSuitSize: 28,
    centerSuitOpacity: 0.15,
    redColor: Color(0xFFD32F2F),
    blackColor: Color(0xFF000000),
  );

  /// Dark-themed card style suitable for dark game tables.
  static PlayingCardStyle get dark {
    return standard.copyWith(
      backgroundColor: const Color(0xFFF5F5F5),
      borderColor: const Color(0xFF424242),
      shadow: const BoxShadow(
        color: Color(0x66000000),
        blurRadius: 6,
        offset: Offset(0, 3),
      ),
    );
  }

  /// Style tuned for the in-game board: crisp corners, readable suits,
  /// and enough contrast against dark felt backgrounds.
  static PlayingCardStyle get gameTable {
    return standard.copyWith(
      backgroundColor: const Color(0xFFF8F8F8),
      borderColor: const Color(0xFFBDBDBD),
      borderWidth: 0.5,
      shadow: const BoxShadow(
        color: Color(0x59000000),
        blurRadius: 5,
        offset: Offset(0, 3),
      ),
      rankTextStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        height: 1.0,
      ),
      suitTextStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        height: 1.0,
      ),
      centerSuitSize: 30,
      centerSuitOpacity: 0.22,
      redColor: const Color(0xFFE53935),
      blackColor: const Color(0xFF212121),
    );
  }

  final double width;
  final double height;
  final BorderRadius borderRadius;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final BoxShadow shadow;
  final EdgeInsets cornerPadding;
  final TextStyle rankTextStyle;
  final TextStyle suitTextStyle;
  final double centerSuitSize;
  final double centerSuitOpacity;
  final Color redColor;
  final Color blackColor;
  final Color faceDownColor;
  final Color faceDownPatternColor;

  /// Returns the foreground color (red or black) for a given [card].
  Color foregroundColorFor(PlayingCard card) =>
      card.isRed ? redColor : blackColor;

  /// Creates a copy of this style with the given fields replaced.
  PlayingCardStyle copyWith({
    double? width,
    double? height,
    BorderRadius? borderRadius,
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    BoxShadow? shadow,
    EdgeInsets? cornerPadding,
    TextStyle? rankTextStyle,
    TextStyle? suitTextStyle,
    double? centerSuitSize,
    double? centerSuitOpacity,
    Color? redColor,
    Color? blackColor,
    Color? faceDownColor,
    Color? faceDownPatternColor,
  }) {
    return PlayingCardStyle(
      width: width ?? this.width,
      height: height ?? this.height,
      borderRadius: borderRadius ?? this.borderRadius,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      shadow: shadow ?? this.shadow,
      cornerPadding: cornerPadding ?? this.cornerPadding,
      rankTextStyle: rankTextStyle ?? this.rankTextStyle,
      suitTextStyle: suitTextStyle ?? this.suitTextStyle,
      centerSuitSize: centerSuitSize ?? this.centerSuitSize,
      centerSuitOpacity: centerSuitOpacity ?? this.centerSuitOpacity,
      redColor: redColor ?? this.redColor,
      blackColor: blackColor ?? this.blackColor,
      faceDownColor: faceDownColor ?? this.faceDownColor,
      faceDownPatternColor: faceDownPatternColor ?? this.faceDownPatternColor,
    );
  }
}
