import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/util/event.resource.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

abstract interface class EventStore {
  Future<List<Event>> readCreatedEvents();

  Future<void> createEvent(Event event);

  Future<void> updateEvent(Event event);

  Future<void> deleteEvent(String eventId);

  Future<List<Event>> loadRegistrations(String userId);

  Future<void> writeRegistrations(String userId, List<Event> events);
}

class SupabaseStore implements EventStore {
  SupabaseStore({supabase.SupabaseClient? client})
    : _client = client ?? supabase.Supabase.instance.client;

  final supabase.SupabaseClient _client;

  Future<bool> readNotificationPreference(String userId) async {
    final value = _client.auth.currentUser?.userMetadata?[AppStorageKeys.notificationsEnabled];
    return value is bool ? value : true;
  }

  Future<void> writeNotificationPreference(String userId, bool enabled) async {
    try {
      await _client.auth.updateUser(
        supabase.UserAttributes(
          data: {AppStorageKeys.notificationsEnabled: enabled},
        ),
      );
    } on Object {
      throw const LocalStorageException();
    }
  }

  @override
  Future<List<Event>> readCreatedEvents() async {
    try {
      final rows = await _client
          .from(AppDatabase.eventsTable)
          .select(
            '${AppDatabase.id}, ${AppDatabase.creatorId}, '
            '${AppDatabase.createdAt}, ${AppDatabase.payload}',
          )
          .order(AppDatabase.createdAt);
      return rows.map(_eventFromRow).toList();
    } on Object {
      throw const LocalStorageException();
    }
  }

  @override
  @override
  Future<void> createEvent(Event event) async {
    try {
      await _client.from(AppDatabase.eventsTable).insert(_eventToRow(event));
    } on Object {
      throw const LocalStorageException();
    }
  }

  @override
  Future<void> updateEvent(Event event) async {
    try {
      await _client
          .from(AppDatabase.eventsTable)
          .update(_eventToRow(event))
          .eq(AppDatabase.id, event.id);
    } on Object {
      throw const LocalStorageException();
    }
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    try {
      await _client.from(AppDatabase.eventsTable).delete().eq(AppDatabase.id, eventId);
    } on Object {
      throw const LocalStorageException();
    }
  }

  @override
  Future<List<Event>> loadRegistrations(String userId) async {
    try {
      final rows = await _client
          .from(AppDatabase.eventRegistrationsTable)
            .select(AppDatabase.payload)
          .eq(AppDatabase.userId, userId);
      return rows
            .map((row) => Event.fromJson(_payload(row[AppDatabase.payload])))
          .toList();
    } on Object {
      throw const LocalStorageException();
    }
  }

  @override
  Future<void> writeRegistrations(String userId, List<Event> events) async {
    try {
      await _client
          .from(AppDatabase.eventRegistrationsTable)
          .delete()
          .eq(AppDatabase.userId, userId);
      if (events.isEmpty) return;
      await _client.from(AppDatabase.eventRegistrationsTable).insert([
        for (final event in events)
          {
            AppDatabase.userId: userId,
            AppDatabase.eventId: event.id,
            AppDatabase.payload: event.toJson(),
          },
      ]);
    } on Object {
      throw const LocalStorageException();
    }
  }

  Event _eventFromRow(Map<String, dynamic> row) {
    final payload = _payload(row[AppDatabase.payload]);
    return Event.fromJson({
      ...payload,
      'id': row[AppDatabase.id] ?? payload['id'],
      'creatorId': row[AppDatabase.creatorId] ?? payload['creatorId'],
      'createdAt': row[AppDatabase.createdAt] ?? payload['createdAt'],
    });
  }

  Map<String, dynamic> _eventToRow(Event event) => {
    AppDatabase.id: event.id,
    AppDatabase.creatorId: event.creatorId,
    AppDatabase.createdAt:
        (event.createdAt ?? DateTime.now()).toIso8601String(),
    AppDatabase.payload: event.toJson(),
  };

  Map<String, dynamic> _payload(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    throw const LocalStorageException();
  }
}

class LocalStorageException implements Exception {
  const LocalStorageException();
}