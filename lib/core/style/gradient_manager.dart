import 'package:flutter/material.dart';
import 'package:bloot/core/style/app_colors.dart';

abstract class GradientManager {
  static LinearGradient hero(AppColors c) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [c.primary, c.secondary],
  );

  static LinearGradient accent(AppColors c) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [c.secondary, c.warning],
  );

  static LinearGradient softBg(AppColors c) => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [c.background, c.primaryLight],
  );
}
