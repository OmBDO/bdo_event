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
  late ProvisionedTestActor admin;
  late ProvisionedTestActor invitee;
  SupabaseClient? adminClient;
  SupabaseClient? inviteeClient;
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

    admin = await provisioner.create(
      testId: 'invitation-journey',
      role: TestActorRole.admin,
    );
    actorCleanup.track(admin);
    invitee = await provisioner.create(
      testId: 'invitation-journey',
      role: TestActorRole.user,
    );
    actorCleanup.track(invitee);
    adminClient = await _signIn(
      clientFactory.createAppClient(),
      admin,
      registrar,
    );
    inviteeClient = await _signIn(
      clientFactory.createAppClient(),
      invitee,
      registrar,
    );

    final adminId = admin.userId;
    if (adminId == null) {
      throw StateError('Admin provisioning returned no user ID.');
    }
    event = EventFixture(context).draft(
      testId: 'invitation-journey',
      title: '${context.runId} Invitation Journey',
      date: '31/12/2029',
      location: 'Integration Hall',
      description: 'Invitation integration journey.',
      creatorId: adminId,
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
    cleanupScope!.add(() async {
        await cleanupClient
          .from('notifications')
          .delete()
          .eq(AppDatabase.eventId, event.eventId);
      await cleanupClient
          .from('event_invitations')
          .delete()
          .eq(AppDatabase.eventId, event.eventId);
      await cleanupClient
          .from(AppDatabase.eventRegistrationsTable)
          .delete()
          .eq(AppDatabase.eventId, event.eventId);
    });
    await adminClient!.from(AppDatabase.eventsTable).insert({
      AppDatabase.id: event.eventId,
      AppDatabase.creatorId: adminId,
      AppDatabase.payload: event.event.toJson(),
    });
  });
  tearDown(() async {
    await appHarness?.dispose();
    await adminClient?.auth.signOut();
    await inviteeClient?.auth.signOut();
    await cleanupScope?.cleanup();
    cleanupScope = null;
  });
  testWidgets('sends an invitation and accepts it from notifications',
      (tester) async {
    final sender = adminClient;
    final recipient = inviteeClient;
    expect(sender, isNotNull);
    expect(recipient, isNotNull);
    if (sender == null || recipient == null) {
      throw StateError('Invitation test clients were not created.');
    }
    final senderSession = sender.auth.currentSession;
    expect(senderSession, isNotNull);
    if (senderSession == null) {
      throw StateError('Admin session was not created.');
    }

    appHarness = AuthenticatedAppHarness(
      environment: environment,
      session: senderSession,
    );
    await appHarness!.start(tester);
    await tester.tap(find.byIcon(Icons.add_circle_outline_rounded));
    await pumpUntil(tester, find.text(event.event.title).hitTestable());
    await tester.tap(find.byTooltip(AppText.inviteUsers));
    await pumpUntil(
      tester,
      find.widgetWithText(CheckboxListTile, invitee.email!),
    );

    final recipientTile = find.widgetWithText(
      CheckboxListTile,
      invitee.email!,
    );
    await tester.tap(recipientTile);
    await pumpUntil(
      tester,
      find.widgetWithText(FilledButton, AppText.sendToUsers(1)),
    );
    await tester.tap(
      find.widgetWithText(FilledButton, AppText.sendToUsers(1)),
    );
    await pumpUntil(tester, find.text(event.event.title).hitTestable());

    final pending = await cleanupClient
      .from('event_invitations')
      .select('status')
        .eq(AppDatabase.eventId, event.eventId)
      .eq('invitee_id', invitee.userId!)
        .single();
    expect(pending['status'], 'pending');

    await appHarness!.dispose();
    appHarness = null;
    final recipientSession = recipient.auth.currentSession;
    expect(recipientSession, isNotNull);
    if (recipientSession == null) {
      throw StateError('Invitee session was not created.');
    }
    appHarness = AuthenticatedAppHarness(
      environment: environment,
      session: recipientSession,
    );
    await appHarness!.start(tester);
    await tester.tap(find.byIcon(Icons.notifications_none_outlined));
    await pumpUntil(tester, find.text(AppText.wouldYouLikeToAttend));
    await tester.tap(find.widgetWithText(FilledButton, AppText.accept));
    await pumpUntil(tester, find.text(AppText.noNotifications));

    final accepted = await cleanupClient
      .from('event_invitations')
      .select('status')
        .eq(AppDatabase.eventId, event.eventId)
      .eq('invitee_id', invitee.userId!)
        .single();
    final registration = await cleanupClient
        .from(AppDatabase.eventRegistrationsTable)
        .select(AppDatabase.registrationStatus)
        .eq(AppDatabase.eventId, event.eventId)
        .eq(AppDatabase.userId, invitee.userId!)
        .single();
    expect(accepted['status'], 'accepted');
    expect(registration[AppDatabase.registrationStatus], 'active');
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

