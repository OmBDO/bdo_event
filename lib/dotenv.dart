import 'package:bdo_event/core/util/resource/app_essential.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Handles application environment discovery and setup security checks.
class DotEnvInitialization {
  final String supabaseUrl;
  final String supabaseAnonKey;

  const DotEnvInitialization._({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
  });

  static DotEnvInitialization? fromValues({
    required String url,
    required String anonKey,
  }) {
    final normalizedUrl = url.trim();
    final normalizedKey = anonKey.trim();
    if (normalizedUrl.isEmpty || normalizedKey.isEmpty) return null;
    return DotEnvInitialization._(
      supabaseUrl: normalizedUrl,
      supabaseAnonKey: normalizedKey,
    );
  }

  /// Loads configuration safely. Returns null if parameters are invalid or missing.
  static Future<DotEnvInitialization?> initialize() async {
    const definedUrl = String.fromEnvironment(AppEssentials.supabaseURLKEY);
    const definedKey = String.fromEnvironment(AppEssentials.supabaseAnonKEY);

    try {
      if (definedUrl.trim().isEmpty || definedKey.trim().isEmpty) {
        await dotenv.load(fileName: '.env');
      }

      final url =
          (definedUrl.trim().isNotEmpty
                  ? definedUrl
                  : dotenv.maybeGet(AppEssentials.supabaseURLKEY) ?? '')
              .trim();
      final key =
          (definedKey.trim().isNotEmpty
                  ? definedKey
                  : dotenv.maybeGet(AppEssentials.supabaseAnonKEY) ?? '')
              .trim();

      return fromValues(url: url, anonKey: key);
    } catch (_) {
      return null;
    }
  }
}
