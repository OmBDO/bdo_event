import 'package:bdo_event/features/watcher_screen/data/datasource/watcher_remote_data_source.dart';
import 'package:bdo_event/features/watcher_screen/domain/model/scan_dashboard.dart';
import 'package:bdo_event/features/watcher_screen/domain/repositories/watcher_repository_contract.dart';

class WatcherRepository implements WatcherRepositoryContract {
  WatcherRepository(this._dataSource);

  final WatcherRemoteDataSource _dataSource;

  @override
  Future<Map<String, dynamic>?> validateRegistration({
    required String token,
    required String eventId,
  }) => _dataSource.validateRegistration(token: token, eventId: eventId);

  @override
  Future<String> checkInRegistration({
    required String token,
    required String eventId,
  }) => _dataSource.checkInRegistration(token: token, eventId: eventId);

  @override
  Future<ScanDashboard> loadDashboard(String eventId) =>
      _dataSource.loadDashboard(eventId);
}
