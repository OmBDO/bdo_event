import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/util/event.resource.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EventDetailHeader extends StatelessWidget {
  const EventDetailHeader({super.key, required this.event});

  final Event event;

  Future<void> _showEventActions(BuildContext context) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: ListTile(
          leading: const Icon(Icons.copy_rounded),
          title: const Text(AppText.copyEventDetails),
          onTap: () => Navigator.of(context).pop('copy'),
        ),
      ),
    );

    if (!context.mounted || action != 'copy') return;
    await Clipboard.setData(
      ClipboardData(
        text: '${event.title}\n${event.date}\n${event.location}',
      ),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text(AppText.eventDetailsCopied)));
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.28),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
              ),
              IconButton(
                onPressed: () => _showEventActions(context),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.28),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.more_vert_rounded, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}