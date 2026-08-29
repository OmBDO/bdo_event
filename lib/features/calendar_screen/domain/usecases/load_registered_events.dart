import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/features/calendar_screen/domain/repositories/calendar_repository.dart';

class LoadRegisteredEvents {
  const LoadRegisteredEvents(this._repository);

  final CalendarRepositoryContract _repository;

  Future<List<Event>> call(String userId) =>
      _repository.loadRegisteredEvents(userId);
}
