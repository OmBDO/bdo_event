import '../cleanup/cleanup_scope.dart';
import 'actor_factory.dart';

typedef DeleteTestActor = Future<void> Function(String userId);

class ActorCleanup {
  const ActorCleanup({
    required this.scope,
    required this.delete,
  });

  final CleanupScope scope;
  final DeleteTestActor delete;

  void track(ProvisionedTestActor actor) {
    final userId = actor.userId;
    if (userId == null) return;
    scope.add(() => delete(userId));
  }
}
