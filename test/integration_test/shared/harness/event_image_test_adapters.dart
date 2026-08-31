import 'dart:typed_data';

import 'package:bdo_event/core/common/event_image/picker.dart';
import 'package:image_picker/image_picker.dart';

class TestEventImagePicker implements EventImagePicker {
  const TestEventImagePicker();

  @override
  Future<XFile?> pickImage() async => XFile.fromData(
    Uint8List.fromList([0, 1, 2, 3]),
    name: 'integration-event.jpg',
    mimeType: 'image/jpeg',
  );
}
