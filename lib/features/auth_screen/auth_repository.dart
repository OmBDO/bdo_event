import 'dart:convert';

import 'package:bdo_event/core/prefs/share_pref.dart';
import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/model/user_model/user_model.dart';
import 'package:flutter/foundation.dart';

class AuthRepository {
  AuthRepository._();

  static const _usersKey = 'auth_users';
  static const _sessionKey = 'auth_session';
  static const _registrationsKey = 'auth_registrations';
  static const _registrationsPrefix = 'auth_registrations:';
  static const _legacyRegistrationsMigratedKey =
      'auth_registrations_migrated_to_user_scope';
  static const _createdEventsKey = 'created_events';
  static User? _currentUser;
  static final ValueNotifier<List<Event>> registrations =
      ValueNotifier<List<Event>>([]);
  static final ValueNotifier<List<Event>> createdEvents =
      ValueNotifier<List<Event>>([]);

  static User? get currentUser => _currentUser;
  static String? get currentUserName => _currentUser?.displayName;
  static bool can(UserPermission permission) =>
      _currentUser?.hasPermission(permission) ?? false;
  static bool canManage(Event event) =>
      can(UserPermission.manageAllEvents) ||
      (event.creatorId == _currentUser?.id &&
          can(UserPermission.updateOwnEvents));

  static Future<void> initialize() async {
    final preferences = await SharePref.instance;
    final sessionEmail = preferences.readString(_sessionKey);
    if (sessionEmail == null) return;
    _currentUser = _readUsers(preferences)[sessionEmail]?.toUser();
    registrations.value = await _loadRegistrations(preferences);
    createdEvents.value = _readCreatedEvents(preferences);
  }

  static Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final preferences = await SharePref.instance;
    final normalizedEmail = email.trim().toLowerCase();
    final users = _readUsers(preferences);

    if (users.containsKey(normalizedEmail)) {
      return 'An account with this email already exists';
    }

    users[normalizedEmail] = _LocalUser(
      id: 'user-${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim(),
      email: normalizedEmail,
      password: password,
      createdAt: DateTime.now(),
    );
    await preferences.writeString(_usersKey, _encodeUsers(users));
    return null;
  }

  static Future<String?> login({
    required String email,
    required String password,
  }) async {
    final preferences = await SharePref.instance;
    final normalizedEmail = email.trim().toLowerCase();
    final user = _readUsers(preferences)[normalizedEmail];

    if (user == null || user.password != password) {
      return 'Email or password is incorrect';
    }

    _currentUser = user.toUser(lastSignedInAt: DateTime.now());
    await preferences.writeString(_sessionKey, normalizedEmail);
    registrations.value = await _loadRegistrations(preferences);
    createdEvents.value = _readCreatedEvents(preferences);
    return null;
  }

  static Future<void> logout() async {
    _currentUser = null;
    registrations.value = [];
    createdEvents.value = [];
    final preferences = await SharePref.instance;
    await preferences.remove(_sessionKey);
  }

  /// Role changes are intentionally restricted to administrators. A future
  /// admin screen or backend sync can call this without changing the UI rules.
  static Future<String?> updateUserRoles({
    required String userId,
    required Set<UserRole> roles,
  }) async {
    if (!can(UserPermission.manageUsers)) {
      return 'Administrator access is required to manage user roles';
    }
    if (roles.isEmpty) return 'A user must have at least one role';

    final preferences = await SharePref.instance;
    final users = _readUsers(preferences);
    final entry = users.entries
        .cast<MapEntry<String, _LocalUser>?>()
        .firstWhere((entry) => entry?.value.id == userId, orElse: () => null);
    if (entry == null) return 'User could not be found';

    final updated = entry.value.copyWith(roles: roles);
    users[entry.key] = updated;
    await preferences.writeString(_usersKey, _encodeUsers(users));
    if (_currentUser?.id == userId) _currentUser = updated.toUser();
    return null;
  }

  static Future<String?> registerEvent(Event event) async {
    final user = _currentUser;
    if (user == null) return 'Please sign in to register for an event';
    if (!user.hasPermission(UserPermission.registerForEvents)) {
      return 'Your account is not allowed to register for events';
    }
    final preferences = await SharePref.instance;
    final events = [..._readRegistrations(preferences)];
    if (events.any((registered) => registered.id == event.id)) {
      return 'You are already registered for this event';
    }

    events.add(event);
    registrations.value = events;
    await preferences.writeString(
      _registrationKeyFor(user.id),
      jsonEncode(events.map((registered) => registered.toJson()).toList()),
    );
    return null;
  }

  static Future<String?> cancelEvent(Event event) async {
    final user = _currentUser;
    if (user == null) return 'Please sign in to manage registrations';
    final preferences = await SharePref.instance;
    final events = [..._readRegistrations(preferences)]
      ..removeWhere((registered) => registered.id == event.id);

    registrations.value = events;
    await preferences.writeString(
      _registrationKeyFor(user.id),
      jsonEncode(events.map((registered) => registered.toJson()).toList()),
    );
    return null;
  }

  static Future<String?> createEvent(Event event) async {
    final user = _currentUser;
    if (user == null) return 'Please sign in to create an event';
    if (!user.hasPermission(UserPermission.createEvents)) {
      return 'Organizer access is required to create events';
    }
    final preferences = await SharePref.instance;
    final events = [..._readCreatedEvents(preferences)];
    events.add(
      event.copyWith(creatorId: user.id, organizerName: user.displayName),
    );
    await preferences.writeString(
      _createdEventsKey,
      jsonEncode(events.map((created) => created.toJson()).toList()),
    );
    createdEvents.value = events;
    return null;
  }

  static Future<String?> updateEvent(Event event) async {
    if (!canManage(event)) {
      return 'You do not have permission to update this event';
    }
    final preferences = await SharePref.instance;
    final events = [..._readCreatedEvents(preferences)];
    final index = events.indexWhere((created) => created.id == event.id);
    if (index == -1) return 'Event could not be found';

    events[index] = event;
    await preferences.writeString(
      _createdEventsKey,
      jsonEncode(events.map((created) => created.toJson()).toList()),
    );
    createdEvents.value = events;
    return null;
  }

  static Future<String?> deleteEvent(Event event) async {
    if (!canManage(event)) {
      return 'You do not have permission to delete this event';
    }
    final preferences = await SharePref.instance;
    final events = [..._readCreatedEvents(preferences)]
      ..removeWhere((created) => created.id == event.id);
    await preferences.writeString(
      _createdEventsKey,
      jsonEncode(events.map((created) => created.toJson()).toList()),
    );
    createdEvents.value = events;
    return null;
  }

  static List<Event> _readRegistrations(SharePref preferences) {
    final userId = _currentUser?.id;
    if (userId == null) return [];
    final value = preferences.readString(_registrationKeyFor(userId));
    if (value == null) return [];

    try {
      final decoded = jsonDecode(value) as List<dynamic>;
      return decoded
          .map((event) => Event.fromJson(event as Map<String, dynamic>))
          .toList();
    } on FormatException {
      return [];
    }
  }

  static Future<List<Event>> _loadRegistrations(SharePref preferences) async {
    final userId = _currentUser?.id;
    if (userId == null) return [];
    final scoped = _readRegistrations(preferences);
    if (scoped.isNotEmpty ||
        preferences.readBool(_legacyRegistrationsMigratedKey)) {
      return scoped;
    }

    final legacyValue = preferences.readString(_registrationsKey);
    if (legacyValue == null) return scoped;
    await preferences.writeString(_registrationKeyFor(userId), legacyValue);
    await preferences.writeBool(_legacyRegistrationsMigratedKey, true);
    return _readRegistrations(preferences);
  }

  static String _registrationKeyFor(String userId) =>
      '$_registrationsPrefix$userId';

  static List<Event> _readCreatedEvents(SharePref preferences) {
    final value = preferences.readString(_createdEventsKey);
    if (value == null) return [];

    try {
      final decoded = jsonDecode(value) as List<dynamic>;
      return decoded
          .map((event) => Event.fromJson(event as Map<String, dynamic>))
          .toList();
    } on FormatException {
      return [];
    }
  }

  static Map<String, _LocalUser> _readUsers(SharePref preferences) {
    final value = preferences.readString(_usersKey);
    if (value == null) return {};

    try {
      final decoded = jsonDecode(value) as Map<String, dynamic>;
      return decoded.map(
        (email, user) =>
            MapEntry(email, _LocalUser.fromJson(user as Map<String, dynamic>)),
      );
    } on FormatException {
      return {};
    }
  }

  static String _encodeUsers(Map<String, _LocalUser> users) {
    return jsonEncode(
      users.map((email, user) => MapEntry(email, user.toJson())),
    );
  }
}

class _LocalUser {
  final String id;
  final String name;
  final String email;
  final String password;
  final Set<UserRole> roles;
  final DateTime createdAt;

  const _LocalUser({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.roles = const {UserRole.attendee},
    required this.createdAt,
  });

  factory _LocalUser.fromJson(Map<String, dynamic> json) {
    return _LocalUser(
      id: json['id'] as String? ?? 'legacy-${json['email'] as String}',
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      roles: ((json['roles'] as List<dynamic>?) ?? const ['attendee'])
          .map(UserRole.fromStorage)
          .toSet(),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  _LocalUser copyWith({Set<UserRole>? roles}) => _LocalUser(
    id: id,
    name: name,
    email: email,
    password: password,
    roles: roles ?? this.roles,
    createdAt: createdAt,
  );

  User toUser({DateTime? lastSignedInAt}) => User(
    id: id,
    displayName: name,
    email: email,
    roles: roles,
    createdAt: createdAt,
    lastSignedInAt: lastSignedInAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'password': password,
    'roles': roles.map((role) => role.storageValue).toList(),
    'createdAt': createdAt.toIso8601String(),
  };
}
