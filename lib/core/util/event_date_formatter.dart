import 'package:intl/intl.dart';

String formatEventDate(String value, String pattern) {
  final parsed = _parseEventDate(value);
  if (parsed == null) return value;
  try {
    return DateFormat(pattern).format(parsed);
  } on FormatException {
    return value;
  }
}

DateTime? _parseEventDate(String value) {
  final parts = value.split('/');
  if (parts.length == 3) {
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day != null && month != null && year != null) {
      return DateTime(year, month, day);
    }
  }
  return DateTime.tryParse(value);
}