import '../fixtures/registration_fixture.dart';
import 'cleanup_scope.dart';

typedef DeleteTestRegistration =
    Future<void> Function(RegistrationFixtureData registration);

class RegistrationCleanup {
  const RegistrationCleanup({
    required this.scope,
    required this.delete,
  });

  final CleanupScope scope;
  final DeleteTestRegistration delete;

  void track(RegistrationFixtureData registration) {
    scope.add(() => delete(registration));
  }
}
