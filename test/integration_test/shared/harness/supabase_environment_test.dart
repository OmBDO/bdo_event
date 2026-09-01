import 'package:flutter_test/flutter_test.dart';

import 'supabase_environment.dart';

void main() {
  test('reads and trims app and cleanup environment values', () {
    final environment = SupabaseEnvironment.fromEnvironment(
      values: const {
        'SUPABASE_URL': ' https://example.supabase.co ',
        'SUPABASE_ANON_KEY': ' anon-key ',
        'SUPABASE_SERVICE_ROLE_KEY': ' service-key ',
      },
    );

    expect(environment.url, 'https://example.supabase.co');
    expect(environment.anonKey, 'anon-key');
    expect(environment.serviceRoleKey, 'service-key');
    expect(environment.isAppConfigured, isTrue);
    expect(environment.isCleanupConfigured, isTrue);
  });

  test('requires both public app values', () {
    final environment = SupabaseEnvironment.fromEnvironment(
      values: const {'SUPABASE_URL': 'https://example.supabase.co'},
    );

    expect(environment.isAppConfigured, isFalse);
    expect(
      environment.requireAppConfiguration,
      throwsA(isA<StateError>()),
    );
  });

  test('requires a host-only cleanup credential separately', () {
    final environment = SupabaseEnvironment.fromEnvironment(
      values: const {
        'SUPABASE_URL': 'https://example.supabase.co',
        'SUPABASE_ANON_KEY': 'anon-key',
      },
    );

    expect(environment.isAppConfigured, isTrue);
    expect(environment.isCleanupConfigured, isFalse);
    expect(
      environment.requireCleanupConfiguration,
      throwsA(
        allOf(
          isA<StateError>(),
          predicate<StateError>(
            (error) => !error.toString().contains('anon-key'),
          ),
        ),
      ),
    );
  });
}
