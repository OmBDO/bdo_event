import 'package:bdo_event/core/model/event_model/event_model.dart';

abstract interface class CalendarRepositoryContract {
  Future<List<Event>> loadRegisteredEvents(String userId);
}
