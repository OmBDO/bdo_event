import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:bdo_event/core/common/configuration_error_app/configuration_error_app.dart';

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
    try {
      // Load environment assets from filesystem storage
      await dotenv.load(fileName: ".env");

      final url = dotenv.maybeGet('SUPABASE_URL') ?? '';
      final key = dotenv.maybeGet('SUPABASE_ANON_KEY') ?? '';

      // Terminate if security definitions are blank
      if (url.isEmpty || key.isEmpty) {
        return null;
      }

      return DotEnvInitialization._(supabaseUrl: url, supabaseAnonKey: key);
    } catch (_) {
      // Catch empty file anomalies or bundle missing crashes
      return null;
    }
  }
}
