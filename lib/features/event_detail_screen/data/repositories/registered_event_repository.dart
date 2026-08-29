import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/prefs/supabase_store.dart';
import 'package:bdo_event/features/auth_screen/data/repositories/auth_repository.dart';
import 'package:bdo_event/features/calendar_screen/data/datasource/registration_remote_data_source.dart';
import 'package:bdo_event/features/event_detail_screen/domain/repositories/registration_repository.dart';
import 'package:bdo_event/core/util/event.resource.dart';

class RegisteredEventRepository implements RegistrationRepositoryContract {
  RegisteredEventRepository({
    required RegistrationDataSource dataSource,
    required AuthRepository authRepository,
  }) : _dataSource = dataSource,
       _authRepository = authRepository;

  final RegistrationDataSource _dataSource;
  final AuthRepository _authRepository;

  /// 1. Verifies if the logged-in user is registered for a specific event
  @override
  Future<bool> isUserRegistered(String eventId) async {
    final user = _authRepository.currentUser;
    if (user == null) return false;

    final events = await _dataSource.load(user.id);
    return events.any((event) => event.id == eventId);
  }

  /// Saves an event registration through the configured remote data source.
  @override
  Future<String?> registerEvent(Event event) async {
    final user = _authRepository.currentUser;
    if (user == null) return AppText.pleaseSignInToRegister;

    if (!event.isAvailable) {
      return AppText.eventNoLongerAvailable;
    }

    if (await isUserRegistered(event.id)) {
      return AppText.alreadyRegistered;
    }

    if (event.capacity != null && event.attendeeCount >= event.capacity!) {
      return AppText.eventAtCapacity;
    }

    final events = await _dataSource.load(user.id);
    if (events.any((registered) => registered.id == event.id)) {
      return AppText.alreadyRegistered;
    }

    try {
      await _dataSource.activate(user.id, event);
    } on LocalStorageException {
      return AppText.unableToSaveRegistration;
    }
    return null;
  }

  /// Deletes a registration through the configured remote data source.
  @override
  Future<String?> cancelRegistration(Event event) async {
    final user = _authRepository.currentUser;
    if (user == null) return AppText.pleaseSignInToModifyRegistrations;

    if (!await isUserRegistered(event.id)) {
      return AppText.notRegistered;
    }

    try {
      await _dataSource.revoke(user.id, event.id);
    } on LocalStorageException {
      return AppText.unableToCancelRegistration;
    }

    return null;
  }
}
