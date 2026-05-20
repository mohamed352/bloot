import 'package:flutter/material.dart';

import 'package:bloot/core/extension/context_values.dart';
import 'package:bloot/core/style/app_colors.dart';

/// Convenience getters for common [BuildContext] lookups.
///
/// Import alongside [ContextValues] for full context helper coverage.
extension BuildContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);

  AppColors get colors => appColors;

  MediaQueryData get mediaQuery => MediaQuery.of(this);

  Size get screenSize => MediaQuery.sizeOf(this);

  bool get isRTL => Directionality.of(this) == TextDirection.rtl;

  bool get isLandscape =>
      MediaQuery.orientationOf(this) == Orientation.landscape;
}
