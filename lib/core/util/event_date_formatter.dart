import 'package:bdo_event/core/util/event_schedule.dart';
import 'package:intl/intl.dart';

String formatEventDate(String value, String pattern) {
  final parsed = EventSchedule.parseEventDate(value);
  if (parsed == null) return value;
  try {
    return DateFormat(pattern).format(parsed);
  } on FormatException {
    return value;
  }
}

String formatEventTime(String? value) {
  if (value == null || value.trim().isEmpty) return '--:--';
  final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(value.trim());
  if (match == null) return value;
  final hour = int.tryParse(match.group(1)!);
  final minute = int.tryParse(match.group(2)!);
  if (hour == null || minute == null || hour > 23 || minute > 59) {
    return value;
  }
  final time = DateTime(2000, 1, 1, hour, minute);
  return DateFormat('h:mm a').format(time);
}