import 'package:bdo_event/core/model/user_model/user_model.dart';
import 'package:bdo_event/features/auth_screen/domain/repositories/auth_repository.dart';

class InitializeAuth {
  const InitializeAuth(this._repository);

  final AuthRepositoryContract _repository;

  Future<void> call() => _repository.initialize();
}

class SignIn {
  const SignIn(this._repository);

  final AuthRepositoryContract _repository;

  Future<String?> call({required String email, required String password}) =>
      _repository.login(email: email, password: password);
}

class SignUp {
  const SignUp(this._repository);

  final AuthRepositoryContract _repository;

  Future<String?> call({
    required String name,
    required String email,
    required String password,
    required UserRole requestedRole,
  }) => _repository.register(
        name: name,
        email: email,
        password: password,
        requestedRole: requestedRole,
      );
}

class SignOut {
  const SignOut(this._repository);

  final AuthRepositoryContract _repository;

  Future<void> call() => _repository.logout();
}
