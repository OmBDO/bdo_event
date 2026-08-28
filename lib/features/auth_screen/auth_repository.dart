import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/model/user_model/local_user_record.dart';
import 'package:bdo_event/core/model/user_model/user_model.dart';
import 'package:bdo_event/core/prefs/local_auth_store.dart';
import 'package:flutter/foundation.dart';
import 'package:bdo_event/features/event_screen/data/event_service.dart';
import 'package:bdo_event/features/calendar_screen/data/registration_service.dart';

class AuthRepository {
  AuthRepository._();

  static final LocalAuthStore _store = LocalAuthStore();
  static final EventService _eventService = EventService(_store);
  static final RegistrationService _registrationService = RegistrationService(
    _store,
  );
  static User? _currentUser;
  static final ValueNotifier<List<Event>> registrations =
      ValueNotifier<List<Event>>([]);
  static final ValueNotifier<List<Event>> createdEvents =
      ValueNotifier<List<Event>>([]);

  static User? get currentUser => _currentUser;
  static String? get currentUserName => _currentUser?.displayName;
  static bool can(UserPermission permission) =>
      _currentUser?.hasPermission(permission) ?? false;
  static bool canUpdate(Event event) =>
      can(UserPermission.manageAllEvents) ||
      (event.creatorId == _currentUser?.id &&
          can(UserPermission.updateOwnEvents));
  static bool canDelete(Event event) =>
      can(UserPermission.manageAllEvents) ||
      (event.creatorId == _currentUser?.id &&
          can(UserPermission.deleteOwnEvents));
  static bool canManage(Event event) => canUpdate(event);

  static Future<void> initialize() async {
    final sessionEmail = await _store.readSessionEmail();
    if (sessionEmail == null) return;
    final storedUser = (await _store.readUsers())[sessionEmail];
    if (storedUser != null) {
      _currentUser = storedUser.toUser(
        notificationsEnabled: await _store.readNotificationPreference(
          storedUser.id,
        ),
      );
    }
    final userId = _currentUser?.id;
    if (userId == null) return;
    registrations.value = await _registrationService.load(userId);
    createdEvents.value = await _eventService.load();
  }

  static Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final users = await _store.readUsers();

    if (users.containsKey(normalizedEmail)) {
      return 'An account with this email already exists';
    }

    users[normalizedEmail] = LocalUserRecord(
      id: 'user-${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim(),
      email: normalizedEmail,
      password: password,
      createdAt: DateTime.now(),
    );
    try {
      await _store.writeUsers(users);
    } on LocalStorageException {
      return 'Unable to create the account';
    }
    return null;
  }

  static Future<String?> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final user = (await _store.readUsers())[normalizedEmail];

    if (user == null || user.password != password) {
      return 'Email or password is incorrect';
    }

    _currentUser = user.toUser(
      lastSignedInAt: DateTime.now(),
      notificationsEnabled: await _store.readNotificationPreference(user.id),
    );
    try {
      await _store.writeSessionEmail(normalizedEmail);
    } on LocalStorageException {
      return 'Unable to start the session';
    }
    registrations.value = await _registrationService.load(user.id);
    createdEvents.value = await _eventService.load();
    return null;
  }

  static Future<void> logout() async {
    _currentUser = null;
    registrations.value = [];
    createdEvents.value = [];
    await _store.clearSession();
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

    final users = await _store.readUsers();
    final entry = users.entries
        .cast<MapEntry<String, LocalUserRecord>?>()
        .firstWhere((entry) => entry?.value.id == userId, orElse: () => null);
    if (entry == null) return 'User could not be found';

    final updated = entry.value.copyWith(roles: roles);
    users[entry.key] = updated;
    try {
      await _store.writeUsers(users);
    } on LocalStorageException {
      return 'Unable to update user roles';
    }
    if (_currentUser?.id == userId) {
      _currentUser = updated.toUser(
        notificationsEnabled: _currentUser?.notificationsEnabled,
      );
    }
    return null;
  }

  static Future<String?> updateNotificationPreference(bool enabled) async {
    final current = _currentUser;
    if (current == null) return 'Please sign in to update preferences';

    try {
      await _store.writeNotificationPreference(current.id, enabled);
    } on LocalStorageException {
      return 'Unable to save notification preference';
    }
    _currentUser = current.copyWith(notificationsEnabled: enabled);
    return null;
  }
}
