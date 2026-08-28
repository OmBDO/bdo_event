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
      id: row['id'] as String,
      eventId: row['event_id'] as String,
      userId: row['user_id'] as String,
      registeredAt: DateTime.parse(row['registered_at'] as String),
      // SQL handles Booleans as numbers (0 or 1), decode it safely here
      isCheckedIn: (row['is_checked_in'] as int? ?? 0) == 1,
    );
  }

  /// Exports payload objects directly to SQL table variables execution strings
  Map<String, dynamic> toSqlMap() => {
    'id': id,
    'event_id': eventId,
    'user_id': userId,
    'registered_at': registeredAt.toIso8601String(),
    'is_checked_in': isCheckedIn ? 1 : 0, // Encode true as 1, false as 0
  };
}
