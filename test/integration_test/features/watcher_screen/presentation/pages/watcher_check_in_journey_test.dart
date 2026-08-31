import 'package:bdo_event/core/util/event_resource.dart';
import 'package:bdo_event/core/util/registration_code_codec.dart';
import 'package:bdo_event/features/watcher_screen/watcher_scan.dart';
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
import '../../../shared/harness/watcher_native_test_adapters.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late SupabaseEnvironment environment;
  late TestRunContext context;
  late SupabaseActorRegistrar registrar;
  late ProvisionedTestActor owner;
  late ProvisionedTestActor attendee;
  late ProvisionedTestActor watcher;
  SupabaseClient? ownerClient;
  SupabaseClient? attendeeClient;
  SupabaseClient? watcherClient;
  late SupabaseClient cleanupClient;
  late EventFixtureData event;
  late String registrationToken;
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
      testId: 'watcher-journey',
      role: TestActorRole.owner,
    );
    actorCleanup.track(owner);
    attendee = await provisioner.create(
      testId: 'watcher-journey',
      role: TestActorRole.user,
    );
    actorCleanup.track(attendee);
    watcher = await provisioner.create(
      testId: 'watcher-journey',
      role: TestActorRole.watcher,
    );
    actorCleanup.track(watcher);
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
    watcherClient = await _signIn(
      clientFactory.createAppClient(),
      watcher,
      registrar,
    );

    final ownerId = owner.userId;
    final attendeeId = attendee.userId;
    if (ownerId == null || attendeeId == null) {
      throw StateError('Watcher journey actors were not provisioned.');
    }
    event = EventFixture(context).draft(
      testId: 'watcher-journey',
      title: '${context.runId} Watcher Check-in',
      date: '31/12/2029',
      location: 'Integration Hall',
      description: 'Watcher check-in integration journey.',
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
        testId: 'watcher-journey',
        actor: attendee.definition,
        event: event,
      ),
    );
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
    final registration = await cleanupClient
        .from(AppDatabase.eventRegistrationsTable)
        .select(AppDatabase.registrationToken)
        .eq(AppDatabase.eventId, event.eventId)
        .eq(AppDatabase.userId, attendeeId)
        .eq(AppDatabase.registrationStatus, AppDatabase.activeRegistration)
        .single();
    registrationToken = registration[AppDatabase.registrationToken] as String;
  });
  tearDown(() async {
    await appHarness?.dispose();
    await watcherClient?.auth.signOut();
    await attendeeClient?.auth.signOut();
    await ownerClient?.auth.signOut();
    await cleanupScope?.cleanup();
    cleanupScope = null;
  });
  testWidgets('validates a manual code and confirms all pending attendees',
      (tester) async {
    final client = watcherClient;
    expect(client, isNotNull);
    if (client == null) {
      throw StateError('Watcher app client was not created.');
    }
    final session = client.auth.currentSession;
    expect(session, isNotNull);
    if (session == null) {
      throw StateError('Watcher session was not created.');
    }
    appHarness = AuthenticatedAppHarness(
      environment: environment,
      session: session,
    );
    await appHarness!.start(
      tester,
      home: WatcherScanScreen(
        scanner: const TestWatcherScannerAdapter(),
        voice: const TestWatcherVoiceAdapter(),
        feedback: const TestWatcherFeedbackAdapter(),
      ),
    );

    final code = RegistrationCodeCodec.encode(
      eventId: event.eventId,
      token: registrationToken,
    );
    final field = find.byType(TextField);
    expect(field, findsOneWidget);
    await tester.enterText(field, code);
    await tester.tap(find.byTooltip(AppText.validateRegistrationCode));
    await pumpUntil(tester, find.text(AppText.pendingCheckIn));

    await tester.tap(find.byTooltip(AppText.viewScanHistory));
    await pumpUntil(tester, find.text(AppText.confirmAll));
    await tester.tap(find.widgetWithText(FilledButton, AppText.confirmAll));
    await pumpUntil(tester, find.text(AppText.checkedIn));

    final checkIns = await cleanupClient
        .from(AppDatabase.checkInsTable)
        .select(AppDatabase.registrationToken)
        .eq(AppDatabase.registrationToken, registrationToken);
    expect(checkIns, hasLength(1));
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
