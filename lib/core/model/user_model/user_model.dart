import 'package:bdo_event/core/util/resource/app_locals.dart';

class _UnsetValue {
  const _UnsetValue();
}

const _unsetValue = _UnsetValue();

/// A stable application identity, independent of the authentication provider.
///
/// Authentication secrets deliberately do not belong in this model. A future
/// API, Firebase, or SSO provider can therefore replace local authentication
/// without changing the rest of the application.
enum UserRole {
  user,
  admin,
  watcher;

  String get storageValue => name;

  static UserRole fromStorage(Object? value) {
    return UserRole.values.firstWhere(
      (role) => role.storageValue == value,
      orElse: () => UserRole.user,
    );
  }
}

enum UserPermission {
  registerForEvents,
  scanRegistrations,
  createEvents,
  updateOwnEvents,
  deleteOwnEvents,
  viewEventAttendees,
  manageAllEvents,
  manageUsers,
}

extension UserRolePermissions on UserRole {
  Set<UserPermission> get permissions => switch (this) {
    UserRole.user => {UserPermission.registerForEvents},
    UserRole.admin => {
      UserPermission.registerForEvents,
      UserPermission.scanRegistrations,
      UserPermission.createEvents,
      UserPermission.updateOwnEvents,
      UserPermission.deleteOwnEvents,
      UserPermission.viewEventAttendees,
      UserPermission.manageAllEvents,
      UserPermission.manageUsers,
    },
    UserRole.watcher => {
      UserPermission.registerForEvents,
      UserPermission.scanRegistrations,
    },
  };
}

class User {
  final String id;
  final String displayName;
  final String email;
  final Set<UserRole> roles;
  final String? photoUrl;
  final String? phoneNumber;
  final String? bio;
  final String locale;
  final bool notificationsEnabled;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastSignedInAt;

  const User({
    required this.id,
    required this.displayName,
    required this.email,
    this.roles = const {UserRole.user},
    this.photoUrl,
    this.phoneNumber,
    this.bio,
    this.locale = AppLocales.englishIndia,
    this.notificationsEnabled = true,
    required this.createdAt,
    this.updatedAt,
    this.lastSignedInAt,
  });

  bool hasPermission(UserPermission permission) =>
      roles.any((role) => role.permissions.contains(permission));

  bool get isAdministrator => roles.contains(UserRole.admin);

  User copyWith({
    String? displayName,
    String? email,
    Set<UserRole>? roles,
    Object? photoUrl = _unsetValue,
    Object? phoneNumber = _unsetValue,
    Object? bio = _unsetValue,
    String? locale,
    bool? notificationsEnabled,
    Object? updatedAt = _unsetValue,
    Object? lastSignedInAt = _unsetValue,
  }) => User(
    id: id,
    displayName: displayName ?? this.displayName,
    email: email ?? this.email,
    roles: roles ?? this.roles,
    photoUrl: identical(photoUrl, _unsetValue) ? this.photoUrl : photoUrl as String?,
    phoneNumber: identical(phoneNumber, _unsetValue)
      ? this.phoneNumber
      : phoneNumber as String?,
    bio: identical(bio, _unsetValue) ? this.bio : bio as String?,
    locale: locale ?? this.locale,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    createdAt: createdAt,
    updatedAt: identical(updatedAt, _unsetValue)
      ? this.updatedAt
      : updatedAt as DateTime?,
    lastSignedInAt: identical(lastSignedInAt, _unsetValue)
      ? this.lastSignedInAt
      : lastSignedInAt as DateTime?,
  );

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String? ?? json['email'] as String,
    displayName:
        json['displayName'] as String? ?? json['name'] as String? ?? '',
    email: json['email'] as String,
    roles: ((json['roles'] as List<dynamic>?) ?? const ['user'])
        .map(UserRole.fromStorage)
        .toSet(),
    photoUrl: json['photoUrl'] as String?,
    phoneNumber: json['phoneNumber'] as String?,
    bio: json['bio'] as String?,
    locale: json['locale'] as String? ?? AppLocales.englishIndia,
    notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
    lastSignedInAt: DateTime.tryParse(json['lastSignedInAt'] as String? ?? ''),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'displayName': displayName,
    'email': email,
    'roles': roles.map((role) => role.storageValue).toList(),
    'photoUrl': photoUrl,
    'phoneNumber': phoneNumber,
    'bio': bio,
    'locale': locale,
    'notificationsEnabled': notificationsEnabled,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'lastSignedInAt': lastSignedInAt?.toIso8601String(),
  };
}
