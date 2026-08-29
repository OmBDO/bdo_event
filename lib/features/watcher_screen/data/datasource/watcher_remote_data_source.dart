import 'package:bdo_event/core/prefs/supabase_store.dart';
import 'package:bdo_event/features/watcher_screen/domain/model/scan_dashboard.dart';

abstract interface class WatcherRemoteDataSource {
  Future<Map<String, dynamic>?> validateRegistration({
    required String token,
    required String eventId,
  });

  Future<String> checkInRegistration({
    required String token,
    required String eventId,
  });

  Future<ScanDashboard> loadDashboard(String eventId);
}

class WatcherRemoteDataSourceImpl implements WatcherRemoteDataSource {
  WatcherRemoteDataSourceImpl(this._store);

  final EventStore _store;

  @override
  Future<Map<String, dynamic>?> validateRegistration({
    required String token,
    required String eventId,
  }) => _store.validateRegistration(token: token, eventId: eventId);

  @override
  Future<String> checkInRegistration({
    required String token,
    required String eventId,
  }) => _store.checkInRegistration(token: token, eventId: eventId);

  @override
  Future<ScanDashboard> loadDashboard(String eventId) async {
    final counts = await Future.wait([
      _store.loadCheckedInCount(eventId),
      _store.loadAttendanceCount(eventId),
    ]);
    return ScanDashboard(
      checkedInCount: counts[0] as int,
      expectedCount: counts[1] as int,
    );
  }
}
