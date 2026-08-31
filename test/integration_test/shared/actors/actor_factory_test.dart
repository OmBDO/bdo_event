import 'package:flutter_test/flutter_test.dart';

import '../harness/test_run_context.dart';
import 'actor_factory.dart';
import 'test_actor.dart';

void main() {
  test('does not provision an anonymous actor', () async {
    var registerCalls = 0;
    final provisioner = TestActorProvisioner(
      context: const TestRunContext('it-run'),
      register: (_) async {
        registerCalls++;
        return 'unexpected';
      },
    );

    final actor = await provisioner.create(
      testId: 'auth',
      role: TestActorRole.anonymous,
    );

    expect(actor.userId, isNull);
    expect(actor.isAuthenticated, isFalse);
    expect(registerCalls, 0);
  });

  test('forwards an authenticated definition to the registrar', () async {
    TestActor? registeredDefinition;
    final provisioner = TestActorProvisioner(
      context: const TestRunContext('it-run'),
      register: (definition) async {
        registeredDefinition = definition;
        return ' user-1 ';
      },
    );

    final actor = await provisioner.create(
      testId: 'rls',
      role: TestActorRole.admin,
    );

    expect(registeredDefinition?.role, TestActorRole.admin);
    expect(registeredDefinition?.email, 'it-run-rls-admin@example.invalid');
    expect(actor.userId, 'user-1');
    expect(actor.role, TestActorRole.admin);
  });

  test('fails fast when the registrar returns no user ID', () async {
    final provisioner = TestActorProvisioner(
      context: const TestRunContext('it-run'),
      register: (_) async => '  ',
    );

    await expectLater(
      provisioner.create(testId: 'auth', role: TestActorRole.user),
      throwsA(isA<StateError>()),
    );
  });
}
