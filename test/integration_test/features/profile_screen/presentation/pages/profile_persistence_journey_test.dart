import 'package:bdo_event/core/util/event_resource.dart';
import 'package:bdo_event/features/profile_screen/profile_visibility.dart';
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
import '../../../shared/harness/authenticated_app_harness.dart';
import '../../../shared/harness/bounded_waiter.dart';
import '../../../shared/harness/supabase_client_factory.dart';
import '../../../shared/harness/supabase_environment.dart';
import '../../../shared/harness/test_run_context.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late SupabaseEnvironment environment;
  late TestRunContext context;
  late SupabaseActorRegistrar registrar;
  late ProvisionedTestActor user;
  SupabaseClient? userClient;
  late SupabaseClient cleanupClient;
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
    user = await provisioner.create(
      testId: 'profile-persistence',
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

  testWidgets('persists profile settings across an app restart',
      (tester) async {
    final client = userClient;
    expect(client, isNotNull);
    if (client == null) {
      throw StateError('Profile app client was not created.');
    }
    final session = client.auth.currentSession;
    expect(session, isNotNull);
    if (session == null) {
      throw StateError('Profile session was not created.');
    }
    appHarness = AuthenticatedAppHarness(
      environment: environment,
      session: session,
    );
    await appHarness!.start(tester);
    await _openProfile(tester);

    final darkModeTile = find.ancestor(
      of: find.text(AppText.darkThemeMode),
      matching: find.byType(ListTile),
    );
    final darkModeSwitch = find.descendant(
      of: darkModeTile,
      matching: find.byType(Switch),
    );
    await tester.tap(darkModeSwitch);
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppText.dateFormat));
    await pumpUntil(tester, find.text(AppDateFormats.yearMonthDay));
    await tester.tap(find.text(AppDateFormats.yearMonthDay));
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppText.profileVisibility));
    await pumpUntil(tester, find.text(ProfileVisibility.public.label));
    await tester.tap(find.text(ProfileVisibility.public.label));
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppText.registrationVisibility));
    await pumpUntil(tester, find.text(RegistrationVisibility.public.label));
    await tester.tap(find.text(RegistrationVisibility.public.label));
    await pumpUntil(tester, find.text(RegistrationVisibility.public.label));

    final userId = user.userId;
    if (userId == null) {
      throw StateError('Profile user has no user ID.');
    }
    await BoundedWaiter().until(() async {
      final row = await cleanupClient
          .from('profile_visibility_settings')
          .select('profile_visibility, registration_visibility')
          .eq('user_id', userId)
          .single();
        return row['profile_visibility'] ==
            ProfileVisibility.public.storageValue &&
          row['registration_visibility'] ==
            RegistrationVisibility.public.storageValue;
    }, description: 'profile visibility settings');

    await appHarness!.dispose();
    appHarness = null;
    appHarness = AuthenticatedAppHarness(
      environment: environment,
      session: session,
    );
    await appHarness!.start(tester, resetPreferences: false);
    await _openProfile(tester);

    final restoredSwitch = find.descendant(
      of: find.ancestor(
        of: find.text(AppText.darkThemeMode),
        matching: find.byType(ListTile),
      ),
      matching: find.byType(Switch),
    );
    expect(tester.widget<Switch>(restoredSwitch).value, isTrue);
    expect(find.text(AppDateFormats.yearMonthDay), findsOneWidget);
    await pumpUntil(tester, find.text(ProfileVisibility.public.label));
    expect(find.text(RegistrationVisibility.public.label), findsOneWidget);
  });

  testWidgets('persists editable profile details across an app restart',
      (tester) async {
    final client = userClient;
    expect(client, isNotNull);
    if (client == null) {
      throw StateError('Profile app client was not created.');
    }
    final session = client.auth.currentSession;
    expect(session, isNotNull);
    if (session == null) {
      throw StateError('Profile session was not created.');
    }
    appHarness = AuthenticatedAppHarness(
      environment: environment,
      session: session,
    );
    await appHarness!.start(tester);
    await _openProfile(tester);
    await tester.tap(find.text(AppText.editProfile));
    await pumpUntil(tester, find.text('Personal details'));

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(2), '+91 555 0101');
    await tester.enterText(fields.at(3), 'Profile details persisted.');
    await tester.tap(find.widgetWithText(FilledButton, AppText.saveProfile));
    await pumpUntil(tester, find.text(AppText.profileUpdated));

    await appHarness!.dispose();
    appHarness = null;
    appHarness = AuthenticatedAppHarness(
      environment: environment,
      session: session,
    );
    await appHarness!.start(tester, resetPreferences: false);
    await _openProfile(tester);
    await tester.tap(find.text(AppText.editProfile));
    await pumpUntil(tester, find.text('Personal details'));

    final restoredFields = find.byType(TextFormField);
    expect(
      tester.widget<TextFormField>(restoredFields.at(2)).controller?.text,
      '+91 555 0101',
    );
    expect(
      tester.widget<TextFormField>(restoredFields.at(3)).controller?.text,
      'Profile details persisted.',
    );
  });
}

Future<void> _openProfile(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.account_box));
  await pumpUntil(tester, find.text(AppText.preferences));
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
