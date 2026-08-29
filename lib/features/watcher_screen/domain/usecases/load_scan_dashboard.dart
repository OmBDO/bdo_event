import 'package:bdo_event/features/watcher_screen/domain/model/scan_dashboard.dart';
import 'package:bdo_event/features/watcher_screen/domain/repositories/watcher_repository_contract.dart';

class LoadScanDashboard {
  LoadScanDashboard(this._repository);

  final WatcherRepositoryContract _repository;

  Future<ScanDashboard> call(String eventId) => _repository.loadDashboard(eventId);
}
