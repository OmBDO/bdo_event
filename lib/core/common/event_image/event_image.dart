import 'package:flutter/material.dart';
import 'package:bdo_event/core/common/event_image/event_image_platform.dart';
import 'package:bdo_event/core/util/event.resource.dart';

class EventImage extends StatefulWidget {
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

  @override
  State<EventImage> createState() => _EventImageState();
}

class _EventImageState extends State<EventImage> {
  late Future<String> _storedImageUrl;

  @override
  void initState() {
    super.initState();
    _storedImageUrl = _resolvePath(widget.path);
  }

  @override
  void didUpdateWidget(covariant EventImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      _storedImageUrl = _resolvePath(widget.path);
    }
  }

  Future<String> _resolvePath(String path) {
    if (path.isEmpty || path.startsWith(AppAssets.assetPathPrefix)) {
      return Future.value(path);
    }
    return resolveStoredImageUrl(path);
  }

  bool get _isAsset => widget.path.startsWith(AppAssets.assetPathPrefix);

  @override
  Widget build(BuildContext context) {
    if (widget.path.isEmpty) {
      return widget.errorBuilder?.call(
            context,
            AppText.missingEventImage,
            StackTrace.current,
          ) ??
          const Icon(Icons.image_outlined, color: Colors.grey, size: 48);
    }

    if (_isAsset) {
      return Image.asset(
        widget.path,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
      );
    }

    return FutureBuilder<String>(
      future: _storedImageUrl,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return widget.errorBuilder?.call(
                context,
                snapshot.error!,
                snapshot.stackTrace,
              ) ??
              const Icon(Icons.image_outlined, color: Colors.grey, size: 48);
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return Image.network(
          snapshot.data!,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          errorBuilder: widget.errorBuilder,
        );
      },
    );
  }
}
