import 'package:flutter/material.dart';

import 'package:bloot/core/extension/context_values.dart';

/// Phone number input field with a country-code prefix button.
///
/// Displays a flag, country code, and phone number input. Tapping the
/// prefix opens a country picker bottom sheet.
class PhoneInputField extends StatelessWidget {
  const PhoneInputField({
    super.key,
    required this.controller,
    required this.countryCode,
    required this.countryFlag,
    this.onTapCountry,
    this.hintText,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String countryCode;
  final String countryFlag;
  final VoidCallback? onTapCountry;
  final String? hintText;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      style: TextStyle(color: colors.textPrimary, fontSize: 16),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: colors.textPlaceholder),
        prefixIcon: InkWell(
          onTap: onTapCountry,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            margin: const EdgeInsetsDirectional.only(end: 8),
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: BorderDirectional(end: BorderSide(color: colors.border)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(countryFlag, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 4),
                Text(
                  countryCode,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: colors.textMuted,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(),
        filled: true,
        fillColor: colors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),
      ),
      onFieldSubmitted: onSubmitted,
    );
  }
}
