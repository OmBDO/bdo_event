import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/features/registered_screen/domain/repositories/registered_event_repository.dart';

class CancelRegisteredEvent {
  const CancelRegisteredEvent(this._repository);

  final RegisteredEventRepositoryContract _repository;

  Future<String?> call(Event event) => _repository.cancelRegistration(event);
}
