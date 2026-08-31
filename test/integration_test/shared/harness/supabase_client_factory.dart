import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_environment.dart';

class SupabaseClientFactory {
  const SupabaseClientFactory(this.environment);

  final SupabaseEnvironment environment;

  SupabaseClient createAppClient() {
    environment.requireAppConfiguration();
    return SupabaseClient(environment.url, environment.anonKey);
  }

  SupabaseClient createCleanupClient() {
    environment.requireCleanupConfiguration();
    return SupabaseClient(environment.url, environment.serviceRoleKey!);
  }
}
