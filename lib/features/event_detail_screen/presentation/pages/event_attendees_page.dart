import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/model/user_model/event_attendee.dart';
import 'package:bdo_event/core/prefs/supabase_store.dart';
import 'package:bdo_event/core/di/app_dependencies.dart';
import 'package:bdo_event/core/common/loading_shimmer/loading_shimmer.dart';
import 'package:flutter/material.dart';

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

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
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
          );
        },
      ),
    );
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