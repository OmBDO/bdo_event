import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/features/registered_screen/domain/usecases/cancel_registered_event.dart';
import 'package:bdo_event/features/registered_screen/presentation/cubit/registered_event_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisteredEventCubit extends Cubit<RegisteredEventState> {
  RegisteredEventCubit({required CancelRegisteredEvent cancelRegisteredEvent})
      : _cancelRegisteredEvent = cancelRegisteredEvent,
        super(const RegisteredEventState());

  final CancelRegisteredEvent _cancelRegisteredEvent;

  void clearState() {
    emit(const RegisteredEventState());
  }

  Future<bool> cancel(Event event) async {
    if (state.isCancelling) return false;
    emit(state.copyWith(isCancelling: true, clearError: true));
    final error = await _cancelRegisteredEvent(event);
    if (error != null) {
      emit(state.copyWith(isCancelling: false, error: error));
      return false;
    }
    emit(state.copyWith(isCancelling: false));
    return true;
  }
}
