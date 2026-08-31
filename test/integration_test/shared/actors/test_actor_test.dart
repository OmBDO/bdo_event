import 'package:flutter_test/flutter_test.dart';

import '../harness/test_run_context.dart';
import 'test_actor.dart';

void main() {
  test('creates an anonymous actor without credentials', () {
    final actor = TestActorFactory(
      const TestRunContext('it-run'),
    ).create(testId: 'auth', role: TestActorRole.anonymous);

    expect(actor.isAuthenticated, isFalse);
    expect(actor.email, isNull);
    expect(actor.displayName, isNull);
    expect(actor.namespace, 'it-run-auth-anonymous');
  });

  test('creates namespaced credentials for authenticated actors', () {
    final actor = TestActorFactory(
      const TestRunContext('it-run'),
    ).create(testId: 'rls', role: TestActorRole.admin);

    expect(actor.isAuthenticated, isTrue);
    expect(actor.email, 'it-run-rls-admin@example.invalid');
    expect(actor.displayName, 'Integration admin');
  });

  test('keeps role identities distinct within one test run', () {
    final factory = TestActorFactory(const TestRunContext('it-run'));

    final owner = factory.create(testId: 'event', role: TestActorRole.owner);
    final unrelated = factory.create(
      testId: 'event',
      role: TestActorRole.unrelated,
    );

    expect(owner.namespace, isNot(unrelated.namespace));
    expect(owner.email, isNot(unrelated.email));
  });
}
