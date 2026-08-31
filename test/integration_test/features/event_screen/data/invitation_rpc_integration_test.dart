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
import '../../../shared/harness/supabase_client_factory.dart';
import '../../../shared/harness/supabase_environment.dart';
import '../../../shared/harness/test_run_context.dart';
import '../../../shared/fixtures/event_fixture.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late SupabaseEnvironment environment;
  late TestRunContext context;
  late SupabaseActorRegistrar registrar;
  late supabase.SupabaseClient adminClient;
  late supabase.SupabaseClient inviteeClient;
  late supabase.SupabaseClient regularClient;
  late supabase.SupabaseClient cleanupClient;
  late ProvisionedTestActor admin;
  late ProvisionedTestActor invitee;
  late ProvisionedTestActor regularUser;
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

    admin = await provisioner.create(
      testId: 'invitation-admin',
      role: TestActorRole.admin,
    );
    actorCleanup.track(admin);
    invitee = await provisioner.create(
      testId: 'invitation-invitee',
      role: TestActorRole.user,
    );
    actorCleanup.track(invitee);
    regularUser = await provisioner.create(
      testId: 'invitation-regular',
      role: TestActorRole.user,
    );
    actorCleanup.track(regularUser);

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
    regularClient = await _signIn(
      clientFactory.createAppClient(),
      regularUser,
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

  test('restricts invitation RPCs and accepts one invite once', () async {
    final event = await _createEvent();

    final recipients = await adminClient.rpc('list_invitation_recipients');
    final recipientIds = (recipients as List<dynamic>)
        .map((row) => (row as Map<String, dynamic>)['user_id'])
        .toList();
    expect(recipientIds, contains(invitee.userId));
    expect(recipientIds, isNot(contains(admin.userId)));
    expect(await regularClient.rpc('list_invitation_recipients'), isEmpty);
    await expectLater(
      regularClient.rpc(
        'send_event_invitations',
        params: {
          'requested_event_id': event.eventId,
          'requested_user_ids': [invitee.userId],
        },
      ),
      throwsA(isA<supabase.PostgrestException>()),
    );

    expect(
      await adminClient.rpc(
        'send_event_invitations',
        params: {
          'requested_event_id': event.eventId,
          'requested_user_ids': [invitee.userId],
        },
      ),
      1,
    );
    expect(
      await adminClient.rpc(
        'send_event_invitations',
        params: {
          'requested_event_id': event.eventId,
          'requested_user_ids': [invitee.userId],
        },
      ),
      0,
    );
    final pending = await cleanupClient
        .from('event_invitations')
        .select('status')
        .eq('event_id', event.eventId)
        .eq('invitee_id', invitee.userId!)
        .single();
    expect(pending['status'], 'pending');

    await expectLater(
      regularClient.rpc(
        'respond_to_event_invitation',
        params: {
          'requested_event_id': event.eventId,
          'requested_status': 'accepted',
        },
      ),
      throwsA(isA<supabase.PostgrestException>()),
    );
    await inviteeClient.rpc(
      'respond_to_event_invitation',
      params: {
        'requested_event_id': event.eventId,
        'requested_status': 'accepted',
      },
    );
    final accepted = await cleanupClient
        .from('event_invitations')
        .select('status')
        .eq('event_id', event.eventId)
        .eq('invitee_id', invitee.userId!)
        .single();
    final registration = await cleanupClient
        .from(AppDatabase.eventRegistrationsTable)
        .select('status')
        .eq(AppDatabase.eventId, event.eventId)
        .eq(AppDatabase.userId, invitee.userId!)
        .single();

    expect(accepted['status'], 'accepted');
    expect(registration[AppDatabase.registrationStatus], 'active');
    await expectLater(
      inviteeClient.rpc(
        'respond_to_event_invitation',
        params: {
          'requested_event_id': event.eventId,
          'requested_status': 'accepted',
        },
      ),
      throwsA(isA<supabase.PostgrestException>()),
    );
  });

  Future<EventFixtureData> _createEvent() async {
    final event = EventFixture(context).draft(
      testId: 'invitation-event',
      title: '${context.runId} Invitation Event',
      creatorId: admin.userId,
    );
    eventCleanup!.track(event);
    await adminClient.from(AppDatabase.eventsTable).insert({
      AppDatabase.id: event.eventId,
      AppDatabase.creatorId: admin.userId,
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
