import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:bloot/core/constants/app_radius.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/di/injection.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/features/moderation/domain/repositories/moderation_repository.dart';

/// Bottom sheet that lets the current user report another user or a piece
/// of content, then submits it through the `reportUser` Cloud Function.
///
/// [targetType] is one of: user, room, stream, message.
Future<void> showReportUserSheet(
  BuildContext context, {
  required String targetUid,
  required String targetType,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) =>
        _ReportUserSheet(targetUid: targetUid, targetType: targetType),
  );
}

class _ReportUserSheet extends StatefulWidget {
  const _ReportUserSheet({required this.targetUid, required this.targetType});

  final String targetUid;
  final String targetType;

  @override
  State<_ReportUserSheet> createState() => _ReportUserSheetState();
}

class _ReportUserSheetState extends State<_ReportUserSheet> {
  static const _reasons = [
    'harassment',
    'inappropriate',
    'spam',
    'cheating',
    'other',
  ];

  final TextEditingController _detailsController = TextEditingController();
  String _selectedReason = _reasons.first;
  bool _submitting = false;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await getIt<ModerationRepository>().reportUser(
        targetUid: widget.targetUid,
        targetType: widget.targetType,
        reason: _selectedReason,
        details: _detailsController.text.trim(),
      );
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text('report_submitted'.tr())));
    } catch (_) {
      if (mounted) setState(() => _submitting = false);
      messenger.showSnackBar(SnackBar(content: Text('report_failed'.tr())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ColorManager.darkSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'report_reason_title'.tr(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: ColorManager.darkTextPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            RadioGroup<String>(
              groupValue: _selectedReason,
              onChanged: _submitting
                  ? (_) {}
                  : (value) => setState(() => _selectedReason = value!),
              child: Column(
                children: _reasons.map((reason) {
                  return RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    value: reason,
                    activeColor: ColorManager.primary,
                    title: Text(
                      'report_reason_$reason'.tr(),
                      style: const TextStyle(
                        color: ColorManager.darkTextPrimary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _detailsController,
              enabled: !_submitting,
              maxLines: 3,
              maxLength: 500,
              style: const TextStyle(
                color: ColorManager.darkTextPrimary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'report_details_hint'.tr(),
                hintStyle: const TextStyle(color: ColorManager.darkTextMuted),
                filled: true,
                fillColor: ColorManager.darkSectionGray,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: ColorManager.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('submit_report'.tr()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
