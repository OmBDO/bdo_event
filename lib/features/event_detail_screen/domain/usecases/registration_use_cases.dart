import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/features/event_detail_screen/domain/repositories/registration_repository.dart';

class RegisterForEvent {
  const RegisterForEvent(this._repository);

  final RegistrationRepositoryContract _repository;

  Future<bool> isUserRegistered(String eventId) =>
      _repository.isUserRegistered(eventId);

  Future<String?> call(Event event) => _repository.registerEvent(event);
}

class CancelEventRegistration {
  const CancelEventRegistration(this._repository);

  final RegistrationRepositoryContract _repository;

  Future<String?> call(Event event) => _repository.cancelRegistration(event);
}
