import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

Future<String> storePickedImage(XFile image) async {
  final documentsDirectory = await getApplicationDocumentsDirectory();
  final storedImage = await File(image.path).copy(
    '${documentsDirectory.path}/event_${DateTime.now().microsecondsSinceEpoch}.jpg',
  );
  return storedImage.path;
}

Widget buildStoredImage({
  required String path,
  required double? width,
  required double? height,
  required BoxFit fit,
  required ImageErrorWidgetBuilder? errorBuilder,
}) {
  return Image.file(
    File(path),
    width: width,
    height: height,
    fit: fit,
    errorBuilder: errorBuilder,
  );
}
