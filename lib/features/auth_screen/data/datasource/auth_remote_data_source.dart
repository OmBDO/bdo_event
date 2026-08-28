import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class AuthRemoteDataSource {
  AuthRemoteDataSource({supabase.SupabaseClient? client})
      : _client = client ?? supabase.Supabase.instance.client;

  final supabase.SupabaseClient _client;

  supabase.User? get currentUser => _client.auth.currentUser;

  Future<supabase.AuthResponse> signUp({
    required String email,
    required String password,
    required String displayName,
  }) => _client.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': displayName},
      );

  Future<supabase.AuthResponse> signIn({
    required String email,
    required String password,
  }) => _client.auth.signInWithPassword(email: email, password: password);

  Future<void> signOut() => _client.auth.signOut();

  Future<supabase.UserResponse> updateUserData(Map<String, dynamic> data) =>
      _client.auth.updateUser(supabase.UserAttributes(data: data));
}
