import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/model/user_model/user_model.dart';
import 'package:bdo_event/features/event_screen/domain/entities/event_operation_result.dart';

abstract interface class EventRepositoryContract {
  Future<List<Event>> loadEvents();
  Future<EventOperationResult> createEvent(Event event, User user);
  Future<EventOperationResult> updateEvent(Event event);
  Future<EventOperationResult> deleteEvent(Event event);
}
