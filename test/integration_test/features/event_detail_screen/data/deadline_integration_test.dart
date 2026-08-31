import 'package:bdo_event/core/util/event_resource.dart' show AppDatabase;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../shared/actors/actor_cleanup.dart';
import '../../../shared/actors/actor_factory.dart';
import '../../../shared/actors/supabase_actor_cleanup.dart';
import '../../../shared/actors/supabase_actor_registrar.dart';
import '../../../shared/actors/test_actor.dart';
import '../../../shared/cleanup/cleanup_scope.dart';
import '../../../shared/cleanup/event_cleanup.dart';
import '../../../shared/cleanup/registration_cleanup.dart';
import '../../../shared/fixtures/event_fixture.dart';
import '../../../shared/fixtures/registration_fixture.dart';
import '../../../shared/harness/supabase_client_factory.dart';
import '../../../shared/harness/supabase_environment.dart';
import '../../../shared/harness/test_run_context.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late SupabaseEnvironment environment;
  late TestRunContext context;
  late SupabaseActorRegistrar registrar;
  late supabase.SupabaseClient ownerClient;
  late supabase.SupabaseClient userClient;
  late supabase.SupabaseClient cleanupClient;
  late ProvisionedTestActor owner;
  late ProvisionedTestActor user;
  CleanupScope? cleanupScope;
  EventCleanup? eventCleanup;
  RegistrationCleanup? registrationCleanup;

  setUp(() async {
    environment = SupabaseEnvironment.fromEnvironment();
    environment.requireCleanupConfiguration();
    context = TestRunContext.create();
    cleanupScope = CleanupScope();
    final clientFactory = SupabaseClientFactory(environment);
    cleanupClient = clientFactory.createCleanupClient();
    registrar = SupabaseActorRegistrar(environment: environment);
    final provisioner = TestActorProvisioner(
      context: context,
      register: registrar.register,
    );
    final actorCleanup = ActorCleanup(
      scope: cleanupScope!,
      delete: SupabaseActorCleanup(environment: environment).delete,
    );

    owner = await provisioner.create(
      testId: 'deadline-owner',
      role: TestActorRole.owner,
    );
    actorCleanup.track(owner);
    user = await provisioner.create(
      testId: 'deadline-user',
      role: TestActorRole.user,
    );
    actorCleanup.track(user);

    ownerClient = await _signIn(
      clientFactory.createAppClient(),
      owner,
      registrar,
    );
    userClient = await _signIn(
      clientFactory.createAppClient(),
      user,
      registrar,
    );
    eventCleanup = EventCleanup(
      scope: cleanupScope!,
      delete: (fixture) async {
        await cleanupClient
            .from(AppDatabase.eventsTable)
            .delete()
            .eq(AppDatabase.id, fixture.eventId);
      },
    );
    registrationCleanup = RegistrationCleanup(
      scope: cleanupScope!,
      delete: (fixture) async {
        await cleanupClient
            .from(AppDatabase.eventRegistrationsTable)
            .delete()
            .eq(AppDatabase.eventId, fixture.eventId)
            .eq(AppDatabase.userId, user.userId!);
      },
    );
  });

  tearDown(() async {
    await cleanupScope?.cleanup();
    cleanupScope = null;
  });

  test('enforces future, boundary, and past registration deadlines', () async {
    final openEvent = await _createEvent(
      'deadline-open',
      DateTime.now().toUtc().add(const Duration(minutes: 5)),
    );
    _trackRegistration(openEvent, 'deadline-open-registration');
    await _activate(openEvent);

    final boundaryEvent = await _createEvent(
      'deadline-boundary',
      DateTime.now().toUtc(),
    );
    await expectLater(
      _activate(boundaryEvent),
      throwsA(
        predicate<supabase.PostgrestException>(
          (error) => error.message.contains('closed'),
        ),
      ),
    );

    final closedEvent = await _createEvent(
      'deadline-closed',
      DateTime.now().toUtc().subtract(const Duration(minutes: 5)),
    );
    final staleFuturePayload = closedEvent.event
        .copyWith(
          registrationDeadline: DateTime.now().toUtc().add(
            const Duration(days: 1),
          ),
        )
        .toJson();
    await expectLater(
      _activate(closedEvent, payload: staleFuturePayload),
      throwsA(
        predicate<supabase.PostgrestException>(
          (error) => error.message.contains('closed'),
        ),
      ),
    );

    final activeRows = await cleanupClient
        .from(AppDatabase.eventRegistrationsTable)
        .select('event_id, status')
        .eq(AppDatabase.userId, user.userId!)
        .eq(AppDatabase.registrationStatus, AppDatabase.activeRegistration);
    expect(activeRows, hasLength(1));
    expect(activeRows.single[AppDatabase.eventId], openEvent.eventId);
  });

  Future<EventFixtureData> _createEvent(
    String testId,
    DateTime deadline,
  ) async {
    final event = EventFixture(context).draft(
      testId: testId,
      title: '${context.runId} $testId',
      creatorId: owner.userId,
      registrationDeadline: deadline,
    );
    eventCleanup!.track(event);
    await ownerClient.from(AppDatabase.eventsTable).insert({
      AppDatabase.id: event.eventId,
      AppDatabase.creatorId: owner.userId,
      AppDatabase.payload: event.event.toJson(),
    });
    return event;
  }

  void _trackRegistration(EventFixtureData event, String testId) {
    final registration = RegistrationFixture(context).draft(
      testId: testId,
      actor: user.definition,
      event: event,
    );
    registrationCleanup!.track(registration);
  }

  Future<void> _activate(
    EventFixtureData event, {
    Map<String, dynamic>? payload,
  }) => userClient.rpc(
    'activate_event_registration',
    params: {
      'requested_event_id': event.eventId,
      'event_payload': payload ?? event.event.toJson(),
    },
  );
}

Future<supabase.SupabaseClient> _signIn(
  supabase.SupabaseClient client,
  ProvisionedTestActor actor,
  SupabaseActorRegistrar registrar,
) async {
  await client.auth.signInWithPassword(
    email: actor.email!,
    password: registrar.passwordFor(actor.definition),
  );
  return client;
}
