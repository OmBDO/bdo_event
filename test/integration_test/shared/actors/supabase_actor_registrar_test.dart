import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import '../harness/supabase_environment.dart';
import '../harness/test_run_context.dart';
import 'supabase_actor_registrar.dart';
import 'test_actor.dart';

void main() {
  final environment = SupabaseEnvironment.fromEnvironment(
    values: const {
      'SUPABASE_URL': 'https://example.supabase.co',
      'SUPABASE_ANON_KEY': 'anon-key',
      'SUPABASE_SERVICE_ROLE_KEY': 'service-key',
    },
  );

  test('provisions a namespaced actor with host-only role metadata', () async {
    late Uri requestUri;
    late Map<String, String> requestHeaders;
    late Map<String, dynamic> requestBody;
    final actor = TestActorFactory(const TestRunContext('run-123'))
        .create(testId: 'event-rls', role: TestActorRole.admin);
    final registrar = SupabaseActorRegistrar(
      environment: environment,
      request: ({required uri, required headers, required body}) async {
        requestUri = uri;
        requestHeaders = headers;
        requestBody = jsonDecode(body) as Map<String, dynamic>;
        return http.Response(jsonEncode({'id': 'user-123'}), 201);
      },
    );

    expect(await registrar.register(actor), 'user-123');
    expect(requestUri.path, '/auth/v1/admin/users');
    expect(requestHeaders['apikey'], 'service-key');
    expect(requestHeaders['Authorization'], 'Bearer service-key');
    expect(requestBody['email'], actor.email);
    expect(requestBody['email_confirm'], isTrue);
    expect(requestBody['password'], registrar.passwordFor(actor));
    expect(requestBody['app_metadata'], {
      'roles': ['admin'],
    });
    expect(requestBody['user_metadata'], {'display_name': actor.displayName});
  });

  test('does not contact Supabase for an anonymous actor', () async {
    var requestCount = 0;
    final registrar = SupabaseActorRegistrar(
      environment: environment,
      request: ({required uri, required headers, required body}) async {
        requestCount++;
        return http.Response('{}', 201);
      },
    );

    final actor = TestActorFactory(const TestRunContext('run-123'))
        .create(testId: 'signed-out', role: TestActorRole.anonymous);

    expect(await registrar.register(actor), isNull);
    expect(requestCount, 0);
  });

  test('redacts the service credential when provisioning fails', () async {
    final registrar = SupabaseActorRegistrar(
      environment: environment,
      request: ({required uri, required headers, required body}) async =>
          http.Response('private server detail', 500),
    );
    final actor = TestActorFactory(const TestRunContext('run-123'))
        .create(testId: 'provisioning-failure', role: TestActorRole.user);

    await expectLater(
      registrar.register(actor),
      throwsA(
        allOf(
          isA<StateError>(),
          predicate<StateError>(
            (error) => !error.toString().contains('service-key'),
          ),
        ),
      ),
    );
  });
}
