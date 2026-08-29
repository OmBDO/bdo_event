import 'package:bdo_event/core/common/app_scroll_tracker/app_scroll_tracker.dart';
import 'package:bdo_event/features/auth_screen/domain/repositories/auth_repository.dart';
import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/features/event_screen/domain/usecases/event_use_cases.dart';
import 'package:bdo_event/features/event_screen/presentation/cubit/event_screen_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bdo_event/core/util/event.resource.dart';

class EventScreenCubit extends Cubit<EventScreenState> {
  EventScreenCubit({
    required this._loadEvents,
    required this._createEvent,
    required this._updateEvent,
    required this._deleteEvent,
    required this._authRepository,
  }) : super(const EventScreenState());

  final LoadEvents _loadEvents;
  final CreateEvent _createEvent;
  final UpdateEvent _updateEvent;
  final DeleteEvent _deleteEvent;
  final AuthRepositoryContract _authRepository;

  Future<void> load() async {
    if (isClosed) return;
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final events = await _loadEvents();
      if (!isClosed) {
        emit(state.copyWith(events: events, isLoading: false));
      }
    } on Object {
      if (!isClosed) {
        emit(
          state.copyWith(isLoading: false, error: AppText.unableToLoadEvents),
        );
      }
    }
  }

  Future<String?> save(Event event, {required bool isEditing}) async {
    final user = _authRepository.currentUser;
    if (user == null) return AppText.pleaseSignInToManageEvents;
    if (isClosed) return AppText.unableToSaveEvent;
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      final result = isEditing
          ? await _updateEvent(event)
          : await _createEvent(event, user);
      if (!isClosed) {
        emit(state.copyWith(isSaving: false, error: result.error));
      }
      return result.error;
    } on Object {
      if (!isClosed) {
        emit(
          state.copyWith(
            isSaving: false,
            error: isEditing
                ? AppText.unableToUpdateEvent
                : AppText.unableToSaveEvent,
          ),
        );
      }
      return isEditing ? AppText.unableToUpdateEvent : AppText.unableToSaveEvent;
    }
  }

  Future<String?> delete(Event event) async {
    try {
      final result = await _deleteEvent(event);
      if (!isClosed) emit(state.copyWith(error: result.error));
      return result.error;
    } on Object {
      if (!isClosed) emit(state.copyWith(error: AppText.unableToDeleteEvent));
      return AppText.unableToDeleteEvent;
    }
  }

  bool canUpdate(Event event) => _authRepository.canUpdate(event);

  bool canDelete(Event event) => _authRepository.canDelete(event);

  void changeTab(int index) {
    if (index == state.selectedTab) return;
    AppScrollTracker.reset(animate: false);
    emit(state.copyWith(selectedTab: index));
  }

  void clearState() {
    emit(const EventScreenState());
  }
}
