import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

/// Centralized share utilities to avoid duplicating share logic.
class ShareService {
  /// Shares plain text via the native share sheet.
  static Future<void> shareText(String text) async {
    final payload = text.trim();
    if (payload.isEmpty) {
      debugPrint('ShareService.shareText: nothing to share');
      return;
    }
    try {
      await Share.share(payload);
      debugPrint('ShareService.shareText: invoked native share sheet');
    } catch (e) {
      debugPrint('ShareService.shareText: error -> $e');
    }
  }

  /// Shares a Duʿā using the app-required formatting.
  /// If [title] is null/empty, only the body is shared.
  /// Format when title present:
  ///   Title (if available): <title>
  ///   Body: <body>
  static Future<void> shareDua({String? title, required String body}) async {
    final cleanedBody = body.trim();
    if (cleanedBody.isEmpty) {
      debugPrint('ShareService.shareDua: body is empty, aborting');
      return;
    }
    final cleanedTitle = (title ?? '').trim();
    final payload = cleanedTitle.isNotEmpty
        ? '$cleanedTitle\n\n$cleanedBody'
        : cleanedBody;
    try {
      await Share.share(payload);
      debugPrint('ShareService.shareDua: invoked native share sheet');
    } catch (e) {
      debugPrint('ShareService.shareDua: error -> $e');
    }
  }
}
