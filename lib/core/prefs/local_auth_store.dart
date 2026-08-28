import 'dart:convert';

import 'package:bdo_event/core/db/utility/database_codec.dart';
import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/model/user_model/local_user_record.dart';
import 'package:bdo_event/core/db/local_database.dart';
import 'package:bdo_event/core/prefs/share_pref.dart';

class LocalAuthStore {
  static const _usersKey = 'auth_users';
  static const _sessionKey = 'auth_session';
  static const _legacyRegistrationsKey = 'auth_registrations';
  static const _registrationsPrefix = 'auth_registrations:';
  static const _legacyRegistrationOwnerKey = 'auth_registrations_legacy_owner';
  static const _legacyRegistrationsMigratedKey =
      'auth_registrations_migrated_to_user_scope';
  static const _notificationPreferencePrefix = 'auth_notifications:';
  static const _createdEventsKey = 'created_events';

  final LocalDatabase _database = LocalDatabase();

  Future<SharePref> get _preferences => SharePref.instance;

  Future<String?> readSessionEmail() async =>
      (await _preferences).readString(_sessionKey);

  Future<void> writeSessionEmail(String email) async {
    await _write((preferences) => preferences.writeString(_sessionKey, email));
  }

  Future<void> clearSession() async {
    await _write((preferences) => preferences.remove(_sessionKey));
  }

  Future<bool> readNotificationPreference(String userId) async {
    return (await _preferences).readBool(
      '$_notificationPreferencePrefix$userId',
      defaultValue: true,
    );
  }

  Future<void> writeNotificationPreference(String userId, bool enabled) async {
    await _write(
      (preferences) => preferences.writeBool(
        '$_notificationPreferencePrefix$userId',
        enabled,
      ),
    );
  }

  Future<Map<String, LocalUserRecord>> readUsers() async {
    final storedUsers = await _database.readUsers();
    if (storedUsers.isNotEmpty) {
      return DatabaseCodec.decodeUsers(storedUsers);
    }

    final value = (await _preferences).readString(_usersKey);
    if (value == null) return {};

    try {
      final decoded = jsonDecode(value);
      if (decoded is! Map<String, dynamic>) return {};
      final users = decoded.map(
        (email, user) => MapEntry(
          email,
          user is Map<String, dynamic>
              ? LocalUserRecord.fromJson(user)
              : throw const FormatException('Invalid user record'),
        ),
      );
      await _writeDatabase(
        () => _database.writeUsers(DatabaseCodec.encodeUsers(users)),
      );
      await _write((preferences) => preferences.remove(_usersKey));
      return users;
    } on Object {
      return {};
    }
  }

  Future<void> writeUsers(Map<String, LocalUserRecord> users) async {
    await _writeDatabase(
      () => _database.writeUsers(DatabaseCodec.encodeUsers(users)),
    );
  }

  Future<List<Event>> readCreatedEvents() async {
    final storedEvents = await _database.readEvents();
    if (storedEvents.isNotEmpty) {
      return DatabaseCodec.decodeEvents(storedEvents);
    }

    final value = (await _preferences).readString(_createdEventsKey);
    if (value == null) return [];
    final events = _decodeEvents(value);
    if (events.isNotEmpty) {
      await _writeDatabase(
        () => _database.writeEvents(DatabaseCodec.encodeEvents(events)),
      );
      await _write((preferences) => preferences.remove(_createdEventsKey));
    }
    return events;
  }

  Future<void> writeCreatedEvents(List<Event> events) async {
    await _writeDatabase(
      () => _database.writeEvents(DatabaseCodec.encodeEvents(events)),
    );
  }

  Future<List<Event>> loadRegistrations(String userId) async {
    final storedEvents = await _database.readRegistrations(userId);
    if (storedEvents.isNotEmpty) {
      return DatabaseCodec.decodeEvents(storedEvents);
    }

    final preferences = await _preferences;
    final scoped = _readRegistrations(preferences, userId);
    if (scoped.isNotEmpty) {
      await _writeRegistrationRecords(userId, scoped);
      await _write(
        (preferences) => preferences.remove(_registrationKeyFor(userId)),
      );
      return scoped;
    }
    if (preferences.readBool(_legacyRegistrationsMigratedKey)) return [];

    final legacyValue = preferences.readString(_legacyRegistrationsKey);
    if (legacyValue == null) return scoped;
    final ownerId = preferences.readString(_legacyRegistrationOwnerKey);
    if (ownerId != null && ownerId != userId) return scoped;
    final legacyEvents = _decodeEvents(legacyValue);
    await _writeRegistrationRecords(userId, legacyEvents);
    await _write(
      (preferences) =>
          preferences.writeString(_legacyRegistrationOwnerKey, userId),
    );
    await _write(
      (preferences) =>
          preferences.writeBool(_legacyRegistrationsMigratedKey, true),
    );
    await _write((preferences) => preferences.remove(_legacyRegistrationsKey));
    return legacyEvents;
  }

  Future<void> writeRegistrations(String userId, List<Event> events) async {
    await _writeRegistrationRecords(userId, events);
  }

  Future<void> _writeRegistrationRecords(
    String userId,
    List<Event> events,
  ) async {
    await _writeDatabase(
      () => _database.writeRegistrations(
        userId,
        DatabaseCodec.encodeEvents(events),
      ),
    );
  }

  Future<void> _writeDatabase(Future<void> Function() operation) async {
    try {
      await operation();
    } on LocalStorageException {
      rethrow;
    } on Object {
      throw const LocalStorageException();
    }
  }

  Future<void> _write(
    Future<bool> Function(SharePref preferences) operation,
  ) async {
    if (!await operation(await _preferences)) {
      throw const LocalStorageException();
    }
  }

  List<Event> _readRegistrations(SharePref preferences, String userId) {
    final value = preferences.readString(_registrationKeyFor(userId));
    if (value == null) return [];
    return _decodeEvents(value);
  }

  List<Event> _decodeEvents(String value) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is! List<dynamic>) return [];
      return decoded
          .map(
            (event) => event is Map<String, dynamic>
                ? Event.fromJson(event)
                : throw const FormatException('Invalid event record'),
          )
          .toList();
    } on Object {
      return [];
    }
  }

  String _registrationKeyFor(String userId) => '$_registrationsPrefix$userId';
}

class LocalStorageException implements Exception {
  const LocalStorageException();
}
