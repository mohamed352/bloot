import 'package:flutter/material.dart';

import 'package:bloot/core/constants/app_radius.dart';
import 'package:bloot/core/extension/context_values.dart';

/// Styled search input field with a clear button.
///
/// Wraps a [TextField] inside a container with the app's surface-variant
/// background and consistent border radius. The clear button appears
/// automatically when the field has text.
class SearchBar extends StatefulWidget {
  const SearchBar({
    super.key,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.controller,
    this.focusNode,
  });

  final String? hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  late final TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.border),
      ),
      child: TextField(
        controller: _controller,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        style: TextStyle(color: colors.textPrimary, fontSize: 15),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: colors.textPlaceholder),
          prefixIcon: Icon(Icons.search_rounded, color: colors.textMuted),
          suffixIcon: _hasText
              ? IconButton(
                  onPressed: _clear,
                  icon: Icon(
                    Icons.clear_rounded,
                    color: colors.textMuted,
                    size: 18,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsetsDirectional.symmetric(vertical: 14),
        ),
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
      ),
    );
  }
}
