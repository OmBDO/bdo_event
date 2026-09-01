import 'package:flutter_test/flutter_test.dart';

import '../actors/test_actor.dart';
import '../fixtures/event_fixture.dart';
import '../fixtures/registration_fixture.dart';
import '../harness/test_run_context.dart';
import 'cleanup_scope.dart';
import 'event_cleanup.dart';
import 'registration_cleanup.dart';

void main() {
  test('forwards typed handles and cleans registrations before events',
      () async {
    const context = TestRunContext('it-run');
    final event = EventFixture(context).draft(testId: 'lifecycle');
    final actor = TestActorFactory(context).create(
      testId: 'lifecycle',
      role: TestActorRole.user,
    );
    final registration = RegistrationFixture(context).draft(
      testId: 'lifecycle',
      actor: actor,
      event: event,
    );
    final scope = CleanupScope();
    final calls = <String>[];
    EventFixtureData? deletedEvent;
    RegistrationFixtureData? deletedRegistration;
    final eventCleanup = EventCleanup(
      scope: scope,
      delete: (value) async {
        deletedEvent = value;
        calls.add('event');
      },
    );
    final registrationCleanup = RegistrationCleanup(
      scope: scope,
      delete: (value) async {
        deletedRegistration = value;
        calls.add('registration');
      },
    );

    eventCleanup.track(event);
    registrationCleanup.track(registration);
    await scope.cleanup();

    expect(calls, ['registration', 'event']);
    expect(deletedEvent, same(event));
    expect(deletedRegistration, same(registration));
  });
}
