import 'package:image_picker/image_picker.dart';

typedef StoreProfileImage = Future<String> Function(XFile image);
typedef DeleteProfileImage = Future<void> Function(String imageUrl);

abstract interface class ProfileImagePicker {
  Future<XFile?> pickImage();
}

class GalleryProfileImagePicker implements ProfileImagePicker {
  GalleryProfileImagePicker({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<XFile?> pickImage() => _picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 85,
    maxWidth: 1200,
  );
}
