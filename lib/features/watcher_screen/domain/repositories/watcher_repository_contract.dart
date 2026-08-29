import 'package:bdo_event/features/watcher_screen/domain/model/scan_dashboard.dart';

abstract interface class WatcherRepositoryContract {
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
