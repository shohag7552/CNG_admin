import 'package:appwrite_boilerplate/app/common/widgets/admin_card.dart';
import 'package:appwrite_boilerplate/app/resources/colors.dart';
import 'package:appwrite_boilerplate/app/resources/constants.dart';
import 'package:appwrite_boilerplate/app/resources/text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Icon + message (+ optional retry) used for empty and error states.
class StateMessage extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? sub;
  final String? actionLabel;
  final VoidCallback? onAction;

  const StateMessage({
    super.key,
    required this.icon,
    required this.text,
    this.sub,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Constants.paddingSizeExtraLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: Constants.iconCircleSize,
              height: Constants.iconCircleSize,
              decoration: BoxDecoration(
                color: ColorResource.primaryDark.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  size: Constants.iconSizeLarge,
                  color: ColorResource.primaryDark),
            ),
            const SizedBox(height: Constants.paddingSizeDefault),
            Text(text,
                textAlign: TextAlign.center,
                style: poppinsBold.copyWith(
                    fontSize: Constants.fontSizeLarge,
                    color: context.textPrimary)),
            if (sub != null)
              Padding(
                padding: const EdgeInsets.only(top: Constants.paddingSizeSmall),
                child: Text(sub!,
                    textAlign: TextAlign.center,
                    style: poppinsRegular.copyWith(color: context.textSecondary)),
              ),
            if (actionLabel != null)
              Padding(
                padding: const EdgeInsets.only(top: Constants.paddingSizeSmall),
                child: OutlinedButton(
                    onPressed: onAction, child: Text(actionLabel!)),
              ),
          ],
        ),
      ),
    );
  }
}

/// Pulsing grey rows shown while a list or card loads.
class SkeletonList extends StatefulWidget {
  final int rows;

  const SkeletonList({super.key, this.rows = 6});

  @override
  State<SkeletonList> createState() => _SkeletonListState();
}

class _SkeletonListState extends State<SkeletonList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.45, end: 1).animate(_pulse),
      child: Column(
        children: [
          for (var i = 0; i < widget.rows; i++)
            Container(
              height: Constants.skeletonRowHeight,
              margin: const EdgeInsets.only(bottom: Constants.paddingSizeSmall),
              decoration: BoxDecoration(
                color: context.textLight.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(Constants.radiusDefault),
              ),
            ),
        ],
      ),
    );
  }
}

/// Picks between skeleton, error+retry, empty and the real [child].
class AsyncStateView extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final bool isEmpty;
  final VoidCallback onRetry;
  final String emptyTitle;
  final String? emptySub;
  final IconData emptyIcon;
  final int skeletonRows;
  final Widget child;

  const AsyncStateView({
    super.key,
    required this.isLoading,
    required this.error,
    required this.isEmpty,
    required this.onRetry,
    required this.child,
    required this.emptyTitle,
    this.emptySub,
    this.emptyIcon = Icons.inbox_rounded,
    this.skeletonRows = 6,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return SkeletonList(rows: skeletonRows);
    if (error != null) {
      return AdminCard(
        child: StateMessage(
          icon: Icons.cloud_off_rounded,
          text: error!,
          actionLabel: 'retry'.tr,
          onAction: onRetry,
        ),
      );
    }
    if (isEmpty) {
      return AdminCard(
          child: StateMessage(icon: emptyIcon, text: emptyTitle, sub: emptySub));
    }
    return child;
  }
}
