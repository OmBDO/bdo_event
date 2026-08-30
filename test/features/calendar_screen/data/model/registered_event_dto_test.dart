import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/features/calendar_screen/data/model/registered_event_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const event = Event(
    id: 'event-1',
    title: 'Town Hall',
    date: '01/09/2026',
    location: 'Pune',
    imageUrl: '',
  );

  test('wraps and unwraps a registered event', () {
    final dto = RegisteredEventDto(event);

    expect(dto.toDomain(), same(event));
    expect(RegisteredEventDto.fromJson(event.toJson()).event.id, 'event-1');
  });

  test('writes the event payload through unchanged', () {
    final payload = RegisteredEventDto(event).toJson();

    expect(payload['id'], event.id);
    expect(payload['title'], event.title);
  });
}
