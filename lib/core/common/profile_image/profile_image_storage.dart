import 'package:bdo_event/core/util/resource/app_buckets.dart';

String? profileImageStoragePathFromPublicUrl(String imageUrl) {
  final uri = Uri.tryParse(imageUrl);
  if (uri == null) return null;

  final segments = uri.pathSegments;
  if (segments.length < 6 ||
      segments.take(4).join('/') != 'storage/v1/object/public' ||
      segments[4] != AppStorageBuckets.profileImages) {
    return null;
  }

  final path = segments.skip(5).join('/');
  return path.isEmpty ? null : path;
}
