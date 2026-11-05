import 'package:appwrite_boilerplate/app/common/widgets/admin_card.dart';
import 'package:appwrite_boilerplate/app/resources/colors.dart';
import 'package:appwrite_boilerplate/app/resources/constants.dart';
import 'package:appwrite_boilerplate/app/resources/text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Image boxes for the documents a reviewer checks. Placeholders until the
/// storage bucket is wired (then they show the uploaded file).
class DocumentPlaceholders extends StatelessWidget {
  const DocumentPlaceholders({super.key});

  @override
  Widget build(BuildContext context) {
    final docs = {
      'doc_driving_licence': Icons.badge_outlined,
      'doc_vehicle_registration': Icons.description_outlined,
      'doc_vehicle_photo': Icons.photo_camera_outlined,
    };
    return AdminCard(
      title: 'documents'.tr,
      child: Wrap(
        spacing: Constants.paddingSizeDefault,
        runSpacing: Constants.paddingSizeDefault,
        children: [
          for (final e in docs.entries)
            SizedBox(
              width: Constants.statCardMinWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: Constants.documentBoxHeight,
                    decoration: BoxDecoration(
                      color: context.textLight.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(Constants.radiusDefault),
                      border: Border.all(color: context.textLight.withValues(alpha: 0.3)),
                    ),
                    child: Center(
                        child: Icon(e.value,
                            size: Constants.iconSizeLarge, color: context.textLight)),
                  ),
                  const SizedBox(height: Constants.paddingSizeExtraSmall),
                  Text(e.key.tr,
                      style: poppinsMedium.copyWith(
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
