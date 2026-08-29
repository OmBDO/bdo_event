import 'package:bdo_event/core/model/user_model/user_model.dart';

abstract interface class AuthRepositoryContract {
  User? get currentUser;

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
