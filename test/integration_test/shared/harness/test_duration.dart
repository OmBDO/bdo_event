import 'dart:convert';

class TestDurationRecorder {
  final _records = <TestDurationRecord>[];

  List<TestDurationRecord> get records => List.unmodifiable(_records);

  Future<T> measure<T>(String name, Future<T> Function() action) async {
    final stopwatch = Stopwatch()..start();
    try {
      return await action();
    } finally {
      _records.add(
        TestDurationRecord(
          name: name,
          milliseconds: stopwatch.elapsedMilliseconds,
        ),
      );
    }
  }

  String toJson() => jsonEncode([
        for (final record in _records) record.toJson(),
      ]);
}

class TestDurationRecord {
  const TestDurationRecord({
    required this.name,
    required this.milliseconds,
  });

  final String name;
  final int milliseconds;

  Map<String, Object> toJson() => {
        'name': name,
        'milliseconds': milliseconds,
      };
}
