import 'package:image_picker/image_picker.dart';

typedef StoreEventImage = Future<String> Function(XFile image);
typedef DeleteEventImage = Future<void> Function(String path);

abstract interface class EventImagePicker {
  Future<XFile?> pickImage();
}

class GalleryEventImagePicker implements EventImagePicker {
  GalleryEventImagePicker({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<XFile?> pickImage() => _picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 85,
    maxWidth: 1600,
  );
}
