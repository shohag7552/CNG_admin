import 'package:appwrite_boilerplate/app/resources/colors.dart';
import 'package:appwrite_boilerplate/app/resources/constants.dart';
import 'package:appwrite_boilerplate/app/resources/text_style.dart';
import 'package:flutter/material.dart';

/// Elevated surface with an optional title row.
class AdminCard extends StatelessWidget {
  final String? title;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const AdminCard({
    super.key,
    this.title,
    this.trailing,
    required this.child,
    this.padding = const EdgeInsets.all(Constants.paddingSizeLarge),
  });

  @override
  Widget build(BuildContext context) {
    // Material (not a coloured Container) so ListTiles inside can paint ink.
    return Material(
      color: context.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.radiusCard),
        side: BorderSide(color: context.textLight.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: padding,
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title!,
                        style: poppinsBold.copyWith(
                          fontSize: Constants.fontSizeLarge,
                          color: context.textPrimary,
                        ),
                      ),
                    ),
                    ?trailing,
                  ],
                ),
                const SizedBox(height: Constants.paddingSizeDefault),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// Label on the left, value on the right.
class InfoRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;

  const InfoRow({super.key, required this.label, this.value, this.valueWidget});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: Constants.paddingSizeExtraSmall + 2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: poppinsRegular.copyWith(color: context.textSecondary),
          ),
          const SizedBox(width: Constants.paddingSizeDefault),
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child:
                  valueWidget ??
                  Text(
                    value ?? '—',
                    textAlign: TextAlign.end,
                    style: poppinsMedium.copyWith(color: context.textPrimary),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
