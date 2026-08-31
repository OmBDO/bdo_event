import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/util/resource/app_database.dart';
import 'package:bdo_event/features/event_detail_screen/data/model/registered_event_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const event = Event(
    id: 'event-1',
    title: 'Town Hall',
    date: '01/09/2026',
    location: 'Pune',
    imageUrl: '',
  );

  test('maps the user and nested event payload from storage', () {
    final dto = RegisteredEventDto.fromJson({
      AppDatabase.userId: 'user-1',
      AppDatabase.payload: event.toJson(),
    });

    expect(dto.userId, 'user-1');
    expect(dto.event.id, event.id);
    expect(dto.event.title, event.title);
  });

  test('writes user, event id, and nested event payload', () {
    final payload = const RegisteredEventDto(
      userId: 'user-1',
      event: event,
    ).toJson();

    expect(payload[AppDatabase.userId], 'user-1');
    expect(payload[AppDatabase.eventId], event.id);
    expect(payload[AppDatabase.payload], event.toJson());
  });
}
