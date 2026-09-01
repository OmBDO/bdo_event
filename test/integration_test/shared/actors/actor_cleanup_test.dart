import 'package:flutter_test/flutter_test.dart';

import '../cleanup/cleanup_scope.dart';
import '../harness/test_run_context.dart';
import 'actor_cleanup.dart';
import 'actor_factory.dart';
import 'test_actor.dart';

void main() {
  test('tracks provisioned users for cleanup', () async {
    final scope = CleanupScope();
    final deletedIds = <String>[];
    final cleanup = ActorCleanup(
      scope: scope,
      delete: (userId) async => deletedIds.add(userId),
    );
    final actor = await TestActorProvisioner(
      context: const TestRunContext('it-run'),
      register: (_) async => 'user-1',
    ).create(testId: 'auth', role: TestActorRole.user);

    cleanup.track(actor);
    await scope.cleanup();

    expect(deletedIds, ['user-1']);
  });

  test('does not register cleanup for anonymous actors', () async {
    final scope = CleanupScope();
    var deleteCalls = 0;
    final cleanup = ActorCleanup(
      scope: scope,
      delete: (_) async => deleteCalls++,
    );
    final actor = await TestActorProvisioner(
      context: const TestRunContext('it-run'),
      register: (_) async => 'unexpected',
    ).create(testId: 'auth', role: TestActorRole.anonymous);

    cleanup.track(actor);
    await scope.cleanup();

    expect(deleteCalls, 0);
  });

  test('keeps actor cleanup order with other teardown actions', () async {
    final scope = CleanupScope();
    final calls = <String>[];
    final cleanup = ActorCleanup(
      scope: scope,
      delete: (userId) async => calls.add(userId),
    );
    cleanup.track(
      const ProvisionedTestActor(
        definition: TestActor(
          role: TestActorRole.user,
          namespace: 'actor',
          email: 'actor@example.invalid',
        ),
        userId: 'user-1',
      ),
    );
    scope.add(() async => calls.add('storage'));

    await scope.cleanup();

    expect(calls, ['storage', 'user-1']);
  });
}
