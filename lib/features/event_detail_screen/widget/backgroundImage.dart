import 'package:bdo_event/core/common/event_image/event_image.dart';
import 'package:bdo_event/features/event_detail_screen/page/event_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BackgroundDecoration extends StatefulWidget {
  const new({super.key, required this.widget});

  final EventDetailPage widget;

  @override
  State<BackgroundDecoration> createState() => _BackgroundDecorationState();
}

class _BackgroundDecorationState extends State<BackgroundDecoration> {
  Future<void> _showEventActions() async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: ListTile(
          leading: const Icon(Icons.copy_rounded),
          title: const Text('Copy event details'),
          onTap: () => Navigator.of(context).pop('copy'),
        ),
      ),
    );

    if (!mounted || action != 'copy') return;
    await Clipboard.setData(
      ClipboardData(
        text:
            '${widget.widget.event.title}\n${widget.widget.event.date}\n${widget.widget.event.location}',
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Event details copied')));
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: widget.widget.event.id,
      child: Stack(
        fit: StackFit.expand,
        children: [
          EventImage(path: widget.widget.event.imageUrl, fit: BoxFit.cover),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Circle Button
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                    ),
                  ),
                  // More Circle Button
                  IconButton(
                    onPressed: _showEventActions,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.more_vert_rounded, size: 18),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
