import 'package:bdo_event/features/watcher_screen/domain/repositories/watcher_repository_contract.dart';

class ValidateRegistration {
  ValidateRegistration(this._repository);

  final WatcherRepositoryContract _repository;

  Future<Map<String, dynamic>?> call({
    required String token,
    required String eventId,
  }) => _repository.validateRegistration(token: token, eventId: eventId);
}
