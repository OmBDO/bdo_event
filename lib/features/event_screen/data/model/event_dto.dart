import 'package:bdo_event/core/model/event_model/event_model.dart';

class EventDto {
  const EventDto(this.event);

  final Event event;

  factory EventDto.fromJson(Map<String, dynamic> json) =>
      EventDto(Event.fromJson(json));

  Map<String, dynamic> toJson() => event.toJson();

  Event toDomain() => event;

  factory EventDto.fromDomain(Event event) => EventDto(event);
}
