import '../actors/test_actor.dart';
import '../harness/test_run_context.dart';
import 'event_fixture.dart';

class RegistrationFixture {
  const RegistrationFixture(this.context);

  final TestRunContext context;

  RegistrationFixtureData draft({
    required String testId,
    required TestActor actor,
    required EventFixtureData event,
  }) {
    return RegistrationFixtureData(
      registrationId: context.namespace('$testId-registration'),
      registrationToken: context.namespace('$testId-token'),
      actor: actor,
      event: event,
    );
  }
}

class RegistrationFixtureData {
  const RegistrationFixtureData({
    required this.registrationId,
    required this.registrationToken,
    required this.actor,
    required this.event,
  });

  final String registrationId;
  final String registrationToken;
  final TestActor actor;
  final EventFixtureData event;

  String get eventId => event.eventId;
}
