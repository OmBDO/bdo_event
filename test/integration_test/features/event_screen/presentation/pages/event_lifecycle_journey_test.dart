import 'package:bdo_event/core/model/event_model/event_catagory.dart';
import 'package:bdo_event/core/util/event_resource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/actors/actor_cleanup.dart';
import '../../../shared/actors/actor_factory.dart';
import '../../../shared/actors/supabase_actor_cleanup.dart';
import '../../../shared/actors/supabase_actor_registrar.dart';
import '../../../shared/actors/test_actor.dart';
import '../../../shared/cleanup/cleanup_scope.dart';
import '../../../shared/cleanup/event_cleanup.dart';
import '../../../shared/fixtures/event_fixture.dart';
import '../../../shared/harness/authenticated_app_harness.dart';
import '../../../shared/harness/supabase_client_factory.dart';
import '../../../shared/harness/supabase_environment.dart';
import '../../../shared/harness/test_run_context.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late SupabaseEnvironment environment;
  late TestRunContext context;
  late SupabaseActorRegistrar registrar;
  late ProvisionedTestActor owner;
  late SupabaseClient cleanupClient;
  SupabaseClient? ownerClient;
  late EventFixtureData event;
  CleanupScope? cleanupScope;
  AuthenticatedAppHarness? appHarness;

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
    owner = await provisioner.create(
      testId: 'event-lifecycle',
      role: TestActorRole.owner,
    );
    ActorCleanup(
      scope: cleanupScope!,
      delete: SupabaseActorCleanup(environment: environment).delete,
    ).track(owner);
    ownerClient = await _signIn(
      clientFactory.createAppClient(),
      owner,
      registrar,
    );

    final ownerId = owner.userId;
    if (ownerId == null) {
      throw StateError('Event lifecycle owner has no user ID.');
    }
    final draft = EventFixture(context).draft(
      testId: 'event-lifecycle',
      title: '${context.runId} Lifecycle Event',
      date: '31/12/2029',
      location: 'Integration Hall',
      description: 'Initial lifecycle description.',
      creatorId: ownerId,
    );
    event = EventFixtureData(
      event: draft.event.copyWith(
        imageUrl: AppAssets.logo,
        startTime: '10:00',
        endTime: '11:00',
        catagory: EventCategory.defaults.first,
      ),
      testId: draft.testId,
    );
    EventCleanup(
      scope: cleanupScope!,
      delete: (fixture) async {
        await cleanupClient
            .from(AppDatabase.eventsTable)
            .delete()
            .eq(AppDatabase.id, fixture.eventId);
      },
    ).track(event);
    await ownerClient!.from(AppDatabase.eventsTable).insert({
      AppDatabase.id: event.eventId,
      AppDatabase.creatorId: ownerId,
      AppDatabase.payload: event.event.toJson(),
    });
  });

  tearDown(() async {
    await appHarness?.dispose();
    await ownerClient?.auth.signOut();
    await cleanupScope?.cleanup();
    cleanupScope = null;
  });

  testWidgets('edits, revisits, and deletes an owned event', (tester) async {
    final client = ownerClient;
    expect(client, isNotNull);
    if (client == null) {
      throw StateError('Event lifecycle owner client was not created.');
    }
    final session = client.auth.currentSession;
    expect(session, isNotNull);
    if (session == null) {
      throw StateError('Event lifecycle owner session was not created.');
    }
    appHarness = AuthenticatedAppHarness(
      environment: environment,
      session: session,
    );
    await appHarness!.start(tester);
    await tester.tap(find.byIcon(Icons.add_circle_outline_rounded));
    final originalTitle = find.text(event.event.title).hitTestable();
    await pumpUntil(tester, originalTitle);
    await tester.tap(originalTitle);
    await pumpUntil(tester, find.bySemanticsLabel(AppText.eventTitle));

    const updatedTitle = 'Updated lifecycle event';
    await tester.enterText(
      find.bySemanticsLabel(AppText.eventTitle),
      updatedTitle,
    );
    await tester.enterText(
      find.bySemanticsLabel(AppText.description),
      'Updated lifecycle description.',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, AppText.updateEvent));
    await pumpUntil(tester, find.text(updatedTitle).hitTestable());

    final saved = await cleanupClient
        .from(AppDatabase.eventsTable)
        .select(AppDatabase.payload)
        .eq(AppDatabase.id, event.eventId)
        .single();
    final savedPayload = saved[AppDatabase.payload] as Map<String, dynamic>;
    expect(savedPayload['title'], updatedTitle);
    expect(savedPayload['description'], 'Updated lifecycle description.');

    final updatedEvent = find.text(updatedTitle).hitTestable();
    await tester.tap(updatedEvent);
    await pumpUntil(tester, find.bySemanticsLabel(AppText.eventTitle));
    expect(
      tester
          .widget<TextFormField>(find.bySemanticsLabel(AppText.eventTitle))
          .controller
          ?.text,
      updatedTitle,
    );
    await tester.pageBack();
    await tester.pumpAndSettle();

    final draggableEvent = find.text(updatedTitle).hitTestable();
    final deleteTarget = find.byType(FloatingActionButton).hitTestable();
    final gesture = await tester.startGesture(tester.getCenter(draggableEvent));
    await tester.pump(const Duration(milliseconds: 300));
    await gesture.moveTo(tester.getCenter(deleteTarget));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text(AppText.deleteEventQuestion), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, AppText.delete));
    await pumpUntil(tester, find.text(AppText.noEventsCreated));
    final deleted = await cleanupClient
        .from(AppDatabase.eventsTable)
        .select(AppDatabase.id)
        .eq(AppDatabase.id, event.eventId);
    expect(deleted, isEmpty);
  });
}

Future<SupabaseClient> _signIn(
  SupabaseClient client,
  ProvisionedTestActor actor,
  SupabaseActorRegistrar registrar,
) async {
  final email = actor.email;
  if (email == null) {
    throw StateError('Authenticated test actor has no email address.');
  }
  await client.auth.signInWithPassword(
    email: email,
    password: registrar.passwordFor(actor.definition),
  );
  return client;
}
