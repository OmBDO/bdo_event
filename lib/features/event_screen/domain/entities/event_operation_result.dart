import 'package:bdo_event/core/model/event_model/event_model.dart';

class EventOperationResult {
  final List<Event> events;
  final String? error;

  const EventOperationResult(this.events, [this.error]);
}
