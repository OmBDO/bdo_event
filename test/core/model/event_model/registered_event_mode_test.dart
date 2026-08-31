import 'package:bdo_event/core/model/event_model/registered_event_mode.dart';
import 'package:bdo_event/core/util/resource/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps SQL registration rows including checked-in state', () {
    final registration = EventRegistration.fromSql({
      AppDatabase.id: 'registration-1',
      AppDatabase.eventId: 'event-1',
      AppDatabase.userId: 'user-1',
      AppDatabase.registeredAt: '2026-08-30T09:00:00Z',
      AppDatabase.isCheckedIn: 1,
    });

    expect(registration.id, 'registration-1');
    expect(registration.eventId, 'event-1');
    expect(registration.userId, 'user-1');
    expect(registration.registeredAt, DateTime.utc(2026, 8, 30, 9));
    expect(registration.isCheckedIn, isTrue);
  });

  test('defaults a missing SQL checked-in value to false', () {
    final registration = EventRegistration.fromSql({
      AppDatabase.id: 'registration-1',
      AppDatabase.eventId: 'event-1',
      AppDatabase.userId: 'user-1',
      AppDatabase.registeredAt: '2026-08-30T09:00:00Z',
    });

    expect(registration.isCheckedIn, isFalse);
  });

  test('writes SQL fields and encodes checked-in state as an integer', () {
    final registration = EventRegistration(
      id: 'registration-1',
      eventId: 'event-1',
      userId: 'user-1',
      registeredAt: DateTime.utc(2026, 8, 30, 9),
      isCheckedIn: true,
    );

    expect(registration.toSqlMap(), {
      AppDatabase.id: 'registration-1',
      AppDatabase.eventId: 'event-1',
      AppDatabase.userId: 'user-1',
      AppDatabase.registeredAt: '2026-08-30T09:00:00.000Z',
      AppDatabase.isCheckedIn: 1,
    });
  });
}
