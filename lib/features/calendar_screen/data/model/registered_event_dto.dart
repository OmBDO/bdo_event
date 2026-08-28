import 'package:bdo_event/core/model/event_model/event_model.dart';

class RegisteredEventDto {
  const RegisteredEventDto(this.event);

  final Event event;

  factory RegisteredEventDto.fromJson(Map<String, dynamic> json) =>
      RegisteredEventDto(Event.fromJson(json));

  Map<String, dynamic> toJson() => event.toJson();

  Event toDomain() => event;
}
