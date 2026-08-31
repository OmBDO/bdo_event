import '../harness/test_run_context.dart';
import 'test_actor.dart';

typedef RegisterTestActor = Future<String?> Function(TestActor actor);

class ProvisionedTestActor {
  const ProvisionedTestActor({
    required this.definition,
    this.userId,
  });

  final TestActor definition;
  final String? userId;

  TestActorRole get role => definition.role;
  String get namespace => definition.namespace;
  String? get email => definition.email;
  bool get isAuthenticated => definition.isAuthenticated;
}

class TestActorProvisioner {
  const TestActorProvisioner({
    required this.context,
    required this.register,
  });

  final TestRunContext context;
  final RegisterTestActor register;

  Future<ProvisionedTestActor> create({
    required String testId,
    required TestActorRole role,
  }) async {
    final definition = TestActorFactory(context).create(
      testId: testId,
      role: role,
    );
    if (!definition.isAuthenticated) {
      return ProvisionedTestActor(definition: definition);
    }

    final userId = await register(definition);
    if (userId == null || userId.trim().isEmpty) {
      throw StateError('Test actor provisioning returned no user ID.');
    }
    return ProvisionedTestActor(
      definition: definition,
      userId: userId.trim(),
    );
  }
}
