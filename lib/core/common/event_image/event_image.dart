import 'package:flutter/material.dart';
import 'package:bdo_event/core/common/event_image/event_image_platform.dart';
import 'package:bdo_event/core/util/event_resource.dart';

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

class _CachedImageUrl {
  const _CachedImageUrl(this.url, this.expiresAt);

  final String url;
  final DateTime expiresAt;
}

class _EventImageState extends State<EventImage> {
  static final Map<String, _CachedImageUrl> _urlCache = {};
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

    final cached = _urlCache[path];
    if (cached != null && cached.expiresAt.isAfter(DateTime.now())) {
      return Future.value(cached.url);
    }

    return resolveStoredImageUrl(path).then((url) {
      _urlCache[path] = _CachedImageUrl(
        url,
        DateTime.now().add(const Duration(minutes: 50)),
      );
      return url;
    });
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
          Icon(
            Icons.image_outlined,
            color: Theme.of(context).colorScheme.onSurface.withValues(
              alpha: 0.45,
            ),
            size: 48,
          );
    }

    if (_isAsset) {
      return Image.asset(
        widget.path,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        frameBuilder: _frameBuilder,
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
              Icon(
                Icons.image_outlined,
                color: Theme.of(context).colorScheme.onSurface.withValues(
                  alpha: 0.45,
                ),
                size: 48,
              );
        }
        if (!snapshot.hasData) {
          return const _ImageLoadingPlaceholder();
        }
        return Image.network(
          snapshot.data!,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          frameBuilder: _frameBuilder,
          errorBuilder: widget.errorBuilder,
        );
      },
    );
  }

  Widget _frameBuilder(
    BuildContext context,
    Widget child,
    int? frame,
    bool wasSynchronouslyLoaded,
  ) {
    if (wasSynchronouslyLoaded || frame != null) return child;
    return const _ImageLoadingPlaceholder();
  }
}

class _ImageLoadingPlaceholder extends StatefulWidget {
  const _ImageLoadingPlaceholder();

  @override
  State<_ImageLoadingPlaceholder> createState() =>
      _ImageLoadingPlaceholderState();
}

class _ImageLoadingPlaceholderState extends State<_ImageLoadingPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, child) => Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-1.5 + (_controller.value * 3), -1),
          end: Alignment(-0.5 + (_controller.value * 3), 1),
          colors: Theme.of(context).brightness == Brightness.dark
              ? [
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.surfaceContainerHighest,
                  Theme.of(context).colorScheme.surface,
                ]
              : const [
                  Color(0xFFFFF1E6),
                  Color(0xFFFFDCC8),
                  Color(0xFFFFF1E6),
                ],
        ),
      ),
      child: child,
    ),
    child: Center(
      child: Icon(
        Icons.image_outlined,
        color: Theme.of(context).colorScheme.primary,
        size: 34,
      ),
    ),
  );
}
