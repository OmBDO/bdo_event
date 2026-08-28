import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<String> storePickedImage(XFile image) async => image.path;

Widget buildStoredImage({
  required String path,
  required double? width,
  required double? height,
  required BoxFit fit,
  required ImageErrorWidgetBuilder? errorBuilder,
}) {
  return Image.network(
    path,
    width: width,
    height: height,
    fit: fit,
    errorBuilder: errorBuilder,
  );
}
