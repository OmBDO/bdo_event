import 'dart:async';

class ConcurrentStartBarrier {
  ConcurrentStartBarrier(this.participantCount)
    : assert(participantCount > 0),
      _release = Completer<void>();

  final int participantCount;
  final Completer<void> _release;
  int _arrived = 0;

  Future<void> wait() {
    if (_arrived >= participantCount) {
      throw StateError('All barrier participants have already arrived.');
    }
    _arrived++;
    if (_arrived == participantCount) _release.complete();
    return _release.future;
  }
}
