import 'package:flutter/material.dart';
import 'package:bdo_event/core/common/event_image/event_image_platform.dart';

class EventImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const EventImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorBuilder,
  });

  bool get _isAsset => path.startsWith('assets/');

  @override
  Widget build(BuildContext context) {
    if (path.isEmpty) {
      return errorBuilder?.call(
            context,
            'Missing event image',
            StackTrace.current,
          ) ??
          const Icon(Icons.image_outlined, color: Colors.grey, size: 48);
    }

    final image = _isAsset
      ? Image.asset(path, width: width, height: height, fit: fit)
      : buildStoredImage(
        path: path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: errorBuilder,
        );
    return image;
  }
}
