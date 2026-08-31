import '../harness/test_run_context.dart';

enum TestActorRole { anonymous, user, watcher, admin, owner, unrelated }

class TestActor {
  const TestActor({
    required this.role,
    required this.namespace,
    this.email,
    this.displayName,
  });

  final TestActorRole role;
  final String namespace;
  final String? email;
  final String? displayName;

  bool get isAuthenticated => role != TestActorRole.anonymous;
}

class TestActorFactory {
  const TestActorFactory(this.context);

  final TestRunContext context;

  TestActor create({
    required String testId,
    required TestActorRole role,
  }) {
    final namespace = context.namespace('$testId-${role.name}');
    if (role == TestActorRole.anonymous) {
      return TestActor(role: role, namespace: namespace);
    }

    return TestActor(
      role: role,
      namespace: namespace,
      email: '$namespace@example.invalid',
      displayName: 'Integration ${role.name}',
    );
  }
}
