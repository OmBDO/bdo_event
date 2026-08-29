import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Handles application environment discovery and setup security checks.
class DotEnvInitialization {
  final String supabaseUrl;
  final String supabaseAnonKey;

  const DotEnvInitialization._({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
  });

  /// Loads configuration safely. Returns null if parameters are invalid or missing.
  static Future<DotEnvInitialization?> initialize() async {
    const definedUrl = String.fromEnvironment('SUPABASE_URL');
    const definedKey = String.fromEnvironment('SUPABASE_ANON_KEY');

    try {
      if (definedUrl.trim().isEmpty || definedKey.trim().isEmpty) {
        await dotenv.load(fileName: '.env');
      }

        final url = (definedUrl.trim().isNotEmpty
              ? definedUrl
              : dotenv.maybeGet('SUPABASE_URL') ?? '')
          .trim();
        final key = (definedKey.trim().isNotEmpty
              ? definedKey
              : dotenv.maybeGet('SUPABASE_ANON_KEY') ?? '')
          .trim();

      if (url.isEmpty || key.isEmpty) return null;

      return DotEnvInitialization._(supabaseUrl: url, supabaseAnonKey: key);
    } catch (_) {
      return null;
    }
  }
}
