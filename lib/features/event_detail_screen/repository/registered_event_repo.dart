import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/features/auth_screen/auth_repository.dart';
import 'package:bdo_event/features/calendar_screen/data/registration_service.dart';
import 'package:bdo_event/core/prefs/local_auth_store.dart';
import 'package:flutter/foundation.dart';

class RegisteredEventRepository {
  RegisteredEventRepository._();

  // Link up your structural database interaction engines exactly like your other repositories
  static final LocalAuthStore _store = LocalAuthStore();
  static final RegistrationService _registrationService = RegistrationService(
    _store,
  );

  /// 1. Verifies if the logged-in user is registered for a specific event
  static bool isUserRegistered(String eventId) {
    if (AuthRepository.currentUser == null) return false;

    // Reads directly from the shared Single Source of Truth inside AuthRepository
    return AuthRepository.registrations.value.any(
      (event) => event.id == eventId,
    );
  }

  /// 2. Saves an event registration entry into your local SQL storage engine
  static Future<String?> registerEvent(Event event) async {
    final user = AuthRepository.currentUser;
    if (user == null) return 'Please sign in to register for events';

    if (isUserRegistered(event.id)) {
      return 'You are already registered for this event';
    }

    if (event.capacity != null && event.attendeeCount >= event.capacity!) {
      return 'This event is fully booked';
    }

    // Call your registration service backend directly
    final result = await _registrationService.register(user.id, event);

    if (result.error != null) {
      return result.error;
    }

    // Update the live global state list notifier with the real response data returned from your backend
    AuthRepository.registrations.value = result.events;
    return null;
  }

  /// 3. Deletes a registration entry from your database
  static Future<String?> cancelRegistration(Event event) async {
    final user = AuthRepository.currentUser;
    if (user == null) return 'Please sign in to modify registrations';

    if (!isUserRegistered(event.id)) {
      return 'You are not registered for this event';
    }

    // Call your cancellation service backend directly
    final result = await _registrationService.cancel(user.id, event);

    if (result.error != null) {
      return result.error;
    }

    // Update the shared UI state list instantly
    AuthRepository.registrations.value = result.events;
    return null;
  }
}
