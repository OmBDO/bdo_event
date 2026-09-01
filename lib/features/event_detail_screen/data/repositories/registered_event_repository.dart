import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/prefs/supabase_store.dart';
import 'package:bdo_event/core/util/resource/app_text.dart';
import 'package:bdo_event/features/auth_screen/domain/repositories/auth_repository.dart';
import 'package:bdo_event/features/event_detail_screen/data/datasource/registration_remote_data_source.dart';
import 'package:bdo_event/features/event_detail_screen/domain/repositories/registration_repository.dart';
import 'package:bdo_event/core/util/event_schedule.dart';

class RegisteredEventRepository implements RegistrationRepositoryContract {
  RegisteredEventRepository({
    required this._dataSource,
    required this._authRepository,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final RegistrationDataSource _dataSource;
  final AuthRepositoryContract _authRepository;
  final DateTime Function() _now;

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

    final now = _now();
    if (EventSchedule.isFinished(event, now: now)) {
      return AppText.eventNoLongerAvailable;
    }

    if (event.registrationDeadline != null &&
        !now.isBefore(event.registrationDeadline!)) {
      return AppText.registrationDeadlinePassed;
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
    } on LocalStorageException catch (error) {
      if (error.message == 'Event has reached its capacity') {
        return AppText.eventAtCapacity;
      }
      if (error.message == 'Registration for this event has closed') {
        return AppText.registrationDeadlinePassed;
      }
      if (error.message == 'Event has ended') {
        return AppText.eventNoLongerAvailable;
      }
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
