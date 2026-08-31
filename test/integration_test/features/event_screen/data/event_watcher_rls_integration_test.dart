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
  late supabase.SupabaseClient watcherClient;
  late ProvisionedTestActor owner;
  late ProvisionedTestActor watcher;
  CleanupScope? cleanupScope;
  EventCleanup? eventCleanup;

  setUp(() async {
    environment = SupabaseEnvironment.fromEnvironment();
    environment.requireCleanupConfiguration();
    context = TestRunContext.create();
    cleanupScope = CleanupScope();
    final clientFactory = SupabaseClientFactory(environment);
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
      testId: 'event-watcher-owner',
      role: TestActorRole.owner,
    );
    actorCleanup.track(owner);
    watcher = await provisioner.create(
      testId: 'event-watcher-role',
      role: TestActorRole.watcher,
    );
    actorCleanup.track(watcher);
    ownerClient = await _signIn(
      clientFactory.createAppClient(),
      owner,
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

  test('watchers can read events but cannot mutate ownership', () async {
    final event = EventFixture(context).draft(
      testId: 'watcher-event',
      title: '${context.runId} Watcher Event',
      creatorId: owner.userId,
    );
    eventCleanup!.track(event);
    await ownerClient.from(AppDatabase.eventsTable).insert({
      AppDatabase.id: event.eventId,
      AppDatabase.creatorId: owner.userId,
      AppDatabase.payload: event.event.toJson(),
    });

    final visible = await watcherClient
        .from(AppDatabase.eventsTable)
        .select('id')
        .eq(AppDatabase.id, event.eventId);
    expect(visible, hasLength(1));

    await watcherClient
        .from(AppDatabase.eventsTable)
        .update({
          AppDatabase.payload: event.event
              .copyWith(title: 'watcher-blocked')
              .toJson(),
        })
        .eq(AppDatabase.id, event.eventId);
    await watcherClient
        .from(AppDatabase.eventsTable)
        .delete()
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
