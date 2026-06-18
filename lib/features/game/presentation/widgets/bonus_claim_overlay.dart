import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:bloot/core/constants/app_radius.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/features/game/presentation/widgets/playing_card/playing_card.dart';

/// Overlay shown during the Hokm bonus-claim phase.
///
/// Allows the player to auto-detect bnaga/mosal bonuses from their hand,
/// claim them, or pass with no bonuses.
class BonusClaimOverlay extends StatefulWidget {
  const BonusClaimOverlay({
    super.key,
    required this.hand,
    required this.onClaim,
    required this.onPass,
  });

  final List<String> hand;
  final ValueChanged<List<Map<String, dynamic>>> onClaim;
  final VoidCallback onPass;

  @override
  State<BonusClaimOverlay> createState() => _BonusClaimOverlayState();
}

class _BonusClaimOverlayState extends State<BonusClaimOverlay> {
  List<Map<String, dynamic>> _bonuses = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorManager.darkCanvas.withValues(alpha: 0.85),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'claim_bonuses'.tr(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: ColorManager.darkTextPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'select_bonus_cards'.tr(),
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
            if (_bonuses.isNotEmpty)
              Column(
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: _bonuses.map((bonus) {
                      final type = bonus['type'] as String? ?? '';
                      final points = bonus['points'] as int? ?? 0;
                      final cards = (bonus['cards'] as List<dynamic>?)
                              ?.cast<String>()
                              .join(' ') ??
                          '';
                      return Container(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: ColorManager.secondary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: ColorManager.secondary.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${type.toUpperCase()} • $points pts',
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
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _detectBonuses,
                  icon: const Icon(Icons.search_rounded, size: 18),
                  label: Text('auto_detect'.tr()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorManager.primary,
                    foregroundColor: ColorManager.darkTextPrimary,
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                OutlinedButton.icon(
                  onPressed: widget.onPass,
                  icon: const Icon(Icons.block_rounded, size: 18),
                  label: Text('no_bonuses'.tr()),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ColorManager.darkTextSecondary,
                    side: const BorderSide(color: ColorManager.darkBorderSoft),
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: _bonuses.isNotEmpty ? _claim : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorManager.success,
                  foregroundColor: ColorManager.darkTextPrimary,
                  disabledBackgroundColor: ColorManager.darkBorderSoft,
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                child: Text('claim'.tr()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _detectBonuses() {
    final bonuses = <Map<String, dynamic>>[];

    // Mosal: four of a kind (J=200, 9=150, A/10/K/Q=100)
    final mosalPoints = <String, int>{
      'J': 200,
      '9': 150,
      'A': 100,
      '10': 100,
      'K': 100,
      'Q': 100,
    };
    final rankGroups = <String, List<String>>{};
    for (final card in widget.hand) {
      final rank = _rankOf(card);
      rankGroups.putIfAbsent(rank, () => []).add(card);
    }
    String? bestMosalRank;
    int bestMosalPoints = 0;
    List<String>? bestMosalCards;
    for (final entry in rankGroups.entries) {
      if (entry.value.length == 4 && (mosalPoints[entry.key] ?? 0) > bestMosalPoints) {
        bestMosalRank = entry.key;
        bestMosalPoints = mosalPoints[entry.key]!;
        bestMosalCards = entry.value;
      }
    }
    if (bestMosalCards != null && bestMosalRank != null) {
      bonuses.add({
        'type': 'mosal',
        'points': bestMosalPoints,
        'cards': bestMosalCards,
        'description': 'Mosal $bestMosalRank ($bestMosalPoints pts)',
      });
    }

    // Bnaga: longest consecutive sequence in a suit (3=20, 4=50, 5+=100)
    final suitGroups = <String, List<String>>{};
    for (final card in widget.hand) {
      final suit = _suitOf(card);
      suitGroups.putIfAbsent(suit, () => []).add(card);
    }
    List<String>? bestSeq;
    for (final entry in suitGroups.entries) {
      if (entry.value.length < 3) continue;
      final sorted = entry.value.toList()
        ..sort((a, b) => _rankIndex(_rankOf(a)) - _rankIndex(_rankOf(b)));
      List<String> current = [sorted.first];
      for (int i = 1; i < sorted.length; i++) {
        if (_rankIndex(_rankOf(sorted[i])) ==
            _rankIndex(_rankOf(current.last)) + 1) {
          current.add(sorted[i]);
        } else {
          if (current.length > (bestSeq?.length ?? 0)) {
            bestSeq = current.toList();
          }
          current = [sorted[i]];
        }
      }
      if (current.length > (bestSeq?.length ?? 0)) {
        bestSeq = current.toList();
      }
    }
    if (bestSeq != null && bestSeq.length >= 3) {
      final points = bestSeq.length == 3 ? 20 : bestSeq.length == 4 ? 50 : 100;
      bonuses.add({
        'type': 'bnaga',
        'points': points,
        'cards': bestSeq,
        'description': 'Bnaga ${bestSeq.length} ($points pts)',
      });
    }

    setState(() {
      _bonuses = bonuses;
    });
  }

  void _claim() {
    widget.onClaim(_bonuses);
  }

  String _rankOf(String card) {
    return card.substring(0, card.length - 1);
  }

  String _suitOf(String card) {
    return card.substring(card.length - 1);
  }

  int _rankIndex(String rank) {
    const order = [
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      'J',
      'Q',
      'K',
      'A',
    ];
    return order.indexOf(rank);
  }
}
