import 'package:flutter/material.dart';
import 'package:bloot/core/style/app_colors.dart';

extension ContextValues on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
  bool get isKeyboardVisible => MediaQuery.viewInsetsOf(this).bottom > 0;
  EdgeInsets get safePadding => MediaQuery.paddingOf(this);
  TextDirection get textDirection => Directionality.of(this);
}
