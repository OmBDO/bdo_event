import 'package:bdo_event/core/util/resource/app_other.dart';
import 'package:bdo_event/core/util/resource/app_buckets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'profile_image_storage.dart';

Future<String> storePickedProfileImage(XFile image) async {
  final client = Supabase.instance.client;
  final userId = client.auth.currentUser?.id;
  if (userId == null) throw StateError('Authentication required');

  final path = '$userId/${DateTime.now().microsecondsSinceEpoch}.jpg';
  await client.storage.from(AppStorageBuckets.profileImages).uploadBinary(
    path,
    await image.readAsBytes(),
    fileOptions: FileOptions(
      contentType: image.mimeType ?? AppMimeTypes.jpeg,
      upsert: false,
    ),
  );
  return client.storage
      .from(AppStorageBuckets.profileImages)
      .getPublicUrl(path);
}

Future<void> deleteStoredProfileImage(String imageUrl) async {
  final path = profileImageStoragePathFromPublicUrl(imageUrl);
  if (path == null) return;
  await Supabase.instance.client.storage
      .from(AppStorageBuckets.profileImages)
      .remove([path]);
}
