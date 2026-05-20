import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:bloot/core/extension/context_values.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/generated/locale_keys.g.dart';

/// Animated LIVE badge with a pulsing red dot.
///
/// Use on stream cards, stream viewer, and any live-related UI.
class LiveBadge extends StatefulWidget {
  const LiveBadge({
    super.key,
    this.size = 6,
    this.showLabel = true,
    this.labelStyle,
  });

  final double size;
  final bool showLabel;
  final TextStyle? labelStyle;

  @override
  State<LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<LiveBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: ColorManager.live.withValues(
                  alpha: _pulseAnimation.value,
                ),
                shape: BoxShape.circle,
              ),
            );
          },
        ),
        if (widget.showLabel) ...[
          const SizedBox(width: 4),
          Text(
            LocaleKeys.live.tr(),
            style:
                widget.labelStyle ??
                TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
          ),
        ],
      ],
    );
  }
}
