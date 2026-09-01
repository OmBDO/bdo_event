import 'dart:async';

class CleanupScope {
  final _actions = <Future<void> Function()>[];
  bool _cleaned = false;
  Future<void>? _cleanupFuture;

  void add(Future<void> Function() action) {
    if (_cleaned) {
      throw StateError('Cleanup has already completed.');
    }
    if (_cleanupFuture != null) {
      throw StateError('Cleanup is already running.');
    }
    _actions.add(action);
  }

  Future<void> cleanup() {
    if (_cleaned) return Future<void>.value();
    final running = _cleanupFuture;
    if (running != null) return running;

    final completer = Completer<void>();
    _cleanupFuture = completer.future;
    unawaited(_runCleanup(completer));
    return completer.future;
  }

  Future<void> _runCleanup(Completer<void> completer) async {
    try {
      Object? firstError;
      StackTrace? firstStackTrace;
      final failedActions = <Future<void> Function()>[];
      for (final action in _actions.reversed) {
        try {
          await action();
        } catch (error, stackTrace) {
          firstError ??= error;
          firstStackTrace ??= stackTrace;
          failedActions.add(action);
        }
      }

      _actions
        ..clear()
        ..addAll(failedActions.reversed);
      if (_actions.isEmpty) _cleaned = true;

      if (firstError != null) {
        completer.completeError(
          firstError,
          firstStackTrace ?? StackTrace.current,
        );
      } else {
        completer.complete();
      }
    } catch (error, stackTrace) {
      completer.completeError(error, stackTrace);
    } finally {
      _cleanupFuture = null;
    }
  }
}
