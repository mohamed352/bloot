import 'package:flutter/material.dart';

import 'package:bloot/core/constants/app_radius.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/extension/context_values.dart';

/// Horizontal scrollable row of selectable filter chips.
///
/// Use on discover, tournament, and chat list screens for category filtering.
class FilterChipRow extends StatelessWidget {
  const FilterChipRow({
    super.key,
    required this.filters,
    required this.selectedIndex,
    required this.onSelected,
    this.padding = const EdgeInsetsDirectional.symmetric(
      horizontal: AppSpacing.screenHorizontal,
    ),
  });

  final List<String> filters;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: padding,
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;

          return GestureDetector(
            onTap: () => onSelected(index),
            child: Container(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              decoration: BoxDecoration(
                color: isSelected ? colors.primary : colors.cardBackground,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: isSelected ? colors.primary : colors.border,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                filters[index],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? colors.textPrimary : colors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
