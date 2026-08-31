import 'package:flutter_test/flutter_test.dart';

import 'bounded_waiter.dart';

void main() {
  test('returns immediately when the condition is already true', () async {
    var attempts = 0;
    final waiter = BoundedWaiter(
      timeout: Duration.zero,
      delay: (_) async => fail('delay should not be called'),
    );

    await waiter.until(() {
      attempts++;
      return true;
    });

    expect(attempts, 1);
  });

  test('polls with the configured delay until the condition is true',
      () async {
    var attempts = 0;
    final delays = <Duration>[];
    final waiter = BoundedWaiter(
      timeout: const Duration(seconds: 1),
      pollInterval: const Duration(milliseconds: 25),
      delay: (duration) async => delays.add(duration),
    );

    await waiter.until(() => ++attempts >= 3);

    expect(attempts, 3);
    expect(delays, [
      const Duration(milliseconds: 25),
      const Duration(milliseconds: 25),
    ]);
  });

  test('times out with the requested condition description', () async {
    final waiter = BoundedWaiter(timeout: Duration.zero);

    await expectLater(
      waiter.until(() => false, description: 'registration propagation'),
      throwsA(
        allOf(
          isA<TimeoutException>(),
          predicate<TimeoutException>(
            (error) => error.message!.contains('registration propagation'),
          ),
        ),
      ),
    );
  });
}
