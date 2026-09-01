import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import '../harness/supabase_environment.dart';
import 'supabase_actor_cleanup.dart';

void main() {
  final environment = SupabaseEnvironment.fromEnvironment(
    values: const {
      'SUPABASE_URL': 'https://example.supabase.co',
      'SUPABASE_ANON_KEY': 'anon-key',
      'SUPABASE_SERVICE_ROLE_KEY': 'service-key',
    },
  );

  test('deletes an actor through the host-only admin endpoint', () async {
    late Uri requestUri;
    late Map<String, String> requestHeaders;
    final cleanup = SupabaseActorCleanup(
      environment: environment,
      delete: ({required uri, required headers}) async {
        requestUri = uri;
        requestHeaders = headers;
        return http.Response('', 204);
      },
    );

    await cleanup.delete(' user-123 ');

    expect(requestUri.path, '/auth/v1/admin/users/user-123');
    expect(requestHeaders['apikey'], 'service-key');
    expect(requestHeaders['Authorization'], 'Bearer service-key');
  });

  test('treats an already deleted actor as clean', () async {
    final cleanup = SupabaseActorCleanup(
      environment: environment,
      delete: ({required uri, required headers}) async =>
          http.Response('', 404),
    );

    await expectLater(cleanup.delete('user-123'), completes);
  });

  test(
    'rejects an empty actor identifier before contacting Supabase',
    () async {
      var requestCount = 0;
      final cleanup = SupabaseActorCleanup(
        environment: environment,
        delete: ({required uri, required headers}) async {
          requestCount++;
          return http.Response('', 204);
        },
      );

      await expectLater(cleanup.delete(' '), throwsArgumentError);
      expect(requestCount, 0);
    },
  );

  test('redacts the service credential when cleanup fails', () async {
    final cleanup = SupabaseActorCleanup(
      environment: environment,
      delete: ({required uri, required headers}) async =>
          http.Response('private detail', 500),
    );

    await expectLater(
      cleanup.delete('user-123'),
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
