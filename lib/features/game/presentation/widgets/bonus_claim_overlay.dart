import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:bloot/core/constants/app_radius.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/features/game/presentation/widgets/playing_card/playing_card.dart';
import 'package:bloot/generated/locale_keys.g.dart';

/// Overlay shown during the Saudi Baloot project-declaration phase.
///
/// Allows the player to claim projects (مشاريع) detected by the engine,
/// toggle individual claims, or pass with no projects.
class BonusClaimOverlay extends StatefulWidget {
  const BonusClaimOverlay({
    super.key,
    required this.hand,
    required this.onClaim,
    required this.onPass,
    this.projects = const [],
    this.gameType,
  });

  final List<String> hand;
  final List<Map<String, dynamic>> projects;
  final String? gameType;
  final ValueChanged<List<Map<String, dynamic>>> onClaim;
  final VoidCallback onPass;

  @override
  State<BonusClaimOverlay> createState() => _BonusClaimOverlayState();
}

class _BonusClaimOverlayState extends State<BonusClaimOverlay> {
  late List<Map<String, dynamic>> _selectedProjects;

  @override
  void initState() {
    super.initState();
    // Pre-select all detected projects so the player can confirm immediately.
    _selectedProjects = List<Map<String, dynamic>>.from(widget.projects);
  }

  @override
  void didUpdateWidget(covariant BonusClaimOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.projects != widget.projects) {
      _selectedProjects = List<Map<String, dynamic>>.from(widget.projects);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasProjects = widget.projects.isNotEmpty;

    return Container(
      color: ColorManager.darkCanvas.withValues(alpha: 0.85),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                LocaleKeys.claim_projects.tr(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: ColorManager.darkTextPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                LocaleKeys.select_projects.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: ColorManager.darkTextSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: widget.hand.map((card) {
                  return PlayingCardWidget(
                    card: PlayingCard.fromString(card),
                    style: PlayingCardStyle.dark,
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (hasProjects)
                Column(
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: widget.projects.map((project) {
                        final type = project['type'] as String? ?? '';
                        final cards = (project['cards'] as List<dynamic>?)
                                ?.cast<String>()
                                .join(' ') ??
                            '';
                        final isSelected = _selectedProjects.any(
                          (p) => p['type'] == type,
                        );
                        return GestureDetector(
                          onTap: () => _toggleProject(project),
                          child: Opacity(
                            opacity: isSelected ? 1.0 : 0.5,
                            child: Container(
                              padding: const EdgeInsetsDirectional.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: ColorManager.secondary.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                border: Border.all(
                                  color: isSelected
                                      ? ColorManager.secondary
                                      : ColorManager.darkBorderSoft,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _projectName(type),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: ColorManager.secondary,
                                    ),
                                  ),
                                  Text(
                                    cards,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: ColorManager.darkTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (hasProjects)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _claim,
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: Text(LocaleKeys.claim.tr()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorManager.success,
                          foregroundColor: ColorManager.darkTextPrimary,
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  if (hasProjects) const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.onPass,
                      icon: const Icon(Icons.block_rounded, size: 18),
                      label: Text(LocaleKeys.no_projects.tr()),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ColorManager.darkTextSecondary,
                        side: const BorderSide(
                          color: ColorManager.darkBorderSoft,
                        ),
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (!hasProjects)
                Text(
                  LocaleKeys.no_projects.tr(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: ColorManager.darkTextSecondary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleProject(Map<String, dynamic> project) {
    final type = project['type'] as String? ?? '';
    setState(() {
      final index = _selectedProjects.indexWhere((p) => p['type'] == type);
      if (index >= 0) {
        _selectedProjects.removeAt(index);
      } else {
        _selectedProjects.add(project);
      }
    });
  }

  void _claim() {
    widget.onClaim(_selectedProjects);
  }

  String _projectName(String type) {
    return switch (type) {
      'sira' => LocaleKeys.project_sira.tr(),
      'fifty' => LocaleKeys.project_fifty.tr(),
      'hundred' => LocaleKeys.project_hundred.tr(),
      'fourAces' => LocaleKeys.project_four_aces.tr(),
      _ => type.toUpperCase(),
    };
  }
}
