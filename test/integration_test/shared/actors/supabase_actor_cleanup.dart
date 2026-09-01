import 'package:http/http.dart' as http;

import '../harness/supabase_environment.dart';

typedef SupabaseAdminDelete = Future<http.Response> Function({
  required Uri uri,
  required Map<String, String> headers,
});

class SupabaseActorCleanup {
  SupabaseActorCleanup({
    required this.environment,
    SupabaseAdminDelete? delete,
  }) : _delete = delete ?? _sendDelete;

  final SupabaseEnvironment environment;
  final SupabaseAdminDelete _delete;

  Future<void> delete(String userId) async {
    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) {
      throw ArgumentError.value(userId, 'userId', 'must not be empty');
    }

    environment.requireCleanupConfiguration();
    final serviceRoleKey = environment.serviceRoleKey!;
    final response = await _delete(
      uri: Uri.parse(
        '${environment.url}/auth/v1/admin/users/$normalizedUserId',
      ),
      headers: {
        'apikey': serviceRoleKey,
        'Authorization': 'Bearer $serviceRoleKey',
      },
    );

    if (response.statusCode == 404) return;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        'Supabase test actor cleanup failed with status '
        '${response.statusCode}.',
      );
    }
  }

  static Future<http.Response> _sendDelete({
    required Uri uri,
    required Map<String, String> headers,
  }) => http.delete(uri, headers: headers);
}
