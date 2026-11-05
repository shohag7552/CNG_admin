import 'package:appwrite_boilerplate/app/resources/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// Whole-number field with helper text and a translated range error.
class SettingsNumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String helper;
  final String? errorKey;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const SettingsNumberField({
    super.key,
    required this.controller,
    required this.label,
    required this.helper,
    required this.errorKey,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Constants.paddingSizeDefault),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        // Empty text counts as 0, which the range check rejects.
        onChanged: (v) => onChanged(int.tryParse(v) ?? 0),
        decoration: InputDecoration(
          labelText: label,
          helperText: helper,
          helperMaxLines: 2,
          errorText: errorKey?.trParams({'min': '$min', 'max': '$max'}),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Constants.radiusDefault)),
        ),
      ),
    );
  }
}
