import 'package:bdo_event/features/watcher_screen/domain/repositories/watcher_repository_contract.dart';

class CheckInRegistration {
  CheckInRegistration(this._repository);

  final WatcherRepositoryContract _repository;

  Future<String> call({
    required String token,
    required String eventId,
  }) => _repository.checkInRegistration(token: token, eventId: eventId);
}
