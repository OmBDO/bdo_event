import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/util/event.resource.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bdo_event/core/util/event_date_formatter.dart';
import 'package:bdo_event/features/profile_screen/presentation/cubit/profile_screen_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:bdo_event/core/deep_link/event_deep_link_service.dart';

class EventDetailHeader extends StatelessWidget {
  const EventDetailHeader({super.key, required this.event});

  final Event event;

  String get _eventLink => EventDeepLinkService.eventUri(event.id).toString();

  Future<void> _shareEvent(BuildContext context) async {
    await SharePlus.instance.share(
      ShareParams(
        title: event.title,
        subject: event.title,
        text: '${event.title}\n$_eventLink',
      ),
    );
  }

  Future<void> _showEventActions(BuildContext context) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share_rounded),
              title: const Text('Share event'),
              onTap: () => Navigator.of(context).pop('share'),
            ),
            ListTile(
              leading: const Icon(Icons.copy_rounded),
              title: const Text(AppText.copyEventDetails),
              onTap: () => Navigator.of(context).pop('copy'),
            ),
          ],
        ),
      ),
    );

    if (!context.mounted) return;
    if (action == 'share') {
      await _shareEvent(context);
      return;
    }
    if (action != 'copy') return;
    await Clipboard.setData(
      ClipboardData(
        text: '${event.title}\n${formatEventDate(event.date, context.read<ProfileScreenCubit>().state.dateFormat)}\n${event.location}',
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