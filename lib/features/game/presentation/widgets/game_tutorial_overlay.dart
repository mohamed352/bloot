import 'dart:async';

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/style/colors.dart';

/// First-time game tutorial overlay with step-by-step walkthrough.
class GameTutorialOverlay extends StatefulWidget {
  const GameTutorialOverlay({super.key, required this.onDone});

  final VoidCallback onDone;

  static const String _prefsKey = 'game_tutorial_seen';

  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_prefsKey) ?? false);
  }

  static Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, true);
  }

  @override
  State<GameTutorialOverlay> createState() => _GameTutorialOverlayState();
}

class _GameTutorialOverlayState extends State<GameTutorialOverlay> {
  int _step = 0;
  Timer? _autoAdvanceTimer;

  final List<_TutorialStep> _steps = [];

  @override
  void initState() {
    super.initState();
    _steps.addAll([
      _TutorialStep(
        icon: Icons.touch_app_rounded,
        title: 'tutorial_tap_to_play'.tr(),
        body: 'tutorial_tap_to_play_desc'.tr(),
      ),
      _TutorialStep(
        icon: Icons.mic_rounded,
        title: 'tutorial_voice_chat'.tr(),
        body: 'tutorial_voice_chat_desc'.tr(),
      ),
      _TutorialStep(
        icon: Icons.chat_bubble_outline_rounded,
        title: 'tutorial_chat'.tr(),
        body: 'tutorial_chat_desc'.tr(),
      ),
      _TutorialStep(
        icon: Icons.emoji_events_rounded,
        title: 'tutorial_win'.tr(),
        body: 'tutorial_win_desc'.tr(),
      ),
    ]);
    _startAutoAdvance();
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    super.dispose();
  }

  void _startAutoAdvance() {
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = Timer(const Duration(seconds: 6), _nextStep);
  }

  void _nextStep() {
    if (_step < _steps.length - 1) {
      setState(() => _step++);
      _startAutoAdvance();
    } else {
      _finish();
    }
  }

  void _finish() {
    _autoAdvanceTimer?.cancel();
    GameTutorialOverlay.markSeen();
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_step];
    return Container(
      color: ColorManager.darkCanvas.withValues(alpha: 0.92),
      child: SafeArea(
        child: GestureDetector(
          onTap: _nextStep,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: ColorManager.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    step.icon,
                    size: 40,
                    color: ColorManager.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  step.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: ColorManager.darkTextPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  step.body,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: ColorManager.darkTextSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _steps.length,
                    (i) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == _step
                            ? ColorManager.primary
                            : ColorManager.darkTextMuted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                TextButton(
                  onPressed: _finish,
                  child: Text(
                    'skip'.tr(),
                    style: const TextStyle(color: ColorManager.darkTextMuted),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TutorialStep {
  const _TutorialStep({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}
