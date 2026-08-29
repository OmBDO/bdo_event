import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:bdo_event/core/common/supabase_request_logger/supabase_request_logger.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({
    supabase.SupabaseClient? client,
    SupabaseRequestLogger logger = const SupabaseRequestLogger(),
  }) : _client = client ?? supabase.Supabase.instance.client,
       _logger = logger;

  final supabase.SupabaseClient _client;
  final SupabaseRequestLogger _logger;

  supabase.User? get currentUser => _client.auth.currentUser;

  Future<supabase.User?> refreshSession() async {
    final response = await _client.auth.refreshSession();
    return response.user;
  }

  Future<supabase.AuthResponse> signUp({
    required String email,
    required String password,
    required String displayName,
    required String requestedRole,
  }) => _logger.track(
        'auth.signUp',
        () => _client.auth.signUp(
          email: email,
          password: password,
          data: {
            'display_name': displayName,
            'requested_role': requestedRole,
          },
        ),
        parameters: {
          'email': email,
          'requestedRole': requestedRole,
          'password': password,
        },
      );

  Future<supabase.AuthResponse> signIn({
    required String email,
    required String password,
  }) => _logger.track(
        'auth.signInWithPassword',
        () => _client.auth.signInWithPassword(email: email, password: password),
        parameters: {'email': email, 'password': password},
      );

  Future<void> signOut() => _logger.track(
        'auth.signOut',
        () => _client.auth.signOut(),
      );

  Future<supabase.UserResponse> updateUserData(Map<String, dynamic> data) =>
      _logger.track(
        'auth.updateUser',
        () => _client.auth.updateUser(supabase.UserAttributes(data: data)),
        parameters: data,
      );
}
