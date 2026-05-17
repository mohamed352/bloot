import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:bloot/features/shell/presentation/widgets/bottom_nav_bar_widget.dart';

class MainShellWidget extends StatelessWidget {
  const MainShellWidget({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavBarWidget(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}