import 'package:bdo_event/core/model/user_model/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class AuthUserDto {
  const AuthUserDto({required this.user, required this.notificationsEnabled});

  final supabase.User user;
  final bool notificationsEnabled;

  User toEntity() {
    final metadata = user.userMetadata ?? const <String, dynamic>{};
    final roles = (user.appMetadata['roles'] as List<dynamic>?)
            ?.map(UserRole.fromStorage)
            .toSet() ??
        {UserRole.attendee};
    return User(
      id: user.id,
      displayName: metadata['display_name'] as String? ??
          metadata['full_name'] as String? ??
          user.email?.split('@').first ??
          'User',
      email: user.email ?? '',
      roles: roles,
      createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
      lastSignedInAt: user.lastSignInAt == null
          ? null
          : DateTime.tryParse(user.lastSignInAt!),
      notificationsEnabled: notificationsEnabled,
    );
  }
}
