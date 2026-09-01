import 'dart:async';

typedef WaitDelay = Future<void> Function(Duration duration);

class BoundedWaiter {
  const BoundedWaiter({
    this.timeout = const Duration(seconds: 10),
    this.pollInterval = const Duration(milliseconds: 100),
    this.delay = _defaultDelay,
  });

  final Duration timeout;
  final Duration pollInterval;
  final WaitDelay delay;

  Future<void> until(
    FutureOr<bool> Function() condition, {
    String description = 'condition',
  }) async {
    final stopwatch = Stopwatch()..start();
    while (true) {
      if (await condition()) return;
      if (stopwatch.elapsed >= timeout) {
        throw TimeoutException(
          'Timed out waiting for $description.',
          timeout,
        );
      }
      await delay(pollInterval);
    }
  }

  static Future<void> _defaultDelay(Duration duration) =>
      Future<void>.delayed(duration);
}
