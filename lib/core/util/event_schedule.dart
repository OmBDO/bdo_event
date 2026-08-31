import 'package:bdo_event/core/model/event_model/event_model.dart';

abstract final class EventSchedule {
  static DateTime? eventDate(Event event) => parseEventDate(event.date);

  static DateTime? parseEventDate(String value) {
    final parts = value.split('/');
    if (parts.length == 3) {
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day != null && month != null && year != null) {
        final date = DateTime(year, month, day);
        return date.year == year &&
                date.month == month &&
                date.day == day
            ? date
            : null;
      }
    }

    final parsed = DateTime.tryParse(value);
    return parsed == null
        ? null
        : DateTime(parsed.year, parsed.month, parsed.day);
  }

  static bool isFinished(Event event, {DateTime? now}) {
    final date = eventDate(event);
    if (date == null) return false;

    final endTime = _parseTime(event.endTime);
    final eventEnd = endTime == null
        ? DateTime(date.year, date.month, date.day + 1)
        : DateTime(date.year, date.month, date.day, endTime.$1, endTime.$2);
    return !(now ?? DateTime.now()).isBefore(eventEnd);
  }

  static bool isUpcoming(Event event, {DateTime? now}) =>
      eventDate(event) != null && !isFinished(event, now: now);

  static (int, int)? _parseTime(String? value) {
    if (value == null) return null;
    final match = RegExp(r'^\s*(\d{1,2}):(\d{2})\s*$').firstMatch(value);
    if (match == null) return null;

    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    if (hour > 23 || minute > 59) return null;
    return (hour, minute);
  }
}
