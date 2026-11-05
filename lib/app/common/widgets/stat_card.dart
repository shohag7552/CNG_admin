import 'package:appwrite_boilerplate/app/resources/colors.dart';
import 'package:appwrite_boilerplate/app/resources/constants.dart';
import 'package:appwrite_boilerplate/app/resources/text_style.dart';
import 'package:flutter/material.dart';

/// Lays [children] out in as many equal columns as fit.
class StatGrid extends StatelessWidget {
  final List<Widget> children;

  const StatGrid({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      const gap = Constants.paddingSizeDefault;
      final cols = ((box.maxWidth + gap) / (Constants.statCardMinWidth + gap))
          .floor()
          .clamp(1, children.length);
      final width = (box.maxWidth - gap * (cols - 1)) / cols;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [for (final c in children) SizedBox(width: width, child: c)],
      );
    });
  }
}

class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tint = color ?? ColorResource.primaryDark;
    return Container(
      padding: const EdgeInsets.all(Constants.paddingSizeLarge),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(Constants.radiusCard),
        border: Border.all(color: context.textLight.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: Constants.avatarSize,
            height: Constants.avatarSize,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(Constants.radiusLarge),
            ),
            child: Icon(icon, color: tint),
          ),
          const SizedBox(width: Constants.paddingSizeDefault),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: poppinsBold.copyWith(
                        fontSize: Constants.fontSizeOverLarge,
                        color: context.textPrimary)),
                Text(label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: poppinsRegular.copyWith(
                        fontSize: Constants.fontSizeSmall,
                        color: context.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
