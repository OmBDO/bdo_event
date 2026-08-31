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
import '../../../shared/cleanup/registration_cleanup.dart';
import '../../../shared/fixtures/event_fixture.dart';
import '../../../shared/fixtures/registration_fixture.dart';
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
  late ProvisionedTestActor attendee;
  SupabaseClient? appClient;
  SupabaseClient? ownerClient;
  late SupabaseClient cleanupClient;
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
    final actorCleanup = ActorCleanup(
      scope: cleanupScope!,
      delete: SupabaseActorCleanup(environment: environment).delete,
    );

    owner = await provisioner.create(
      testId: 'ticket-cancellation',
      role: TestActorRole.owner,
    );
    actorCleanup.track(owner);
    attendee = await provisioner.create(
      testId: 'ticket-cancellation',
      role: TestActorRole.user,
    );
    actorCleanup.track(attendee);

    ownerClient = await _signIn(
      clientFactory.createAppClient(),
      owner,
      registrar,
    );
    appClient = await _signIn(
      clientFactory.createAppClient(),
      attendee,
      registrar,
    );

    final ownerId = owner.userId;
    if (ownerId == null) {
      throw StateError('Event owner provisioning returned no user ID.');
    }
    event = EventFixture(context).draft(
      testId: 'ticket-cancellation',
      title: '${context.runId} Ticket Cancellation',
      date: '31/12/2029',
      location: 'Integration Hall',
      description: 'Ticket cancellation integration journey.',
      creatorId: ownerId,
      capacity: 10,
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
    RegistrationCleanup(
      scope: cleanupScope!,
      delete: (fixture) async {
        final attendeeId = attendee.userId;
        if (attendeeId == null) return;
        await cleanupClient
            .from(AppDatabase.eventRegistrationsTable)
            .delete()
            .eq(AppDatabase.eventId, fixture.eventId)
            .eq(AppDatabase.userId, attendeeId);
      },
    ).track(
      RegistrationFixture(context).draft(
        testId: 'ticket-cancellation',
        actor: attendee.definition,
        event: event,
      ),
    );
    await ownerClient!.from(AppDatabase.eventsTable).insert({
      AppDatabase.id: event.eventId,
      AppDatabase.creatorId: ownerId,
      AppDatabase.payload: event.event.toJson(),
    });
  });

  tearDown(() async {
    await appHarness?.dispose();
    await appClient?.auth.signOut();
    await ownerClient?.auth.signOut();
    await cleanupScope?.cleanup();
    cleanupScope = null;
  });

  testWidgets('cancels a ticket and removes it from the calendar',
      (tester) async {
    final client = appClient;
    expect(client, isNotNull);
    if (client == null) {
      throw StateError('Test app client was not created.');
    }
    await client.rpc(
      'activate_event_registration',
      params: {
        'requested_event_id': event.eventId,
        'event_payload': event.event.toJson(),
      },
    );
    final session = client.auth.currentSession;
    expect(session, isNotNull);
    if (session == null) {
      throw StateError('Test attendee session was not created.');
    }

    appHarness = AuthenticatedAppHarness(
      environment: environment,
      session: session,
    );
    await appHarness!.start(tester);
    await tester.tap(find.byIcon(Icons.app_registration_rounded));
    final visibleEvent = find.text(event.event.title).hitTestable();
    await pumpUntil(tester, visibleEvent);
    await tester.tap(visibleEvent);
    await pumpUntil(
      tester,
      find.widgetWithText(
        OutlinedButton,
        AppText.cancelRegistrationButton,
      ),
    );

    await tester.tap(
      find.widgetWithText(OutlinedButton, AppText.cancelRegistrationButton),
    );
    await tester.pumpAndSettle();
    expect(find.text(AppText.cancelRegistrationQuestion), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, AppText.cancelEvent));
    await pumpUntil(tester, find.text(AppText.calendarReady));

    expect(find.text(event.event.title).hitTestable(), findsNothing);
    final revoked = await cleanupClient
        .from(AppDatabase.eventRegistrationsTable)
        .select(AppDatabase.registrationStatus)
        .eq(AppDatabase.eventId, event.eventId)
        .eq(AppDatabase.userId, attendee.userId!)
        .single();
    expect(revoked[AppDatabase.registrationStatus], 'revoked');
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

