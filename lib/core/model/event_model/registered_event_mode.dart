import 'package:bdo_event/core/util/event_resource.dart';

class EventRegistration {
  final String id;
  final String eventId;
  final String userId;
  final DateTime registeredAt;
  final bool isCheckedIn;

  const EventRegistration({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.registeredAt,
    this.isCheckedIn = false,
  });

  /// Factory blueprint map converting raw SQL data rows directly to Dart objects
  factory EventRegistration.fromSql(Map<String, dynamic> row) {
    return EventRegistration(
      id: row[AppDatabase.id] as String,
      eventId: row[AppDatabase.eventId] as String,
      userId: row[AppDatabase.userId] as String,
      registeredAt: DateTime.parse(row[AppDatabase.registeredAt] as String),
      // SQL handles Booleans as numbers (0 or 1), decode it safely here
      isCheckedIn: (row[AppDatabase.isCheckedIn] as int? ?? 0) == 1,
    );
  }

  /// Exports payload objects directly to SQL table variables execution strings
  Map<String, dynamic> toSqlMap() => {
    AppDatabase.id: id,
    AppDatabase.eventId: eventId,
    AppDatabase.userId: userId,
    AppDatabase.registeredAt: registeredAt.toIso8601String(),
    AppDatabase.isCheckedIn: isCheckedIn ? 1 : 0,
  };
}
