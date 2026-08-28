import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/features/calendar_screen/data/datasource/registration_remote_data_source.dart';
import 'package:bdo_event/features/calendar_screen/domain/repositories/calendar_repository.dart';

class CalendarRepository implements CalendarRepositoryContract {
  const CalendarRepository(this._dataSource);

  final RegistrationDataSource _dataSource;

  @override
  Future<List<Event>> loadRegisteredEvents(String userId) =>
      _dataSource.load(userId);
}
