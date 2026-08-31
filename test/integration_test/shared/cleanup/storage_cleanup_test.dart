import 'package:flutter_test/flutter_test.dart';

import 'cleanup_scope.dart';
import 'storage_cleanup.dart';

void main() {
  test('tracks bucket and path for reverse-order cleanup', () async {
    final scope = CleanupScope();
    final deleted = <String>[];
    final cleanup = StorageCleanup(
      scope: scope,
      delete: (bucket, path) async => deleted.add('$bucket/$path'),
    );

    final eventObject = cleanup.track(
      bucket: 'event-images',
      path: 'user-1/event.jpg',
    );
    cleanup.track(bucket: 'profile-images', path: 'user-1/profile.jpg');
    await eventObject.delete();
    await eventObject.delete();
    await scope.cleanup();

    expect(deleted, [
      'event-images/user-1/event.jpg',
      'profile-images/user-1/profile.jpg',
    ]);
  });
}
