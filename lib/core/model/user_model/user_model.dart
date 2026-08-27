/// A stable application identity, independent of the authentication provider.
///
/// Authentication secrets deliberately do not belong in this model. A future
/// API, Firebase, or SSO provider can therefore replace local authentication
/// without changing the rest of the application.
enum UserRole {
  attendee,
  organizer,
  administrator;

  String get storageValue => name;

  static UserRole fromStorage(Object? value) {
    return UserRole.values.firstWhere(
      (role) => role.storageValue == value,
      orElse: () => UserRole.attendee,
    );
  }
}

enum UserPermission {
  registerForEvents,
  createEvents,
  updateOwnEvents,
  deleteOwnEvents,
  manageAllEvents,
  manageUsers,
}

extension UserRolePermissions on UserRole {
  Set<UserPermission> get permissions => switch (this) {
    UserRole.attendee => {UserPermission.registerForEvents},
    UserRole.organizer => {
      UserPermission.registerForEvents,
      UserPermission.createEvents,
      UserPermission.updateOwnEvents,
      UserPermission.deleteOwnEvents,
    },
    UserRole.administrator => UserPermission.values.toSet(),
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
    this.roles = const {UserRole.attendee},
    this.photoUrl,
    this.phoneNumber,
    this.bio,
    this.locale = 'en-IN',
    this.notificationsEnabled = true,
    required this.createdAt,
    this.updatedAt,
    this.lastSignedInAt,
  });

  bool hasPermission(UserPermission permission) =>
      roles.any((role) => role.permissions.contains(permission));

  bool get isAdministrator => roles.contains(UserRole.administrator);

  User copyWith({
    String? displayName,
    String? email,
    Set<UserRole>? roles,
    String? photoUrl,
    String? phoneNumber,
    String? bio,
    String? locale,
    bool? notificationsEnabled,
    DateTime? updatedAt,
    DateTime? lastSignedInAt,
  }) => User(
    id: id,
    displayName: displayName ?? this.displayName,
    email: email ?? this.email,
    roles: roles ?? this.roles,
    photoUrl: photoUrl ?? this.photoUrl,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    bio: bio ?? this.bio,
    locale: locale ?? this.locale,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastSignedInAt: lastSignedInAt ?? this.lastSignedInAt,
  );

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String? ?? json['email'] as String,
    displayName: json['displayName'] as String? ?? json['name'] as String? ?? '',
    email: json['email'] as String,
    roles: ((json['roles'] as List<dynamic>?) ?? const ['attendee'])
        .map(UserRole.fromStorage)
        .toSet(),
    photoUrl: json['photoUrl'] as String?,
    phoneNumber: json['phoneNumber'] as String?,
    bio: json['bio'] as String?,
    locale: json['locale'] as String? ?? 'en-IN',
    notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
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
