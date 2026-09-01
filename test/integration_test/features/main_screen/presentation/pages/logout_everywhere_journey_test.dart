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
import '../../../../shared/harness/authenticated_app_harness.dart';
import '../../../../shared/harness/supabase_client_factory.dart';
import '../../../../shared/harness/supabase_environment.dart';
import '../../../../shared/harness/test_run_context.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late SupabaseEnvironment environment;
  late TestRunContext context;
  late SupabaseActorRegistrar registrar;
  late ProvisionedTestActor user;
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
    user = await provisioner.create(
      testId: 'logout-everywhere',
      role: TestActorRole.user,
    );
    ActorCleanup(
      scope: cleanupScope!,
      delete: SupabaseActorCleanup(environment: environment).delete,
    ).track(user);
    userClient = await _signIn(
      clientFactory.createAppClient(),
      user,
      registrar,
    );
  });

  tearDown(() async {
    await appHarness?.dispose();
    await userClient?.auth.signOut();
    await cleanupScope?.cleanup();
    cleanupScope = null;
  });

  testWidgets('signs out every session and returns to authentication', (
    tester,
  ) async {
    final client = userClient;
    expect(client, isNotNull);
    if (client == null) {
      throw StateError('Logout-everywhere client was not created.');
    }
    final session = client.auth.currentSession;
    expect(session, isNotNull);
    if (session == null) {
      throw StateError('Logout-everywhere session was not created.');
    }
    appHarness = AuthenticatedAppHarness(
      environment: environment,
      session: session,
    );
    await appHarness!.start(tester);
    await pumpUntil(tester, find.byTooltip(AppText.accountMenu));
    await tester.tap(find.byTooltip(AppText.accountMenu));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppText.profile));
    await pumpUntil(tester, find.text(AppText.supportLegal));
    await tester.tap(find.text(AppText.signOutEverywhere));
    await pumpUntil(tester, find.text(AppText.signOutEverywhereQuestion));

    await tester.tap(
      find.widgetWithText(FilledButton, AppText.signOutEverywhere),
    );
    await pumpUntil(tester, find.text(AppText.signIn));
    expect(Supabase.instance.client.auth.currentSession, isNull);
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
