import 'dart:math';

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/core/constants/app_spacing.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _progressController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOut,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    _logoController.forward();
    _progressController.forward();

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) context.goNamed(RouteNames.welcome);
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.darkCanvas,
      body: Stack(
        children: [
          // Floating card suits background
          ...List.generate(6, (index) => _FloatingSuit(index: index)),
          // Center content
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo container
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ColorManager.primary.withValues(alpha: 0.15),
                        boxShadow: [
                          BoxShadow(
                            color: ColorManager.primary.withValues(alpha: 0.3),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.style_rounded,
                          size: 56,
                          color: ColorManager.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Text(
                      'bloot'.tr(),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: ColorManager.darkTextPrimary,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'live_baloot'.tr(),
                      style: TextStyle(
                        fontSize: 14,
                        color: ColorManager.darkTextSecondary.withValues(
                          alpha: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Progress bar at bottom
          Positioned(
            bottom: 48 + MediaQuery.paddingOf(context).bottom,
            left: 64,
            right: 64,
            child: AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _progressController.value,
                    backgroundColor: ColorManager.darkBorderSoft,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      ColorManager.primary,
                    ),
                    minHeight: 4,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingSuit extends StatefulWidget {
  const _FloatingSuit({required this.index});

  final int index;

  @override
  State<_FloatingSuit> createState() => _FloatingSuitState();
}

class _FloatingSuitState extends State<_FloatingSuit>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  final List<IconData> _suits = [
    Icons.favorite,
    Icons.square,
    Icons.circle,
    Icons.change_history,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3 + widget.index),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final random = Random(widget.index);
    final left = random.nextDouble() * size.width * 0.8;
    final top = random.nextDouble() * size.height * 0.6 + size.height * 0.1;
    final color = widget.index.isEven
        ? ColorManager.primary.withValues(alpha: 0.08)
        : ColorManager.secondary.withValues(alpha: 0.08);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return PositionedDirectional(
          start: left,
          top: top + (_controller.value - 0.5) * 30,
          child: Transform.rotate(
            angle: _controller.value * pi * 0.5,
            child: Icon(
              _suits[widget.index % _suits.length],
              size: 24 + random.nextDouble() * 24,
              color: color,
            ),
          ),
        );
      },
    );
  }
}
