import 'package:bdo_event/core/util/resource/app_text.dart';
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
import '../../../../shared/harness/supabase_client_factory.dart'
    show SupabaseClientFactory;
import '../../../../shared/harness/supabase_environment.dart';
import '../../../../shared/harness/test_run_context.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late SupabaseEnvironment environment;
  late TestRunContext context;
  SupabaseClient? setupClient;
  late SupabaseActorRegistrar registrar;
  late ProvisionedTestActor actor;
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
    actor = await provisioner.create(
      testId: 'authentication-journey',
      role: TestActorRole.user,
    );
    ActorCleanup(
      scope: cleanupScope!,
      delete: SupabaseActorCleanup(environment: environment).delete,
    ).track(actor);

    final preAuthClient = setupClient = clientFactory.createAppClient();
    final email = actor.email;
    if (email == null) {
      throw StateError('Authenticated test actor has no email address.');
    }
    await preAuthClient.auth.signInWithPassword(
      email: email,
      password: registrar.passwordFor(actor.definition),
    );
  });

  tearDown(() async {
    await appHarness?.dispose();
    await setupClient?.auth.signOut();
    await cleanupScope?.cleanup();
    cleanupScope = null;
  });

  testWidgets('restores a session, reaches the shell, and logs out', (
    tester,
  ) async {
    final preAuthClient = setupClient;
    expect(preAuthClient, isNotNull);
    if (preAuthClient == null) {
      throw StateError('Test app client was not created.');
    }
    final session = preAuthClient.auth.currentSession;
    expect(session, isNotNull);
    if (session == null) {
      throw StateError('Test actor session was not created.');
    }

    appHarness = AuthenticatedAppHarness(
      environment: environment,
      session: session,
    );
    await appHarness!.start(tester);

    expect(find.byTooltip(AppText.accountMenu), findsOneWidget);

    await tester.tap(find.byTooltip(AppText.accountMenu));
    await tester.pumpAndSettle();
    expect(find.text(AppText.logOut), findsOneWidget);

    await tester.tap(find.text(AppText.logOut));
    await tester.pumpAndSettle();

    expect(find.byTooltip(AppText.accountMenu), findsNothing);
    expect(find.text(AppText.signIn), findsOneWidget);
    expect(Supabase.instance.client.auth.currentSession, isNull);
  });
}
