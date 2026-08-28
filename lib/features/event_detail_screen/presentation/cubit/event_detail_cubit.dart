import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/features/event_detail_screen/domain/usecases/registration_use_cases.dart';
import 'package:bdo_event/features/event_detail_screen/presentation/cubit/event_detail_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bdo_event/core/util/event.resource.dart';
import 'package:bdo_event/core/prefs/supabase_store.dart';

class EventDetailCubit extends Cubit<EventDetailState> {
  EventDetailCubit({
    required RegisterForEvent registerForEvent,
    required CancelEventRegistration cancelEventRegistration,
    required EventStore eventStore,
    required AuthRepository authRepository,
  })  : _registerForEvent = registerForEvent,
        _cancelEventRegistration = cancelEventRegistration,
        _eventStore = eventStore,
        _authRepository = authRepository,
        super(const EventDetailState());

  final RegisterForEvent _registerForEvent;
  final CancelEventRegistration _cancelEventRegistration;
  final EventStore _eventStore;
  final AuthRepository _authRepository;

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
    try {
      final count = await _eventStore.loadAttendanceCount(event.id);
      if (!isClosed) {
        emit(state.copyWith(
          attendanceCount: count,
          isLoadingAttendance: false,
        ));
      }
    } on Object {
      if (!isClosed) emit(state.copyWith(isLoadingAttendance: false));
    }
  }

  Future<String?> register(Event event) => _submit(
        event,
        action: _registerForEvent,
        registeredAfter: true,
      );

  Future<String?> cancel(Event event) => _submit(
        event,
        action: _cancelEventRegistration,
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
    emit(state.copyWith(isSubmitting: true, clearError: true));
    final error = await action(event);
    emit(state.copyWith(
      isSubmitting: false,
      isRegistered: error == null ? registeredAfter : state.isRegistered,
      error: error,
    ));
    return error;
  }
}