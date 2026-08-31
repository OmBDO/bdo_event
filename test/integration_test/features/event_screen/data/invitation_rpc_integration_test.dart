import 'package:bdo_event/core/util/event_resource.dart' show AppDatabase;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../shared/actors/actor_cleanup.dart';
import '../../../shared/actors/actor_factory.dart';
import '../../../shared/actors/supabase_actor_cleanup.dart';
import '../../../shared/actors/supabase_actor_registrar.dart';
import '../../../shared/actors/supabase_actor_role_updater.dart';
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
        regularClient.from('event_invitations').insert({
          'event_id': event.eventId,
          'inviter_id': regularUser.userId,
          'invitee_id': invitee.userId,
        }),
        throwsA(isA<supabase.PostgrestException>()),
      );
      await expectLater(
        inviteeClient
            .from('event_invitations')
            .update({'status': 'declined'})
            .eq('event_id', event.eventId)
            .eq('invitee_id', invitee.userId!),
        throwsA(isA<supabase.PostgrestException>()),
      );

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

  test(
    'applies registration admission rules when accepting an invitation',
    () async {
      final capacityEvent = await _createEvent(
        testId: 'invitation-capacity-event',
        capacity: 1,
      );
      await _activate(regularClient, capacityEvent);
      await _sendInvitation(capacityEvent);

      await expectLater(
        _respondToInvitation(capacityEvent),
        throwsA(
          predicate<supabase.PostgrestException>(
            (error) => error.message.contains('capacity'),
          ),
        ),
      );
      expect(await _invitationStatus(capacityEvent), 'pending');
      expect(await _activeRegistrations(capacityEvent), hasLength(1));

      final deadlineEvent = await _createEvent(
        testId: 'invitation-deadline-event',
        registrationDeadline: DateTime.now().toUtc().subtract(
          const Duration(minutes: 1),
        ),
      );
      await _sendInvitation(deadlineEvent);

      await expectLater(
        _respondToInvitation(deadlineEvent),
        throwsA(
          predicate<supabase.PostgrestException>(
            (error) => error.message.contains('closed'),
          ),
        ),
      );
      expect(await _invitationStatus(deadlineEvent), 'pending');
      expect(await _activeRegistrations(deadlineEvent), isEmpty);

      final finishedEvent = await _createEvent(
        testId: 'invitation-finished-event',
        date: '01/01/2020',
      );
      await _sendInvitation(finishedEvent);

      await expectLater(
        _respondToInvitation(finishedEvent),
        throwsA(
          predicate<supabase.PostgrestException>(
            (error) => error.message.contains('ended'),
          ),
        ),
      );
      expect(await _invitationStatus(finishedEvent), 'pending');
      expect(await _activeRegistrations(finishedEvent), isEmpty);

      final now = DateTime.now().toUtc();
      final finishedByTimeEvent = await _createEvent(
        testId: 'invitation-finished-by-time-event',
        date: '${now.day}/${now.month}/${now.year}',
        endTime: '00:00',
      );
      await _sendInvitation(finishedByTimeEvent);

      await expectLater(
        _respondToInvitation(finishedByTimeEvent),
        throwsA(
          predicate<supabase.PostgrestException>(
            (error) => error.message.contains('ended'),
          ),
        ),
      );
      expect(await _invitationStatus(finishedByTimeEvent), 'pending');
      expect(await _activeRegistrations(finishedByTimeEvent), isEmpty);

      final unavailableEvent = await _createEvent(
        testId: 'invitation-unavailable-event',
        isAvailable: false,
      );
      await _sendInvitation(unavailableEvent);

      await expectLater(
        _respondToInvitation(unavailableEvent),
        throwsA(
          predicate<supabase.PostgrestException>(
            (error) => error.message.contains('no longer available'),
          ),
        ),
      );
      expect(await _invitationStatus(unavailableEvent), 'pending');
      expect(await _activeRegistrations(unavailableEvent), isEmpty);
    },
  );

  test('revoked admin roles cannot use an already-issued session', () async {
    final event = await _createEvent(testId: 'stale-admin-event');
    await SupabaseActorRoleUpdater(environment: environment).setRoles(
      admin.userId!,
      const ['user'],
    );

    expect(await adminClient.rpc('list_invitation_recipients'), isEmpty);
    await expectLater(
      adminClient.rpc(
        'send_event_invitations',
        params: {
          'requested_event_id': event.eventId,
          'requested_user_ids': [invitee.userId],
        },
      ),
      throwsA(isA<supabase.PostgrestException>()),
    );
  });

  Future<EventFixtureData> _createEvent({
    String testId = 'invitation-event',
    String date = '31/12/2099',
    String? endTime,
    bool? isAvailable,
    int? capacity,
    DateTime? registrationDeadline,
  }) async {
    final draft = EventFixture(context).draft(
      testId: testId,
      title: '${context.runId} Invitation Event',
      date: date,
      creatorId: admin.userId,
      capacity: capacity,
      registrationDeadline: registrationDeadline,
    );
    final event = EventFixtureData(
      event: draft.event.copyWith(
        endTime: endTime,
        isAvailable: isAvailable,
      ),
      testId: draft.testId,
    );
    eventCleanup!.track(event);
    await adminClient.from(AppDatabase.eventsTable).insert({
      AppDatabase.id: event.eventId,
      AppDatabase.creatorId: admin.userId,
      AppDatabase.payload: event.event.toJson(),
    });
    return event;
  }

  Future<void> _activate(
    supabase.SupabaseClient client,
    EventFixtureData event,
  ) => client.rpc(
    'activate_event_registration',
    params: {
      'requested_event_id': event.eventId,
      'event_payload': event.event.toJson(),
    },
  );

  Future<void> _sendInvitation(EventFixtureData event) => adminClient.rpc(
    'send_event_invitations',
    params: {
      'requested_event_id': event.eventId,
      'requested_user_ids': [invitee.userId],
    },
  );

  Future<void> _respondToInvitation(EventFixtureData event) =>
      inviteeClient.rpc(
        'respond_to_event_invitation',
        params: {
          'requested_event_id': event.eventId,
          'requested_status': 'accepted',
        },
      );

  Future<String> _invitationStatus(EventFixtureData event) async {
    final row = await cleanupClient
        .from('event_invitations')
        .select('status')
        .eq('event_id', event.eventId)
        .eq('invitee_id', invitee.userId!)
        .single();
    return row['status'] as String;
  }

  Future<List<dynamic>> _activeRegistrations(EventFixtureData event) =>
      cleanupClient
          .from(AppDatabase.eventRegistrationsTable)
          .select(AppDatabase.registrationStatus)
          .eq(AppDatabase.eventId, event.eventId)
          .eq(AppDatabase.registrationStatus, AppDatabase.activeRegistration);

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
