import 'package:bdo_event/core/di/app_dependencies.dart';
import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/model/user_model/event_attendee.dart';
import 'package:bdo_event/core/prefs/supabase_store.dart';
import 'package:bdo_event/features/event_detail_screen/presentation/pages/event_attendees_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../notification_screen/presentation/pages/notification_screen_widget_test.dart'
    as fixtures;

void main() {
  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('shows the attendee loading state', (tester) async {
    final store = fixtures.FakeNotificationEventStore(pendingAttendees: true);
    await pumpAttendeesPage(tester, store);

    expect(find.byType(ListView), findsOneWidget);
    store.completeAttendees(const []);
    await tester.pumpAndSettle();
    expect(find.text('No attendees registered yet'), findsOneWidget);
  });

  testWidgets('shows the empty attendee state', (tester) async {
    await pumpAttendeesPage(tester, fixtures.FakeNotificationEventStore());

    expect(find.text('No attendees registered yet'), findsOneWidget);
  });

  testWidgets('shows an error when attendees cannot be loaded', (tester) async {
    await pumpAttendeesPage(
      tester,
      fixtures.FakeNotificationEventStore(attendeeError: true),
    );

    expect(find.text('Unable to load attendees'), findsOneWidget);
  });

  testWidgets('renders attendees and confirms CSV copy', (tester) async {
    final attendees = [
      const EventAttendee(userId: 'user-1', displayName: 'Asha'),
      const EventAttendee(userId: 'user-2', displayName: ''),
    ];
    await pumpAttendeesPage(
      tester,
      fixtures.FakeNotificationEventStore(attendees: attendees),
    );

    expect(find.text('Asha'), findsOneWidget);
    expect(find.text('Registered for Town Hall'), findsNWidgets(2));
    expect(find.text('?'), findsOneWidget);
    expect(find.text('Share CSV'), findsOneWidget);

    await tester.tap(find.byTooltip('Copy attendee list as CSV'));
    await tester.pump();

    expect(find.text('Attendee CSV copied'), findsOneWidget);
  });
}

Future<void> pumpAttendeesPage(
  WidgetTester tester,
  fixtures.FakeNotificationEventStore store,
) async {
  getIt.registerSingleton<EventStore>(store);
  await tester.pumpWidget(
    MaterialApp(
      home: EventAttendeesPage(
        event: Event(
          id: 'event-1',
          title: 'Town Hall',
          date: '01/09/2099',
          location: 'Pune',
          imageUrl: '',
        ),
      ),
    ),
  );
  await tester.pump();
}
