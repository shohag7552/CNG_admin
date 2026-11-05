import 'dart:async';

import 'package:appwrite_boilerplate/app/resources/colors.dart';
import 'package:appwrite_boilerplate/app/resources/constants.dart';
import 'package:appwrite_boilerplate/app/resources/text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Debounced search box; calls [onChanged] 300 ms after typing stops.
class SearchField extends StatefulWidget {
  final String hint;
  final ValueChanged<String> onChanged;

  const SearchField({super.key, required this.hint, required this.onChanged});

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final TextEditingController _text = TextEditingController();
  Timer? _debounce;

  void _changed(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => widget.onChanged(v));
    setState(() {});
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Constants.searchFieldWidth,
      child: TextField(
        controller: _text,
        onChanged: _changed,
        decoration: InputDecoration(
          hintText: widget.hint,
          isDense: true,
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _text.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'clear'.tr,
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    _text.clear();
                    _changed('');
                  },
                ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Constants.radiusDefault)),
        ),
      ),
    );
  }
}

/// Labelled dropdown with an "All" entry (null value).
class FilterDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<(T, String)> options;
  final ValueChanged<T?> onChanged;

  const FilterDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Constants.filterFieldWidth,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Constants.radiusDefault)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T?>(
            value: value,
            isDense: true,
            isExpanded: true,
            dropdownColor: context.cardBackground,
            style: poppinsRegular.copyWith(color: context.textPrimary),
            items: [
              DropdownMenuItem<T?>(value: null, child: Text('all'.tr)),
              for (final o in options)
                DropdownMenuItem<T?>(value: o.$1, child: Text(o.$2)),
            ],
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}

/// Single-select chip row with an "All" chip (null value).
class FilterChips<T> extends StatelessWidget {
  final T? value;
  final List<(T, String)> options;
  final ValueChanged<T?> onChanged;

  const FilterChips({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Constants.paddingSizeSmall,
      runSpacing: Constants.paddingSizeExtraSmall,
      children: [
        ChoiceChip(
            label: Text('all'.tr),
            selected: value == null,
            onSelected: (_) => onChanged(null)),
        for (final o in options)
          ChoiceChip(
              label: Text(o.$2),
              selected: value == o.$1,
              onSelected: (_) => onChanged(o.$1)),
      ],
    );
  }
}
