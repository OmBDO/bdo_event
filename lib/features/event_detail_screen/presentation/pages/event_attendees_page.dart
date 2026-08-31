import 'dart:convert';

import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/model/user_model/event_attendee.dart';
import 'package:bdo_event/core/prefs/supabase_store.dart';
import 'package:bdo_event/core/di/app_dependencies.dart';
import 'package:bdo_event/core/common/clipboard_share.dart';
import 'package:bdo_event/core/common/loading_shimmer/loading_shimmer.dart';
import 'package:bdo_event/core/util/resource/app_file.dart';
import 'package:bdo_event/core/util/resource/app_other.dart';
import 'package:bdo_event/core/util/resource/app_text.dart';
import 'package:bdo_event/core/util/ui/app_ui.dart';
import 'package:bdo_event/features/event_detail_screen/domain/usecases/build_attendee_csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gap/gap.dart';

class EventAttendeesPage extends StatelessWidget {
  const EventAttendeesPage({
    super.key,
    required this.event,
    this.clipboardAdapter,
    this.shareAdapter,
  });

  final Event event;
  final ClipboardAdapter? clipboardAdapter;
  final ShareAdapter? shareAdapter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppText.eventAttendees)),
      body: FutureBuilder<List<EventAttendee>>(
        future: getIt<EventStore>().loadEventAttendees(event.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AttendeeListShimmer();
          }
          if (snapshot.hasError) {
            return const Center(child: Text(AppText.unableToLoadAttendees));
          }

          final attendees = snapshot.data ?? const <EventAttendee>[];
          if (attendees.isEmpty) {
            return const Center(child: Text(AppText.noAttendeesRegistered));
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.ios_share_outlined),
                        label: const Text(AppText.shareCsv),
                        onPressed: () => _shareCsv(context, event, attendees),
                      ),
                    ),
                    const Gap(AppSpace.space10),
                    IconButton(
                      tooltip: AppText.copyAttendeeListAsCsv,
                      icon: const Icon(Icons.copy_all_outlined),
                      onPressed: () => _copyCsv(context, event, attendees),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  itemCount: attendees.length,
                  separatorBuilder: (_, _) => const Gap(AppSpace.space10),
                  itemBuilder: (context, index) {
                    final attendee = attendees[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      leading: EventAttendeeAvatar(
                        attendee: attendee,
                        radius: 24,
                      ),
                      title: Text(
                        attendee.displayName,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(AppText.registeredForEvent(event.title)),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _shareCsv(
    BuildContext context,
    Event event,
    List<EventAttendee> attendees,
  ) async {
    final csv = const BuildAttendeeCsv()(
      eventTitle: event.title,
      attendees: attendees,
    );
    final fileName =
      '${_safeFileName(event.title)}_attendees${AppFileFormats.attendeeCsvExtension}';
    await tryShareContent(
      shareAdapter ?? const SharePlusAdapter(),
      ShareParams(
        text: AppText.attendeeListFor(event.title),
        files: [
          XFile.fromData(
            utf8.encode(csv),
            name: fileName,
            mimeType: AppMimeTypes.csv,
          ),
        ],
        fileNameOverrides: [fileName],
      ),
    );
  }

  Future<void> _copyCsv(
    BuildContext context,
    Event event,
    List<EventAttendee> attendees,
  ) async {
    final csv = const BuildAttendeeCsv()(
      eventTitle: event.title,
      attendees: attendees,
    );
    final copied = await tryCopyText(
      clipboardAdapter ?? const SystemClipboardAdapter(),
      csv,
    );
    if (!copied || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppText.attendeeCsvCopied)),
    );
  }

  String _safeFileName(String title) {
    final fileName = title.replaceAll(RegExp(r'[^a-zA-Z0-9_-]+'), '_');
    return fileName.isEmpty ? 'event' : fileName;
  }
}

class EventAttendeeAvatar extends StatelessWidget {
  const EventAttendeeAvatar({
    super.key,
    required this.attendee,
    this.radius = 14,
  });

  final EventAttendee attendee;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final photoUrl = attendee.photoUrl;
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.teal.shade100,
      backgroundImage: photoUrl == null || photoUrl.isEmpty
          ? null
          : NetworkImage(photoUrl),
      child: photoUrl == null || photoUrl.isEmpty
          ? Text(
              attendee.displayName.isEmpty
                  ? '?'
                  : attendee.displayName.trim()[0].toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w800),
            )
          : null,
    );
  }
}
