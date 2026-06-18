import 'package:flutter/material.dart';

import 'package:bloot/core/constants/app_radius.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/extension/context_values.dart';

/// Animated skeleton placeholder with a sliding shimmer effect.
///
/// Use inside [ListView.builder] or [GridView.builder] while data is loading.
/// The shimmer animation runs automatically and loops indefinitely.
class SkeletonCard extends StatefulWidget {
  const SkeletonCard({
    super.key,
    this.height = 120,
    this.width = double.infinity,
    this.borderRadius = AppRadius.lg,
  });

  final double height;
  final double width;
  final double borderRadius;

  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                colors.surfaceVariant,
                colors.surfaceVariant.withValues(alpha: 0.6),
                colors.surfaceVariant,
              ],
              stops: const [0.0, 0.5, 1.0],
              transform: _SlideGradientTransform(percent: _controller.value),
            ).createShader(bounds);
          },
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: colors.surfaceVariant,
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
          ),
        );
      },
    );
  }
}

/// Horizontal skeleton row with an avatar circle and two text lines.
///
/// Useful for list-item placeholders (chat rows, stream rows, etc.).
class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          SkeletonCard(height: 48, width: 48, borderRadius: AppRadius.full),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonCard(height: 14, borderRadius: AppRadius.sm),
                SizedBox(height: AppSpacing.sm),
                SkeletonCard(
                  height: 12,
                  width: 120,
                  borderRadius: AppRadius.sm,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideGradientTransform extends GradientTransform {
  const _SlideGradientTransform({required this.percent});

  final double percent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * (percent * 2 - 1), 0, 0);
  }
}
