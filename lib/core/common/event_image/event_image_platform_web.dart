import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<String> storePickedImage(XFile image) async {
  final client = Supabase.instance.client;
  final userId = client.auth.currentUser?.id;
  if (userId == null) throw StateError('Authentication required');

  final imagePath = '$userId/${DateTime.now().microsecondsSinceEpoch}.jpg';
  await client.storage.from('event-images').uploadBinary(
    imagePath,
    await image.readAsBytes(),
    fileOptions: FileOptions(
      contentType: image.mimeType ?? 'image/jpeg',
      upsert: false,
    ),
  );
  return imagePath;
}

Future<String> resolveStoredImageUrl(String path) async {
  if (path.startsWith('http://') || path.startsWith('https://')) return path;
  return Supabase.instance.client.storage
      .from('event-images')
      .createSignedUrl(path, 3600);
}

Future<void> deleteStoredImage(String path) async {
  if (path.startsWith('http://') || path.startsWith('https://')) return;
  await Supabase.instance.client.storage.from('event-images').remove([path]);
}
