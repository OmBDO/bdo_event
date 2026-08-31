import 'package:bdo_event/core/util/resource/app_buckets.dart';
import 'package:bdo_event/core/util/resource/app_file.dart';
import 'package:bdo_event/core/util/resource/app_other.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<String> storePickedImage(XFile image) async {
  final client = Supabase.instance.client;
  final userId = client.auth.currentUser?.id;
  if (userId == null) throw StateError('Authentication required');

  final imagePath =
      '$userId/${DateTime.now().microsecondsSinceEpoch}${AppFileFormats.eventImageExtension}';
  await client.storage
      .from(AppStorageBuckets.eventImages)
      .uploadBinary(
        imagePath,
        await image.readAsBytes(),
        fileOptions: FileOptions(
          contentType: image.mimeType ?? AppMimeTypes.jpeg,
          upsert: false,
        ),
      );
  return imagePath;
}

Future<String> resolveStoredImageUrl(String path) async {
  if (path.startsWith('http://') || path.startsWith('https://')) return path;
  return Supabase.instance.client.storage
      .from(AppStorageBuckets.eventImages)
      .createSignedUrl(path, 3600);
}

Future<void> deleteStoredImage(String path) async {
  if (path.startsWith('http://') || path.startsWith('https://')) return;
  await Supabase.instance.client.storage
      .from(AppStorageBuckets.eventImages)
      .remove([path]);
}
