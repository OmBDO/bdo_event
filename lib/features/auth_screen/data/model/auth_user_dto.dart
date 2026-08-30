import 'package:bdo_event/core/model/user_model/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class AuthUserDto {
  const AuthUserDto({required this.user, required this.notificationsEnabled});
  final supabase.User user;
  final bool notificationsEnabled;
  User toEntity() {
    final metadata = user.userMetadata ?? const <String, dynamic>{};
    final configuredRoles = user.appMetadata['roles'];
    final roleValues = configuredRoles is List<dynamic>
        ? configuredRoles
        : configuredRoles == null
        ? const <dynamic>[]
        : [configuredRoles];
    final roles = roleValues.map(UserRole.fromStorage).toSet();
    return User(
      id: user.id,
      displayName:
          metadata['display_name'] as String? ??
          metadata['full_name'] as String? ??
          user.email?.split('@').first ??
          'User',
      email: user.email ?? '',
      roles: roles.isEmpty ? {UserRole.user} : roles,
        photoUrl:
          metadata['photo_url'] as String? ??
          metadata['avatar_url'] as String? ??
          metadata['picture'] as String?,
      phoneNumber: metadata['phone_number'] as String?,
      bio: metadata['bio'] as String?,
      locale: metadata['locale'] as String? ?? 'en-IN',
      createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
      lastSignedInAt: user.lastSignInAt == null
          ? null
          : DateTime.tryParse(user.lastSignInAt!),
      notificationsEnabled: notificationsEnabled,
    );
  }
}
