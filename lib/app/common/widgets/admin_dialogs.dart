import 'package:appwrite_boilerplate/app/resources/colors.dart';
import 'package:appwrite_boilerplate/app/resources/constants.dart';
import 'package:appwrite_boilerplate/app/resources/text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Asks for a mandatory reason. Resolves to the trimmed reason, or null when
/// dismissed. (The controller re-checks it; this is only the friendly layer.)
Future<String?> showReasonDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = true,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _ReasonDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      destructive: destructive,
    ),
  );
}

class _ReasonDialog extends StatefulWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final bool destructive;

  const _ReasonDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.destructive,
  });

  @override
  State<_ReasonDialog> createState() => _ReasonDialogState();
}

class _ReasonDialogState extends State<_ReasonDialog> {
  static const int _maxLength = 200;
  final TextEditingController _reason = TextEditingController();
  bool _showError = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  void _submit() {
    final r = _reason.text.trim();
    if (r.isEmpty) {
      setState(() => _showError = true);
      return;
    }
    Navigator.of(context).pop(r);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.cardBackground,
      title: Text(widget.title,
          style: poppinsBold.copyWith(color: context.textPrimary)),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Constants.dialogMaxWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.message,
                style: poppinsRegular.copyWith(color: context.textSecondary)),
            const SizedBox(height: Constants.paddingSizeDefault),
            TextField(
              controller: _reason,
              autofocus: true,
              maxLines: 3,
              maxLength: _maxLength,
              onChanged: (_) {
                if (_showError) setState(() => _showError = false);
              },
              decoration: InputDecoration(
                labelText: 'reason'.tr,
                errorText: _showError ? 'reason_required'.tr : null,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Constants.radiusDefault)),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('cancel'.tr)),
        FilledButton(
          style: FilledButton.styleFrom(
              backgroundColor:
                  widget.destructive ? ColorResource.error : ColorResource.primaryDark),
          onPressed: _submit,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: ctx.cardBackground,
      title: Text(title, style: poppinsBold.copyWith(color: ctx.textPrimary)),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Constants.dialogMaxWidth),
        child: Text(message,
            style: poppinsRegular.copyWith(color: ctx.textSecondary)),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('cancel'.tr)),
        FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(confirmLabel)),
      ],
    ),
  );
  return ok ?? false;
}
