import 'package:bdo_event/core/util/resource/app_database.dart';
import 'package:bdo_event/core/util/resource/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../shared/actors/actor_cleanup.dart';
import '../../../../shared/actors/actor_factory.dart';
import '../../../../shared/actors/supabase_actor_cleanup.dart';
import '../../../../shared/actors/supabase_actor_registrar.dart';
import '../../../../shared/actors/test_actor.dart';
import '../../../../shared/cleanup/cleanup_scope.dart';
import '../../../../shared/cleanup/event_cleanup.dart';
import '../../../../shared/fixtures/event_fixture.dart';
import '../../../../shared/harness/authenticated_app_harness.dart';
import '../../../../shared/harness/supabase_client_factory.dart';
import '../../../../shared/harness/supabase_environment.dart';
import '../../../../shared/harness/test_run_context.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late SupabaseEnvironment environment;
  late TestRunContext context;
  late SupabaseActorRegistrar registrar;
  late ProvisionedTestActor owner;
  late ProvisionedTestActor attendee;
  SupabaseClient? appClient;
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
      testId: 'registration-journey',
      role: TestActorRole.owner,
    );
    actorCleanup.track(owner);
    attendee = await provisioner.create(
      testId: 'registration-journey',
      role: TestActorRole.user,
    );
    actorCleanup.track(attendee);

    final ownerSession = await _signIn(
      clientFactory.createAppClient(),
      owner,
      registrar,
    );
    ownerClient = ownerSession;
    final attendeeSession = await _signIn(
      clientFactory.createAppClient(),
      attendee,
      registrar,
    );
    appClient = attendeeSession;

    final ownerId = owner.userId;
    if (ownerId == null) {
      throw StateError('Event owner provisioning returned no user ID.');
    }
    event = EventFixture(context).draft(
      testId: 'registration-journey',
      title: '${context.runId} Registration Journey',
      date: '31/12/2029',
      location: 'Integration Hall',
      creatorId: ownerId,
      capacity: 10,
    );
    EventCleanup(
      scope: cleanupScope!,
      delete: (fixture) async {
        await clientFactory
            .createCleanupClient()
            .from(AppDatabase.eventsTable)
            .delete()
            .eq(AppDatabase.id, fixture.eventId);
      },
    ).track(event);
    await ownerSession.from(AppDatabase.eventsTable).insert({
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

  testWidgets('registers, opens a ticket, and appears in the calendar', (
    tester,
  ) async {
    final client = appClient;
    expect(client, isNotNull);
    if (client == null) {
      throw StateError('Test app client was not created.');
    }
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
    await pumpUntil(tester, find.byIcon(Icons.north_east).hitTestable());

    await tester.tap(find.byIcon(Icons.north_east).hitTestable());
    await tester.pumpAndSettle();
    final registerButton = find.widgetWithText(
      ElevatedButton,
      AppText.register,
    );
    expect(registerButton, findsOneWidget);

    await tester.tap(registerButton);
    await pumpUntil(
      tester,
      find.widgetWithText(ElevatedButton, AppText.myTicket),
    );

    await tester.tap(find.widgetWithText(ElevatedButton, AppText.myTicket));
    await pumpUntil(tester, find.text(AppText.registrationCode));

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.app_registration_rounded));
    await pumpUntil(tester, find.text(event.event.title).hitTestable());
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
