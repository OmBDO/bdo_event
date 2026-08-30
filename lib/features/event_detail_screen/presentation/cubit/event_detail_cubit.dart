import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/model/user_model/user_model.dart';
import 'package:bdo_event/features/auth_screen/domain/repositories/auth_repository.dart';
import 'package:bdo_event/features/event_detail_screen/domain/usecases/registration_use_cases.dart';
import 'package:bdo_event/features/event_detail_screen/presentation/cubit/event_detail_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bdo_event/core/util/event_resource.dart';
import 'package:bdo_event/core/prefs/supabase_store.dart';

class EventDetailCubit extends Cubit<EventDetailState> {
  EventDetailCubit({
    required this._registerForEvent,
    required this._cancelEventRegistration,
    required this._eventStore,
    required this._authRepository,
  }) : super(const EventDetailState());

  final RegisterForEvent _registerForEvent;
  final CancelEventRegistration _cancelEventRegistration;
  final EventStore _eventStore;
  final AuthRepositoryContract _authRepository;
  int _attendanceRequestId = 0;

  Future<void> checkRegistration(Event event) async {
    final registered = await _registerForEvent.isUserRegistered(event.id);
    if (!isClosed) emit(state.copyWith(isRegistered: registered));
  }

  Future<void> loadAttendanceCount(Event event) async {
    if (!_authRepository.can(UserPermission.viewEventAttendees) ||
        event.creatorId != _authRepository.currentUser?.id) {
      return;
    }
    emit(state.copyWith(isLoadingAttendance: true));
    final requestId = ++_attendanceRequestId;
    try {
      final count = await _eventStore.loadAttendanceCount(event.id);
      if (!isClosed && requestId == _attendanceRequestId) {
        emit(
          state.copyWith(attendanceCount: count, isLoadingAttendance: false),
        );
      }
    } on Object {
      if (!isClosed && requestId == _attendanceRequestId) {
        emit(state.copyWith(isLoadingAttendance: false));
      }
    }
  }

  Future<String?> register(Event event) =>
      _submit(event, action: _registerForEvent.call, registeredAfter: true);

  Future<String?> cancel(Event event) => _submit(
    event,
    action: _cancelEventRegistration.call,
    registeredAfter: false,
  );

  void clearState() {
    emit(const EventDetailState());
  }

  Future<String?> _submit(
    Event event, {
    required Future<String?> Function(Event) action,
    required bool registeredAfter,
  }) async {
    if (state.isSubmitting) return AppText.updateInProgress;
    if (isClosed) return AppText.updateInProgress;
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      final error = await action(event);
      if (!isClosed) {
        emit(
          state.copyWith(
            isSubmitting: false,
            isRegistered: error == null ? registeredAfter : state.isRegistered,
            error: error,
          ),
        );
      }
      return error;
    } on Object {
      if (!isClosed) {
        emit(
          state.copyWith(
            isSubmitting: false,
            error: registeredAfter
                ? AppText.unableToSaveRegistration
                : AppText.unableToCancelRegistration,
          ),
        );
      }
      return registeredAfter
          ? AppText.unableToSaveRegistration
          : AppText.unableToCancelRegistration;
    }
  }
}
