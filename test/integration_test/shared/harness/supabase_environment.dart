import 'dart:io';

class SupabaseEnvironment {
  const SupabaseEnvironment({
    required this.url,
    required this.anonKey,
    this.serviceRoleKey,
  });

  factory SupabaseEnvironment.fromEnvironment({
    Map<String, String>? values,
  }) {
    final environment = values ?? Platform.environment;
    return SupabaseEnvironment(
      url: environment['SUPABASE_URL']?.trim() ?? '',
      anonKey: environment['SUPABASE_ANON_KEY']?.trim() ?? '',
      serviceRoleKey: environment['SUPABASE_SERVICE_ROLE_KEY']?.trim(),
    );
  }

  final String url;
  final String anonKey;
  final String? serviceRoleKey;

  bool get isAppConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  bool get isCleanupConfigured =>
      isAppConfigured && serviceRoleKey?.isNotEmpty == true;

  void requireAppConfiguration() {
    if (!isAppConfigured) {
      throw StateError('SUPABASE_URL and SUPABASE_ANON_KEY are required.');
    }
  }

  void requireCleanupConfiguration() {
    requireAppConfiguration();
    if (!isCleanupConfigured) {
      throw StateError('SUPABASE_SERVICE_ROLE_KEY is required for cleanup.');
    }
  }
}
