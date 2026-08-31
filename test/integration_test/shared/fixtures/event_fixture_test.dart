import 'package:flutter_test/flutter_test.dart';

import '../harness/test_run_context.dart';
import 'event_fixture.dart';

void main() {
  test('creates a typed event with a namespaced ID', () {
    final fixture = EventFixture(TestRunContext('it-run'));

    final data = fixture.draft(
      testId: 'event-crud',
      title: 'Lifecycle event',
      creatorId: 'owner-1',
      capacity: 10,
    );

    expect(data.testId, 'event-crud');
    expect(data.eventId, 'it-run-event-crud-event');
    expect(data.event.title, 'Lifecycle event');
    expect(data.event.creatorId, 'owner-1');
    expect(data.event.capacity, 10);
  });

  test('creates distinct IDs for distinct test cases', () {
    final fixture = EventFixture(TestRunContext('it-run'));

    final first = fixture.draft(testId: 'registration');
    final second = fixture.draft(testId: 'invitation');

    expect(first.eventId, isNot(second.eventId));
  });

  test('uses safe defaults for optional event fields', () {
    final data = EventFixture(TestRunContext('it-run')).draft(
      testId: 'defaults',
    );

    expect(data.event.title, 'Integration test event');
    expect(data.event.date, '31/12/2099');
    expect(data.event.location, 'Pune');
    expect(data.event.imageUrl, isEmpty);
    expect(data.event.registrationDeadline, isNull);
  });
}
