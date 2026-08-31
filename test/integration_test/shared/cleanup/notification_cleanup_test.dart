import 'package:flutter_test/flutter_test.dart';

import 'cleanup_scope.dart';
import 'notification_cleanup.dart';

void main() {
  test('tracks notification IDs in the cleanup scope', () async {
    final scope = CleanupScope();
    final deletedIds = <int>[];
    final cleanup = NotificationCleanup(
      scope: scope,
      delete: (notificationId) async => deletedIds.add(notificationId),
    );

    cleanup.track(42);
    await scope.cleanup();

    expect(deletedIds, [42]);
  });
}
