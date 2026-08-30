import 'package:bdo_event/core/model/user_model/event_attendee.dart';

class BuildAttendeeCsv {
  const BuildAttendeeCsv();

  String call({required String eventTitle, required List<EventAttendee> attendees}) {
    final rows = <String>[
      'Event,Attendee name,User ID',
      for (final attendee in attendees)
        '${_escape(eventTitle)},${_escape(attendee.displayName)},${_escape(attendee.userId)}',
    ];
    return rows.join('\n');
  }

  String _escape(String value) => '"${value.replaceAll('"', '""')}"';
}
