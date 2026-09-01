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
import '../../../../shared/harness/authenticated_app_harness.dart';
import '../../../../shared/harness/supabase_client_factory.dart';
import '../../../../shared/harness/supabase_environment.dart';
import '../../../../shared/harness/test_run_context.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late SupabaseEnvironment environment;
  late TestRunContext context;
  late SupabaseActorRegistrar registrar;
  late ProvisionedTestActor admin;
  late ProvisionedTestActor user;
  SupabaseClient? adminClient;
  SupabaseClient? userClient;
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
    admin = await provisioner.create(
      testId: 'role-navigation-admin',
      role: TestActorRole.admin,
    );
    actorCleanup.track(admin);
    user = await provisioner.create(
      testId: 'role-navigation-user',
      role: TestActorRole.user,
    );
    actorCleanup.track(user);
    adminClient = await _signIn(
      clientFactory.createAppClient(),
      admin,
      registrar,
    );
    userClient = await _signIn(
      clientFactory.createAppClient(),
      user,
      registrar,
    );
  });

  tearDown(() async {
    await appHarness?.dispose();
    await adminClient?.auth.signOut();
    await userClient?.auth.signOut();
    await cleanupScope?.cleanup();
    cleanupScope = null;
  });

  testWidgets('shows organizer navigation only for an administrator', (
    tester,
  ) async {
    final adminSession = adminClient?.auth.currentSession;
    expect(adminSession, isNotNull);
    if (adminSession == null) {
      throw StateError('Admin role-navigation session was not created.');
    }
    appHarness = AuthenticatedAppHarness(
      environment: environment,
      session: adminSession,
    );
    await appHarness!.start(tester);
    await pumpUntil(tester, find.byIcon(Icons.add_circle_outline_rounded));
    expect(find.byIcon(Icons.add_circle_outline_rounded), findsOneWidget);

    await appHarness!.dispose();
    appHarness = null;

    final userSession = userClient?.auth.currentSession;
    expect(userSession, isNotNull);
    if (userSession == null) {
      throw StateError('Regular role-navigation session was not created.');
    }
    appHarness = AuthenticatedAppHarness(
      environment: environment,
      session: userSession,
    );
    await appHarness!.start(tester);
    await pumpUntil(tester, find.byIcon(Icons.account_box));
    expect(find.byIcon(Icons.add_circle_outline_rounded), findsNothing);
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
