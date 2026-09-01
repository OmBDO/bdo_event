import 'cleanup_scope.dart';

typedef DeleteTestNotification = Future<void> Function(int notificationId);

class NotificationCleanup {
  const NotificationCleanup({
    required this.scope,
    required this.delete,
  });

  final CleanupScope scope;
  final DeleteTestNotification delete;

  void track(int notificationId) {
    scope.add(() => delete(notificationId));
  }
}
