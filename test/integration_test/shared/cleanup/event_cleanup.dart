import '../fixtures/event_fixture.dart';
import 'cleanup_scope.dart';

typedef DeleteTestEvent = Future<void> Function(EventFixtureData event);

class EventCleanup {
  const EventCleanup({
    required this.scope,
    required this.delete,
  });

  final CleanupScope scope;
  final DeleteTestEvent delete;

  void track(EventFixtureData event) {
    scope.add(() => delete(event));
  }
}
