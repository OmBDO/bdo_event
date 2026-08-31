import 'cleanup_scope.dart';

typedef DeleteTestStorageObject = Future<void> Function(
  String bucket,
  String path,
);

class StorageCleanup {
  const StorageCleanup({
    required this.scope,
    required this.delete,
  });

  final CleanupScope scope;
  final DeleteTestStorageObject delete;

  StorageObjectCleanup track({required String bucket, required String path}) {
    final tracked = StorageObjectCleanup(
      deleteAction: () => delete(bucket, path),
    );
    scope.add(tracked.delete);
    return tracked;
  }
}

class StorageObjectCleanup {
  StorageObjectCleanup({required this.deleteAction});

  final Future<void> Function() deleteAction;
  bool _deleted = false;

  Future<void> delete() async {
    if (_deleted) return;
    await deleteAction();
    _deleted = true;
  }
}
