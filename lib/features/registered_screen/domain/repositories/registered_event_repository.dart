import 'package:bdo_event/core/model/event_model/event_model.dart';

abstract interface class RegisteredEventRepositoryContract {
  Future<String?> cancelRegistration(Event event);
}
