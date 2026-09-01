import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import '../harness/supabase_environment.dart';
import 'supabase_actor_role_updater.dart';

void main() {
  final environment = SupabaseEnvironment.fromEnvironment(
    values: const {
      'SUPABASE_URL': 'https://example.supabase.co',
      'SUPABASE_ANON_KEY': 'anon-key',
      'SUPABASE_SERVICE_ROLE_KEY': 'service-key',
    },
  );

  test(
    'updates effective roles through the host-only admin endpoint',
    () async {
      late Uri requestUri;
      late Map<String, String> requestHeaders;
      late Map<String, dynamic> requestBody;
      final updater = SupabaseActorRoleUpdater(
        environment: environment,
        update: ({required uri, required headers, required body}) async {
          requestUri = uri;
          requestHeaders = headers;
          requestBody = jsonDecode(body) as Map<String, dynamic>;
          return http.Response('{}', 200);
        },
      );

      await updater.setRoles(' user-123 ', const ['user']);

      expect(requestUri.path, '/auth/v1/admin/users/user-123');
      expect(requestHeaders['apikey'], 'service-key');
      expect(requestHeaders['Authorization'], 'Bearer service-key');
      expect(requestBody, {
        'app_metadata': {
          'roles': ['user'],
        },
      });
    },
  );

  test('rejects an empty user identifier before contacting Supabase', () async {
    var requestCount = 0;
    final updater = SupabaseActorRoleUpdater(
      environment: environment,
      update: ({required uri, required headers, required body}) async {
        requestCount++;
        return http.Response('{}', 200);
      },
    );

    await expectLater(updater.setRoles(' ', const []), throwsArgumentError);
    expect(requestCount, 0);
  });

  test('redacts the service credential when role update fails', () async {
    final updater = SupabaseActorRoleUpdater(
      environment: environment,
      update: ({required uri, required headers, required body}) async =>
          http.Response('private detail', 500),
    );

    await expectLater(
      updater.setRoles('user-123', const ['user']),
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
