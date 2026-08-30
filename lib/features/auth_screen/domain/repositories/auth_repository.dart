import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/model/user_model/user_model.dart';

abstract interface class AuthRepositoryContract {
  User? get currentUser;

  bool can(UserPermission permission);

  bool canUpdate(Event event);

  bool canDelete(Event event);

  Future<void> initialize();

  Future<String?> register({
    required String name,
    required String email,
    required String password,
    required UserRole requestedRole,
  });

  Future<String?> login({required String email, required String password});

  Future<String?> updatePassword(String password);

  Future<String?> updateProfile({
    required String displayName,
    required String email,
    String? photoUrl,
    String? phoneNumber,
    String? bio,
    String? locale,
  });

  Future<void> logout();

  Future<String?> logoutEverywhere();

  Future<String?> updateNotificationPreference(bool enable);
}
