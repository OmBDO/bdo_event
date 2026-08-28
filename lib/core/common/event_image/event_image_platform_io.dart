import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:bdo_event/core/util/event.resource.dart';

Future<String> storePickedImage(XFile image) async {
  final documentsDirectory = await getApplicationDocumentsDirectory();
  final storedImage = await File(image.path).copy(
    '${documentsDirectory.path}/${AppIdentifiers.storedEventFilePrefix}${DateTime.now().microsecondsSinceEpoch}${AppIdentifiers.storedEventFileExtension}',
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
