import 'dart:convert';

import 'package:http/http.dart' as http;

import '../harness/supabase_environment.dart';
import 'test_actor.dart';

typedef SupabaseAdminRequest = Future<http.Response> Function({
  required Uri uri,
  required Map<String, String> headers,
  required String body,
});

class SupabaseActorRegistrar {
  SupabaseActorRegistrar({
    required this.environment,
    SupabaseAdminRequest? request,
  }) : _request = request ?? _post;

  final SupabaseEnvironment environment;
  final SupabaseAdminRequest _request;

  Future<String?> register(TestActor actor) async {
    if (!actor.isAuthenticated) return null;
    final email = actor.email;
    if (email == null || email.trim().isEmpty) {
      throw StateError('Authenticated test actors require an email address.');
    }

    environment.requireCleanupConfiguration();
    final serviceRoleKey = environment.serviceRoleKey!;
    final response = await _request(
      uri: Uri.parse('${environment.url}/auth/v1/admin/users'),
      headers: {
        'apikey': serviceRoleKey,
        'Authorization': 'Bearer $serviceRoleKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': passwordFor(actor),
        'email_confirm': true,
        'user_metadata': {
          if (actor.displayName != null) 'display_name': actor.displayName,
        },
        'app_metadata': {'roles': _roleClaims(actor.role)},
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        'Supabase test actor provisioning failed with status '
        '${response.statusCode}.',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) return null;
    final userId = decoded['id'];
    if (userId is! String || userId.trim().isEmpty) return null;
    return userId.trim();
  }

  String passwordFor(TestActor actor) =>
      '${actor.namespace}-Integration!42';

  static List<String> _roleClaims(TestActorRole role) {
    switch (role) {
      case TestActorRole.admin:
      case TestActorRole.owner:
        return const ['admin'];
      case TestActorRole.watcher:
        return const ['watcher'];
      case TestActorRole.anonymous:
      case TestActorRole.user:
      case TestActorRole.unrelated:
        return const ['user'];
    }
  }

  static Future<http.Response> _post({
    required Uri uri,
    required Map<String, String> headers,
    required String body,
  }) => http.post(uri, headers: headers, body: body);
}
