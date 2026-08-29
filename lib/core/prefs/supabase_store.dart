import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/common/supabase_request_logger/supabase_request_logger.dart';
import 'package:bdo_event/core/util/event.resource.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

abstract interface class EventStore {
  Future<List<Event>> readCreatedEvents();

  Future<void> createEvent(Event event);

  Future<void> updateEvent(Event event);

  Future<void> deleteEvent(String eventId);

  Future<List<Event>> loadRegistrations(String userId);

  Future<void> writeRegistrations(String userId, List<Event> events);

  Future<void> activateRegistration(String userId, Event event);

  Future<void> revokeRegistration(String userId, String eventId);

  Future<String?> loadRegistrationToken(String userId, String eventId);

  Future<Map<String, dynamic>?> validateRegistration({
    required String token,
    required String eventId,
  });

  Future<String> checkInRegistration({
    required String token,
    required String eventId,
  });

  Future<int> loadAttendanceCount(String eventId);
}

class SupabaseStore implements EventStore {
  SupabaseStore({
    supabase.SupabaseClient? client,
    this._logger = const SupabaseRequestLogger(),
  }) : _client = client ?? supabase.Supabase.instance.client;

  final supabase.SupabaseClient _client;
  final SupabaseRequestLogger _logger;

  Future<bool> readNotificationPreference(String userId) async {
    final value = _client
        .auth
        .currentUser
        ?.userMetadata?[AppStorageKeys.notificationsEnabled];
    return value is bool ? value : true;
  }

  Future<void> writeNotificationPreference(String userId, bool enabled) async {
    try {
      await _logger.track(
        'auth.updateUser',
        () => _client.auth.updateUser(
          supabase.UserAttributes(
            data: {AppStorageKeys.notificationsEnabled: enabled},
          ),
        ),
        parameters: {'notificationsEnabled': enabled},
      );
    } on Object {
      throw const LocalStorageException();
    }
  }

  @override
  Future<List<Event>> readCreatedEvents() async {
    try {
      final rows = await _logger.track(
        'events.select',
        () => _client
            .from(AppDatabase.eventsTable)
            .select(
              '${AppDatabase.id}, ${AppDatabase.creatorId}, '
              '${AppDatabase.createdAt}, ${AppDatabase.payload}',
            )
            .order(AppDatabase.createdAt),
      );
      return rows.map(_eventFromRow).toList();
    } on Object {
      throw const LocalStorageException();
    }
  }

  @override
  Future<void> createEvent(Event event) async {
    try {
      await _logger.track(
        'events.insert',
        () => _client.from(AppDatabase.eventsTable).insert(_eventToRow(event)),
        parameters: {'eventId': event.id},
      );
    } on Object {
      throw const LocalStorageException();
    }
  }

  @override
  Future<void> updateEvent(Event event) async {
    try {
      await _logger.track(
        'events.update',
        () => _client
            .from(AppDatabase.eventsTable)
            .update(_eventToRow(event))
            .eq(AppDatabase.id, event.id),
        parameters: {'eventId': event.id},
      );
    } on Object {
      throw const LocalStorageException();
    }
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    try {
      await _logger.track(
        'events.delete',
        () => _client
            .from(AppDatabase.eventsTable)
            .delete()
            .eq(AppDatabase.id, eventId),
        parameters: {'eventId': eventId},
      );
    } on Object {
      throw const LocalStorageException();
    }
  }

  @override
  Future<List<Event>> loadRegistrations(String userId) async {
    try {
      final rows = await _logger.track(
        'registrations.selectActive',
        () => _client
            .from(AppDatabase.eventRegistrationsTable)
            .select(AppDatabase.payload)
            .eq(AppDatabase.userId, userId)
            .eq(AppDatabase.registrationStatus, AppDatabase.activeRegistration),
        parameters: {'userId': userId},
      );
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
      await _logger.track(
        'registrations.deleteForUser',
        () => _client
            .from(AppDatabase.eventRegistrationsTable)
            .delete()
            .eq(AppDatabase.userId, userId),
        parameters: {'userId': userId},
      );
      if (events.isEmpty) return;
      await _logger.track(
        'registrations.insertBatch',
        () => _client.from(AppDatabase.eventRegistrationsTable).insert([
          for (final event in events)
            {
              AppDatabase.userId: userId,
              AppDatabase.eventId: event.id,
              AppDatabase.payload: event.toJson(),
            },
        ]),
        parameters: {'userId': userId, 'count': events.length},
      );
    } on Object {
      throw const LocalStorageException();
    }
  }

  @override
  Future<void> activateRegistration(String userId, Event event) async {
    try {
      await _logger.track(
        'rpc.activateEventRegistration',
        () => _client.rpc(
          'activate_event_registration',
          params: {
            'requested_event_id': event.id,
            'event_payload': event.toJson(),
          },
        ),
        parameters: {'eventId': event.id, 'userId': userId},
      );
    } on Object {
      throw const LocalStorageException();
    }
  }

  @override
  Future<void> revokeRegistration(String userId, String eventId) async {
    try {
      await _logger.track(
        'rpc.revokeEventRegistration',
        () => _client.rpc(
          'revoke_event_registration',
          params: {'requested_event_id': eventId},
        ),
        parameters: {'eventId': eventId, 'userId': userId},
      );
    } on Object {
      throw const LocalStorageException();
    }
  }

  @override
  Future<String?> loadRegistrationToken(String userId, String eventId) async {
    try {
      final row = await _logger.track(
        'registrations.selectToken',
        () => _client
            .from(AppDatabase.eventRegistrationsTable)
            .select(AppDatabase.registrationToken)
            .eq(AppDatabase.userId, userId)
            .eq(AppDatabase.eventId, eventId)
            .eq(AppDatabase.registrationStatus, AppDatabase.activeRegistration)
            .maybeSingle(),
        parameters: {'userId': userId, 'eventId': eventId},
      );
      return row?[AppDatabase.registrationToken] as String?;
    } on Object {
      throw const LocalStorageException();
    }
  }

  @override
  Future<Map<String, dynamic>?> validateRegistration({
    required String token,
    required String eventId,
  }) async {
    try {
      final result = await _logger.track(
        'rpc.validateEventRegistration',
        () => _client.rpc(
          'validate_event_registration',
          params: {'requested_token': token, 'requested_event_id': eventId},
        ),
        parameters: {'eventId': eventId, 'token': token},
      );
      if (result is List && result.isNotEmpty && result.first is Map) {
        return Map<String, dynamic>.from(result.first as Map);
      }
      return null;
    } on Object {
      throw const LocalStorageException();
    }
  }

  @override
  Future<String> checkInRegistration({
    required String token,
    required String eventId,
  }) async {
    try {
      final result = await _logger.track(
        'rpc.checkInEventRegistration',
        () => _client.rpc(
          'check_in_event_registration',
          params: {'requested_token': token, 'requested_event_id': eventId},
        ),
        parameters: {'eventId': eventId, 'token': token},
      );
      return result as String? ?? 'invalid';
    } on Object {
      throw const LocalStorageException();
    }
  }

  @override
  Future<int> loadAttendanceCount(String eventId) async {
    try {
      final result = await _logger.track(
        'rpc.loadEventAttendanceCount',
        () => _client.rpc(
          'load_event_attendance_count',
          params: {'requested_event_id': eventId},
        ),
        parameters: {'eventId': eventId},
      );
      return (result as num).toInt();
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
    AppDatabase.createdAt: (event.createdAt ?? DateTime.now())
        .toIso8601String(),
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
