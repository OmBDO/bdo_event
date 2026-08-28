import 'package:bdo_event/core/model/event_model/event_model.dart';

abstract interface class RegistrationRepositoryContract {
  Future<bool> isUserRegistered(String eventId);
  Future<String?> registerEvent(Event event);
  Future<String?> cancelRegistration(Event event);
}
