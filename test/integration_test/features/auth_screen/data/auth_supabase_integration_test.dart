import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../shared/actors/supabase_actor_cleanup.dart';
import '../../../shared/cleanup/cleanup_scope.dart';
import '../../../shared/harness/supabase_client_factory.dart';
import '../../../shared/harness/supabase_environment.dart';
import '../../../shared/harness/test_run_context.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late SupabaseEnvironment environment;
  late TestRunContext context;
  late SupabaseClientFactory clientFactory;
  late SupabaseActorCleanup actorCleanup;
  CleanupScope? cleanupScope;

  setUp(() {
    environment = SupabaseEnvironment.fromEnvironment();
    environment.requireCleanupConfiguration();
    context = TestRunContext.create();
    clientFactory = SupabaseClientFactory(environment);
    actorCleanup = SupabaseActorCleanup(environment: environment);
    cleanupScope = CleanupScope();
  });

  tearDown(() async {
    await cleanupScope?.cleanup();
    cleanupScope = null;
  });

  Future<_SignUpResult> signUp(String testId, String requestedRole) async {
    final email = '${context.namespace(testId)}@example.invalid';
    final password = '${context.namespace(testId)}-Auth!42';
    final client = clientFactory.createAppClient();
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {
        'display_name': 'Requested $requestedRole',
        'requested_role': requestedRole,
      },
    );
    final user = response.user;
    expect(user, isNotNull);
    cleanupScope!.add(() => actorCleanup.delete(user!.id));
    return _SignUpResult(user: user!, client: client);
  }

  test('requested privileged roles require trusted approval', () async {
    final adminRequest = await signUp('requested-admin', 'admin');
    final watcherRequest = await signUp('requested-watcher', 'watcher');
    final userRequest = await signUp('requested-user', 'user');
    final refreshedAdmin = await adminRequest.client.auth.refreshSession();
    final refreshedUser = refreshedAdmin.user;

    expect(adminRequest.user.userMetadata?['requested_role'], 'admin');
    expect(watcherRequest.user.userMetadata?['requested_role'], 'watcher');
    expect(userRequest.user.userMetadata?['requested_role'], 'user');
    expect(adminRequest.user.appMetadata['roles'], isNot(contains('admin')));
    expect(
      watcherRequest.user.appMetadata['roles'],
      isNot(contains('watcher')),
    );
    expect(userRequest.user.appMetadata['roles'], isNot(contains('admin')));
    expect(refreshedUser, isNotNull);
    expect(refreshedUser!.appMetadata['roles'], isNot(contains('admin')));

    final requests = await clientFactory
        .createCleanupClient()
        .from('role_requests')
        .select('user_id, requested_role, status')
        .inFilter('user_id', [
          adminRequest.user.id,
          watcherRequest.user.id,
          userRequest.user.id,
        ]);
    final byRole = {
      for (final row in requests as List<dynamic>)
        row['requested_role'] as String: row as Map<String, dynamic>,
    };

    expect(byRole['admin']?['status'], 'pending');
    expect(byRole['watcher']?['status'], 'pending');
    expect(byRole['user']?['status'], 'pending');
  });
}

class _SignUpResult {
  const _SignUpResult({required this.user, required this.client});

  final supabase.User user;
  final supabase.SupabaseClient client;
}
