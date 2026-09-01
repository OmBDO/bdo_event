import 'package:bdo_event/core/model/event_model/event_model.dart';

import '../harness/test_run_context.dart';

class EventFixture {
  const EventFixture(this.context);

  final TestRunContext context;

  EventFixtureData draft({
    required String testId,
    String title = 'Integration test event',
    String description = "Draft",
    String date = '31/12/2099',
    String location = 'Pune',
    String imageUrl = '',
    String? creatorId,
    int? capacity,
    DateTime? registrationDeadline,
  }) {
    final eventId = context.namespace('$testId-event');
    return EventFixtureData(
      event: Event(
        id: eventId,
        title: title,
        date: date,
        location: location,
        imageUrl: imageUrl,
        creatorId: creatorId,
        capacity: capacity,
        registrationDeadline: registrationDeadline,
      ),
      testId: testId,
    );
  }
}

class EventFixtureData {
  const EventFixtureData({required this.event, required this.testId});

  final Event event;
  final String testId;

  String get eventId => event.id;
}
