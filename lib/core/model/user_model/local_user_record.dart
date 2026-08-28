import 'package:bdo_event/core/model/user_model/user_model.dart';

class LocalUserRecord {
  final String id;
  final String name;
  final String email;
  final String password;
  final Set<UserRole> roles;
  final DateTime createdAt;

  const LocalUserRecord({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.roles = const {UserRole.attendee},
    required this.createdAt,
  });

  factory LocalUserRecord.fromJson(Map<String, dynamic> json) {
    return LocalUserRecord(
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

  LocalUserRecord copyWith({Set<UserRole>? roles}) => LocalUserRecord(
    id: id,
    name: name,
    email: email,
    password: password,
    roles: roles ?? this.roles,
    createdAt: createdAt,
  );

  User toUser({DateTime? lastSignedInAt, bool? notificationsEnabled}) => User(
    id: id,
    displayName: name,
    email: email,
    roles: roles,
    notificationsEnabled: notificationsEnabled ?? true,
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
