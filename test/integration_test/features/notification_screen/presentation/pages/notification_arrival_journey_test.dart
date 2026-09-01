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
import '../../../../shared/cleanup/registration_cleanup.dart';
import '../../../../shared/fixtures/event_fixture.dart';
import '../../../../shared/fixtures/registration_fixture.dart';
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
  SupabaseClient? ownerClient;
  SupabaseClient? attendeeClient;
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
      testId: 'notification-arrival',
      role: TestActorRole.owner,
    );
    actorCleanup.track(owner);
    attendee = await provisioner.create(
      testId: 'notification-arrival',
      role: TestActorRole.user,
    );
    actorCleanup.track(attendee);
    ownerClient = await _signIn(
      clientFactory.createAppClient(),
      owner,
      registrar,
    );
    attendeeClient = await _signIn(
      clientFactory.createAppClient(),
      attendee,
      registrar,
    );

    final ownerId = owner.userId;
    final attendeeId = attendee.userId;
    if (ownerId == null || attendeeId == null) {
      throw StateError('Notification journey actors were not provisioned.');
    }
    event = EventFixture(context).draft(
      testId: 'notification-arrival',
      title: '${context.runId} Arrival Event',
      date: '31/12/2029',
      location: 'Integration Hall',
      description: 'Notification arrival integration journey.',
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
        await cleanupClient
            .from(AppDatabase.eventRegistrationsTable)
            .delete()
            .eq(AppDatabase.eventId, fixture.eventId)
            .eq(AppDatabase.userId, attendeeId);
      },
    ).track(
      RegistrationFixture(context).draft(
        testId: 'notification-arrival',
        actor: attendee.definition,
        event: event,
      ),
    );
    cleanupScope!.add(() async {
      await cleanupClient
          .from('event_arrivals')
          .delete()
          .eq(AppDatabase.eventId, event.eventId);
      await cleanupClient
          .from('notifications')
          .delete()
          .eq(AppDatabase.eventId, event.eventId);
    });
    await ownerClient!.from(AppDatabase.eventsTable).insert({
      AppDatabase.id: event.eventId,
      AppDatabase.creatorId: ownerId,
      AppDatabase.payload: event.event.toJson(),
    });
    await attendeeClient!.rpc(
      'activate_event_registration',
      params: {
        'requested_event_id': event.eventId,
        'event_payload': event.event.toJson(),
      },
    );
    await cleanupClient.from('notifications').insert({
      'user_id': attendeeId,
      'event_id': event.eventId,
      'notification_type': 'arrival_confirmation',
      'title': 'Confirm your arrival',
      'message': 'Please confirm your attendance.',
      'event_date': '2029-12-31',
    });
  });

  tearDown(() async {
    await appHarness?.dispose();
    await attendeeClient?.auth.signOut();
    await ownerClient?.auth.signOut();
    await cleanupScope?.cleanup();
    cleanupScope = null;
  });

  testWidgets('confirms attendance from a notification', (tester) async {
    final client = attendeeClient;
    expect(client, isNotNull);
    if (client == null) {
      throw StateError('Notification app client was not created.');
    }
    final session = client.auth.currentSession;
    expect(session, isNotNull);
    if (session == null) {
      throw StateError('Notification attendee session was not created.');
    }
    appHarness = AuthenticatedAppHarness(
      environment: environment,
      session: session,
    );
    await appHarness!.start(tester);
    await tester.tap(find.byIcon(Icons.notifications_none_outlined));
    await pumpUntil(tester, find.text(AppText.arrivalConfirmation));
    expect(
      find.widgetWithText(OutlinedButton, AppText.attending),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(OutlinedButton, AppText.attending));
    await pumpUntil(tester, find.text(AppText.arrivalConfirmed));
    expect(
      find.widgetWithText(OutlinedButton, AppText.attending),
      findsNothing,
    );

    final arrival = await cleanupClient
        .from('event_arrivals')
        .select('status')
        .eq(AppDatabase.eventId, event.eventId)
        .eq(AppDatabase.userId, attendee.userId!)
        .single();
    expect(arrival['status'], 'attending');
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
