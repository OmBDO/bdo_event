import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/model/user_model/user_model.dart';
import 'package:bdo_event/features/auth_screen/data/repositories/auth_repository.dart';
import 'package:bdo_event/features/event_screen/data/datasource/event_remote_data_source.dart';
import 'package:bdo_event/features/event_screen/domain/entities/event_operation_result.dart';
import 'package:bdo_event/features/event_screen/domain/repositories/event_repository.dart';
import 'package:bdo_event/core/util/event.resource.dart';

class EventRepository implements EventRepositoryContract {
  EventRepository({
    required EventDataSource dataSource,
    required AuthRepository authRepository,
  }) : _eventDataSource = dataSource,
       _authRepository = authRepository;

  final EventDataSource _eventDataSource;
  final AuthRepository _authRepository;

  User? get currentUser => _authRepository.currentUser;
  String? get currentUserName => _authRepository.currentUserName;
  bool can(UserPermission permission) => _authRepository.can(permission);
  bool canUpdate(Event event) => _authRepository.canUpdate(event);
  bool canDelete(Event event) => _authRepository.canDelete(event);
  bool canManage(Event event) => canUpdate(event);

  @override
  Future<EventOperationResult> createEvent(Event event, User user) async {
    if (!user.hasPermission(UserPermission.createEvents)) {
      return const EventOperationResult(
        [],
        AppText.adminAccessRequiredForEvents,
      );
    }
    final result = await _eventDataSource.create(event, user);
    return result;
  }

  @override
  Future<EventOperationResult> updateEvent(Event event) async {
    if (!canUpdate(event)) {
      return const EventOperationResult([], AppText.cannotUpdateEvent);
    }
    final result = await _eventDataSource.update(event);
    return result;
  }

  @override
  Future<EventOperationResult> deleteEvent(Event event) async {
    if (!canDelete(event)) {
      return const EventOperationResult([], AppText.cannotDeleteEvent);
    }
    final result = await _eventDataSource.delete(event);
    return result;
  }

  @override
  Future<List<Event>> loadEvents() async {
    return _eventDataSource.loadEvents();
  }
}
