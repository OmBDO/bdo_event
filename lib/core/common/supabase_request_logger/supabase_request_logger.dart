import 'dart:developer' as developer;

class SupabaseRequestLogger {
  const SupabaseRequestLogger();

  Future<T> track<T>(
    String operation,
    Future<T> Function() request, {
    Map<String, Object?> parameters = const {},
  }) async {
    final stopwatch = Stopwatch()..start();
    _log('request', operation, parameters);
    try {
      final response = await request();
      _log('response', operation, {'type': response.runtimeType.toString()});
      return response;
    } on Object catch (error, stackTrace) {
      _log('error', operation, {'error': error.runtimeType.toString()});
      developer.log(
        'Supabase request failed: $operation',
        name: 'bdo_event.supabase',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    } finally {
      stopwatch.stop();
      _log('timing', operation, {'durationMs': stopwatch.elapsedMilliseconds});
    }
  }

  void _log(String phase, String operation, Map<String, Object?> data) {
    developer.log(
      '$phase $operation ${_sanitize(data)}',
      name: 'bdo_event.supabase',
    );
  }

  Map<String, Object?> _sanitize(Map<String, Object?> data) => {
    for (final entry in data.entries)
      entry.key: _isSensitive(entry.key) ? '[REDACTED]' : entry.value,
  };

  bool _isSensitive(String key) {
    final normalized = key.toLowerCase();
    return normalized.contains('password') ||
        normalized.contains('token') ||
        normalized.contains('secret') ||
        normalized.contains('authorization') ||
        normalized.contains('key');
  }
}
