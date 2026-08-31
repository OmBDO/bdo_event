import 'package:flutter_test/flutter_test.dart';

import 'cleanup_scope.dart';

void main() {
  test('runs cleanup actions in reverse registration order', () async {
    final scope = CleanupScope();
    final calls = <String>[];
    scope.add(() async => calls.add('event'));
    scope.add(() async => calls.add('registration'));
    scope.add(() async => calls.add('actor'));

    await scope.cleanup();

    expect(calls, ['actor', 'registration', 'event']);
  });

  test('cleanup is idempotent and rejects new actions afterward', () async {
    final scope = CleanupScope();
    var calls = 0;
    scope.add(() async => calls++);

    await scope.cleanup();
    await scope.cleanup();

    expect(calls, 1);
    expect(
      () => scope.add(() async {}),
      throwsA(isA<StateError>()),
    );
  });

  test('runs all actions and propagates the first cleanup failure', () async {
    final scope = CleanupScope();
    final calls = <String>[];
    scope.add(() async => calls.add('last'));
    scope.add(() async {
      calls.add('first-failure');
      throw StateError('cleanup failed');
    });
    scope.add(() async => calls.add('first'));

    await expectLater(scope.cleanup(), throwsA(isA<StateError>()));

    expect(calls, ['first', 'first-failure', 'last']);
  });

  test('retains failed actions so a later cleanup can retry them', () async {
    final scope = CleanupScope();
    var attempts = 0;
    scope.add(() async {
      attempts++;
      if (attempts == 1) throw StateError('try again');
    });

    await expectLater(scope.cleanup(), throwsA(isA<StateError>()));
    await scope.cleanup();

    expect(attempts, 2);
  });
}
