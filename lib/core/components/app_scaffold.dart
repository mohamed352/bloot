import 'package:flutter/material.dart';

import 'package:bloot/core/extension/context_values.dart';

/// Consistent scaffold wrapper for the Bloot app.
///
/// Applies the dark canvas background and optional [SafeArea] handling.
/// Use this instead of raw [Scaffold] to ensure every screen follows
/// the same base layout rules.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.useSafeArea = true,
    this.resizeToAvoidBottomInset = true,
    this.extendBodyBehindAppBar = false,
  });

  final Widget? body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool useSafeArea;
  final bool resizeToAvoidBottomInset;
  final bool extendBodyBehindAppBar;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    Widget content = body ?? const SizedBox.shrink();

    if (useSafeArea) {
      content = SafeArea(
        top: appBar == null,
        bottom: bottomNavigationBar == null,
        child: content,
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: appBar,
      body: content,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    );
  }
}
