import 'package:share_plus/share_plus.dart';
import 'package:talbna/utils/constants.dart';

class ShareUtils {
  // Constants for link types
  static const String TYPE_REELS = "reels";
  static const String TYPE_POST = "post";

  // Differentiated sharing method with type parameter
  static Future<void> shareServicePost(
      int postId,
      {String? title, required String type}
      ) async {
    // Create different URLs based on the source type
    String url;
    if (type == TYPE_REELS) {
      url = '${Constants.apiBaseUrl}/api/deep-link/reels/$postId';
    } else {
      url = '${Constants.apiBaseUrl}/api/deep-link/service-post/$postId';
    }

    String shareText;
    if (title != null && title.isNotEmpty) {
      shareText = 'Check out this $type: $title\n$url';
    } else {
      shareText = 'Check out this $type\n$url';
    }

    await Share.share(
      shareText,
      subject: title ?? 'Shared $type',
    );
  }

  // Helper methods for specific content types
  static Future<void> shareReel(int postId, {String? title}) async {
    await shareServicePost(postId, title: title, type: TYPE_REELS);
  }

  static Future<void> sharePost(int postId, {String? title}) async {
    await shareServicePost(postId, title: title, type: TYPE_POST);
  }
}