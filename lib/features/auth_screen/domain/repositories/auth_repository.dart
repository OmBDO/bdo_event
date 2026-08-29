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

  Future<String?> login({
    required String email,
    required String password,
  });

  Future<void> logout();
}
