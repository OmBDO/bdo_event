import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_client_factory.dart';
import 'supabase_environment.dart';

void main() {
  test('creates an app client from the public test configuration', () {
    final factory = SupabaseClientFactory(
      const SupabaseEnvironment(
        url: 'https://example.supabase.co',
        anonKey: 'anon-key',
      ),
    );

    expect(factory.createAppClient(), isA<SupabaseClient>());
  });

  test('requires a service role key for the cleanup client', () {
    final factory = SupabaseClientFactory(
      const SupabaseEnvironment(
        url: 'https://example.supabase.co',
        anonKey: 'anon-key',
      ),
    );

    expect(factory.createCleanupClient, throwsA(isA<StateError>()));
  });

  test('creates a separate cleanup client when host credentials exist', () {
    final factory = SupabaseClientFactory(
      const SupabaseEnvironment(
        url: 'https://example.supabase.co',
        anonKey: 'anon-key',
        serviceRoleKey: 'service-key',
      ),
    );

    final appClient = factory.createAppClient();
    final cleanupClient = factory.createCleanupClient();

    expect(cleanupClient, isA<SupabaseClient>());
    expect(cleanupClient, isNot(same(appClient)));
  });

  test('fails app-client creation when public configuration is incomplete', () {
    final factory = SupabaseClientFactory(
      const SupabaseEnvironment(url: '', anonKey: ''),
    );

    expect(factory.createAppClient, throwsA(isA<StateError>()));
  });
}
