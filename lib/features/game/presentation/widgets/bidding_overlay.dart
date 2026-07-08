import 'dart:async';

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:bloot/core/constants/app_radius.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/extension/context_values.dart';
import 'package:bloot/generated/locale_keys.g.dart';

/// Bidding phase overlay shown during the Baloot game.
///
/// Allows the current bidder to select Sun, Hokm, Ashkal, or Pass.
class BiddingOverlay extends StatefulWidget {
  const BiddingOverlay({
    super.key,
    required this.currentBidder,
    required this.onBid,
    this.timeLeft = 30,
    this.isEnabled = true,
    this.faceUpCard,
    this.ashkalEnabled = false,
  });

  final String currentBidder;
  final ValueChanged<String> onBid;
  final int timeLeft;
  final bool isEnabled;
  final String? faceUpCard;

  /// Whether the Ashkal (أشكل) bid option is available to this player.
  final bool ashkalEnabled;

  @override
  State<BiddingOverlay> createState() => _BiddingOverlayState();
}

class _BiddingOverlayState extends State<BiddingOverlay> {
  late int _secondsLeft;
  Timer? _timer;
  bool _autoPassed = false;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.timeLeft;
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant BiddingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentBidder != widget.currentBidder ||
        oldWidget.timeLeft != widget.timeLeft ||
        oldWidget.isEnabled != widget.isEnabled) {
      _timer?.cancel();
      _autoPassed = false;
      _secondsLeft = widget.timeLeft;
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        }
      });

      if (_secondsLeft <= 0 && widget.isEnabled && !_autoPassed) {
        _autoPassed = true;
        _timer?.cancel();
        widget.onBid('pass');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      color: colors.background.withValues(alpha: 0.85),
      child: Center(
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${widget.currentBidder} ${LocaleKeys.bidding.tr()}',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${LocaleKeys.time_remaining.tr()}: ${_secondsLeft}s',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              if (widget.faceUpCard != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  '${'proposed_trump'.tr()}: ${widget.faceUpCard}',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xxxl),
              Wrap(
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.lg,
                alignment: WrapAlignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    child: _BidButton(
                      label: LocaleKeys.sun.tr(),
                      icon: Icons.wb_sunny_rounded,
                      color: colors.secondary,
                      isEnabled: widget.isEnabled,
                      onTap: () => widget.onBid('sun'),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: _BidButton(
                      label: LocaleKeys.hokm.tr(),
                      icon: Icons.shield_rounded,
                      color: colors.primary,
                      isEnabled: widget.isEnabled,
                      onTap: () => widget.onBid('hokm'),
                    ),
                  ),
                  if (widget.ashkalEnabled)
                    SizedBox(
                      width: 100,
                      child: _BidButton(
                        label: LocaleKeys.ashkal.tr(),
                        icon: Icons.auto_awesome_rounded,
                        color: colors.success,
                        isEnabled: widget.isEnabled,
                        onTap: () => widget.onBid('ashkal'),
                      ),
                    ),
                  SizedBox(
                    width: 100,
                    child: _BidButton(
                      label: LocaleKeys.commonCancel.tr(),
                      icon: Icons.close_rounded,
                      color: colors.textMuted,
                      isEnabled: widget.isEnabled,
                      onTap: () => widget.onBid('pass'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxxl),
              if (_secondsLeft <= 5)
                Text(
                  LocaleKeys.hurry_up.tr(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.error,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BidButton extends StatelessWidget {
  const _BidButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isEnabled = true,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.45,
        child: Container(
          padding: const EdgeInsetsDirectional.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
