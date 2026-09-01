import 'package:bdo_event/core/util/resource/app_database.dart';
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
import '../../../shared/harness/concurrent_start_barrier.dart';
import '../../../shared/harness/supabase_client_factory.dart';
import '../../../shared/harness/supabase_environment.dart';
import '../../../shared/harness/test_run_context.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late SupabaseEnvironment environment;
  late TestRunContext context;
  late SupabaseActorRegistrar registrar;
  late supabase.SupabaseClient ownerClient;
  late supabase.SupabaseClient firstUserClient;
  late supabase.SupabaseClient secondUserClient;
  late supabase.SupabaseClient cleanupClient;
  late ProvisionedTestActor owner;
  late ProvisionedTestActor firstUser;
  late ProvisionedTestActor secondUser;
  CleanupScope? cleanupScope;
  EventCleanup? eventCleanup;

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
      testId: 'capacity',
      role: TestActorRole.owner,
    );
    actorCleanup.track(owner);
    firstUser = await provisioner.create(
      testId: 'capacity-first',
      role: TestActorRole.user,
    );
    actorCleanup.track(firstUser);
    secondUser = await provisioner.create(
      testId: 'capacity-second',
      role: TestActorRole.user,
    );
    actorCleanup.track(secondUser);

    ownerClient = await _signIn(
      clientFactory.createAppClient(),
      owner,
      registrar,
    );
    firstUserClient = await _signIn(
      clientFactory.createAppClient(),
      firstUser,
      registrar,
    );
    secondUserClient = await _signIn(
      clientFactory.createAppClient(),
      secondUser,
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
  });

  tearDown(() async {
    await cleanupScope?.cleanup();
    cleanupScope = null;
  });

  test('capacity one admits exactly one synchronized registration', () async {
    Future<EventFixtureData> createCapacityEvent() async {
      final event = EventFixture(context).draft(
        testId: 'capacity-event',
        title: '${context.runId} Capacity Event',
        creatorId: owner.userId,
        capacity: 1,
      );
      eventCleanup!.track(event);
      await ownerClient.from(AppDatabase.eventsTable).insert({
        AppDatabase.id: event.eventId,
        AppDatabase.creatorId: owner.userId,
        AppDatabase.payload: event.event.toJson(),
      });
      return event;
    }

    void trackRegistration(
      ProvisionedTestActor actor,
      EventFixtureData event,
      String testId,
    ) {
      final registration = RegistrationFixture(context)
          .draft(testId: testId, actor: actor.definition, event: event);
      RegistrationCleanup(
        scope: cleanupScope!,
        delete: (_) async {
          await cleanupClient
              .from(AppDatabase.eventRegistrationsTable)
              .delete()
              .eq(AppDatabase.eventId, event.eventId)
              .eq(AppDatabase.userId, actor.userId!);
        },
      ).track(registration);
    }

    final event = await createCapacityEvent();
    trackRegistration(firstUser, event, 'capacity-first-registration');
    trackRegistration(secondUser, event, 'capacity-second-registration');
    final barrier = ConcurrentStartBarrier(2);

    final outcomes = await Future.wait([
      _activateAtBarrier(firstUserClient, event, barrier),
      _activateAtBarrier(secondUserClient, event, barrier),
    ]);
    final failures = outcomes.whereType<supabase.PostgrestException>();
    final activeRows = await cleanupClient
        .from(AppDatabase.eventRegistrationsTable)
        .select('user_id, status')
        .eq(AppDatabase.eventId, event.eventId)
        .eq(AppDatabase.registrationStatus, AppDatabase.activeRegistration);

    expect(outcomes.where((outcome) => outcome == null), hasLength(1));
    expect(failures, hasLength(1));
    expect(failures.single.message, contains('capacity'));
    expect(activeRows, hasLength(1));
  });
}

Future<Object?> _activateAtBarrier(
  supabase.SupabaseClient client,
  EventFixtureData event,
  ConcurrentStartBarrier barrier,
) async {
  await barrier.wait();
  try {
    await client.rpc(
      'activate_event_registration',
      params: {
        'requested_event_id': event.eventId,
        'event_payload': event.event.toJson(),
      },
    );
    return null;
  } catch (error) {
    return error;
  }
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
