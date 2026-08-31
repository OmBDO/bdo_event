import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'test_duration.dart';

void main() {
  test('records successful actions in execution order', () async {
    final recorder = TestDurationRecorder();

    final result = await recorder.measure('auth-smoke', () async => 'ready');
    await recorder.measure('event-read', () async {});

    expect(result, 'ready');
    expect(recorder.records.map((record) => record.name), [
      'auth-smoke',
      'event-read',
    ]);
    expect(
      recorder.records.every((record) => record.milliseconds >= 0),
      isTrue,
    );
  });

  test('records a failing action before propagating its error', () async {
    final recorder = TestDurationRecorder();

    await expectLater(
      recorder.measure('failing-setup', () async {
        throw StateError('setup failed');
      }),
      throwsA(isA<StateError>()),
    );

    expect(recorder.records.single.name, 'failing-setup');
  });

  test('serializes duration records as machine-readable JSON', () async {
    final recorder = TestDurationRecorder();
    await recorder.measure('smoke', () async {});

    final decoded = jsonDecode(recorder.toJson()) as List<dynamic>;

    expect(decoded, hasLength(1));
    expect(decoded.single['name'], 'smoke');
    expect(decoded.single['milliseconds'], isA<int>());
  });

  test('does not expose a mutable records list', () {
    final recorder = TestDurationRecorder();
    final records = recorder.records;

    expect(() => records.clear(), throwsUnsupportedError);
  });
}
