import 'dart:convert';

import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/model/user_model/local_user_record.dart';

class DatabaseCodec {
  const DatabaseCodec._();

  static Map<String, String> encodeUsers(
    Map<String, LocalUserRecord> users,
  ) {
    return {
      for (final entry in users.entries) entry.key: jsonEncode(entry.value.toJson()),
    };
  }

  static Map<String, String> encodeEvents(List<Event> events) {
    return {
      for (final event in events) event.id: jsonEncode(event.toJson()),
    };
  }

  static Map<String, LocalUserRecord> decodeUsers(
    Map<String, String> records,
  ) {
    final users = <String, LocalUserRecord>{};
    for (final entry in records.entries) {
      try {
        final decoded = jsonDecode(entry.value);
        if (decoded is Map<String, dynamic>) {
          users[entry.key] = LocalUserRecord.fromJson(decoded);
        }
      } on Object {
        continue;
      }
    }
    return users;
  }

  static List<Event> decodeEvents(Iterable<String> records) {
    final events = <Event>[];
    for (final record in records) {
      try {
        final decoded = jsonDecode(record);
        if (decoded is Map<String, dynamic>) {
          events.add(Event.fromJson(decoded));
        }
      } on Object {
        continue;
      }
    }
    return events;
  }
}
