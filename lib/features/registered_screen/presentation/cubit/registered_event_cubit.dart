import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/prefs/supabase_store.dart';
import 'package:bdo_event/core/notifications/event_reminder_notification_service.dart';
import 'package:bdo_event/features/auth_screen/domain/repositories/auth_repository.dart';
import 'package:bdo_event/features/registered_screen/domain/usecases/cancel_registered_event.dart';
import 'package:bdo_event/features/registered_screen/presentation/cubit/registered_event_state.dart';
import 'package:bdo_event/core/util/event_resource.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisteredEventCubit extends Cubit<RegisteredEventState> {
  RegisteredEventCubit({
    required this._cancelRegisteredEvent,
    required this._authRepository,
    required this._eventStore,
    required this._reminderNotifications,
  }) : super(const RegisteredEventState());

  final CancelRegisteredEvent _cancelRegisteredEvent;
  final AuthRepositoryContract _authRepository;
  final EventStore _eventStore;
  final EventReminderNotificationService? _reminderNotifications;
  int _tokenRequestId = 0;

  Future<void> loadToken(String eventId) async {
    final userId = _authRepository.currentUser?.id;
    if (userId == null) return;
    emit(state.copyWith(isLoadingToken: true, clearError: true));
    final requestId = ++_tokenRequestId;
    try {
      final token = await _eventStore.loadRegistrationToken(userId, eventId);
      if (!isClosed && requestId == _tokenRequestId) {
        emit(state.copyWith(isLoadingToken: false, registrationToken: token));
      }
    } on Object {
      if (!isClosed && requestId == _tokenRequestId) {
        emit(
          state.copyWith(
            isLoadingToken: false,
            error: AppText.unableToLoadTicket,
          ),
        );
      }
    }
  }

  void clearState() {
    emit(const RegisteredEventState());
  }

  Future<void> _cancelReminder(String eventId) async {
    final reminderNotifications = _reminderNotifications;
    if (reminderNotifications == null) return;

    try {
      await reminderNotifications.cancelEventReminder(eventId);
    } on Object {
      return;
    }
  }

  Future<bool> cancel(Event event) async {
    if (state.isCancelling) return false;
    if (isClosed) return false;
    emit(state.copyWith(isCancelling: true, clearError: true));
    try {
      final error = await _cancelRegisteredEvent(event);
      if (error == null) {
        await _cancelReminder(event.id);
      }
      if (!isClosed) {
        emit(state.copyWith(isCancelling: false, error: error));
      }
      return error == null;
    } on Object {
      if (!isClosed) {
        emit(
          state.copyWith(
            isCancelling: false,
            error: AppText.unableToCancelRegistration,
          ),
        );
      }
      return false;
    }
  }
}
