import 'dart:async';

import 'package:bdo_event/core/deep_link/deep_link_source.dart';
import 'package:bdo_event/core/util/resource/app_database.dart';
import 'package:bdo_event/core/util/resource/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../shared/actors/actor_cleanup.dart';
import '../../shared/actors/actor_factory.dart';
import '../../shared/actors/supabase_actor_cleanup.dart';
import '../../shared/actors/supabase_actor_registrar.dart';
import '../../shared/actors/test_actor.dart';
import '../../shared/cleanup/cleanup_scope.dart';
import '../../shared/cleanup/event_cleanup.dart';
import '../../shared/fixtures/event_fixture.dart';
import '../../shared/harness/authenticated_app_harness.dart';
import '../../shared/harness/supabase_client_factory.dart';
import '../../shared/harness/supabase_environment.dart';
import '../../shared/harness/test_run_context.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late SupabaseEnvironment environment;
  late TestRunContext context;
  late SupabaseActorRegistrar registrar;
  late ProvisionedTestActor owner;
  late ProvisionedTestActor attendee;
  SupabaseClient? ownerClient;
  late SupabaseClient cleanupClient;
  late EventFixtureData event;
  CleanupScope? cleanupScope;
  UnauthenticatedAppHarness? appHarness;
  _TestDeepLinkSource? deepLinkSource;

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
      testId: 'deep-link-journey',
      role: TestActorRole.owner,
    );
    actorCleanup.track(owner);
    attendee = await provisioner.create(
      testId: 'deep-link-journey',
      role: TestActorRole.user,
    );
    actorCleanup.track(attendee);
    ownerClient = await _signIn(
      clientFactory.createAppClient(),
      owner,
      registrar,
    );

    final ownerId = owner.userId;
    if (ownerId == null) {
      throw StateError('Deep-link owner provisioning returned no user ID.');
    }
    event = EventFixture(context).draft(
      testId: 'deep-link-journey',
      title: '${context.runId} Deep Link Event',
      date: '31/12/2029',
      location: 'Integration Hall',

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
    await ownerClient!.from(AppDatabase.eventsTable).insert({
      AppDatabase.id: event.eventId,
      AppDatabase.creatorId: ownerId,
      AppDatabase.payload: event.event.toJson(),
    });
  });

  tearDown(() async {
    await appHarness?.dispose();
    await ownerClient?.auth.signOut();
    await deepLinkSource?.close();
    await cleanupScope?.cleanup();
    cleanupScope = null;
  });

  testWidgets('holds a custom link until sign-in, then opens the event', (
    tester,
  ) async {
    deepLinkSource = _TestDeepLinkSource(
      Uri.parse('bdoevent://events/${event.eventId}'),
    );
    appHarness = UnauthenticatedAppHarness(environment: environment);
    await appHarness!.start(tester, deepLinkSource: deepLinkSource);
    await pumpUntil(tester, find.bySemanticsLabel(AppText.emailAddress));

    expect(find.text(event.event.description), findsNothing);
    final email = attendee.email;
    if (email == null) {
      throw StateError('Deep-link attendee has no email address.');
    }
    await tester.enterText(find.bySemanticsLabel(AppText.emailAddress), email);
    await tester.enterText(
      find.bySemanticsLabel(AppText.password),
      registrar.passwordFor(attendee.definition),
    );
    await tester.tap(find.widgetWithText(ElevatedButton, AppText.signIn));
    await pumpUntil(tester, find.text(event.event.description));

    expect(find.text(event.event.description), findsOneWidget);
    deepLinkSource!.add(
      Uri.parse('https://invalid.example/events/${event.eventId}'),
    );
    await tester.pumpAndSettle();
    expect(find.text(event.event.description), findsOneWidget);
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

class _TestDeepLinkSource implements DeepLinkSource {
  _TestDeepLinkSource(this._initialUri);

  final Uri? _initialUri;
  final _controller = StreamController<Uri>.broadcast();

  @override
  Stream<Uri> get uriStream => _controller.stream;

  @override
  Future<Uri?> get initialUri async => _initialUri;

  void add(Uri uri) => _controller.add(uri);

  Future<void> close() => _controller.close();
}
