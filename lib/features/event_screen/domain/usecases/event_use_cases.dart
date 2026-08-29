import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/model/user_model/user_model.dart';
import 'package:bdo_event/features/event_screen/domain/entities/event_operation_result.dart';
import 'package:bdo_event/features/event_screen/domain/repositories/event_repository.dart';

class LoadEvents {
  const LoadEvents(this._repository);

  final EventRepositoryContract _repository;

  Future<List<Event>> call() => _repository.loadEvents();
}

class CreateEvent {
  const CreateEvent(this._repository);

  final EventRepositoryContract _repository;

  Future<EventOperationResult> call(Event event, User user) =>
      _repository.createEvent(event, user);
}

class UpdateEvent {
  const UpdateEvent(this._repository);

  final EventRepositoryContract _repository;

  Future<EventOperationResult> call(Event event) => _repository.updateEvent(event);
}

class DeleteEvent {
  const DeleteEvent(this._repository);

  final EventRepositoryContract _repository;

  Future<EventOperationResult> call(Event event) => _repository.deleteEvent(event);
}
