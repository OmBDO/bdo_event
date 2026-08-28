import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/features/registered_screen/data/datasource/registered_event_remote_data_source.dart';
import 'package:bdo_event/features/registered_screen/domain/repositories/registered_event_repository.dart';

class RegisteredEventRepository implements RegisteredEventRepositoryContract {
    RegisteredEventRepository({required RegisteredEventRemoteDataSource dataSource})
            : _dataSource = dataSource;

  final RegisteredEventRemoteDataSource _dataSource;

  @override
  Future<String?> cancelRegistration(Event event) =>
      _dataSource.cancelRegistration(event);
}
