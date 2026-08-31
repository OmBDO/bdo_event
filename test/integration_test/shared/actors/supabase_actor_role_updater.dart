import 'dart:convert';

import 'package:http/http.dart' as http;

import '../harness/supabase_environment.dart';

typedef SupabaseAdminUpdate = Future<http.Response> Function({
  required Uri uri,
  required Map<String, String> headers,
  required String body,
});

class SupabaseActorRoleUpdater {
  SupabaseActorRoleUpdater({
    required this.environment,
    SupabaseAdminUpdate? update,
  }) : _update = update ?? _sendUpdate;

  final SupabaseEnvironment environment;
  final SupabaseAdminUpdate _update;

  Future<void> setRoles(String userId, Iterable<String> roles) async {
    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) {
      throw ArgumentError.value(userId, 'userId', 'must not be empty');
    }

    environment.requireCleanupConfiguration();
    final serviceRoleKey = environment.serviceRoleKey!;
    final response = await _update(
      uri: Uri.parse(
        '${environment.url}/auth/v1/admin/users/$normalizedUserId',
      ),
      headers: {
        'apikey': serviceRoleKey,
        'Authorization': 'Bearer $serviceRoleKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'app_metadata': {'roles': roles.toList()},
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        'Supabase test actor role update failed with status '
        '${response.statusCode}.',
      );
    }
  }

  static Future<http.Response> _sendUpdate({
    required Uri uri,
    required Map<String, String> headers,
    required String body,
  }) => http.put(uri, headers: headers, body: body);
}
