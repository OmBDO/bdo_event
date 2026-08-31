import 'package:flutter_test/flutter_test.dart';

import 'test_run_context.dart';

void main() {
  test('normalizes a supplied seed and creates namespaced IDs', () {
    final context = TestRunContext.create(seed: 'Run 42 / Smoke');

    expect(context.runId, 'run-42-smoke');
    expect(context.namespace('Event CRUD'), 'run-42-smoke-event-crud');
  });

  test('uses a non-empty fallback run ID when the seed is blank', () {
    final context = TestRunContext.create(seed: '   ');

    expect(context.runId, isNotEmpty);
    expect(context.namespace('case'), endsWith('-case'));
  });

  test('keeps separate test IDs separate within one run', () {
    const context = TestRunContext('run-1');

    expect(context.namespace('auth'), isNot(context.namespace('event')));
  });
}
