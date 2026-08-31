import 'package:flutter_test/flutter_test.dart';

import '../actors/test_actor.dart';
import '../harness/test_run_context.dart';
import 'event_fixture.dart';
import 'registration_fixture.dart';

void main() {
  test('composes a registration handle from an actor and event', () {
    const context = TestRunContext('it-run');
    final actor = TestActorFactory(context).create(
      testId: 'registration',
      role: TestActorRole.user,
    );
    final event = EventFixture(context).draft(testId: 'registration');
    final registration = RegistrationFixture(context).draft(
      testId: 'registration',
      actor: actor,
      event: event,
    );

    expect(registration.eventId, event.eventId);
    expect(registration.actor, same(actor));
    expect(registration.registrationId, 'it-run-registration-registration');
    expect(registration.registrationToken, 'it-run-registration-token');
  });

  test('keeps registration handles isolated by test ID', () {
    const context = TestRunContext('it-run');
    final actor = TestActorFactory(context).create(
      testId: 'shared',
      role: TestActorRole.user,
    );
    final event = EventFixture(context).draft(testId: 'shared');
    final fixture = RegistrationFixture(context);

    final first = fixture.draft(testId: 'first', actor: actor, event: event);
    final second = fixture.draft(testId: 'second', actor: actor, event: event);

    expect(first.registrationId, isNot(second.registrationId));
    expect(first.registrationToken, isNot(second.registrationToken));
  });
}
