import 'dart:convert';

import 'package:bdo_event/core/prefs/share_pref.dart';

class AuthRepository {
  AuthRepository._();

  static const _usersKey = 'auth_users';
  static const _sessionKey = 'auth_session';
  static _LocalUser? _currentUser;

  static String? get currentUserName => _currentUser?.name;

  static Future<void> initialize() async {
    final preferences = await SharePref.instance;
    final sessionEmail = preferences.readString(_sessionKey);
    if (sessionEmail == null) return;
    _currentUser = _readUsers(preferences)[sessionEmail];
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
      name: name.trim(),
      email: normalizedEmail,
      password: password,
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

    _currentUser = user;
    await preferences.writeString(_sessionKey, normalizedEmail);
    return null;
  }

  static Future<void> logout() async {
    _currentUser = null;
    final preferences = await SharePref.instance;
    await preferences.remove(_sessionKey);
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
  final String name;
  final String email;
  final String password;

  const _LocalUser({
    required this.name,
    required this.email,
    required this.password,
  });

  factory _LocalUser.fromJson(Map<String, dynamic> json) {
    return _LocalUser(
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
    );
  }

  Map<String, String> toJson() => {
    'name': name,
    'email': email,
    'password': password,
  };
}
