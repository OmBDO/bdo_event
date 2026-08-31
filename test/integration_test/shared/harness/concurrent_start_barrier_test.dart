import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'concurrent_start_barrier.dart';

void main() {
  test('releases all participants when the expected count arrives', () async {
    final barrier = ConcurrentStartBarrier(2);
    final first = barrier.wait();
    var firstReleased = false;
    first.then((_) => firstReleased = true);

    expect(firstReleased, isFalse);
    final second = barrier.wait();
    await Future.wait([first, second]);

    expect(firstReleased, isTrue);
  });

  test('rejects participants beyond the configured count', () async {
    final barrier = ConcurrentStartBarrier(1);
    await barrier.wait();

    expect(() => barrier.wait(), throwsA(isA<StateError>()));
  });

  test('requires a positive participant count', () {
    expect(() => ConcurrentStartBarrier(0), throwsA(isA<AssertionError>()));
  });
}
