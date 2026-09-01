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
  late supabase.SupabaseClient watcherClient;
  late supabase.SupabaseClient cleanupClient;
  late ProvisionedTestActor owner;
  late ProvisionedTestActor user;
  late ProvisionedTestActor watcher;
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
      testId: 'registration',
      role: TestActorRole.owner,
    );
    actorCleanup.track(owner);
    user = await provisioner.create(
      testId: 'registration',
      role: TestActorRole.user,
    );
    actorCleanup.track(user);
    watcher = await provisioner.create(
      testId: 'registration',
      role: TestActorRole.watcher,
    );
    actorCleanup.track(watcher);

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
    watcherClient = await _signIn(
      clientFactory.createAppClient(),
      watcher,
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

  test(
    'revocation invalidates the old token and excludes the registration',
    () async {
      Future<EventFixtureData> createEvent() async {
        final event = EventFixture(context).draft(
          testId: 'registration-event',
          title: '${context.runId} Registration Event',
          creatorId: owner.userId,
        );
        eventCleanup!.track(event);
        await ownerClient.from(AppDatabase.eventsTable).insert({
          AppDatabase.id: event.eventId,
          AppDatabase.creatorId: owner.userId,
          AppDatabase.payload: event.event.toJson(),
        });
        return event;
      }

      Future<void> activate(EventFixtureData event) => userClient.rpc(
        'activate_event_registration',
        params: {
          'requested_event_id': event.eventId,
          'event_payload': event.event.toJson(),
        },
      );

      Future<String> activeToken(EventFixtureData event) async {
        final row = await userClient
            .from(AppDatabase.eventRegistrationsTable)
            .select(AppDatabase.registrationToken)
            .eq(AppDatabase.eventId, event.eventId)
            .eq(AppDatabase.registrationStatus, AppDatabase.activeRegistration)
            .single();
        return row[AppDatabase.registrationToken] as String;
      }

      final event = await createEvent();
      final registration = RegistrationFixture(context)
          .draft(testId: 'lifecycle', actor: user.definition, event: event);
      registrationCleanup!.track(registration);

      await activate(event);
      final firstToken = await activeToken(event);
      await userClient.rpc(
        'revoke_event_registration',
        params: {'requested_event_id': event.eventId},
      );
      final revoked = await cleanupClient
          .from(AppDatabase.eventRegistrationsTable)
          .select('status')
          .eq(AppDatabase.eventId, event.eventId)
          .eq(AppDatabase.userId, user.userId!)
          .single();

      expect(revoked[AppDatabase.registrationStatus], 'revoked');
      expect(
        await userClient
            .from(AppDatabase.eventRegistrationsTable)
            .select(AppDatabase.registrationToken)
            .eq(AppDatabase.eventId, event.eventId)
            .eq(AppDatabase.registrationStatus, AppDatabase.activeRegistration),
        isEmpty,
      );
      expect(
        await watcherClient.rpc(
          'validate_event_registration',
          params: {
            'requested_token': firstToken,
            'requested_event_id': event.eventId,
          },
        ),
        isEmpty,
      );
    },
  );

  test('an active user cannot register for the same event twice', () async {
    Future<EventFixtureData> createEvent() async {
      final event = EventFixture(context).draft(
        testId: 'registration-event',
        title: '${context.runId} Registration Event',
        creatorId: owner.userId,
      );
      eventCleanup!.track(event);
      await ownerClient.from(AppDatabase.eventsTable).insert({
        AppDatabase.id: event.eventId,
        AppDatabase.creatorId: owner.userId,
        AppDatabase.payload: event.event.toJson(),
      });
      return event;
    }

    Future<void> activate(EventFixtureData event) => userClient.rpc(
      'activate_event_registration',
      params: {
        'requested_event_id': event.eventId,
        'event_payload': event.event.toJson(),
      },
    );

    final event = await createEvent();
    final registration = RegistrationFixture(context)
        .draft(testId: 'duplicate', actor: user.definition, event: event);
    registrationCleanup!.track(registration);

    await activate(event);
    await expectLater(
      activate(event),
      throwsA(isA<supabase.PostgrestException>()),
    );
  });

  test('a user cannot delete a registration row directly', () async {
    Future<EventFixtureData> createEvent() async {
      final event = EventFixture(context).draft(
        testId: 'registration-event',
        title: '${context.runId} Registration Event',
        creatorId: owner.userId,
      );
      eventCleanup!.track(event);
      await ownerClient.from(AppDatabase.eventsTable).insert({
        AppDatabase.id: event.eventId,
        AppDatabase.creatorId: owner.userId,
        AppDatabase.payload: event.event.toJson(),
      });
      return event;
    }

    Future<void> activate(EventFixtureData event) => userClient.rpc(
      'activate_event_registration',
      params: {
        'requested_event_id': event.eventId,
        'event_payload': event.event.toJson(),
      },
    );

    final event = await createEvent();
    final registration = RegistrationFixture(context)
        .draft(testId: 'direct-delete', actor: user.definition, event: event);
    registrationCleanup!.track(registration);

    await activate(event);
    await userClient
        .from(AppDatabase.eventRegistrationsTable)
        .delete()
        .eq(AppDatabase.eventId, event.eventId)
        .eq(AppDatabase.userId, user.userId!);

    final rows = await cleanupClient
        .from(AppDatabase.eventRegistrationsTable)
        .select(AppDatabase.registrationStatus)
        .eq(AppDatabase.eventId, event.eventId)
        .eq(AppDatabase.userId, user.userId!);
    expect(rows, hasLength(1));
    expect(
      rows.single[AppDatabase.registrationStatus],
      AppDatabase.activeRegistration,
    );
  });
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
