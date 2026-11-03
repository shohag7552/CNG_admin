import 'package:appwrite_boilerplate/app/common/widgets/custom_toster.dart';
import 'package:appwrite_boilerplate/app/resources/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

/// Hands a deep link out to whatever the platform uses for sharing.
///
/// The link points at the deployed web build ([Constants.webBaseUrl]) rather
/// than a custom scheme, so it opens for recipients without the app; the same
/// path is claimed by the Android App Link / iOS Universal Link.
class ShareHelper {
  ShareHelper._();

  /// Public URL of an in-app [path] such as `/item/123`.
  static Uri urlFor(String path) => Uri.parse('${Constants.webBaseUrl}$path');

  /// Opens the share sheet for [title] + the link to [path]. Falls back to
  /// copying the link when sharing is unavailable or fails.
  ///
  /// [context] should belong to the triggering widget: iPadOS anchors its
  /// share popover to that rect and throws without one.
  static Future<void> share(
    BuildContext context, {
    required String title,
    required String path,
  }) async {
    final url = urlFor(path);
    try {
      final result = await SharePlus.instance.share(
        ShareParams(
          text: '$title\n\n$url',
          subject: title,
          sharePositionOrigin: _originOf(context),
        ),
      );
      if (result.status == ShareResultStatus.unavailable) await _copyLink(url);
    } catch (_) {
      await _copyLink(url);
    }
  }

  static Rect? _originOf(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  static Future<void> _copyLink(Uri url) async {
    await Clipboard.setData(ClipboardData(text: url.toString()));
    customToster('link_copied'.tr, isSuccess: true);
  }
}
