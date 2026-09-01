import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/util/event_schedule.dart';

class EventReminderPolicy {
  static const leadTimeOptions = <int>[60, 1440, 10080];

  static DateTime? eventStartTime(Event event) {
    final date = EventSchedule.eventDate(event);
    final time = event.startTime;
    if (date == null || time == null) return null;

    final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(time.trim());
    if (match == null) return null;
    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    if (hour > 23 || minute > 59) return null;
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  static DateTime? reminderTime(
    Event event, {
    Duration leadTime = const Duration(days: 1),
  }) {
    final eventStart = eventStartTime(event);
    if (eventStart == null) return null;
    return eventStart.subtract(leadTime);
  }

  static int notificationIdFor(String eventId) {
    var hash = 17;
    for (final codeUnit in eventId.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x7fffffff;
    }
    return hash;
  }
}
