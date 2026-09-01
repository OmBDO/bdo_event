import 'package:bdo_event/core/util/resource/app_database.dart';
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
import '../../../shared/cleanup/notification_cleanup.dart';
import '../../../shared/fixtures/event_fixture.dart';
import '../../../shared/harness/supabase_client_factory.dart';
import '../../../shared/harness/supabase_environment.dart';
import '../../../shared/harness/test_run_context.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late SupabaseEnvironment environment;
  late TestRunContext context;
  late SupabaseActorRegistrar registrar;
  late supabase.SupabaseClient userClient;
  late supabase.SupabaseClient unrelatedClient;
  late supabase.SupabaseClient cleanupClient;
  late ProvisionedTestActor eventOwner;
  late ProvisionedTestActor user;
  late ProvisionedTestActor unrelatedUser;
  CleanupScope? cleanupScope;
  EventCleanup? eventCleanup;
  NotificationCleanup? notificationCleanup;

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

    eventOwner = await provisioner.create(
      testId: 'notification-owner',
      role: TestActorRole.user,
    );
    actorCleanup.track(eventOwner);
    user = await provisioner.create(
      testId: 'notification-user',
      role: TestActorRole.user,
    );
    actorCleanup.track(user);
    unrelatedUser = await provisioner.create(
      testId: 'notification-unrelated',
      role: TestActorRole.user,
    );
    actorCleanup.track(unrelatedUser);
    userClient = await _signIn(
      clientFactory.createAppClient(),
      user,
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
        await cleanupClient
            .from(AppDatabase.eventsTable)
            .delete()
            .eq(AppDatabase.id, fixture.eventId);
      },
    );
    notificationCleanup = NotificationCleanup(
      scope: cleanupScope!,
      delete: (notificationId) async {
        await cleanupClient
            .from('notifications')
            .delete()
            .eq('id', notificationId);
      },
    );
  });

  tearDown(() async {
    await cleanupScope?.cleanup();
    cleanupScope = null;
  });

  test('scopes notification reads and mark-read mutations by user', () async {
    final event = EventFixture(context).draft(
      testId: 'notification-event',
      title: '${context.runId} Notification Event',
      creatorId: eventOwner.userId,
    );
    eventCleanup!.track(event);
    await cleanupClient.from(AppDatabase.eventsTable).insert({
      AppDatabase.id: event.eventId,
      AppDatabase.creatorId: eventOwner.userId,
      AppDatabase.payload: event.event.toJson(),
    });
    await cleanupClient.from('notifications').insert({
      'user_id': user.userId,
      'event_id': event.eventId,
      'notification_type': 'integration',
      'title': 'Integration notification',
      'message': 'Notification isolation check',
      'event_date': '2099-12-31',
    });
    final notification = await cleanupClient
        .from('notifications')
        .select('id, is_read')
        .eq('user_id', user.userId!)
        .eq('event_id', event.eventId)
        .single();
    notificationCleanup!.track(notification['id'] as int);
    final notificationId = notification['id'] as int;

    final userNotifications = await userClient.rpc('load_user_notifications');
    expect(userNotifications, hasLength(1));
    expect((userNotifications as List).single['isRead'], isFalse);
    expect(await userClient.rpc('count_user_unread_notifications'), 1);
    expect(await unrelatedClient.rpc('load_user_notifications'), isEmpty);
    expect(await unrelatedClient.rpc('count_user_unread_notifications'), 0);

    await unrelatedClient.rpc(
      'mark_notification_read',
      params: {'requested_notification_id': notificationId},
    );
    final unchanged = await cleanupClient
        .from('notifications')
        .select('is_read')
        .eq('id', notification['id'])
        .single();
    expect(unchanged['is_read'], isFalse);

    await userClient.rpc(
      'mark_notification_read',
      params: {'requested_notification_id': notificationId},
    );
    final readNotifications = await userClient.rpc('load_user_notifications');
    expect((readNotifications as List).single['isRead'], isTrue);
    expect(await userClient.rpc('count_user_unread_notifications'), 0);
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
