import 'dart:convert';

import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/model/user_model/event_attendee.dart';
import 'package:bdo_event/core/prefs/supabase_store.dart';
import 'package:bdo_event/core/di/app_dependencies.dart';
import 'package:bdo_event/core/common/loading_shimmer/loading_shimmer.dart';
import 'package:bdo_event/features/event_detail_screen/domain/usecases/build_attendee_csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class EventAttendeesPage extends StatelessWidget {
  const EventAttendeesPage({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event attendees')),
      body: FutureBuilder<List<EventAttendee>>(
        future: getIt<EventStore>().loadEventAttendees(event.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AttendeeListShimmer();
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Unable to load attendees'));
          }

          final attendees = snapshot.data ?? const <EventAttendee>[];
          if (attendees.isEmpty) {
            return const Center(child: Text('No attendees registered yet'));
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
                        label: const Text('Share CSV'),
                        onPressed: () => _shareCsv(context, event, attendees),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      tooltip: 'Copy attendee list as CSV',
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
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final attendee = attendees[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      leading: EventAttendeeAvatar(attendee: attendee, radius: 24),
                      title: Text(
                        attendee.displayName,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text('Registered for ${event.title}'),
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
    final fileName = '${_safeFileName(event.title)}_attendees.csv';
    await SharePlus.instance.share(
      ShareParams(
        text: 'Attendee list for ${event.title}',
        files: [XFile.fromData(utf8.encode(csv), name: fileName, mimeType: 'text/csv')],
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
    await Clipboard.setData(ClipboardData(text: csv));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendee CSV copied')),
      );
    }
  }

  String _safeFileName(String title) {
    final fileName = title.replaceAll(RegExp(r'[^a-zA-Z0-9_-]+'), '_');
    return fileName.isEmpty ? 'event' : fileName;
  }
}

class EventAttendeeAvatar extends StatelessWidget {
  const EventAttendeeAvatar({required this.attendee, this.radius = 14});

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