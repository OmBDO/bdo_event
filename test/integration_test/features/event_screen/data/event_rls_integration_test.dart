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
import '../../../shared/fixtures/event_fixture.dart';
import '../../../shared/harness/supabase_client_factory.dart';
import '../../../shared/harness/supabase_environment.dart';
import '../../../shared/harness/test_run_context.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late SupabaseEnvironment environment;
  late TestRunContext context;
  late SupabaseActorRegistrar registrar;
  late supabase.SupabaseClient ownerClient;
  late supabase.SupabaseClient regularClient;
  late supabase.SupabaseClient unrelatedClient;
  late supabase.SupabaseClient anonymousClient;
  late ProvisionedTestActor owner;
  late ProvisionedTestActor regularUser;
  late ProvisionedTestActor unrelatedUser;
  CleanupScope? cleanupScope;
  EventCleanup? eventCleanup;

  setUp(() async {
    environment = SupabaseEnvironment.fromEnvironment();
    environment.requireCleanupConfiguration();
    context = TestRunContext.create();
    cleanupScope = CleanupScope();
    final clientFactory = SupabaseClientFactory(environment);
    anonymousClient = clientFactory.createAppClient();
    registrar = SupabaseActorRegistrar(environment: environment);
    final actorProvisioner = TestActorProvisioner(
      context: context,
      register: registrar.register,
    );
    final actorCleanup = ActorCleanup(
      scope: cleanupScope!,
      delete: SupabaseActorCleanup(environment: environment).delete,
    );

    owner = await actorProvisioner.create(
      testId: 'event-rls',
      role: TestActorRole.owner,
    );
    actorCleanup.track(owner);
    regularUser = await actorProvisioner.create(
      testId: 'event-rls',
      role: TestActorRole.user,
    );
    actorCleanup.track(regularUser);
    unrelatedUser = await actorProvisioner.create(
      testId: 'event-rls',
      role: TestActorRole.unrelated,
    );
    actorCleanup.track(unrelatedUser);

    ownerClient = await _signIn(
      clientFactory.createAppClient(),
      owner,
      registrar,
    );
    regularClient = await _signIn(
      clientFactory.createAppClient(),
      regularUser,
      registrar,
    );
    unrelatedClient = await _signIn(
      clientFactory.createAppClient(),
      unrelatedUser,
      registrar,
    );
    eventCleanup = EventCleanup(
      scope: cleanupScope!,
      delete: (fixture) async {
        await clientFactory
            .createCleanupClient()
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

  test('authenticated users can read an admin-owned event', () async {
    final event = await _createEvent();
    final rows = await regularClient
        .from(AppDatabase.eventsTable)
        .select('id, creator_id, payload')
        .eq(AppDatabase.id, event.eventId);

    expect(rows, hasLength(1));
    expect(rows.single[AppDatabase.id], event.eventId);
    expect(rows.single[AppDatabase.creatorId], owner.userId);
  });

  test('anonymous clients cannot read or create events', () async {
    final event = await _createEvent();
    final anonymousRows = await anonymousClient
      .from(AppDatabase.eventsTable)
      .select('id')
      .eq(AppDatabase.id, event.eventId);
    expect(anonymousRows, isEmpty);

    final candidate = EventFixture(context).draft(
      testId: 'anonymous-create',
      creatorId: owner.userId,
    );
    eventCleanup!.track(candidate);
    await expectLater(
      anonymousClient.from(AppDatabase.eventsTable).insert({
        AppDatabase.id: candidate.eventId,
        AppDatabase.creatorId: owner.userId,
        AppDatabase.payload: candidate.event.toJson(),
      }),
      throwsA(isA<supabase.PostgrestException>()),
    );
  });

  test('regular users cannot create events or mutate another owner event',
      () async {
    final event = await _createEvent();
    final unauthorizedEvent = EventFixture(context).draft(
      testId: 'unauthorized-create',
      creatorId: regularUser.userId,
    );

    await expectLater(
      regularClient.from(AppDatabase.eventsTable).insert({
        AppDatabase.id: unauthorizedEvent.eventId,
        AppDatabase.creatorId: regularUser.userId,
        AppDatabase.payload: unauthorizedEvent.event.toJson(),
      }),
      throwsA(isA<supabase.PostgrestException>()),
    );
    await unrelatedClient
        .from(AppDatabase.eventsTable)
        .update({
          AppDatabase.payload: event.event.copyWith(title: 'blocked').toJson(),
        })
        .eq(AppDatabase.id, event.eventId);
    final unchanged = await ownerClient
        .from(AppDatabase.eventsTable)
        .select('payload')
        .eq(AppDatabase.id, event.eventId)
        .single();

    expect(
      (unchanged[AppDatabase.payload] as Map)['title'],
      event.event.title,
    );
    await unrelatedClient
        .from(AppDatabase.eventsTable)
        .delete()
        .eq(AppDatabase.id, event.eventId);
    final remaining = await ownerClient
      .from(AppDatabase.eventsTable)
      .select('id')
      .eq(AppDatabase.id, event.eventId);
    expect(remaining, hasLength(1));
  });

  Future<EventFixtureData> _createEvent() async {
    final event = EventFixture(context).draft(
      testId: 'owned-event',
      title: '${context.runId} Event',
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
