import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/model/user_model/event_attendee.dart';
import 'package:bdo_event/core/model/notification_model/notification_model.dart';
import 'package:bdo_event/core/common/supabase_request_logger/supabase_request_logger.dart';
import 'package:bdo_event/core/util/event_resource.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

abstract interface class EventStore {
  Future<List<Event>> readCreatedEvents();

  Future<void> createEvent(Event event);

  Future<void> updateEvent(Event event);

  Future<void> deleteEvent(String eventId);

  Future<List<Event>> loadRegistrations(String userId);

  Future<Map<String, int>> loadRegistrationCounts(List<String> eventIds);

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

  Future<int> loadCheckedInCount(String eventId);

  Future<List<EventAttendee>> loadEventAttendees(String eventId);

  Future<List<AppNotification>> loadNotifications();

  Future<int> loadUnreadNotificationCount();

  Future<void> markNotificationRead(String notificationId);

  Future<void> updateArrivalStatus({
    required String eventId,
    required ArrivalStatus status,
  });

  Future<void> recordLoginActivity({String? deviceLabel, String? platform});

  Future<Map<String, String>> loadProfileVisibility(String userId);

  Future<void> saveProfileVisibility({
    required String userId,
    required String profileVisibility,
    required String registrationVisibility,
  });

  Future<List<Map<String, String>>> loadInvitationRecipients();

  Future<int> sendEventInvitations({
    required String eventId,
    required List<String> userIds,
  });

  Future<void> respondToEventInvitation({
    required String eventId,
    required bool accepted,
  });
}

class SupabaseStore implements EventStore {
  SupabaseStore({
    supabase.SupabaseClient? client,
    this._logger = const SupabaseRequestLogger(),
  }) : _client = client ?? supabase.Supabase.instance.client;

  final supabase.SupabaseClient _client;
  final SupabaseRequestLogger _logger;

  @override
  Future<void> recordLoginActivity({
    String? deviceLabel,
    String? platform,
  }) async {
    try {
      await _logger.track(
        'rpc.recordLoginActivity',
        () => _client.rpc(
          'record_login_activity',
          params: {
            'requested_device_label': deviceLabel,
            'requested_platform': platform,
          },
        ),
        parameters: {'platform': platform},
      );
    } on Object {
      throw const LocalStorageException();
    }
  }

  @override
  Future<Map<String, String>> loadProfileVisibility(String userId) async {
    try {
      final row = await _client
          .from('profile_visibility_settings')
          .select('profile_visibility, registration_visibility')
          .eq('user_id', userId)
          .maybeSingle();
      return {
        'profile_visibility':
            row?['profile_visibility'] as String? ?? 'private',
        'registration_visibility':
            row?['registration_visibility'] as String? ?? 'private',
      };
    } on Object {
      throw const LocalStorageException();
    }
  }

  @override
  Future<void> saveProfileVisibility({
    required String userId,
    required String profileVisibility,
    required String registrationVisibility,
  }) async {
    try {
      await _client.from('profile_visibility_settings').upsert({
        'user_id': userId,
        'profile_visibility': profileVisibility,
        'registration_visibility': registrationVisibility,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } on Object {
      throw const LocalStorageException();
    }
  }

  @override
  Future<List<Map<String, String>>> loadInvitationRecipients() async {
    try {
      final rows = await _client.rpc('list_invitation_recipients');
      return (rows as List<dynamic>).map((row) {
        final value = row as Map<String, dynamic>;
        return {
          'id': value['user_id'].toString(),
          'name': value['display_name'] as String? ?? '',
          'email': value['email'] as String? ?? '',
        };
      }).toList();
    } on Object {
      throw const LocalStorageException();
    }
  }

  @override
  Future<int> sendEventInvitations({
    required String eventId,
    required List<String> userIds,
  }) async {
    try {
      final result = await _client.rpc(
        'send_event_invitations',
        params: {'requested_event_id': eventId, 'requested_user_ids': userIds},
      );
      return (result as num?)?.toInt() ?? 0;
    } on Object {
      throw const LocalStorageException();
    }
  }

  @override
  Future<void> respondToEventInvitation({
    required String eventId,
    required bool accepted,
  }) async {
    try {
      await _client.rpc(
        'respond_to_event_invitation',
        params: {
          'requested_event_id': eventId,
          'requested_status': accepted ? 'accepted' : 'declined',
        },
      );
    } on Object {
      throw const LocalStorageException();
    }
  }

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
  Future<Map<String, int>> loadRegistrationCounts(List<String> eventIds) async {
    if (eventIds.isEmpty) return const {};
    try {
      final rows = await _logger.track(
        'rpc.loadEventRegistrationCounts',
        () => _client.rpc(
          'load_event_registration_counts',
          params: {'requested_event_ids': eventIds},
        ),
        parameters: {'eventIds': eventIds},
      );
      return {
        for (final row in rows as List<dynamic>)
          (row['eventId'] as String): (row['registrationCount'] as num).toInt(),
      };
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
    } on supabase.PostgrestException catch (error) {
      throw LocalStorageException(error.message);
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

  @override
  Future<int> loadCheckedInCount(String eventId) async {
    try {
      final result = await _logger.track(
        'rpc.loadEventCheckInCount',
        () => _client.rpc(
          'load_event_check_in_count',
          params: {'requested_event_id': eventId},
        ),
        parameters: {'eventId': eventId},
      );
      return (result as num).toInt();
    } on Object {
      throw const LocalStorageException();
    }
  }

  @override
  Future<List<EventAttendee>> loadEventAttendees(String eventId) async {
    try {
      final rows = await _logger.track(
        'rpc.loadEventAttendees',
        () => _client.rpc(
          'load_event_attendees',
          params: {'requested_event_id': eventId},
        ),
        parameters: {'eventId': eventId},
      );
      return (rows as List<dynamic>)
          .map((row) => EventAttendee.fromJson(row as Map<String, dynamic>))
          .toList();
    } on Object {
      throw const LocalStorageException();
    }
  }

  @override
  Future<List<AppNotification>> loadNotifications() async {
    try {
      final rows = await _logger.track(
        'rpc.loadUserNotifications',
        () => _client.rpc('load_user_notifications'),
      );
      return (rows as List<dynamic>)
          .map((row) => AppNotification.fromJson(row as Map<String, dynamic>))
          .toList();
    } on Object {
      throw const LocalStorageException();
    }
  }

  @override
  Future<int> loadUnreadNotificationCount() async {
    try {
      final result = await _logger.track(
        'rpc.countUserUnreadNotifications',
        () => _client.rpc('count_user_unread_notifications'),
      );
      return (result as num).toInt();
    } on Object {
      throw const LocalStorageException();
    }
  }

  @override
  Future<void> markNotificationRead(String notificationId) async {
    try {
      await _logger.track(
        'rpc.markNotificationRead',
        () => _client.rpc(
          'mark_notification_read',
          params: {'requested_notification_id': int.parse(notificationId)},
        ),
        parameters: {'notificationId': notificationId},
      );
    } on Object {
      throw const LocalStorageException();
    }
  }

  @override
  Future<void> updateArrivalStatus({
    required String eventId,
    required ArrivalStatus status,
  }) async {
    try {
      await _logger.track(
        'rpc.updateArrivalStatus',
        () => _client.rpc(
          'update_event_arrival_status',
          params: {
            'requested_event_id': eventId,
            'requested_status': switch (status) {
              ArrivalStatus.attending => 'attending',
              ArrivalStatus.notAttending => 'not_attending',
              ArrivalStatus.pending => 'pending',
            },
          },
        ),
        parameters: {'eventId': eventId, 'status': status.name},
      );
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
  const LocalStorageException([this.message]);

  final String? message;
}
