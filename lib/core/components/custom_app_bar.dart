import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:bloot/core/extension/context_values.dart';
import 'package:bloot/core/style/colors.dart';

/// Custom app bar with RTL-aware back navigation and consistent styling.
///
/// Uses a transparent background and centers the title by default.
/// The back button is automatically shown when the navigation stack
/// can pop, unless [showBackButton] is explicitly set to `false`.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.title,
    this.actions,
    this.showBackButton,
    this.onBackPressed,
    this.backgroundColor,
    this.elevation = 0,
    this.bottom,
  });

  final String? title;
  final List<Widget>? actions;
  final bool? showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final double elevation;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final canPop = Navigator.of(context).canPop() || context.canPop();
    final effectiveShowBack = showBackButton ?? canPop;

    return AppBar(
      backgroundColor: backgroundColor ?? colors.background,
      foregroundColor: colors.textPrimary,
      elevation: elevation,
      scrolledUnderElevation: 0.5,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: effectiveShowBack
          ? IconButton(
              onPressed: onBackPressed ?? () => context.pop(),
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: ColorManager.darkTextPrimary,
              ),
            )
          : null,
      title: title != null
          ? Text(
              title!,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            )
          : null,
      actions: actions,
      bottom: bottom,
    );
  }
}
