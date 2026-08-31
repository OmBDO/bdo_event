import 'dart:typed_data';

import 'package:bdo_event/core/common/profile_image/picker.dart';
import 'package:image_picker/image_picker.dart';

class TestProfileImagePicker implements ProfileImagePicker {
  const TestProfileImagePicker();

  @override
  Future<XFile?> pickImage() async => XFile.fromData(
    Uint8List.fromList([4, 5, 6, 7]),
    name: 'integration-profile.jpg',
    mimeType: 'image/jpeg',
  );
}
