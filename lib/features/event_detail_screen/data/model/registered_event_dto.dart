import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/util/event.resource.dart';

class RegisteredEventDto {
  const RegisteredEventDto({
    required this.userId,
    required this.event,
  });

  final String userId;
  final Event event;

  factory RegisteredEventDto.fromJson(Map<String, dynamic> json) =>
      RegisteredEventDto(
        userId: json[AppDatabase.userId] as String,
        event: Event.fromJson(
          Map<String, dynamic>.from(json[AppDatabase.payload] as Map),
        ),
      );

  Map<String, dynamic> toJson() => {
    AppDatabase.userId: userId,
    AppDatabase.eventId: event.id,
    AppDatabase.payload: event.toJson(),
  };
}
