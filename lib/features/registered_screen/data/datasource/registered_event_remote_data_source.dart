import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/features/event_detail_screen/domain/usecases/registration_use_cases.dart';

class RegisteredEventRemoteDataSource {
  RegisteredEventRemoteDataSource(this._cancelEventRegistration);

  final CancelEventRegistration _cancelEventRegistration;

  Future<String?> cancelRegistration(Event event) =>
      _cancelEventRegistration(event);
}
