import 'package:bdo_event/core/common/event_image/event_image.dart';
import 'package:bdo_event/features/event_detail_screen/presentation/pages/event_detail_screen.dart';
import 'package:flutter/material.dart';

class BackgroundDecoration extends StatefulWidget {
  const BackgroundDecoration({super.key, required this.widget});

  final EventDetailPage widget;

  @override
  State<BackgroundDecoration> createState() => _BackgroundDecorationState();
}

class _BackgroundDecorationState extends State<BackgroundDecoration> {
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: widget.widget.event.id,
      child: Stack(
        fit: StackFit.expand,
        children: [
          EventImage(path: widget.widget.event.imageUrl, fit: BoxFit.cover),
        ],
      ),
    );
  }
}
